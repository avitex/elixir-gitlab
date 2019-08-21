defmodule Gitlab.Pagination.Page do
  @moduledoc """
  Pagination information for a page.

  If the number of resources is more than 10,000, `total`, `total_pages` and `link.last` will be `nil`.
  """

  use TypedStruct

  alias Gitlab.Pagination
  alias Gitlab.Pagination.Link

  typedstruct do
    field(:link, Link.t(), enforce: true)
    field(:page, integer())
    field(:next_page, integer())
    field(:prev_page, integer())
    field(:per_page, integer())
    field(:total, integer())
    field(:total_pages, integer())
    field(:transform, Pagination.transform())
  end

  @spec from_parts(Link.t(), [{atom(), binary() | nil}], Pagination.transform()) :: t()
  def from_parts(link, parts, transform) do
    parts =
      Enum.filter(parts, fn {_, value} ->
        is_binary(value) and value != ""
      end)

    %__MODULE__{
      link: link,
      page: get_part(parts, :page),
      next_page: get_part(parts, :next_page),
      prev_page: get_part(parts, :prev_page),
      per_page: get_part(parts, :per_page),
      total: get_part(parts, :total),
      total_pages: get_part(parts, :total_pages),
      transform: transform
    }
  end

  defp get_part(parts, key) do
    case Keyword.get(parts, key) do
      nil ->
        nil

      part ->
        String.to_integer(part)
    end
  end
end
