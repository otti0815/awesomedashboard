defmodule AwesomeDashboard.App.Sensor do
  use Ash.Resource,
    otp_app: :awesome_dashboard,
    domain: AwesomeDashboard.App,
    data_layer: AshSqlite.DataLayer,
    extensions: [Ash.Notifier.PubSub]

  sqlite do
    table "sensors"
    repo AwesomeDashboard.Repo
  end

  code_interface do
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get?: true, args: [:id]
  end

  actions do
    defaults [:read, :destroy, create: [], update: []]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
    end
  end

  pub_sub do
    module AwesomeDashboard.PubSub
    prefix "sensor"
    broadcast_type :phoenix_broadcast
    publish :create, "created"
    publish :update, "updated"
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :humidity, :float
    attribute :temperature, :float

    timestamps()
  end
end
