defmodule SecretSantaWeb.SubscriberControllerTest do
  @moduledoc false
  use SecretSantaWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "Adds a subscriber", %{conn: conn} do
    path = subscriber_path(conn, :create)
    email = "john@test.com"

    conn = post(conn, path, %{email: email})
    json = json_response(conn, 201)["data"]

    assert json == %{"email" => email}
  end

  test "Removes a subscriber", %{conn: conn} do
    email = "john@test.com"
    attrs = %{email: email}
    {:ok, _} = SecretSanta.Auth.add_subscriber(attrs)
    path = subscriber_path(conn, :delete, attrs)

    conn = delete(conn, path)
    response = json_response(conn, 200)
    assert response == %{"ok" => true}
  end

  test "Checks for presence of email query param", %{conn: conn} do
    path = subscriber_path(conn, :delete)
    conn = delete(conn, path)
    response = json_response(conn, 400)
    assert response == %{"message" => "Email query param left empty"}
  end

  # Generate docs
  test "POST /api/v1/subscribers", %{conn: conn} do
    conn = conn
        |> post("/api/v1/subscribers", %{email: "john@test.com"})
        |> doc(description: "Create subscriber", operation_id: "create_subscriber")
    assert conn.status == 201
  end

  test "DELETE /api/v1/subscribers", %{conn: conn} do
    email = "john@test.com"
    SecretSanta.Auth.add_subscriber(%{email: email})
    conn = conn
        |> delete("/api/v1/subscribers?email=#{email}")
        |> doc(description: "Delete subscriber", operation_id: "delete_subscriber")
    assert conn.status == 200
  end
end
