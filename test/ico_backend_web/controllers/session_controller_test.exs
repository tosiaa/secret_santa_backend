defmodule SecretSantaWeb.SessionControllerTest do
  @moduledoc false
  use SecretSantaWeb.ConnCase

  alias SecretSantaWeb.Support.UserHelper

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "Signs in with correct data", %{conn: conn} do
    %{user: user, data: data} = UserHelper.fixture(:user, :personal)

    {data_inserted_at, data_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(data)
    {user_inserted_at, user_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(user)

    path = session_path(conn, :create)

    conn = post(conn, path, UserHelper.user_login_attrs)
    json = json_response(conn, 201)

    user_json = json["data"]["user"]
    data_json = json["data"]["personal_data"]

    assert user_json == %{
      "id" => user_json["id"],
      "email" => user.email,
      "country_of_residence" => user.country_of_residence,
      "ethereum_public_address" => user.ethereum_public_address,
      "planned_contribution" => user.planned_contribution |> Decimal.to_string,
      "inserted_at" => user_inserted_at,
      "updated_at" => user_updated_at,
    }

    assert data_json == %{
      "first_name" => data.first_name,
      "middle_name" => data.middle_name,
      "last_name" => data.last_name,
      "date_of_birth" => data.date_of_birth |> Date.to_iso8601,
      "place_of_birth" => data.place_of_birth,
      "document_type" => Atom.to_string(data.document_type),
      "document_number" => data.document_number,
      "mobile" => data.mobile,
      "street_address" => data.street_address,
      "town" => data.town,
      "post_code" => data.post_code,
      "state" => data.state,
      "country" => data.country,
      "inserted_at" => data_inserted_at,
      "updated_at" => data_updated_at,
      "user_id" => user_json["id"]
    }

    assert json["meta"]["token"] != nil

  end

  test "Does not sign in with incorrect data", %{conn: conn} do
    UserHelper.fixture(:user, :personal)
    path = session_path(conn, :create)

    conn = post(conn, path, %{UserHelper.user_login_attrs | password: "incorrect"})
    response = json_response(conn, 401)
    assert response == %{"message" => "Invalid email or password"}
  end

  test "Logs out", %{conn: conn} do
    {conn, _} = UserHelper.secure_conn(conn)
    path = session_path(conn, :delete)

    conn = delete(conn, path)
    response = json_response(conn, 204)
    assert response == %{"ok" => true}
  end

  test "Refreshes session", %{conn: conn} do
    {conn, %{user: user, data: data}} = UserHelper.secure_conn(conn)

    {data_inserted_at, data_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(data)
    {user_inserted_at, user_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(user)

    path = session_path(conn, :refresh)

    conn = post(conn, path, %{})

    json = json_response(conn, 200)

    user_json = json["data"]["user"]
    data_json = json["data"]["personal_data"]

    assert user_json == %{
      "id" => user_json["id"],
      "email" => user.email,
      "country_of_residence" => user.country_of_residence,
      "ethereum_public_address" => user.ethereum_public_address,
      "planned_contribution" => user.planned_contribution |> Decimal.to_string,
      "inserted_at" => user_inserted_at,
      "updated_at" => user_updated_at,
    }

    assert data_json == %{
      "first_name" => data.first_name,
      "middle_name" => data.middle_name,
      "last_name" => data.last_name,
      "date_of_birth" => data.date_of_birth |> Date.to_iso8601,
      "place_of_birth" => data.place_of_birth,
      "document_type" => Atom.to_string(data.document_type),
      "document_number" => data.document_number,
      "mobile" => data.mobile,
      "street_address" => data.street_address,
      "town" => data.town,
      "post_code" => data.post_code,
      "state" => data.state,
      "country" => data.country,
      "inserted_at" => data_inserted_at,
      "updated_at" => data_updated_at,
      "user_id" => user_json["id"],
    }

    assert json["meta"]["token"] != nil
  end

  test "Does not refresh with no token", %{conn: conn} do
    UserHelper.fixture(:user, :personal)
    path = session_path(conn, :refresh)

    conn = post(conn, path, %{})
    response = json_response(conn, 401)
    assert response == %{"message" => "Not Authenticated"}
  end

  # Generate docs

  test "POST /api/v1/users/login", %{conn: conn} do
    conn = conn
        |> UserHelper.secure_conn()
        |> elem(0)
        |> post("/api/v1/users/login", UserHelper.user_login_attrs)
        |> doc(description: "Log in", operation_id: "log_in")
    assert conn.status == 201
  end

  test "DELETE /api/v1/users/logout", %{conn: conn} do
    conn = conn
        |> UserHelper.secure_conn()
        |> elem(0)
        |> delete("/api/v1/users/logout")
        |> doc(description: "Log out", operation_id: "log_out")
    assert conn.status == 204
  end

  test "POST /api/v1/users/refresh", %{conn: conn} do
    conn = conn
        |> UserHelper.secure_conn()
        |> elem(0)
        |> post("/api/v1/users/refresh", %{})
        |> doc(description: "Refresh session", operation_id: "refresh_session")
    assert conn.status == 200
  end
end
