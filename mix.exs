defmodule Gitlab.MixProject do
  use Mix.Project

  def project do
    [
      app: :gitlab,
      version: "0.1.0",
      elixir: "~> 1.8",
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:tesla, "~> 1.3.3"},
      {:jason, ">= 1.0.0"},
      {:typed_struct, github: "ejpcmac/typed_struct", branch: "develop"},
      {:typed_struct_cast, github: "avitex/typed-struct-cast", branch: "master"},
      {:hackney, "~> 1.17.1"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
