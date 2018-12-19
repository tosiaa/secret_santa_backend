defmodule SecretSantaWeb.Router do
  use SecretSantaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug SecretSanta.Auth.Pipeline
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api", SecretSantaWeb.API do
    pipe_through(:api)

    scope "/v1", V1 do
      get("/user", UserController, :current_user)
      put("/user", UserController, :update)
      get("/users", UserController, :index)
      post("/users", UserController, :create)
      post("/users/login", SessionController, :create)
      delete("/users/logout", SessionController, :delete)
      post("/users/refresh", SessionController, :refresh)
    end
  end
end
