defmodule WhyDidRecompile.XrefPlainFormatParserTest do
  use ExUnit.Case, async: true

  alias WhyDidRecompile.{XrefPlainFormatParser, Dep}

  test "returns deps by path" do
    output = """
    lib/why_did_recompile.ex
    lib/why_did_recompile/dep.ex
    lib/why_did_recompile/xref_plain_format_parser.ex
    `-- lib/why_did_recompile/dep.ex (compile)
    """

    result = XrefPlainFormatParser.call(output)

    expected = %{
      "lib/why_did_recompile.ex" => [],
      "lib/why_did_recompile/dep.ex" => [],
      "lib/why_did_recompile/xref_plain_format_parser.ex" => [
        %Dep{kind: :compile, path: "lib/why_did_recompile/dep.ex"}
      ]
    }

    assert result == expected
  end
end
