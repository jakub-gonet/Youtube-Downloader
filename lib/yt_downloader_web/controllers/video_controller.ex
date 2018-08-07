defmodule YtDownloaderWeb.VideoController do
  use YtDownloaderWeb, :controller

  def show(conn, %{"id" => id}) do
    wanted = [
      id: ["id"],
      title: ["snippet", "title"],
      channel: ["snippet", "channelTitle"],
      channel_id: ["snippet", "channelId"],
      desc: ["snippet", "description"]
    ]

    results =
      id
      |> YtUtility.get_video_data()
      |> Map.get("items")
      |> List.first()
      |> YtUtility.extract_video_data(wanted)

    render(conn, "video.html", data: results)
  end
end
