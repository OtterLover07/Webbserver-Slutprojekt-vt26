get '/noaccess' do
  redirect "/pool" if session[:admin]
  slim :'errors/noaccess'
end