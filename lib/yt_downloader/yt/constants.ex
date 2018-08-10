defmodule YtUtils.Constants do
   @moduledoc false

   defmacro __using__(_) do
    quote do
      @yt_api_key Application.get_env(:yt_downloader, :yt_api_key)
      
      @watch_url "https://www.youtube.com/watch?"
      @shortened_watch_url "https://youtu.be/"
      @playlist_url "https://www.youtube.com/playlist?"

      @downloader "youtube-dl"
      @download_path "priv/downloads"
      @video_template "#{@download_path}/%(title)s_%(id)s.%(ext)s"
      @playlist_template "#{@download_path}/%(playlist)s/%(playlist_index)s - %(title)s_%(id)s.%(ext)s"
      @downloader_options ["-i", "--ignore-config", "--print-json", "--geo-bypass"]
    end
  end
end