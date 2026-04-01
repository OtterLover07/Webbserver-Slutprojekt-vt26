require 'sinatra/reloader'

before '/pool*' do
    if !session[:admin]
        redirect '/noaccess'
    end
end

get '/pool' do
    @pool = get_pool
    slim :'pool/index'
end

get '/pool/new' do
    slim :'pool/new'
end

post '/new' do
    name, rarity = params[:name], params[:rarity]
    flash[:pool_message] = "Could Not Create (name already exists)" if get_pool(item_name: name) != nil
    add_item(name, rarity)
    redirect '/pool'
end

get '/pool/:id/edit' do
  id = params[:id].to_i
  @item = get_pool(id: id)
  slim :'pool/edit'
end

post '/pool/edit' do
    name, rarity, id = params[:name], params[:rarity], params[:id]
    update_item(name, rarity, id)
    redirect '/pool'
end

post '/pool/delete' do
    to_delete = params[:id].to_i
    delete_row("pool", to_delete)
    redirect '/pool'
end