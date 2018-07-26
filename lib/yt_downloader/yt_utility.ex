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

  @doc """
  Downloads a given link to given file type and returns path where file was saved.

  `file_type` is `bestvideo`, `bestaudio`, `worstvideo` or `worstaudio`
  `file_type` can be also one of the numbers returned by `get_available_formats/1`
  or `3gp`, `aac`, `flv`, `m4a`, `mp3`, `mp4`, `ogg`, `wav`, `webm` extentions (if available of course).
  """
  def download(url = @playlist_url <> _, file_type),
    do: _download(url, @playlist_template, file_type)

  def download(url = @watch_url <> _, file_type), do: _download(url, @video_template, file_type)

  defp _download(link, file_template, file_type) do
    args = List.flatten([@downloader_options, "-o" <> file_template, "-f " <> file_type, link])

    {json, error_code} =
      System.cmd(
        @downloader,
        args
      )

    with 0 <- error_code,
         {:ok, metadata} <- Poison.decode(json),
         filepath <- extract_file_path_from_map(metadata) do
      {metadata, filepath}
    else
      1 -> {:error, :downloader_error}
      error -> error
    end
  end

  @doc """
  Gets available formats via downloader from given link.
  Returns map with three keys: `num`, `extension` and `description`.
  """
  def get_available_formats(link) do
    {output, error} =
      System.cmd(
        @downloader,
        ["--list-formats", link]
      )

    with 0 <- error,
         formats <- get_formats_list(output) do
      formats
    else
      1 -> {:error, :format_downloader_error}
      error -> error
    end
  end

  defp get_formats_list(formats_string) do
    by_groups = ~r{(\d+)\s+(\w+)\s+(.+)}

    formats_string
    |> String.split("\n")
    |> Enum.map(&Regex.run(by_groups, &1, capture: :all_but_first))
    |> Enum.filter(& &1)
    |> Enum.map(fn [num, ext, desc] -> %{num: num, extension: ext, description: desc} end)
    |> Enum.sort_by(&{&1.extension, &1.num})
  end

  defp extract_file_path_from_map(metadata) do
    Map.get(metadata, "_filename", {:error, :missing_entry})
  end

  defp extract_param_from_link(arguments_string, param) do
    arguments_string
    |> URI.decode_query()
    |> Map.get(param, {:error, :no_param})
  end
end
