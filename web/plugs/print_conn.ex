defmodule ReactiveServer.Plugs.PrintConn do
  
  def init(default), do: default

  def call(conn, _) do
  	IO.inspect(conn)
  	conn
  end

end
