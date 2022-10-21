defmodule ExpandEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/alexandrubagu/expand_ex"
  @version "0.1.0"

  def project do
    [
      app: :expand_ex,
      version: @version,
      elixir: "~> 1.12",
      package: package(),
      deps: deps()
    ]
  end

  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      name: :expand_ex,
      description: "Expands import|require|alias into multiple lines",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Bagu Alexandru Bogdan"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
