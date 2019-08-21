defmodule Gitlab.Issues.NewIssue do
  use TypedStruct
  use TypedStruct.Cast

  typedstruct do
    plugin(TypedStruct.Cast.Plugin)

    field(:title, String.t())
    field(:description, String.t())
    field(:confidential, boolean())
    field(:assignee_ids, [integer()])
    field(:milestone_id, integer())
    field(:labels, [String.t()])
    field(:created_at, NaiveDateTime.t(), cast: NaiveDateTime)
    field(:due_date, Date.t(), cast: Date)
    field(:weight, integer())
    # field :merge_request_to_resolve_discussions_of, integer()
    # field :discussion_to_resolve: String.t()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      Jason.Encode.map(Map.drop(value, [:__struct__]), opts)
    end
  end
end
