
defmodule Sender do
  alias Spawn
  def sendem() do
    pid1 = spawn(Spawn,:greet,[])
    pid2 = spawn(Spawn,:greet,[])
    send(pid1,{self(),:fred})
    send(pid2,{self(),:tom})

    get_reply()

    get_reply()

  end

  def get_reply() do
    receive do
      msg ->
        IO.inspect( msg)
      end

  end
end

defmodule Spawn do
  def greet() do
    receive do
      {sender, token} -> send(sender, {:ok,token})
      IO.puts(" got #{token}")
      greet()
    end
  end
end
