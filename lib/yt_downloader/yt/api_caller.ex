defmodule YtUtils.ApiCaller do
  @doc false 
  require Logger
  use YtUtils.Constants

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
    |> perform_api_request(api_call_query)
    |> Map.merge(search_info)
  end

  @doc """
  Gets video data from YT API
  """
  def video_properties(id, part \\ "snippet,id") do
    video_api_url = "https://www.googleapis.com/youtube/v3/videos"

    api_call_query = %{
      key: @yt_api_key,
      part: part,
      id: id
    }

    perform_api_request(video_api_url, api_call_query)
  end

  @doc """
  Gets playlist data from YT API
  """
  def playlist_properties(id, part \\ "snippet,id") do
    playlist_api_url = "https://www.googleapis.com/youtube/v3/playlistItems"

    api_call_query = %{
      key: @yt_api_key,
      part: part,
      playlistId: id,
      maxResults: 50
    }

    perform_api_request(playlist_api_url, api_call_query)
  end

  defp perform_api_request(url, query) do
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
end
