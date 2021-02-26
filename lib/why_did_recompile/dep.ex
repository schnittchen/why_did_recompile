defmodule WhyDidRecompile.Dep do
  @moduledoc """
  A dependency. `kind` is in `[:compile, :export, :runtime]`.
  """

  defstruct [:path, :kind]
end
