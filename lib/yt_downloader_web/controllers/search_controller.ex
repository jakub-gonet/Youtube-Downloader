defmodule YtDownloaderWeb.SearchController do
  use YtDownloaderWeb, :controller

  def search(conn, %{"search" => %{"q" => query}}) do
    case YtUtility.valid_link?(query) do
      {:ok, type} ->
        redirect_to(conn, query, type)

      :error ->
        render(conn, "search.html", search_results: YtUtility.search(query, "video,playlist"))
    end
  end

  defp redirect_to(conn, query, :video), do: redirect(conn, to: video_path(conn, :show, query))

  defp redirect_to(conn, query, :playlist),
    do: redirect(conn, to: playlist_path(conn, :show, query))
end
