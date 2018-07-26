defmodule YtUtility do
  @moduledoc """
  This module is supposed to contain all operations related with parsing youtube link,
  downloading content and providing resource path on disk
  """

  @watch_url "https://www.youtube.com/watch?"
  @shortened_watch_url "https://youtu.be/"
  @playlist_url "https://www.youtube.com/playlist?"

  @downloader "youtube-dl"
  @download_path "priv/downloads"
  @video_template "#{@download_path}/%(title)s_%(id)s.%(ext)s"
  @playlist_template "#{@download_path}/%(playlist)s/%(playlist_index)s - %(title)s_%(id)s.%(ext)s"
  @downloader_options ["-i", "--ignore-config", "--print-json", "--geo-bypass"]

  @doc """
  Parses a link and returns prepared youtube link without all GET params except `v=` in case of videos
  and `list=` in case of playlists

  It accepts normal link, shortened (from share button) link and link to playlist
  ## Examples
  iex> YtDownloader.parse("")
  {:error, :empty_link}

  iex> YtDownloader.parse("https://www.youtube.com/watch?v=5hEh9LiSzow&list=tL5JECtaejrVtRCecgYPihN594KQhKgfHv&index=7")
  "https://www.youtube.com/watch?v=5hEh9LiSzow"

  iex> YtDownloader.parse("https://www.youtube.com/playlist?list=tL5JECtaejrVtRCecgYPihN594KQhKgfHv")
  "https://www.youtube.com/playlist?list=tL5JECtaejrVtRCecgYPihN594KQhKgfHv"

  iex> YtDownloader.parse("https://youtu.be/2O5euYPzcrY")
  "https://www.youtube.com/watch?v=2O5euYPzcrY"
  """
  def parse(url)

  def parse(@playlist_url <> params),
    do: @playlist_url <> "list=" <> extract_param_from_link(params, "list")

  def parse(@watch_url <> params), do: @watch_url <> "v=" <> extract_param_from_link(params, "v")
  def parse(@shortened_watch_url <> params), do: @watch_url <> "v=" <> params
  def parse(""), do: {:error, :empty_link}
  def parse(_), do: {:error, :unrecognized_link}

  defp extract_param_from_link(arguments_string, param) do
    arguments_string
    |> URI.decode_query()
    |> Map.get(param, {:error, :no_param})
  end
end
