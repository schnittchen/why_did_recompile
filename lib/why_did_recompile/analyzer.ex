defmodule WhyDidRecompile.Analyzer do
  def find_compile_dep_chain(deps_by_path, opts) do
    {opts, []} = Keyword.split(opts, [:source, :target])
    %{source: source, target: target} = Map.new(opts)

    find_dep_chain(deps_by_path, source, target, [], true)
    |> case do
      nil ->
        nil

      deps ->
        deps
        |> Enum.map(fn dep -> {dep.path, dep.kind} end)
        |> case do
          list ->
            [{source, :initial}] ++ list
        end
    end
  end

  defp find_dep_chain(deps_by_path, source_path, target_path, seen, first_step?) do
    Map.fetch!(deps_by_path, source_path)
    |> Enum.reject(&(&1.path in seen))
    |> Enum.filter(fn dep ->
      dep.kind == :compile || !first_step?
    end)
    |> Enum.find_value(fn %{path: next_path} = dep ->
      if next_path == target_path do
        [dep]
      else
        seen = [next_path | seen]

        case find_dep_chain(deps_by_path, next_path, target_path, seen, false) do
          nil -> nil
          chain -> [dep | chain]
        end
      end
    end)
  end
end
