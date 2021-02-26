# WhyDidRecompile

Why did some files get recompiled after I made a nonsubstantial change to a single file?

As an Elixir project becomes larger, recompilation during development can become slower and slower,
because compile time dependencies creep in. Elixir's own `mix xref` task can help to analyze the
situation, but identifying the dependencies involved can still be tedious.

This package contains a mix task that can answer the initial question.

## Installation

Install as an archive:

```
mix archive.install github schnittchen/why_did_recompile
```

<!---
If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `why_did_recompile` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:why_did_recompile, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/why_did_recompile](https://hexdocs.pm/why_did_recompile).
-->

## Usage

```
mix why_did_recompile --compiled=lib/my_project/a.ex --changed=lib/my_project/b.ex
```

will print out, if possible, a dependency chain from a.ex to b.ex that requires a.ex to recompile
when b.ex changes.

## Scope

Currently, export dependencies are treated as runtime dependencies.
