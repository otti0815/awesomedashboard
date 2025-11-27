defmodule AwesomeDashboardWeb.DashboardLive do
  use AwesomeDashboardWeb, :live_view
  alias AwesomeDashboard.App.Item
  alias AwesomeDashboard.App.Sensor
  require Ash.Query

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AwesomeDashboard.PubSub, "sensor:created")
      Phoenix.PubSub.subscribe(AwesomeDashboard.PubSub, "sensor:updated")
    end

    items = Ash.read!(Item)
    sensors = Ash.read!(Sensor)
    {:ok, assign(socket, items: items, sensors: sensors)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "create",
          payload: %Ash.Notifier.Notification{resource: AwesomeDashboard.App.Sensor, data: sensor}
        },
        socket
      ) do
    {:noreply, update(socket, :sensors, fn sensors -> [sensor | sensors] end)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "update",
          payload: %Ash.Notifier.Notification{resource: AwesomeDashboard.App.Sensor, data: sensor}
        },
        socket
      ) do
    {:noreply,
     update(socket, :sensors, fn sensors ->
       Enum.map(sensors, fn s -> if s.id == sensor.id, do: sensor, else: s end)
     end)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 p-8">
      <div class="max-w-7xl mx-auto">
        <header class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900">Awesome Dashboard</h1>
          <p class="text-gray-600">Managed by Ash Framework & MCP</p>
        </header>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for item <- @items do %>
            <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow duration-300">
              <div class="flex items-center justify-between mb-4">
                <h2 class="text-xl font-semibold text-gray-800">{item.name}</h2>
                <span class="text-xs text-gray-400 font-mono">{String.slice(item.id, 0, 8)}...</span>
              </div>
              <div class="text-sm text-gray-500">
                <!-- Placeholder for more details -->
                Item details here.
              </div>
            </div>
          <% end %>
          
    <!-- Add Item Card -->
          <div class="bg-white rounded-lg shadow-md p-6 border-2 border-dashed border-gray-300 flex items-center justify-center cursor-pointer hover:border-blue-500 transition-colors duration-300">
            <span class="text-gray-500 font-medium">+ Add New Item</span>
          </div>
        </div>

        <h2 class="text-2xl font-bold text-gray-900 mt-12 mb-6">Sensors</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for sensor <- @sensors do %>
            <div class="bg-white rounded-lg shadow-md p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-800">{sensor.name}</h3>
                <span class="text-xs text-gray-400 font-mono">
                  {String.slice(sensor.id, 0, 8)}...
                </span>
              </div>

              <div class="flex justify-around items-center">
                <!-- Humidity Gauge -->
                <div class="relative w-32 h-32">
                  <svg class="w-full h-full" viewBox="0 0 36 36">
                    <path
                      class="text-gray-200"
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="3.8"
                    />
                    <path
                      class="text-blue-500 transition-all duration-1000 ease-out"
                      stroke-dasharray={"#{sensor.humidity}, 100"}
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="3.8"
                    />
                  </svg>
                  <div class="absolute inset-0 flex flex-col items-center justify-center">
                    <span class="text-2xl font-bold text-gray-700">{sensor.humidity}%</span>
                    <span class="text-xs text-gray-500">Humidity</span>
                  </div>
                </div>
                
    <!-- Temperature Display -->
                <div class="text-center">
                  <div class="text-3xl font-bold text-gray-800">{sensor.temperature}°C</div>
                  <div class="text-xs text-gray-500">Temperature</div>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
