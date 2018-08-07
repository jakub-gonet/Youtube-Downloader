defmodule YtUtility do
  require Logger

  @moduledoc """
  This module is supposed to contain all operations related with parsing youtube link,
  downloading content and providing resource path on disk
  """
  @yt_api_key Application.get_env(:yt_downloader, :yt_api_key)

  @watch_url "https://www.youtube.com/watch?"
  @shortened_watch_url "https://youtu.be/"
  @playlist_url "https://www.youtube.com/playlist?"

  @downloader "youtube-dl"
  @download_path "priv/downloads"
  @video_template "#{@download_path}/%(title)s_%(id)s.%(ext)s"
  @playlist_template "#{@download_path}/%(playlist)s/%(playlist_index)s - %(title)s_%(id)s.%(ext)s"
  @downloader_options ["-i", "--ignore-config", "--print-json", "--geo-bypass"]

  @doc """
  Checks if link starts with Youtube's links for video or playlist.

  Returns `:video`, `:playlist` or `:other`
  """
  def get_url_type(link) do
    cond do
      String.starts_with?(link, [@watch_url, @shortened_watch_url]) -> :video
      String.starts_with?(link, @playlist_url) -> :playlist
      true -> :other
    end
  end

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
  Extracts provided data from API's response to map.

  `params` should be keywords list, value should be a path list.

  ## Example:
  iex> results = YtUtility.search("hello", "video", 2)["items"]
  iex> options = [title: ["snippet", "title"], thumbnail: ["snippet", "thumbnails", "medium", "url"]]
  iex> Enum.map(results, &YtUtility.extract_video_data(&1, options))
  [
    %{
      thumbnail: "https://i.ytimg.com/vi/YQHsXMglC9A/mqdefault.jpg",
      title: "Adele - Hello"
    },
    %{
      thumbnail: "https://i.ytimg.com/vi/bFhQL130aYQ/mqdefault.jpg",
      title: "Hello | Đàm Vĩnh Hưng x Binz | Hương Giang, Trấn Thành, Thánh Catwalk Sinon, Hữu Vi | Official MV"
    }
  ]


  """
  def extract_video_data(data, params), do: _extract_video_data(%{}, data, params)

  defp _extract_video_data(extracted, _data, []), do: extracted

  defp _extract_video_data(extracted, data, [{name, field_name} | tail]) do
    extracted
    |> Map.merge(%{name => get_in(data, field_name)})
    |> _extract_video_data(data, tail)
  end

  @doc """
  Gets video data from YT API
  """
  def get_video_data(id, part \\ "snippet,id") do
    video_api_url = "https://www.googleapis.com/youtube/v3/videos"

    api_call_query = %{
      key: @yt_api_key,
      part: part,
      id: id
    }

    make_api_request(video_api_url, api_call_query)
  end

  @doc """
  Gets playlist data from YT API
  """
  def get_playlist_data(id, part \\ "snippet,id") do
    playlist_api_url = "https://www.googleapis.com/youtube/v3/playlistItems"

    api_call_query = %{
      key: @yt_api_key,
      part: part,
      playlistId: id,
      maxResults: 50
    }

    make_api_request(playlist_api_url, api_call_query)
  end

  @doc """
  Makes a request to YT API asking for search results.
  Returns results or `{:error, "reason"}` tuple.

  `results_number` is a number between 0 to 50, inclusive.
  `types` is a string of a comma-separated list of resource types.
  Acceptable values are:
    +video
    +channel
    +playlist.
  """
  def search(query, types \\ "video,channel,playlist", results_number \\ 10) do
    Logger.info("Searching for \"#{query}\"")
    search_api_url = "https://www.googleapis.com/youtube/v3/search"

    api_call_query = %{
      key: @yt_api_key,
      q: query,
      maxResults: results_number,
      type: types,
      part: "snippet"
    }

    search_info = %{
      "search_info" => %{
        "query" => query,
        "search_types" => types,
        "requested_results_num" => results_number
      }
    }

    search_api_url
    |> make_api_request(api_call_query)
    |> Map.merge(search_info)
  end

  @doc """
  Downloads a given link to given file type and returns path where file was saved.

  `file_type` is `bestvideo`, `bestaudio`, `worstvideo` or `worstaudio`
  `file_type` can be also one of the numbers returned by `get_available_formats/1`
  or `3gp`, `aac`, `flv`, `m4a`, `mp3`, `mp4`, `ogg`, `wav`, `webm` extentions (if available of course).
  """
  def download(url, filetype)

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

  defp make_api_request(url, query) do
    with %{body: body, status_code: 200} <- HTTPotion.get(url, query: query),
         {:ok, result} <- Poison.decode(body),
         :ok <- valid_api_response?(result) do
      result
    else
      %{status_code: code} -> {:error, "API returned #{code} code."}
      err -> err
    end
  end

  defp valid_api_response?(response) do
    case Map.has_key?(response, "error") do
      false -> :ok
      true -> {:error, "API error: #{response["code"]}, #{response["message"]}"}
    end
  end

  defp get_formats_list(formats_string) do
    by_groups = ~r{(\d+)\s+(\w+)\s+(.+)}

    formats_string
    |> String.split("\n")
    |> Enum.map(&Regex.run(by_groups, &1, capture: :all_but_first))
    |> Enum.reject(&is_nil(&1))
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
