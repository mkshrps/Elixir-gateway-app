defmodule Spawn do
  def greet() do
    receive do
      {sender, token} -> send(sender, {:ok,token})
      greet()
    end
  end
end
