defmodule KbrwFormation.Mixfile do
  use Mix.Project

  def project do
    [app: :kbrw_formation,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     compilers: [:reaxt_webpack] ++ Mix.compilers
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:reaxt, :logger, :cowboy, :plug, :inets],
      mod: {KbrwFormation, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 2.1.0"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.3.4"},      
      {:reaxt, github: "kbrw/reaxt", tag: "2.1.0"},
      {:rulex, git: "https://github.com/kbrw/rulex.git"},
      {:exfsm, git: "https://github.com/kbrw/exfsm.git"},
      {:ewebmachine, "2.2.0"},
    ]
  end
end
