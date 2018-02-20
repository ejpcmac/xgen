defmodule <%= @mod %> do
  @moduledoc """
  Documentation for <%= @mod %>.
  """

  @doc """
  Hello world.

  ## Examples

      iex> <%= @mod %>.hello
      :world

  """
  @spec hello :: :world
  def hello do
    :world
  end
end
