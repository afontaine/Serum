defmodule Mix.Tasks.Serum do
  @moduledoc """
  Prints a list of available Serum tasks.

      mix serum

  This task does not take any command line argument.
  """

  @shortdoc "Prints a list of available Serum tasks"

  use Mix.Task
  alias Mix.Tasks.Serum.CLIHelper

  @b IO.ANSI.bright()
  @c IO.ANSI.cyan()
  @r IO.ANSI.reset()

  @impl true
  def run(_) do
    """
    #{CLIHelper.version_string()}Available tasks are:
    #{@c}mix serum          #{@r}# Prints this help message
    #{@c}mix serum.build    #{@r}# Builds the Serum project
    #{@c}mix serum.gen.page #{@r}# Adds a new page to the current project
    #{@c}mix serum.gen.post #{@r}# Adds a new blog post to the current project
    #{@c}mix serum.server   #{@r}# Starts the Serum development server

    Please visit #{@b}http://dalgona.github.io/Serum#{@r}
    for full documentations.
    """
    |> String.trim_trailing()
    |> Mix.shell().info()
  end
end
