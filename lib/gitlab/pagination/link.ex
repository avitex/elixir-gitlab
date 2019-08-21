defmodule Gitlab.Pagination.Link do
  @type t :: %{
          first: binary | nil,
          prev: binary | nil,
          next: binary | nil,
          last: binary | nil
        }

  @type rel :: :first | :prev | :next | :last

  defstruct [:first, :prev, :next, :last]

  @spec from_rels(%{binary => binary}) :: t()
  def from_rels(rels) do
    %__MODULE__{
      first: Map.get(rels, "first"),
      prev: Map.get(rels, "prev"),
      next: Map.get(rels, "next"),
      last: Map.get(rels, "last", nil)
    }
  end
end
