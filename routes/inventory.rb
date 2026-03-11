require 'sinatra/reloader'

# before '/inventory*' do
#     if !session[:user_id]
#         redirect '/noaccount'
#     end
# end

get '/inventory' do
    redirect "/inventory/#{session[:user_id]}"
end

get '/inventory/:uid' do
    user_id = params[:uid]
    @user = db.execute('SELECT * FROM users WHERE user_id=?', user_id).first
    @inventory = db.execute("SELECT * FROM pulled_items 
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
    slim :'inventory/index'
end

post '/inventory/:uid/delete/:item_id' do
    user_id, to_delete = params[:uid], params[:item_id]

    if !((user_id.to_s == session[:user_id].to_s) || session[:admin])
        redirect "/noaccess"
    end

    db.execute "UPDATE pulled_items SET amount=(amount-1) WHERE item_id LIKE ? AND owner_id LIKE ?", [to_delete, user_id]
    db.execute "DELETE FROM pulled_items WHERE item_id LIKE ? AND owner_id LIKE ? AND amount<=0",[to_delete, user_id]

    redirect "/inventory/#{user_id}"
end