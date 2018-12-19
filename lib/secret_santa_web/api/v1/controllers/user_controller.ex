defmodule SecretSantaWeb.API.V1.UserController do
  use SecretSantaWeb, :controller
  use SecretSantaWeb.GuardedController

  alias Plug.Conn
  alias SecretSanta.Auth
  alias SecretSanta.Auth.Users
  alias SecretSanta.Mailer
  alias SecretSantaWeb.Email
  alias SecretSantaWeb.Guardian.Plug

  action_fallback(SecretSantaWeb.FallbackController)

  plug(Guardian.Plug.EnsureAuthenticated when action in [:current_user, :update])

  def index(conn, _params, _user) do
    users_count = Users.get_users_count()

    render(conn, "index.json", users_count: users_count)
  end

  def create(conn, params, _) do
    conn = Conn.fetch_query_params(conn)
    query_params = Map.new(conn.query_params)
    case Auth.create_user(params) do
      {:ok, %{user: user, data: _data}} ->
        Email.sign_in_email(user)
        |> Mailer.deliver_now()

        conn
        |> put_status(:created)
        |> render("create.json", user: user)

      {:error, _, changeset, _} ->
        conn
        |> put_status(:bad_request)
        |> render(SecretSantaWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def current_user(conn, _params, user) do
    jwt = Plug.current_token(conn)

    if user != nil do
      render(conn, "show.json", jwt: jwt, user: user)
    else
      conn
      |> put_status(:not_found)
      |> render(SecretSantaWeb.ErrorView, "404.json", [])
    end

    conn
      |> put_status(:ok)
      |> render("show.json", jwt: jwt, user: user)
  end

  def update(conn, params, user) do
    jwt = Plug.current_token(conn)

    case Users.update_user(user, params) do
      {:ok, user} ->
        render(conn, "show.json", jwt: jwt, user: user)

      {:error, changeset} ->
        render(conn, SecretSantaWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
