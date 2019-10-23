defmodule Serum.Asset do
  @moduledoc """
  Defines a struct describing a normal asset.

  ## Fields
  * `file`: Source path
  * `type`: Type of source file
  * `url`: Absolute URl of the asset
  * `output`: Destination path
  * `data`: Source data
  """

  @type t :: %__MODULE__{
          file: binary(),
          type: binary(),
          url: binary(),
          output: binary(),
          data: binary()
        }

  defstruct [:file, :type, :url, :output, :data, :extras]

  @spec new(binary(), binary(), map()) :: t()
  def new(path, data, proj) do
    asset_dir = (proj.src == "." && "assets") || Path.join(proj.src, "assets")
    filename = Path.relative_to(path, asset_dir)

    %__MODULE__{
      file: path,
      url: Path.join(proj.base_url),
      output: Path.join(proj.dest, filename),
      type: get_type(filename),
      data: data
    }
  end

  @spec compact(t()) :: map()
  def compact(%__MODULE__{} = asset) do
    asset
    |> Map.drop(~w(__struct__ data file output type)a)
    |> Map.put(:type, :asset)
  end

  @spec get_type(binary()) :: binary()
  defp get_type(filename) do
    Path.extname(filename)
  end
end
