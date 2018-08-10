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
      |> YtUtils.video_data()
      |> Map.get("items")
      |> List.first()
      |> YtUtils.extract_properties(wanted)

    render(conn, "video.html", data: results)
  end
end
