defmodule AwesomeDashboardWeb.SensorController do
  use AwesomeDashboardWeb, :controller
  require Ash.Query

  def create_reading(conn, %{"id" => id, "humidity" => humidity, "temperature" => temperature}) do
    # Find or create the sensor
    case AwesomeDashboard.App.Sensor.get_by_id(id) do
      {:ok, sensor} ->
        update_sensor(conn, sensor, humidity, temperature)

      {:error, _} ->
        create_sensor(conn, id, humidity, temperature)
    end
  end

  defp update_sensor(conn, sensor, humidity, temperature) do
    case AwesomeDashboard.App.Sensor.update(sensor, %{
           humidity: humidity,
           temperature: temperature
         }) do
      {:ok, _sensor} ->
        json(conn, %{status: "ok"})

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: inspect(error)})
    end
  end

  defp create_sensor(conn, id, humidity, temperature) do
    case AwesomeDashboard.App.Sensor.create(%{
           id: id,
           name: id,
           humidity: humidity,
           temperature: temperature
         }) do
      {:ok, _sensor} ->
        json(conn, %{status: "ok"})

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: inspect(error)})
    end
  end
end
