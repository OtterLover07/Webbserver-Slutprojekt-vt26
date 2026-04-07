require 'sinatra/reloader'
require 'bcrypt'


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

############### database interactions ###############
def get_pool(item_name: nil, id: nil, filter: nil, variables: [])
  if item_name
    db.execute("SELECT * FROM pool WHERE name LIKE ?",item_name).first
  elsif id
    db.execute("SELECT * FROM pool WHERE id=?",id).first
  elsif filter
    db.execute("SELECT * FROM pool WHERE #{filter}", variables)
  else
    db.execute("SELECT * FROM pool ORDER BY
                CASE rarity
                  WHEN 'common' THEN 0
                  WHEN 'uncommon' THEN 1
                  WHEN 'rare' THEN 2
                  WHEN 'epic' THEN 3
                  WHEN 'legendary' THEN 4
                  WHEN 'mythical' THEN 5
                END")
  end
end

def add_item(name, rarity)
  db.execute("INSERT OR IGNORE INTO pool (name, rarity) VALUES (?,?)",[name, rarity])
end

def update_item(name, rarity, id)
  db.execute("UPDATE pool SET name=?, rarity=? WHERE id=?",[name, rarity, id])
end

def delete_row(target_table, id)
  db.execute "DELETE FROM #{target_table} WHERE id=?",id
end

def get_user(user_id: nil, username: nil)
  if user_id
    db.execute('SELECT * FROM users WHERE user_id=?', user_id).first
  elsif username
    db.execute('SELECT * FROM users WHERE username=?', username.downcase).first
  else
    return nil
  end
end

def register_user(username, password, admin)
  pwd_digest = BCrypt::Password.create(password)
  admin ? insert_admin = 1 : insert_admin = 0
  db.execute('INSERT INTO users (username, pwd_digest, admin) VALUES (?, ?, ?)', [username.downcase, pwd_digest, insert_admin])
end

def password_correct?(password, pwd_digest)
  BCrypt::Password.new(pwd_digest) == password
end

def get_login_attempts(user_id)
  db.execute("SELECT login_attempts FROM users WHERE user_id=?", user_id).first["login_attempts"]
end

def increase_login_attempts(user_id)
  db.execute("UPDATE users SET login_attempts = (users.login_attempts + 1) WHERE user_id=?", user_id)
end

def impose_timeout(user_id)
  timeout_until = Time.now.to_i + 300
  db.execute("UPDATE users SET timeout_until=? WHERE user_id=?", [timeout_until, user_id])
end

def store_item(item, user_id)
  if prefix = item["prefix"]
    db.execute "INSERT OR IGNORE INTO pulled_items VALUES (?, ?, 0, ?)", [item["id"],user_id, prefix]
    db.execute "UPDATE pulled_items SET amount=(amount+1) WHERE item_id LIKE ? AND owner_id LIKE ? AND prefix LIKE ?", [item["id"],user_id, prefix]
  else
    db.execute "INSERT OR IGNORE INTO pulled_items VALUES (?, ?, 0, 'null')", [item["id"],user_id]
    db.execute "UPDATE pulled_items SET amount=(amount+1) WHERE item_id LIKE ? AND owner_id LIKE ? AND prefix LIKE 'null'", [item["id"],user_id]
  end
end

def get_inventory(user_id)
  db.execute("SELECT * FROM pulled_items 
        INNER JOIN pool ON pulled_items.item_id = pool.id
        WHERE owner_id LIKE ? ORDER BY
        CASE rarity
          WHEN 'common' THEN 0
          WHEN 'uncommon' THEN 1
          WHEN 'rare' THEN 2
          WHEN 'epic' THEN 3
          WHEN 'legendary' THEN 4
          WHEN 'mythical' THEN 5
        END", user_id)
end

def delete_inventory_item(item_id, user_id)
  db.execute "UPDATE pulled_items SET amount=(amount-1) WHERE item_id LIKE ? AND owner_id LIKE ?", [item_id, user_id]
  db.execute "DELETE FROM pulled_items WHERE item_id LIKE ? AND owner_id LIKE ? AND amount<=0",[item_id, user_id]
end

def login_timeout?(user_id)
  return (Time.now.to_i <= db.execute("SELECT timeout_until FROM users WHERE user_id=?", user_id).first["timeout_until"])
end

def first_user
  db.execute("SELECT user_id FROM users ORDER BY user_id ASC LIMIT 1").first
end
def last_user
  db.execute("SELECT user_id FROM users ORDER BY user_id DESC LIMIT 1").first
end

##################### functions #####################
def pull_item
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

  item = get_pool(filter: "rarity LIKE ? ORDER BY RANDOM() LIMIT 1", variables: [rarity]).first
  prefix = gen_prefix
  item["prefix"] = prefix
  return item
end

def gen_prefix
  prefixes = ["Hale's Own", "Extremely Rad", "Mom's Favourite", "Freshly Cut", "Weird", "Peckin' Awesome", "Prefixed", "Prototype", "Sanitized"]
  if rand <= 0.0003
    return prefixes[rand(0..(prefixes.length - 1))]
  else
    return nil
  end
end