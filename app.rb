require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'sinatra/flash'

require_relative 'model'

enable :sessions

helpers do
  def db(hash = true)
    return @db if @db

    @db = SQLite3::Database.new "db/database.db"
      if hash
        @db.results_as_hash = true
      else
        @db.results_as_hash = false
      end
    
      return @db
  end

  def rarities
    return ["common","uncommon","rare","epic","legendary","mythical"]
  end
end

get '/' do
  slim(:main)
end

get '/pull' do
  @loot = pull_item(4)
  if user_id = session[:user_id]
    @loot.each { |item| store_pulled_item(item, user_id)}
  end
  slim :pull
end

path = __dir__ + "/routes/*.rb"
Dir[path].each {|file| require file }
