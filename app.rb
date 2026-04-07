require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'sinatra/flash'
also_reload 'model'

require_relative 'model'

enable :sessions

# liten kommentar så jag kan göra en sista push

get '/' do
  slim(:main)
end

get '/pull' do
  @loot = []
  4.times { @loot << pull_item }
    
  if user_id = session[:user_id]
    @loot.each { |item| store_item(item, user_id)}
  end
  slim :pull
end

path = __dir__ + "/routes/*.rb"
Dir[path].each {|file| require file }
