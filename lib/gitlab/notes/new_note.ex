defmodule Gitlab.Notes.NewNote do
  use TypedStruct
  use TypedStruct.Cast

  @type opts :: t() | map()

  typedstruct do
    plugin(TypedStruct.Cast.Plugin)

    field(:body, String.t(), enforce: true)
    field(:created_at, NaiveDateTime.t(), cast: NaiveDateTime)
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      Jason.Encode.map(Map.drop(value, [:__struct__]), opts)
    end
  end
end
