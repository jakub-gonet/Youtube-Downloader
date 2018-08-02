defmodule YtDownloaderWeb.PageController do
  use YtDownloaderWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
