defmodule Gitlab.Projects.RepositoryFile do
  use TypedStruct
  use TypedStruct.Cast

  alias Gitlab.Endpoint

  @behaviour Endpoint

  typedstruct do
    plugin(TypedStruct.Cast.Plugin)

    field(:file_name, String.t())
    field(:file_path, String.t())
    field(:size, integer())
    field(:encoding, String.t())
    field(:content, String.t())
    field(:content_sha256, String.t())
    field(:ref, String.t())
    field(:blob_id, String.t())
    field(:commit_id, String.t())
    field(:last_commit_id, String.t())
  end

  @impl Endpoint
  def endpoint_name() do
    "repository/files"
  end

  def encode_file_path(path) do
    URI.encode_www_form(path)
  end
end
