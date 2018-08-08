defmodule YtDownloaderWeb.DownloadController do
  use YtDownloaderWeb, :controller
  require Logger

  def new(conn, params) do
    # render conn, "download.html", query: query
    Logger.info(inspect(params))
    redirect(conn, to: "/")
   end
end
