defmodule AwesomeDashboard.App do
  use Ash.Domain,
    otp_app: :awesome_dashboard

  resources do
    resource AwesomeDashboard.App.Item
  end
end
