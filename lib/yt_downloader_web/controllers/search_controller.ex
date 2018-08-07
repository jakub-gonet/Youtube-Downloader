defmodule YtDownloaderWeb.SearchController do
  use YtDownloaderWeb, :controller
  require Logger

  def search(conn, %{"search" => %{"q" => query}}) do
    case YtUtility.get_url_type(query) do
      type when type in [:video, :playlist] ->
        redirect_to(conn, query, type)

      :other ->
        get_id = fn :get, data, _next -> data["playlistId"] || data["videoId"] end

        get_type = fn :get, data, _next ->
          case data do
            "youtube#playlist" -> :playlist
            "youtube#video" -> :video
            _ -> :error
          end
        end

        wanted = [
          id: ["id", get_id],
          type: ["id", "kind", get_type],
          title: ["snippet", "title"],
          channel: ["snippet", "channelTitle"],
          desc: ["snippet", "description"],
          thumbnail: ["snippet", "thumbnails", "medium", "url"]
        ]

        results =
          query
          |> YtUtility.search("video,playlist")
          |> Map.get("items")
          |> Enum.map(&YtUtility.extract_video_data(&1, wanted))

        render(conn, "search.html", search_results: results)
    end
  end

  defp redirect_to(conn, query, :video), do: redirect(conn, to: video_path(conn, :show, query))

  defp redirect_to(conn, query, :playlist),
    do: redirect(conn, to: playlist_path(conn, :show, query))
end
