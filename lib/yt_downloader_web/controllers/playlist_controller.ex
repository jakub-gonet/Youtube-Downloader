defmodule YtDownloaderWeb.PlaylistController do
  use YtDownloaderWeb, :controller

  def show(conn, %{"id" => id}) do
    render(conn, "video.html", id: id)
  end
end
