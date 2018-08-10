defmodule YtUtils.DataExtractor do
  @doc false

  use YtUtils.Constants
  @doc """
  Parses a link and returns prepared youtube link without all GET params except `v=` in case of videos
  and `list=` in case of playlists

  It accepts normal link, shortened (from share button) link and link to playlist
  ## Examples
  iex> YtDownloader.prepare_link("")
  {:error, :empty_link}

  iex> YtDownloader.prepare_link("https://www.youtube.com/watch?v=5hEh9LiSzow&list=tL5JECtaejrVtRCecgYPihN594KQhKgfHv&index=7")
  "https://www.youtube.com/watch?v=5hEh9LiSzow"

  iex> YtDownloader.prepare_link("https://www.youtube.com/playlist?list=tL5JECtaejrVtRCecgYPihN594KQhKgfHv")
  "https://www.youtube.com/playlist?list=tL5JECtaejrVtRCecgYPihN594KQhKgfHv"

  iex> YtDownloader.prepare_link("https://youtu.be/2O5euYPzcrY")
  "https://www.youtube.com/watch?v=2O5euYPzcrY"
  """
  def prepare_link(url)

  def prepare_link(@playlist_url <> params),
    do: @playlist_url <> "list=" <> extract_param_from_link(params, "list")

  def prepare_link(@watch_url <> params),
    do: @watch_url <> "v=" <> extract_param_from_link(params, "v")

  def prepare_link(@shortened_watch_url <> params), do: @watch_url <> "v=" <> params
  def prepare_link(""), do: {:error, :empty_link}
  def prepare_link(_), do: {:error, :unrecognized_link}

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
  def extract_video_properties(properties, params),
    do: _extract_video_properties(%{}, properties, params)

  defp _extract_video_properties(extracted, _properties, []), do: extracted

  defp _extract_video_properties(extracted, properties, [{name, field_name} | tail]) do
    extracted
    |> Map.merge(%{name => get_in(properties, field_name)})
    |> _extract_video_properties(properties, tail)
  end

  @doc """
  Checks if link starts with Youtube's links for video or playlist.

  Returns `:video`, `:playlist` or `:other`
  """
  def url_type(link) do
    cond do
      String.starts_with?(link, [@watch_url, @shortened_watch_url]) -> :video
      String.starts_with?(link, @playlist_url) -> :playlist
      true -> :other
    end
  end

  defp extract_param_from_link(arguments_string, param) do
    arguments_string
    |> URI.decode_query()
    |> Map.get(param, {:error, :no_param})
  end
end
