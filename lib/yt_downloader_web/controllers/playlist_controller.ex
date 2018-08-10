defmodule YtDownloaderWeb.PlaylistController do
  use YtDownloaderWeb, :controller

  def show(conn, %{"id" => id} = params) do
    playlist_title = Map.get(params, "title", "Playlist")
    wanted = [
      id: ["snippet", "resourceId", "videoId"],
      title: ["snippet", "title"],
      position: ["snippet", "position"],
      thumbnail: ["snippet", "thumbnails", "default", "url"],
    ]

    results =
      id
      |> YtUtils.playlist_data()
      |> Map.get("items")
      |> Enum.map(&YtUtils.extract_properties(&1, wanted))

    render(conn, "playlist.html", videos: results, title: playlist_title)
  end
end
