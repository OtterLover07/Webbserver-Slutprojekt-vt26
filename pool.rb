require 'sinatra/reloader'

before '/pool*' do
    if !session[:admin]
        redirect '/noaccess'
    end
end

get '/pool' do
    @pool = db.execute("SELECT * FROM pool ORDER BY
        CASE rarity
          WHEN 'common' THEN 0
          WHEN 'uncommon' THEN 1
          WHEN 'rare' THEN 2
          WHEN 'epic' THEN 3
          WHEN 'legendary' THEN 4
          WHEN 'mythical' THEN 5
        END")
    slim :'pool/index'
end

get '/pool/new' do
    slim :'pool/new'
end

post '/new' do
    item = [params[:name], params[:rarity]]

    db.execute("INSERT INTO pool (name, rarity) VALUES (?,?)",item)
    redirect '/'
end

get '/pool/:id/edit' do

end

post '/pool/edit' do

end

get '/pool/delete' do
    to_delete = params[:id].to_i

    db.execute "DELETE FROM pool WHERE id=?",to_delete
    redirect '/pools'
end