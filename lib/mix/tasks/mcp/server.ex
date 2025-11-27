defmodule Mix.Tasks.Mcp.Server do
  use Mix.Task
  require Logger

  @shortdoc "Runs the MCP server on Stdio"
  def run(_) do
    Mix.Task.run("app.start")
    # Logger.info("Starting MCP Server on Stdio")
    # Don't log to stdio if it interferes with JSON-RPC.
    # Configure Logger to file or stderr?
    # For now, I'll assume Logger prints to stderr (default in Mix).

    loop(%{session_id: nil})
  end

  defp loop(state) do
    case IO.read(:stdio, :line) do
      :eof ->
        :ok

      line ->
        new_state = handle_line(line, state)
        loop(new_state)
    end
  end

  defp handle_line(line, state) do
    case Jason.decode(line) do
      {:ok, json} ->
        process_request(json, state)

      {:error, _} ->
        IO.puts(
          Jason.encode!(%{
            jsonrpc: "2.0",
            error: %{code: -32700, message: "Parse error"},
            id: nil
          })
        )

        state
    end
  end

  defp process_request(json, state) do
    case GenMCP.Validator.validate_request(json) do
      {:ok, :request, %GenMCP.MCP.InitializeRequest{} = req} ->
        opts = [server: AwesomeDashboard.MCP.Server, session_id: "stdio-session"]
        {:ok, session_id} = GenMCP.Mux.start_session(opts)
        handle_mux_request(session_id, req, json["id"])
        Map.put(state, :session_id, session_id)

      {:ok, :request, req} ->
        if state.session_id do
          handle_mux_request(state.session_id, req, json["id"])
          state
        else
          IO.puts(
            Jason.encode!(%{
              jsonrpc: "2.0",
              error: %{code: -32002, message: "Not initialized"},
              id: json["id"]
            })
          )

          state
        end

      {:ok, :notification, notif} ->
        if state.session_id do
          GenMCP.Mux.notify(state.session_id, notif)
        end

        state

      {:error, _reason} ->
        IO.puts(
          Jason.encode!(%{
            jsonrpc: "2.0",
            error: %{code: -32600, message: "Invalid Request"},
            id: json["id"]
          })
        )

        state
    end
  rescue
    e ->
      # Logger.error("Error processing request: #{inspect(e)}")
      IO.puts(
        Jason.encode!(%{
          jsonrpc: "2.0",
          error: %{code: -32603, message: "Internal Error: #{inspect(e)}"},
          id: json["id"]
        })
      )

      state
  end

  defp handle_mux_request(session_id, req, msg_id) do
    chan_info = {:channel, __MODULE__, self(), %{}}

    case GenMCP.Mux.request(session_id, req, chan_info) do
      {:result, result} ->
        resp = %{jsonrpc: "2.0", result: result, id: msg_id}
        IO.puts(Jason.encode!(resp))

      {:error, reason} ->
        {_code, payload} = GenMCP.RpcError.cast_error(reason)
        resp = %{jsonrpc: "2.0", error: payload, id: msg_id}
        IO.puts(Jason.encode!(resp))
    end
  end
end
