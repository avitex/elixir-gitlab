defmodule Gitlab.Pagination do
  alias Gitlab.Client

  alias Gitlab.Pagination.{
    Link,
    Page
  }

  @type paginatable :: Link.t() | Page.t()
  @type direction :: :forward | :backward
  @type transform :: (any() -> {:ok, any()} | {:error, any()}) | nil

  @type single_result :: Client.paginated_single_result()
  @type stream_result :: Client.paginated_stream_result()

  @doc """
  Creates a query string given pagination parameters.
  """
  @spec query(integer() | nil, integer() | nil) :: binary
  def query(page, per_page \\ nil) do
    page = if is_nil(page), do: 1, else: page

    opts =
      if is_nil(per_page) do
        %{page: page}
      else
        %{page: page, per_page: per_page}
      end

    URI.encode_query(opts)
  end

  @doc """
  Returns whether or not a paginatable has a given link relation.
  """
  @spec has_rel?(Link.t() | Page.t(), Link.rel()) :: boolean
  def has_rel?(page = %Page{}, rel) do
    has_rel?(page.link, rel)
  end

  def has_rel?(link = %Link{}, rel) do
    url = Map.get(link, rel)
    !is_nil(url)
  end

  @spec has_first?(Link.t() | Page.t()) :: boolean
  def has_first?(link) do
    has_rel?(link, :first)
  end

  @spec has_prev?(Link.t() | Page.t()) :: boolean
  def has_prev?(link) do
    has_rel?(link, :prev)
  end

  @spec has_next?(Link.t() | Page.t()) :: boolean
  def has_next?(link) do
    has_rel?(link, :next)
  end

  @spec has_last?(Link.t() | Page.t()) :: boolean
  def has_last?(link) do
    has_rel?(link, :last)
  end

  @doc """
  Gets a stream of paginated items.
  """
  @spec get_stream(Client.t(), Page.t()) :: stream_result
  def get_stream(client, page = %Page{}) do
    get_stream(client, page.link, :forward, page.transform)
  end

  @spec get_stream(Client.t(), Page.t()) :: stream_result
  def get_stream(client, page = %Page{}, direction) do
    get_stream(client, page.link, direction, page.transform)
  end

  @spec get_stream(Client.t(), Link.t(), direction(), transform()) :: stream_result
  def get_stream(client, link = %Link{}, direction, transform \\ nil) do
    rel =
      case direction do
        :forward -> :next
        :backward -> :prev
      end

    Stream.resource(
      fn -> link end,
      fn link ->
        if has_rel?(link, rel) do
          case get_rel(client, link, rel, transform) do
            {:ok, [], _page} -> {:halt, :ok}
            {:ok, items, page} -> {items, page.link}
            {:error, error} -> {:halt, {:error, error}}
          end
        else
          {:halt, :ok}
        end
      end,
      # TODO: handle errors
      fn acc -> acc end
    )
  end

  @spec get_rel(Client.t(), Page.t(), Link.rel()) :: single_result
  def get_rel(client, page = %Page{}, rel) do
    get_rel(client, page.link, rel, page.transform)
  end

  @spec get_rel(Client.t(), Link.t(), Link.rel(), transform()) :: single_result
  def get_rel(client, link = %Link{}, rel, transform \\ nil) do
    case Map.get(link, rel) do
      nil -> {:error, "no #{rel} in link"}
      url -> Client.get_paginated(client, url, transform: transform)
    end
  end

  @spec get_first(Client.t(), Link.t() | Page.t()) :: single_result
  def get_first(client, page_or_link) do
    get_rel(client, page_or_link, :first)
  end

  @spec get_prev(Client.t(), Link.t() | Page.t()) :: single_result
  def get_prev(client, page_or_link) do
    get_rel(client, page_or_link, :prev)
  end

  @spec get_next(Client.t(), Link.t() | Page.t()) :: single_result
  def get_next(client, page_or_link) do
    get_rel(client, page_or_link, :next)
  end

  @spec get_last(Client.t(), Link.t() | Page.t()) :: single_result
  def get_last(client, page_or_link) do
    get_rel(client, page_or_link, :last)
  end
end
