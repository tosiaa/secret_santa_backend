defmodule SecretSantaWeb.UserControllerTest do
  @moduledoc false
  use SecretSantaWeb.ConnCase
  use Bamboo.Test
  alias SecretSantaWeb.Support.UserHelper

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "Creates personal user and sends confirmation email", %{conn: conn} do
    path = user_path(conn, :create, %{type: "personal"})
    user = UserHelper.default_personal_user

    conn = post(conn, path, user)
    json = json_response(conn, 201)

    assert json == %{"status" => "ok"}
    assert_email_delivered_with(html_body: ~r/\?token\=/)
  end

  test "Creates corporate user and sends confirmation email", %{conn: conn} do
    path = user_path(conn, :create, %{type: "corporate"})
    user = UserHelper.default_corporate_user

    conn = post(conn, path, user)
    json = json_response(conn, 201)

    assert json == %{"status" => "ok"}
    assert_email_delivered_with(html_body: ~r/\?token\=/)
  end

  test "Refuses to create user if email is already taken", %{conn: conn} do
    UserHelper.fixture(:user, :personal)
    path = user_path(conn, :create)
    conn = post(conn, path, UserHelper.user_default_attrs)
    json = json_response(conn, 400)["errors"]
    assert json == %{
      "email" => ["has already been taken"]
    }
  end

  test "Returns user details when token is present", %{conn: conn} do
    {sconn, %{user: user, data: data}} = UserHelper.secure_conn(conn)
    path = user_path(sconn, :current_user)
    conn = get(sconn, path)
    json = json_response(conn, 200)

    {data_inserted_at, data_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(data)
    {user_inserted_at, user_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(user)

    user_json = json["data"]["user"]
    data_json = json["data"]["personal_data"]

    assert user_json == %{
      "email" => user.email,
      "id" => user.id,
      "ethereum_public_address" => user.ethereum_public_address,
      "planned_contribution" => user.planned_contribution |> Decimal.to_string,
      "country_of_residence" => user.country_of_residence,
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
      "user_id" => user.id
    }

    assert json["meta"]["token"] != nil
  end

  test "Do not return user details without a token", %{conn: conn} do
    UserHelper.fixture(:user, :personal)
    path = user_path(conn, :current_user)
    conn = get(conn, path)
    assert text_response(conn, 401) == "unauthenticated"
  end

  test "Update user details", %{conn: conn} do
    {conn, %{user: user, data: data}} = UserHelper.secure_conn(conn)
    path = user_path(conn, :update)
    new_name = "Other"
    {data_inserted_at, data_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(data)
    {user_inserted_at, user_updated_at} = SecretSanta.Auth.FieldsHelper.get_iso_timestamps(user)

    conn = put(conn, path, %{first_name: new_name})
    json = json_response(conn, 200)
    user_json = json["data"]["user"]
    data_json = json["data"]["personal_data"]

    assert user_json == %{
      "email" => user.email,
      "id" => user.id,
      "ethereum_public_address" => user.ethereum_public_address,
      "planned_contribution" => user.planned_contribution |> Decimal.to_string,
      "country_of_residence" => user.country_of_residence,
      "inserted_at" => user_inserted_at,
      "updated_at" => user_updated_at,
    }

    assert data_json == %{
      "first_name" => new_name,
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
      "updated_at" => data_json["updated_at"],
      "user_id" => user.id
    }
    assert data_updated_at != data_json["updated_at"]
    assert json["meta"]["token"] != nil
  end

  # Generate docs

  test "GET /api/v1/users", %{conn: conn} do
    UserHelper.fixture(:user, :personal)

    conn = conn
      |> put_req_header("accept", "application/json")
      |> get("/api/v1/users")
      |> doc(description: "Get users count", operation_id: "get_user_count")

    assert conn.status == 200

    response = json_response(conn, 200)
    assert response == %{"users_count" => 1}
  end

  test "GET /api/v1/user", %{conn: conn} do
    conn = conn
        |> UserHelper.secure_conn()
        |> elem(0)
        |> get("/api/v1/user")
        |> doc(description: "Get user details", operation_id: "get_user")
    assert conn.status == 200
  end

  test "POST /api/v1/users - personal", %{conn: conn} do
    conn = conn
        |> post("/api/v1/users?type=personal", UserHelper.default_personal_user)
        |> doc(description: "Create new personal user", operation_id: "create_personal_user")
    assert conn.status == 201
  end

  test "POST /api/v1/users - corporate", %{conn: conn} do
    conn = conn
        |> post("/api/v1/users?type=corporate", UserHelper.default_corporate_user)
        |> doc(description: "Create new corporate user", operation_id: "create_corporate_user")
    assert conn.status == 201
  end

  test "PUT /api/v1/user", %{conn: conn} do
    conn = conn
        |> UserHelper.secure_conn()
        |> elem(0)
        |> put("/api/v1/user", %{first_name: "Other"})
        |> doc(description: "Change user details", operation_id: "get_user")
    assert conn.status == 200
  end
end
