
node(:auth) do
  if User.current.logged?
    if @access_token
      { type: 'oauth2', uid: User.current.id, token: @access_token.token }
    else
      { type: 'user', uid: User.current.id }
    end
  elsif @current_client
    { type: 'client', uid: @current_client.identifier }
  else
    { type: 'anonymous' }
  end
end
