defmodule WhyDidRecompile.AnalyzerTest do
  use ExUnit.Case, async: true

  alias WhyDidRecompile.{Analyzer, Dep}

  # Note `deps_by_path/1` generates a deps map from a string, where
  # * "a -> b" means that a has a runtime dependency on b
  # * "a => b" means that a has a compile time dependency on b
  # * "S" is the source and "T" is the target when calling find_compile_dep_chain

  describe "find_compile_dep_chain" do
    test "returns nil when nothing found" do
      deps_by_path = deps_by_path("S -> 1 -> T")

      assert find_compile_dep_chain(deps_by_path) == nil

      deps_by_path = deps_by_path("1 => S -> T")

      assert find_compile_dep_chain(deps_by_path) == nil

      deps_by_path = deps_by_path("S -> 1 => T")

      assert find_compile_dep_chain(deps_by_path) == nil

      deps_by_path = deps_by_path("S -> 1 -> T => 2")

      assert find_compile_dep_chain(deps_by_path) == nil

      deps_by_path =
        """
        1 -> 2 => S -> 1
        1 -> T
        """
        |> deps_by_path

      assert find_compile_dep_chain(deps_by_path) == nil
    end

    test "returns shortest thinkable chain" do
      deps_by_path = deps_by_path("S => T")

      assert find_compile_dep_chain(deps_by_path) == [
               {"S", :initial},
               {"T", :compile}
             ]
    end

    test "returns chain starting with compile time dep" do
      deps_by_path = deps_by_path("S => 1 -> T")

      assert find_compile_dep_chain(deps_by_path) == [
               {"S", :initial},
               {"1", :compile},
               {"T", :runtime}
             ]
    end

    test "returns chain involving loop" do
      deps_by_path = deps_by_path("S => 1 -> S -> T")

      assert find_compile_dep_chain(deps_by_path) == [
               {"S", :initial},
               {"1", :compile},
               {"S", :runtime},
               {"T", :runtime}
             ]
    end

    defp find_compile_dep_chain(deps_by_path) do
      Analyzer.find_compile_dep_chain(deps_by_path, source: "S", target: "T")
    end

    defp deps_by_path(binary) do
      binary
      |> String.split("\n")
      |> Enum.flat_map(fn line ->
        String.split(line)
        |> Enum.chunk_every(3, 2, :discard)
        |> Enum.map(fn [from, arrow, to] ->
          kind =
            case arrow do
              "->" -> :runtime
              "=>" -> :compile
            end

          {from, %Dep{kind: kind, path: to}}
        end)
      end)
      |> Enum.group_by(fn {from, _} -> from end, fn {_, dep} -> dep end)
      |> case do
        map ->
          map
          |> Map.values()
          |> Enum.flat_map(& &1)
          |> Enum.reduce(map, fn %{path: path}, map -> Map.put_new(map, path, []) end)
      end
    end
  end
end
