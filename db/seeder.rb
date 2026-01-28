require 'sqlite3'

db = SQLite3::Database.new("db/database.db")


def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS pool')
end

def create_tables(db)
  db.execute('CREATE TABLE pool (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE NOT NULL,
              rarity TEXT CHECK (rarity IN ("common", "uncommon", "rare", "epic", "legendary", "mythical"))
              )')
end

def populate_tables(db)
  db.execute('INSERT INTO pool (name, rarity) VALUES ("Sword of Souls", "common")')
  db.execute('INSERT INTO pool (name, rarity) VALUES ("Maid Outfit", "uncommon")')
  db.execute('INSERT INTO pool (name, rarity) VALUES ("Banana", "rare")')
  db.execute('INSERT INTO pool (name, rarity) VALUES ("Cool Sunglasses", "epic")')
  db.execute('INSERT INTO pool (name, rarity) VALUES ("AK47", "legendary")')
  db.execute('INSERT INTO pool (name, rarity) VALUES ("Trump\'s Last Braincell", "mythical")')
end


seed!(db)





