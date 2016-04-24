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
    plug :put_resp_content_type, Plug.MIME.type("json")
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug ReactiveServer.Plug.CurrentUser
  end

  pipeline :api_session do 
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end
  
  scope "/", ReactiveServer do
    pipe_through [:browser, :browser_session]   # Use the default browser stack

    get "/", PageController, :index
    get "/signup", PageController, :signup
    post "/signup", PageController, :create

    get "/login", SessionController, :login_page, as: :session
    post "/login", SessionController, :login, as: :session
    get "/logout", SessionController, :logout, as: :session

    resources "/users", UserController
    resources "/chatrooms", ChatRoomController

    post "/users/:id", UserController, :update

  end

  # Other scopes may use custom stacks.
  scope "/api", ReactiveServer do
     pipe_through [:api, :api_session]
     
     resources "/users", UserController
     post "/login", SessionController, :login, as: :session
  end
end
