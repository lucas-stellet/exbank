defmodule Exbank.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ExbankWeb.Telemetry,
      # Start the Ecto repository
      Exbank.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Exbank.PubSub},
      # Start the Endpoint (http/https)
      ExbankWeb.Endpoint,
      # cloak_ecto
      Exbank.Vault,
      # Bank Providers Clients Registry
      {Registry, keys: :unique, name: BankClientsRegistry},
      # Bank Providers Clients
      {DynamicSupervisor, name: TellerClientManager}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exbank.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExbankWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
