defmodule AwesomeDashboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AwesomeDashboard.Repo,
      AwesomeDashboardWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:awesome_dashboard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AwesomeDashboard.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AwesomeDashboard.Finch},
      # Start a worker by calling: AwesomeDashboard.Worker.start_link(arg)
      # {AwesomeDashboard.Worker, arg},
      # Start to serve requests, typically the last entry
      AwesomeDashboardWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwesomeDashboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AwesomeDashboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
