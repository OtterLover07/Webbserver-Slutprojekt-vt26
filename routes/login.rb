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
            session[:user_id] = db.execute('SELECT user_id FROM users WHERE username=?', username.downcase).first['user_id']
            session[:admin] = true if admin == "1"
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
    pwd, username = params[:pwd], params[:username]
    if !user = db.execute('SELECT * FROM users WHERE username=?', username.downcase).first
        flash[:login_fail] = "Login unsucessful: user does not exist"
        redirect '/login'
    end
    # p user
    if login_timeout?(user)
        flash[:login_fail] = "This account has had too many attempted logins. Please wait 5 minutes and try again."
        redirect '/login'
    end
    log_start_attempts(user)

    if BCrypt::Password.new(user['pwd_digest']) == pwd
        session[:user_id] = user['user_id']
        session[:admin] = true if user['admin'] == 1
    else
        flash[:login_fail] = "Login unsucessful: Incorrect password"

        db.execute("UPDATE users SET login_attempts = (users.login_attempts + 1) WHERE user_id=?", user["user_id"])
        @attempts = db.execute("SELECT login_attempts FROM users WHERE user_id=?", user["user_id"]).first["login_attempts"]
        if @attempts >= session[:start_attempts][user["user_id"]] + 10
            timeout_until = Time.now.to_i + 300
            db.execute("UPDATE users SET timeout_until=? WHERE user_id=?", [timeout_until, user["user_id"]])
        end

        redirect '/login'
    end
    redirect redirect_to
end

post('/logout') do
    session.clear
    redirect('/')
end