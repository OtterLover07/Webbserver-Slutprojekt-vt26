require 'sinatra/reloader'


before '/inventory/:uid*' do
    id = params[:uid].to_i
    if !get_user(user_id: id)
        redirect "/inventory/#{id+1}"
    elsif id < min = first_user['user_id']
        redirect "/inventory/#{min}"
    elsif id > max = last_user['user_id']
        redirect "/inventory/#{max}"
    end
end

get '/inventory' do
    redirect "/inventory/#{session[:user_id]}"
end

get '/inventory/:uid' do
    user_id = params[:uid]
    @user = get_user(user_id: user_id)
    @inventory = get_inventory(user_id)
    @browse = [user_id.to_i+1, user_id.to_i-1]
    slim :'inventory/index'
end

post '/inventory/:uid/delete/:item_id' do
    user_id, to_delete = params[:uid], params[:item_id]
    redirect "/noaccess" if !((user_id.to_s == session[:user_id].to_s) || session[:admin])
    delete_inventory_item(to_delete, user_id)
    redirect "/inventory/#{user_id}"
end