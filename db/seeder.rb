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
  # db.execute('DROP TABLE IF EXISTS pool')
  # db.execute('DROP TABLE IF EXISTS users') 
  db.execute('DROP TABLE IF EXISTS pulled_items') 
end

def create_tables(db)
  db.execute('CREATE TABLE IF NOT EXISTS pool (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE NOT NULL,
              rarity TEXT CHECK (rarity IN ("common", "uncommon", "rare", "epic", "legendary", "mythical"))
              )')
  db.execute('CREATE TABLE IF NOT EXISTS users (
              user_id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TINYTEXT UNIQUE NOT NULL,
              pwd_digest TEXT NOT NULL,
              admin BOOLEAN DEFAULT 0)')
  db.execute('CREATE TABLE IF NOT EXISTS pulled_items (
              item_id INTEGER, 
              owner_id INTEGER,
              amount INTEGER,
              prefix TEXT,
              FOREIGN KEY(item_id) REFERENCES pool(id),
              FOREIGN KEY(owner_id) REFERENCES users(user_id),
              UNIQUE (item_id, owner_id, prefix)
              )')
end

def populate_tables(db)
  db.execute('INSERT OR IGNORE INTO pool (name, rarity) VALUES ("Sword of Souls", "common")')
  db.execute('INSERT OR IGNORE INTO pool (name, rarity) VALUES ("Maid Outfit", "uncommon")')
  db.execute('INSERT OR IGNORE INTO pool (name, rarity) VALUES ("Banana", "rare")')
  db.execute('INSERT OR IGNORE INTO pool (name, rarity) VALUES ("Cool Sunglasses", "epic")')
  db.execute('INSERT OR IGNORE INTO pool (name, rarity) VALUES ("AK47", "legendary")')
  db.execute('INSERT OR IGNORE INTO pool (name, rarity) VALUES ("Trump\'s Last Braincell", "mythical")')

  db.execute('INSERT OR IGNORE INTO users (username, pwd_digest, admin) VALUES ("admin", "$2a$12$sU6i5aEftHnuhG.6rE9G9O9BflEdAvhUY7/s56M4oYoRYaQ2OoNWK", 1)')
end


seed!(db)





