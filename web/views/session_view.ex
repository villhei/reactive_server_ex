  
defmodule ReactiveServer.SessionView do
	use ReactiveServer.Web, :view
	
	def render("token.json", %{user: user}) do
		{:ok, jwt, _ } = Guardian.encode_and_sign(user)
		%{code: 200,
			message: "Login succesful", 
			jwt_token: jwt
		}
  end
	
	def render("new.json", assigns) do
		Poison.encode!(assigns.users)
  end
end
