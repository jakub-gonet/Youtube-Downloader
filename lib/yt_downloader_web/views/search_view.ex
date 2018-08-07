defmodule YtDownloaderWeb.SearchView do
  use YtDownloaderWeb, :view

  def get_searched_query(query)
  def get_searched_query(%{"search_info" => %{"query" => q}}), do: q

end
