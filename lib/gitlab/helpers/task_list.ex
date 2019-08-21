defmodule Gitlab.Helpers.TaskList do
  @type t :: [{line(), task(), done()}]

  @type line :: String.t()
  @type task :: String.t()
  @type done :: boolean()

  @item_complete_pattern ~r/(\[[xX]\])/

  @item_pattern_inner [
    ~S'^',
    # optional blockquote characters
    ~S'(?:(?:>\s{0,4})*)',
    # list prefix required - task item has to be always in a list
    ~S'\s*(?:[-+*]|(?:\d+\.))',
    # whitespace prefix has to be always presented for a list item
    ~S'\s+',
    # checkbox
    ~S'(\[\s\]|\[[xX]\])',
    # followed by whitespace and some text.
    ~S'(\s.+)'
  ]

  @item_pattern Regex.compile!(
                  Enum.join(@item_pattern_inner),
                  "mx"
                )

  @spec parse(String.t()) :: t()
  def parse(content) do
    @item_pattern
    |> Regex.scan(content)
    |> Enum.map(&parse_task/1)
  end

  @spec parse_checkbox(String.t()) :: boolean()
  def parse_checkbox(checkbox) do
    Regex.match?(@item_complete_pattern, checkbox)
  end

  @spec render_checkbox(boolean()) :: String.t()
  def render_checkbox(checked) do
    if checked do
      "[x]"
    else
      "[ ]"
    end
  end

  defp parse_task([line, checkbox, task]) do
    task = String.trim_leading(task)
    done = parse_checkbox(checkbox)
    {line, task, done}
  end
end
