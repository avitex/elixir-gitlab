defmodule Gitlab.Issues.Issue do
  use TypedStruct
  use TypedStruct.Cast

  alias Gitlab.Endpoint
  alias Gitlab.Projects.Project

  @type id :: integer()
  @type iid :: integer()

  @behaviour Endpoint

  typedstruct do
    plugin(TypedStruct.Cast.Plugin)

    field(:id, integer())
    field(:iid, iid())
    field(:project_id, Project.id())
    field(:description, String.t())
    # TODO
    field(:state, String.t())
    field(:labels, [String.t()])
    field(:upvotes, integer())
    field(:downvotes, integer())
    field(:merge_requests_count, integer())
    field(:title, String.t())
    field(:updated_at, NaiveDateTime.t(), cast: NaiveDateTime)
    field(:created_at, NaiveDateTime.t(), cast: NaiveDateTime)
    field(:closed_at, NaiveDateTime.t(), cast: NaiveDateTime)
    field(:user_notes_count, integer())
    field(:due_date, Date.t(), cast: Date)
    field(:web_url, String.t())
    field(:confidential, boolean())
    field(:discussion_locked, boolean())

    # TODO
    # field :task_completion_status
    # field :time_stats
    # field :closed_by
    # field :milestone, Milestone.t()
    # field :author, Author.t()
    # field :assignees
    # field :assignee
  end

  @impl Endpoint
  def endpoint_name() do
    "issues"
  end

  @spec endpoint_scope(t()) :: Endpoint.scope()
  def endpoint_scope(issue = %__MODULE__{}) do
    {__MODULE__, endpoint_parent_scope(issue), issue.iid}
  end

  @spec endpoint_parent_scope(t()) :: Endpoint.scope()
  def endpoint_parent_scope(issue = %__MODULE__{}) do
    {Project, issue.project_id}
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      Jason.Encode.map(Map.drop(value, [:__struct__]), opts)
    end
  end
end
