defmodule SecretSantaWeb.API.V1.UserView do
  use SecretSantaWeb, :view

  alias __MODULE__
  alias SecretSanta.User
  alias SecretSanta.Repo

  def render("index.json", %{users_count: users_count}), do: %{
    users_count: users_count
  }

  def render("show.json", %{jwt: jwt, user: user}), do:
    %{
      data: render_one(user, UserView, "user.json"),
      meta: %{token: jwt}
    }


  def render("create.json", _) do
    %{status: "ok"}
  end

  def render("error.json", %{message: message}) do
    %{message: message}
  end

  def render("user.json", %{user: user}) do
    {inserted_at, updated_at} = SecretSanta.FieldsHelper.get_iso_timestamps(user)
    user
      |> Map.from_struct()
      |> Map.put(:inserted_at, inserted_at)
      |> Map.put(:updated_at, updated_at)
      |> Map.take(User.attrs_for_view())
  end
end
