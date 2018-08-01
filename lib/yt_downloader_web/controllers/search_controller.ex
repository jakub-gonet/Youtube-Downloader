defmodule YtDownloaderWeb.SearchController do
  use YtDownloaderWeb, :controller

  def search(conn, %{"search" => %{"q" => query}}) do
    if {:ok, type} = YtUtility.valid_link?(query) do
      case type do
        :video -> redirect conn, to: video_path(conn, :show, query)
        :playlist -> redirect conn, to: playlist_path(conn, :show, query)
      end
    else
      render(conn, "search.html", search_results: YtUtility.search(query))
    end
  end
end
