defmodule AwesomeDashboard.MCP.Server do
  @behaviour GenMCP
  alias GenMCP.MCP
  require Logger

  alias AwesomeDashboard.App.Item

  @impl true
  def init(_session_id, _opts) do
    Logger.info("MCP Server initialized")
    {:ok, %{}}
  end

  @impl true
  def handle_request(%MCP.InitializeRequest{}, _chan_info, state) do
    result =
      MCP.intialize_result(
        capabilities: MCP.capabilities(tools: %{}),
        server_info: MCP.server_info(name: "AwesomeDashboard", version: "0.1.0")
      )

    {:reply, {:result, result}, state}
  end

  def handle_request(%MCP.ListToolsRequest{}, _chan_info, state) do
    tools = [
      %MCP.Tool{
        name: "list_items",
        description: "List all items in the dashboard",
        inputSchema: %{
          type: "object",
          properties: %{},
          required: []
        }
      }
    ]

    result = MCP.list_tools_result(tools: tools)
    {:reply, {:result, result}, state}
  end

  def handle_request(
        %MCP.CallToolRequest{params: %MCP.CallToolRequestParams{name: "list_items"}},
        _chan_info,
        state
      ) do
    items = Ash.read!(Item)
    item_list = Enum.map(items, & &1.name)
    content = [%MCP.TextContent{type: "text", text: inspect(item_list)}]
    result = MCP.call_tool_result(content: content)
    {:reply, {:result, result}, state}
  end

  def handle_request(req, _chan_info, state) do
    Logger.warning("Unknown request: #{inspect(req)}")
    # Fallback
    error = %{code: -32601, message: "Method not found"}
    {:reply, {:error, error}, state}
  end

  @impl true
  def handle_notification(_notif, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
