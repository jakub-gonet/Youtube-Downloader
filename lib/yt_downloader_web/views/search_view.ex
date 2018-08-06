defmodule YtDownloaderWeb.SearchView do
  use YtDownloaderWeb, :view

  def get_searched_query(query)
  def get_searched_query(%{"search_info" => %{"query" => q}}), do: q

  def extract_video_data(search_result)

  def extract_video_data(query = %{"snippet" => video_data}) do
    %{
      channel: video_data["channelTitle"],
      title: video_data["title"],
      desc: video_data["description"],
      thumbnail: get_in(video_data, ["thumbnails", "medium", "url"]),
      video_id: get_id(query)
    }
  end

  def kind(%{"kind" => "youtube#playlist"}), do: :playlist
  def kind(%{"kind" => "youtube#video"}), do: :video
  def kind(_), do: :error

  defp get_id(%{"id" => id}) do
    Map.get(id, "playlistId") || Map.get(id, "videoId")
  end
end
