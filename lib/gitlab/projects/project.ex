defmodule Gitlab.Projects.Project do
  use TypedStruct

  alias Gitlab.Endpoint

  @type id :: integer()
  @type path :: [String.t()]

  @behaviour Endpoint

  typedstruct do
    field(:id, id())
  end

  @impl Endpoint
  def endpoint_name() do
    "projects"
  end

  #############################################################################
  ## ID

  @spec normalize_id(id() | path() | nil) :: id() | nil
  def normalize_id(id) when is_binary(id) do
    URI.encode_www_form(id)
  end

  def normalize_id(path) when is_list(path) do
    id_from_path(path)
  end

  def normalize_id(nil) do
    nil
  end

  @spec id_from_path(path()) :: id()
  def id_from_path(path) do
    path
    |> Enum.join("/")
    |> normalize_id()
  end
end
