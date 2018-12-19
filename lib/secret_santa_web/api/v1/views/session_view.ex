defmodule SecretSantaWeb.API.V1.SessionView do
  use SecretSantaWeb, :view

  alias SecretSantaWeb.API.V1.UserView

  def render("show.json", params) do
    Phoenix.View.render(UserView, "show.json", params)
  end

  def render("delete.json", _) do
    %{ok: true}
  end

  def render("error.json", params) do
    Phoenix.View.render(UserView, "error.json", params)
  end
end
