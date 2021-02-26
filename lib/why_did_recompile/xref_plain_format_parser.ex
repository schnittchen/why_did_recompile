defmodule WhyDidRecompile.XrefPlainFormatParser do
  alias WhyDidRecompile.Dep

  def call(binary) do
    String.split(binary, "\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.chunk_while(
      [],
      fn line, acc ->
        case line do
          <<_>> <> "-- " <> _rest ->
            {:cont, [line | acc]}

          _else ->
            {:cont, acc, [line]}
        end
      end,
      fn acc -> {:cont, acc, nil} end
    )
    |> Enum.reject(&(&1 == []))
    |> Enum.map(fn chunk ->
      [head | rest] = Enum.reverse(chunk)

      rest
      |> Enum.map(fn line ->
        case String.split(line, " ") do
          [_arrow, path] ->
            %Dep{path: path, kind: :runtime}

          [_arrow, path, "(export)"] ->
            %Dep{path: path, kind: :export}

          [_arrow, path, "(compile)"] ->
            %Dep{path: path, kind: :compile}
        end
      end)
      |> case do
        deps ->
          {head, deps}
      end
    end)
    |> Map.new()
  end
end
