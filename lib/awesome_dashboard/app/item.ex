defmodule AwesomeDashboard.App.Item do
  use Ash.Resource,
    otp_app: :awesome_dashboard,
    domain: AwesomeDashboard.App,
    data_layer: AshSqlite.DataLayer

  sqlite do
    table "items"
    repo AwesomeDashboard.Repo
  end

  actions do
    defaults [:read, :destroy, create: [], update: []]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
  end
end
