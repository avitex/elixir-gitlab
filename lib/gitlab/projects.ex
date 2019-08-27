defmodule Gitlab.Projects do
  alias Gitlab.Client
  alias Gitlab.Endpoint

  alias __MODULE__.{
    Project,
    RepositoryFile,
  }

  def get_repo_file(client, project_id, file_path) do
    url = repo_file_url(project_id, file_path)
    with {:ok, body} <- Client.get(client, url) do
      {:ok, RepositoryFile.cast!(body)}
    end
  end

  def get_repo_file_raw(client, project_id, file_path) do
    url = repo_file_url(project_id, file_path) <> "/raw"
    Client.get(client, url)
  end

  defp repo_file_url(project_id, file_path) do
    project_scope = {Project, Project.normalize_id(project_id)}
    file_path = RepositoryFile.encode_file_path(file_path)
    Endpoint.url({RepositoryFile, project_scope, file_path})
  end
end
