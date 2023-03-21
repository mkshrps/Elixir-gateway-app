defmodule TrackerSup do
  use Supervisor


  def init(state) do
     child = [{SupervisorTracker,state }]
    Supervisor.start_link(child, strategy: :one_for_one)

 end
end

