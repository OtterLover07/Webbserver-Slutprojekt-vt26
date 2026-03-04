get '/noaccess' do
  redirect "/pool" if session[:admin]
  slim :'errors/noaccess'
end
get '/noaccount' do
  redirect "/inventory" if session[:uid]
  slim :'errors/noaccount'
end