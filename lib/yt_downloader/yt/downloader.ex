defmodule YtUtils.Downloader do
  @doc false 
  use YtUtils.Constants

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
         filepath <- extract_file_path(metadata) do
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
  def list_available_formats(link) do
    {output, error} =
      System.cmd(
        @downloader,
        ["--list-formats", link]
      )

    with 0 <- error,
         formats <- extract_formats(output) do
      formats
    else
      1 -> {:error, :format_downloader_error}
      error -> error
    end
  end

  defp extract_formats(formats_string) do
    by_groups = ~r{(\d+)\s+(\w+)\s+(.+)}

    formats_string
    |> String.split("\n")
    |> Enum.map(&Regex.run(by_groups, &1, capture: :all_but_first))
    |> Enum.reject(&is_nil(&1))
    |> Enum.map(fn [num, ext, desc] -> %{num: num, extension: ext, description: desc} end)
    |> Enum.sort_by(&{&1.extension, &1.num})
  end

  defp extract_file_path(metadata) do
    Map.get(metadata, "_filename", {:error, :missing_entry})
  end
end