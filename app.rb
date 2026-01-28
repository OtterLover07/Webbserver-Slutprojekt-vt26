require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

require_relative 'login.rb'

def db(hash = true)
return @db if @db

@db = SQLite3::Database.new("db/database.db")
  if hash
    @db.results_as_hash = true
  else
    @db.results_as_hash = false
  end

  return @db
end

get('/') do
  slim(:main)
end

get('/pull') do
  @loot = []
  # if (1.0...0.5) === 0.8994041638438267
  4.times do
    number = Random.new.rand
    if number <= 1.0/1000
      rarity = "mythical"
    elsif number <= 1.0/250
      rarity = "legendary"
    elsif number <= 1.0/50
      rarity = "epic"
    elsif number <= 1.0/25
      rarity = "rare"
    elsif number <= 1.0/5
      rarity = "uncommon"
    else
      rarity = "common"
    end
   
    item = db.execute("SELECT * FROM pool WHERE rarity LIKE ? LIMIT 1", rarity).first
    @loot << item
    # @loot << number.to_s
  end
  slim(:pull)
end

get('/pool') do
  @pool = db.execute("SELECT * FROM pool ORDER BY rarity")
  slim(:'pool/index')
end