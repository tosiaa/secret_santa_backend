defmodule SecretSantaWeb.API.V1.SessionController do
  use SecretSantaWeb, :controller

  alias SecretSanta.Auth
  alias SecretSantaWeb.Guardian, as: IcoGuardian
  alias SecretSantaWeb.Guardian.Plug, as: IcoPlug

  def create(conn, params) do
    case authenticate(params) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} = user
          |> IcoGuardian.encode_and_sign(%{}, token_type: :token)

        conn
          |> put_status(:created)
          |> render("show.json", user: user, jwt: jwt)

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: reason)
    end
  end

  def delete(conn, _) do
    conn
    |> IcoPlug.sign_out()
    |> put_status(:no_content)
    |> render("delete.json")
  end

  def refresh(conn, _params) do
    user = IcoPlug.current_resource(conn)
    jwt = IcoPlug.current_token(conn)

    case IcoGuardian.refresh(jwt, ttl: {30, :days}) do
      {:ok, _, {new_jwt, _new_claims}} ->
        conn
        |> put_status(:ok)
        |> render("show.json", user: user, jwt: new_jwt)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: "Not Authenticated")
    end
  end

  defp authenticate(%{"login" => login, "password" => password}) do
    Auth.authenticate_user(login, password)
  end

  defp authenticate(_), do: {:error, "Username or password not provided"}
end
