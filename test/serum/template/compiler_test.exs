defmodule Serum.Template.CompilerTest do
  use ExUnit.Case, async: true
  require Serum.TestHelper
  import Serum.TestHelper, only: :macros
  alias Serum.Template.Compiler, as: TC

  describe "compile_files/2" do
    test "compile includable templates" do
      file = %Serum.File{src: fixture("templates/good.html.eex")}
      {:ok, file} = Serum.File.read(file)
      {:ok, includes} = TC.compile_files([file], type: :include)
      {output, _} = Code.eval_quoted(includes["good"].ast)

      assert includes["good"].type === :include
      assert String.contains?(output, "Hello, world!")

      tc_options = [type: :template, includes: includes]
      key = "good-using-includes"
      file = %Serum.File{src: fixture("templates/#{key}.html.eex")}
      {:ok, file} = Serum.File.read(file)
      {:ok, %{^key => template}} = TC.compile_files([file], tc_options)
      {output, _} = Code.eval_quoted(template.ast)

      assert template.type === :template
      assert String.contains?(output, "Include Test")
      assert String.contains?(output, "Hello, world!")
    end

    test "compile templates" do
      key = "good-using-helpers"
      file = %Serum.File{src: fixture("templates/#{key}.html.eex")}
      {:ok, file} = Serum.File.read(file)
      {:ok, %{^key => template}} = TC.compile_files([file], type: :template)
      assigns = [site: %{base_url: "/test_site/"}]
      {output, _} = Code.eval_quoted(template.ast, assigns: assigns)

      assert template.type === :template
      assert String.contains?(output, "/test_site/index.html")
    end

    test "handle ill-formed templates" do
      files =
        fixture("templates")
        |> Path.join("bad-*.html.eex")
        |> Path.wildcard()
        |> Enum.map(&%Serum.File{src: &1})
        |> Enum.map(&Serum.File.read/1)
        |> Enum.map(fn {:ok, file} -> file end)

      {:error, {_, errors}} = TC.compile_files(files, type: :template)

      assert length(errors) === length(files)
    end
  end
end
