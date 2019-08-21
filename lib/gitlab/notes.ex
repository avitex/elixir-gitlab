defmodule Gitlab.Notes do
  alias Gitlab.Client
  # alias Gitlab.Issue

  alias __MODULE__.{
    Note,
    NewNote
  }

  # @spec create_note(Client.t(), Gitlab.End, NewNote.t() | map()) ::
  #         {:ok, Note.t()} | {:error, binary}
  def create_note(client, scope, new_note) do
    notes_url = Gitlab.Endpoint.url({Note, scope})

    with {:ok, new_note} <- NewNote.cast(new_note),
         {:ok, body} <- Client.post(client, notes_url, new_note) do
      Note.cast(body)
    end
  end
end
