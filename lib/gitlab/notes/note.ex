defmodule Gitlab.Notes.Note do
  use TypedStruct
  use TypedStruct.Cast

  # alias Gitlab.Notes
  alias Gitlab.Endpoint

  @behaviour Endpoint

  @type id :: integer()

  typedstruct do
    plugin(TypedStruct.Cast.Plugin)

    field(:id, id())
    field(:body, String.t())

    field(:system, boolean())
    field(:resolvable, boolean())

    field(:noteable_id, integer())
    field(:noteable_type, String.t())
    field(:noteable_iid, integer())

    field(:updated_at, NaiveDateTime.t(), cast: NaiveDateTime)
    field(:created_at, NaiveDateTime.t(), cast: NaiveDateTime)

    # field(:author)
    # field(:attachment)
  end

  @impl Endpoint
  def endpoint_name() do
    "notes"
  end

  @spec parent_scope(t()) :: Endpoint.scope()
  def parent_scope(note = %__MODULE__{}) do
    case note.notable_type do
      "Issue" -> {Issue, note.notable_iid}
    end
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      Jason.Encode.map(Map.drop(value, [:__struct__]), opts)
    end
  end
end
