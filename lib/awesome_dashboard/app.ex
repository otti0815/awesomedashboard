defmodule AwesomeDashboard.App do
  use Ash.Domain,
    otp_app: :awesome_dashboard

  resources do
    resource AwesomeDashboard.App.Item
    resource AwesomeDashboard.App.Sensor
  end
end
