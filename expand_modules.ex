defmodule ExpandModules do
  @moduledoc false

  @cmd "find"
  @cmd_args [".", "-name", "*.ex", "-not", "-path", "./deps/*"]
  @regex ~r/  (import|require|alias) [\w.]+.{[\n \w,.]+}\n/

  def expand() do
    {output, 0} = System.cmd(@cmd, @cmd_args)

    output
    |> String.split("\n", trim: true)
    |> Task.async_stream(fn file ->
      file
      |> read_file()
      |> process_alias()
      |> write_new_content(file)
    end)
    |> Stream.run()
  end

  defp read_file(file), do: File.read!(file)
  defp process_alias(content), do: process_alias(content, Regex.run(@alias_regex, content))
  defp process_alias(content, nil), do: content
  defp process_alias(content, aliases_content), do: do_process_alias(content, aliases_content)
  defp write_new_content(content, file), do: File.write!(file, content)

  defp do_process_alias(content, [alias_content | _]) do
    expanded_alias = expand_alias(alias_content)
    new_content = String.replace(content, alias_content, "#{expanded_alias}\n")

    process_alias(new_content)
  end

  def expand_alias(alias_content) do
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
