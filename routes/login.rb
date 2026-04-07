require 'sinatra/reloader'

get('/register') do
    slim :'login/register'
end

post('/register') do
    redirect_to, username, admin = params[:redirect], params[:username], (params[:admin] == "true" ? true : false)
    password, confirm_password = params[:password], params[:pwd_confirm]

    username_check = get_user(username: username)
    if !username_check
        if password == confirm_password
            register_user(username, password, admin)
            session[:user_id] = get_user(username: username)['user_id']
            session[:admin] = true if admin
            if redirect_to
                redirect redirect_to
            else
                redirect '/'
            end
        else
            flash[:pwd_fail] = "Passwords must match."
            redirect('/register')
        end
    else
        flash[:username_fail] = "Username already taken"
        redirect('/register')
    end
end

get '/login' do
    @redirect_to = params[:redirect]
    slim :'login/login'
end

post '/login' do
    redirect_to = params[:redirect]

    password, username = params[:pwd], params[:username]
    if !user = get_user(username: username)
        flash[:login_fail] = "Login unsucessful: user does not exist"
        redirect '/login'
    end
    user_id = user['user_id']

    if login_timeout?(user_id)
        flash[:login_fail] = "This account has had too many attempted logins. Please wait 5 minutes and try again."
        redirect '/login'
    end
    
    session[:start_attempts] = {} if !session[:start_attempts]

    if !session[:start_attempts][user_id]
      session[:start_attempts][user_id] = get_login_attempts(user_id)
    end

    if password_correct?(password, user['pwd_digest'])
        session[:user_id] = user_id
        session[:admin] = true if user['admin'] == 1
    else
        flash[:login_fail] = "Login unsucessful: Incorrect password"

        @attempts = get_login_attempts(user_id)
        increase_login_attempts(user_id)
        impose_timeout(user_id) if @attempts > session[:start_attempts][user_id] + 10

        redirect '/login'
    end
    redirect redirect_to
end

post('/logout') do
    session.clear
    redirect('/')
end