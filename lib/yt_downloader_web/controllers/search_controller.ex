defmodule YtDownloaderWeb.SearchController do
  use YtDownloaderWeb, :controller

  def search(conn, %{"search" => %{"q" => query}}) do
    render conn, "search.html", query: query
  end
end