defmodule ReactiveServer.Router do
  use ReactiveServer.Web, :router

  # This is the browser pipeline, defined as plug actions
  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # This is the JSON api pipeline
  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  scope "/", ReactiveServer do
    pipe_through [:browser, :browser_session]   # Use the default browser stack

    get "/", PageController, :index
    get "/signup", PageController, :signup
    post "/signup", PageController, :create

    get "/login", SessionController, :login_page, as: :login
    post "/login", SessionController, :login, as: :login
    get "/logout", SessionController, :logout, as: :logout

    resources "/users", UserController
    post "/users/:id", UserController, :update

  end

  # Other scopes may use custom stacks.
  # scope "/api", ReactiveServer do
  #   pipe_through :api
  # end
end
