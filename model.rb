require 'sinatra/reloader'
############### database interactions ###############
def user(user_id)
    db.execute('SELECT * FROM users WHERE user_id=?', user_id).first
end
def login_attempts(user_id)
    db.execute("SELECT login_attempts FROM users WHERE user_id=?", user_id).first["login_attempts"]
end

def store_pulled_item(item, user_id)
    if prefix = item["prefix"]
        db.execute "INSERT OR IGNORE INTO pulled_items VALUES (?, ?, 0, ?)", [item["id"],user_id, prefix]
        db.execute "UPDATE pulled_items SET amount=(amount+1) WHERE item_id LIKE ? AND owner_id LIKE ? AND prefix LIKE ?", [item["id"],user_id, prefix]
    else
        db.execute "INSERT OR IGNORE INTO pulled_items VALUES (?, ?, 0, 'null')", [item["id"],user_id]
        db.execute "UPDATE pulled_items SET amount=(amount+1) WHERE item_id LIKE ? AND owner_id LIKE ? AND prefix LIKE 'null'", [item["id"],user_id]
    end
end


##################### functions #####################
def pull_item(amount = 1)
    items = []
    amount.times do
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
        prefix = gen_prefix
        item["prefix"] = prefix
        items << item
    end
    items
end

def gen_prefix
  prefixes = ["Hale's Own", "Extremely Rad", "Mom's Favourite", "Freshly Cut", "Weird", "Peckin' Awesome", "Prefixed", "Prototype", "Sanitized"]
  if rand <= 0.0003
    return prefixes[rand(0..(prefixes.length - 1))]
  else
    return nil
  end
end

def login_timeout?(user)
    if Time.now.to_i <= db.execute("SELECT timeout_until FROM users WHERE user_id=?", user["user_id"]).first["timeout_until"]
        true
    end
    false
end

def log_start_attempts(user)
    if !session[:start_attempts]
        session[:start_attempts] = {}
    end
    if !session[:start_attempts][user["user_id"]]
        session[:start_attempts][user["user_id"]] = login_attempts(user["user_id"])
    end
    p session[:start_attempts]
    p Time.now.to_i
end
