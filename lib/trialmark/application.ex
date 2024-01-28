defmodule Trialmark.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TrialmarkWeb.Telemetry,
      Trialmark.Repo,
      {DNSCluster, query: Application.get_env(:trialmark, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Trialmark.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Trialmark.Finch},
      # Start a worker by calling: Trialmark.Worker.start_link(arg)
      # {Trialmark.Worker, arg},
      # Start to serve requests, typically the last entry
      TrialmarkWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Trialmark.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TrialmarkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
