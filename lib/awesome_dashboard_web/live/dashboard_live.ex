defmodule AwesomeDashboardWeb.DashboardLive do
  use AwesomeDashboardWeb, :live_view
  alias AwesomeDashboard.App.Item

  def mount(_params, _session, socket) do
    items = Ash.read!(Item)
    {:ok, assign(socket, items: items)}
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
      </div>
    </div>
    """
  end
end
