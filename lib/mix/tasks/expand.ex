defmodule Mix.Tasks.Expand do
  @moduledoc """
  Expands import|require|alias into multiple lines
  """

  use Mix.Task

  @cmd "find"
  @cmd_args [
    ".",
    "-type",
    "f",
    "-name",
    "*.ex",
    "-o",
    "-name",
    "*.exs",
    "-not",
    "-path",
    "./deps/*"
  ]
  @regex ~r/  (import|require|alias) [\w.]+.{[\n \w,.]+}\n/

  @shortdoc "Simply calls the Hello.say/0 function."
  @impl Mix.Task
  def run(_args) do
    {output, 0} = System.cmd(@cmd, @cmd_args)

    output
    |> String.split("\n", trim: true)
    |> Task.async_stream(fn file ->
      file
      |> read_file()
      |> process_content()
      |> write_new_content(file)
    end)
    |> Stream.run()
  end

  defp read_file(file), do: File.read!(file)
  defp process_content(content), do: process_content(content, Regex.run(@regex, content))
  defp process_content(content, nil), do: content
  defp process_content(content, aliases_content), do: do_process_content(content, aliases_content)
  defp write_new_content(content, file), do: File.write!(file, content)

  defp do_process_content(content, [not_expanded_content | _]) do
    expanded_content = expand_content(not_expanded_content)
    new_content = String.replace(content, not_expanded_content, "#{expanded_content}\n")

    process_content(new_content)
  end

  def expand_content(alias_content) do
    [base, modules_content] = String.split(alias_content, "{")

    modules_content
    |> normalize_modules()
    |> Enum.map(&"#{base}#{&1}")
    |> Enum.join("\n")
  end

  def normalize_modules(modules_content) do
    modules_content
    |> String.replace(~r/(,|,?\n)/, " ")
    |> String.replace(~r/[ ]{2,}/, " ", trim: true)
    |> String.replace(~r/(} |}\n)/, "")
    |> String.split(" ", trim: true)
  end
end
