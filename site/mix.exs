defmodule Erlangelist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :erlangelist,
      version: "0.0.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [release: :prod],
      aliases: [
        release: ["cmd npm run deploy --prefix ./assets", "phx.digest", "release"]
      ],
      dialyzer: [plt_add_deps: :transitive, remove_defaults: [:unknown]],
      releases: [
        erlangelist: [
          include_executables_for: [:unix],
          steps: [:assemble, :tar]
        ]
      ]
    ]
  end

  def application do
    [
      mod: {ErlangelistApp, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.14"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.1"},
      {:plug, "~> 1.7"},
      {:earmark, "~> 1.4"},
      {:makeup_elixir, "~> 0.14"},
      {:makeup_erlang, "~> 0.1"},
      {:parent, "~> 0.9"},
      {:site_encrypt, github: "sasa1977/site_encrypt"},
      {:deep_merge, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:dialyxir, "~> 1.0", runtime: false},
      {:sshex, "~> 2.0", runtime: false},
      {:table_rex, "~> 3.0", runtime: false},
      {:jason, "~> 1.0"},
      {:mox, "~> 0.5", only: :test},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"}
    ]
  end
end
