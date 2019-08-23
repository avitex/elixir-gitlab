defmodule Gitlab.Client do
  @moduledoc """
  Gitlab API Client.
  """

  alias Gitlab.Pagination

  @type t :: Tesla.client()

  @type result :: {:ok, any()} | result_error()
  @type result_error :: {:error, any()}

  @type paginated_result :: paginated_stream_result() | paginated_single_result()
  @type paginated_stream_result :: {:ok, Stream.t()} | result_error()
  @type paginated_single_result :: {:ok, any(), Pagination.Page.t()} | result_error()

  @type access_token :: {:private, binary()} | {:oauth, binary()}

  @type new_opts :: [
          base_url: binary,
          access_token: access_token(),
          adapter: Tesla.Client.adapter() | nil,
        ]

  @type pagination_opts :: [
          type: :single | {:stream, Pagination.direction()},
          transform: Pagination.transform()
        ]

  @default_base_url "https://gitlab.com/api/v4"

  @doc """
  Create a new Gitlab client.
  """
  @spec new(new_opts()) :: t()
  def new(opts \\ []) do
    base_url = Keyword.get(opts, :base_url, @default_base_url)
    access_token = Keyword.get(opts, :access_token)
    adapter = Keyword.get(opts, :adapter)

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.DecodeRels,
      Tesla.Middleware.JSON
    ]

    middleware
    |> access_token_middleware(access_token)
    |> Tesla.client(adapter)
  end

  @doc false
  @spec get(t(), binary()) :: result()
  def get(client, url) do
    client
    |> Tesla.get(url)
    |> transform_result(:standard, client)
  end

  @doc false
  @spec get_paginated(t(), binary(), pagination_opts()) :: paginated_result
  def get_paginated(client, url, opts \\ []) do
    client
    |> Tesla.get(url)
    |> transform_result({:paginated, opts}, client)
  end

  @doc false
  @spec post(t(), binary(), any()) :: result
  def post(client, url, body) do
    client
    |> Tesla.post(url, body)
    |> transform_result(:standard, client)
  end

  @doc false
  @spec put(t(), binary(), any()) :: result
  def put(client, url, body) do
    client
    |> Tesla.put(url, body)
    |> transform_result(:standard, client)
  end

  @doc """
  Build an auth header given an access token.
  """
  @spec access_token_header(access_token()) :: {binary(), binary()}
  def access_token_header({:private, access_token}) do
    {"Private-Token", access_token}
  end

  def access_token_header({:oauth, access_token}) do
    {"Authorization", "Bearer " <> access_token}
  end

  defp access_token_middleware(middleware, nil) do
    middleware
  end

  defp access_token_middleware(middleware, access_token) do
    headers = [access_token_header(access_token)]
    middleware ++ [{Tesla.Middleware.Headers, headers}]
  end

  #############################################################################

  defp transform_result({:error, error}, _to, _client) do
    {:error, error}
  end

  defp transform_result({:ok, env}, :standard, _client) do
    with {:ok, env} <- validate_response(env) do
      {:ok, env.body}
    end
  end

  defp transform_result({:ok, env}, {:paginated, opts}, client) do
    with {:ok, env} <- validate_response(env) do
      link = Pagination.Link.from_rels(env.opts[:rels])
      type = Keyword.get(opts, :type, :single)
      transform = Keyword.get(opts, :transform)

      page =
        Pagination.Page.from_parts(
          link,
          [
            page: Tesla.get_header(env, "x-page"),
            next_page: Tesla.get_header(env, "x-next-page"),
            prev_page: Tesla.get_header(env, "x-prev-page"),
            per_page: Tesla.get_header(env, "x-per-page"),
            total: Tesla.get_header(env, "x-total"),
            total_pages: Tesla.get_header(env, "x-total-pages")
          ],
          transform
        )

      with {:ok, items} <- transform_paginated_items(env.body, [], transform) do
        case type do
          :single ->
            {:ok, items, page}

          {:stream, direction} ->
            stream = Pagination.get_stream(client, page, direction)
            {:ok, Stream.concat(items, stream)}
        end
      end
    end
  end

  #############################################################################

  defp transform_paginated_items(items, _, nil) do
    {:ok, items}
  end

  defp transform_paginated_items([], acc, _transform) do
    {:ok, Enum.reverse(acc)}
  end

  defp transform_paginated_items([item | items], acc, transform) do
    with {:ok, item} <- transform.(item) do
      transform_paginated_items(items, [item | acc], transform)
    end
  end

  #############################################################################

  defp validate_response(env) do
    if env.status < 300 do
      {:ok, env}
    else
      {:error, env}
    end
  end
end
