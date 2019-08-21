defmodule Gitlab.Issues do
  alias Gitlab.Client
  alias Gitlab.Endpoint
  # alias Gitlab.Pagination
  # alias Gitlab.Projects.Project

  alias __MODULE__.{
    Issue,
    NewIssue
  }

  @spec get_issue(Client.t(), Issue.id()) :: {:ok, Issue.t()} | {:error, binary}
  def get_issue(client, id) do
    get_issue(client, nil, id)
  end

  @spec get_issue(Client.t(), Endpoint.scope(), Issue.iid()) ::
          {:ok, Issue.t()} | {:error, binary}
  def get_issue(client, scope, iid) do
    issue_url = Endpoint.url({Issue, iid}, scope)

    with {:ok, body} <- Client.get(client, issue_url) do
      issue_from_json(body)
    end
  end

  # @spec new_issue(Client.t(), issuable(), map() | NewIssue.t()) ::
  #        {:ok, Issue.t()} | {:error, binary}
  def create_issue(client, scope, new_issue) do
    issues_url = Endpoint.url({Issue, scope})
    new_issue = new_issue |> NewIssue.cast!() |> prepare_issue_opts_for_query()

    with {:ok, body} <- Client.post(client, issues_url, new_issue) do
      issue_from_json(body)
    end
  end

  # TODO: filters typespec
  # @spec list_issues(Client.t(), Project.id(), map()) ::
  #        {:ok, [Issue.t()], Pagination.Page.t()} | {:error, binary}
  def list_issues(client, scope, opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})
    query_opts = prepare_issue_opts_for_query(filters)
    issues_url = Endpoint.url(Issue, scope) <> "?" <> URI.encode_query(query_opts)
    pagination = Keyword.get(opts, :pagination, [])

    Client.get_paginated(client, issues_url,
      type: Keyword.get(pagination, :type, :single),
      transform: &issue_from_json/1
    )
  end

  def update_issue(client, issue) do
    issue = prepare_issue_opts_for_query(issue)
    issue_url = Endpoint.url(Issue.endpoint_scope(issue))

    with {:ok, body} <- Client.put(client, issue_url, issue) do
      {:ok, Issue.cast!(body)}
    end
  end

  @spec mv_issue(Client.t(), Project.id(), Issue.iid(), map()) :: Client.result()
  def mv_issue(client, project_id, issue_iid, opts) do
    project_issue_url = Endpoint.url({Issue, {Project, project_id}, issue_iid})
    Client.post(client, project_issue_url <> "/move", opts)
  end

  #############################################################################
  ## Misc

  defp prepare_issue_opts_for_query(opts) do
    case Map.fetch(opts, :labels) do
      {:ok, labels} -> Map.put(opts, :labels, Enum.join(labels, ","))
      :error -> opts
    end
  end

  defp issue_from_json(data) do
    {:ok, Issue.cast!(data)}
  end
end
