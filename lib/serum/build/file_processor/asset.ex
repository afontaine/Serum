defmodule Serum.Build.FileProcessor.Asset do
  @moduledoc false

  import Serum.IOProxy, only: [put_msg: 2]
  alias Serum.Project
  alias Serum.Result
  alias Serum.Asset
  alias Serum.Plugin

  @doc false
  @spec preprocess_assets([Serum.File.t()], Project.t()) :: Result.t({[Asset.t()], [map()]})
  def preprocess_assets(files, proj) do
    put_msg(:info, "Processing asset files...")

    result =
      files
      |> Task.async_stream(&preprocess_asset(&1, proj))
      |> Enum.map(&elem(&1, 1))
      |> Result.aggregate_values(:file_processor)

    case result do
      {:ok, assets} -> {:ok, {assets, Enum.map(assets, &Asset.compact/1)}}
      {:error, _} = error -> error
    end
  end

  @spec preprocess_asset(Serum.File.t(), Project.t()) :: Result.t(Asset.t())
  def preprocess_asset(file, proj) do
    with {:ok, %{in_data: data} = file2} <- Plugin.processing_asset(file) do
      asset = Asset.new(file2.src, data, proj)

      {:ok, asset}
    else
      {:invalid, message} -> {:error, {message, file.src, 0}}
      {:error, _} = err -> err
    end
  end

  @spec process_assets([Asset.t()]) :: Result.t([Asset.t()])
  def process_assets(assets) do
    assets
    |> Task.async_stream(&process_asset(&1))
    |> Enum.map(&elem(&1, 1))
    |> Result.aggregate_values(:file_processor)
    |> case do
      {:ok, assets} -> Plugin.processed_assets(assets)
      {:error, _} = error -> error
    end
  end

  @spec process_asset(Asset.t()) :: Result.t(Asset.t())
  defp process_asset(asset) do
    Plugin.processed_asset(asset)
  end
end
