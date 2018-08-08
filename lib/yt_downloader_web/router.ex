defmodule YtDownloaderWeb.Router do
  use YtDownloaderWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", YtDownloaderWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/search", SearchController, :search)
    get("/video/:id", VideoController, :show)
    get("/playlist/:id", PlaylistController, :show)
    post("/download", DownloadController, :new)
  end

  # Other scopes may use custom stacks.
  # scope "/api", YtDownloaderWeb do
  #   pipe_through :api
  # end
end
