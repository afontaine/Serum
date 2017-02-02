defmodule Serum.PostInfo do
  @moduledoc "This module defines PostInfo struct."

  import Serum.Util
  alias Serum.ProjectInfoStorage
  alias Serum.Build

  @type t :: %Serum.PostInfo{}

  defstruct [:file, :title, :date, :raw_date, :tags, :url, :preview_text]

  @doc "A helper function for creating a new PostInfo struct."
  @spec new(String.t, Build.header, Build.erl_datetime, String.t) :: t

  def new(filename, header, raw_date, preview) do
    base = ProjectInfoStorage.get owner(), :base_url
    date_fmt = ProjectInfoStorage.get owner(), :date_format
    {title, tags, _lines} = header
    date_str =
      raw_date
      |> Timex.to_datetime(:local)
      |> Timex.format!(date_fmt)
    %Serum.PostInfo{
      file: filename,
      title: title,
      tags: tags,
      preview_text: preview,
      raw_date: raw_date,
      date: date_str,
      url: base <> "posts/" <> filename <> ".html"
    }
  end
end

defimpl Inspect, for: Serum.PostInfo do
  def inspect(info, _opts), do: ~s(#Serum.PostInfo<"#{info.title}">)
end
