require 'bcrypt'
require 'sinatra/reloader'

get('/register') do
    slim :'login/register'
end

post('/register') do
    redirect_to = params[:redirect]
    username = params[:username]
    password, confirm_password = params[:password], params[:pwd_confirm]
    admin = ((params[:admin] == "true" ? "1" : "0"))

    username_check = db.execute('SELECT user_id FROM users WHERE username=?', username.downcase)
    if username_check.empty?
        if password == confirm_password
            pwd_digest = BCrypt::Password.create(password)
            db.execute('INSERT INTO users (username, pwd_digest, admin) VALUES (?, ?, ?)', [username.downcase, pwd_digest, admin])
            session[:user_id] = db.execute('SELECT user_id FROM users WHERE username=?', username.downcase).first
            session[:admin] = true if admin == "1"
            if redirect_to
                redirect redirect_to
            else
                redirect '/'
            end
        else
            session[:pwd_fail] = "Passwords must match."
            redirect('/register')
        end
    else
        session[:username_fail] = "Username already taken"
        redirect('/register')
    end
end

get '/login' do
    @redirect_to = params[:redirect]
    slim :'login/login'
end

post('/login') do
    redirect_to = params[:redirect]
    pwd, username = params[:pwd], params[:username]
    if !user = db.execute('SELECT * FROM users WHERE username=?', username.downcase).first
        flash[:login_fail] = "Login unsucessful: user does not exist"
        redirect '/login'
    end
    # p user

    if BCrypt::Password.new(user['pwd_digest']) == pwd
        session[:user_id] = user['user_id']
        session[:admin] = true if user['admin'] == 1
    else
        flash[:login_fail] = "Login unsucessful: Incorrect password"
        redirect '/login'
    end
    redirect redirect_to
end

post('/logout') do
    session.clear
    redirect('/')
end