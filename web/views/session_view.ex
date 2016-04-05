  
defmodule ReactiveServer.SessionView do
	use ReactiveServer.Web, :view
	
	def render("new.json", assigns) do
		Poison.encode!(assigns.users)
  end
end
