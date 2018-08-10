defmodule YtUtils do
  alias YtUtils.ApiCaller
  alias YtUtils.Downloader
  alias YtUtils.DataExtractor

  @searched_types "video,playlist"
  @searched_result_number 10

  @yt_api_parts "snippet,id"

  def search(query), do: ApiCaller.search(query, @searched_types, @searched_result_number)
  def video_data(id), do: ApiCaller.video_properties(id, @yt_api_parts)
  def playlist_data(id), do: ApiCaller.playlist_properties(id, @yt_api_parts)
  def download(link, filetype), do: Downloader.download(link, filetype)
  def normalize_link(link), do: DataExtractor.prepare_link(link)
  def extract_properties(vid_data, wanted), do: DataExtractor.extract_video_properties(vid_data, wanted)
  def url_type(link), do: DataExtractor.url_type(link)
end
