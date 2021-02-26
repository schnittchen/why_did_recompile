defmodule Mix.Tasks.WhyDidRecompile do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Echoes arguments"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [compiled: :string, changed: :string])

    case opts |> Enum.sort() |> Keyword.split([:compiled, :changed]) do
      {[changed: changed, compiled: compiled], []} -> do_run(changed, compiled)
      {_, [_ | _] = excess} -> raise "Excess argument(s): #{inspect(excess)}"
      _else -> raise "Missing arguments, required: --compiled=path1 --changed=path2"
    end
  end

  alias WhyDidRecompile.{XrefPlainFormatParser, Analyzer}

  defp do_run(changed, compiled) do
    with(
      {:ok, output} <- xref_output(),
      deps_by_path = XrefPlainFormatParser.call(output),
      :ok <- check_path_given(deps_by_path, compiled),
      :ok <- check_path_given(deps_by_path, changed)
    ) do
      Analyzer.find_compile_dep_chain(deps_by_path, source: compiled, target: changed)
      |> case do
        nil ->
          Mix.shell().info("Could not find a transitive compile time dependency for you.")

        result ->
          Mix.shell().info("Found a transitive compile time dependency for you:")

          IO.inspect(result)
      end
    end
  end

  defp xref_output do
    Mix.shell().info("Running mix deps, this can take a while...")

    case System.cmd("mix", ["xref", "graph", "--format=plain"]) do
      {output, 0} -> {:ok, output}
      _else -> :error
    end
  end

  defp check_path_given(deps_by_path, path) do
    unless Map.has_key?(deps_by_path, path) do
      raise "path #{path} not found in output of `mix xref`"
    end

    :ok
  end
end
