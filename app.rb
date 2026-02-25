require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

# require_relative 'model.rb'

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
   
    item = db.execute("SELECT * FROM pool WHERE rarity LIKE ? ORDER BY RANDOM() LIMIT 1", rarity).first
    if user_id = session[:uid] 
      db.execute "INSERT OR IGNORE INTO pulled_items VALUES (?, 0, ?)", [item["id"],user_id]
      db.execute("UPDATE pulled_items SET amount = (amount + 1) WHERE (item_id,owner_id) LIKE (?,?)", [item["id"],user_id])
    end
    @loot << item
    # @loot << number.to_s
  end
  slim :pull
end


Dir["C:/Users/melker.willforss/Documents/Webbserverprogrammering/Webbserver-Slutprojekt-vt26/routes/*.rb"].each {|file| require file }
# require_relative 'errors.rb'
# require_relative 'login.rb'
# require_relative 'pool.rb'