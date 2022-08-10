require_relative('app\controllers\controller')

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def test_password(password, hash)
  BCrypt::Password.new(hash) == password
end

class MyServer < Sinatra::Base

  enable :sessions
  enable :inline_templates

  $usersDB = DB[:users]
  $filesDB = DB[:files]

  configure do
    set :run            , 'true'
    set :public_folder  , 'public'
    set :views          , 'app/views'
  end

  get '/' do
    if current_user
      @css = ["welcome-styles"]
      erb :welcome
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  post '/login' do
    user_key = $usersDB.where(:username => params[:username]).all
    if !user_key.empty?
      user_key = user_key[0][:twofaKey]
      totp = ROTP::TOTP.new(user_key, issuer: "Barrys Site")
    end
    if !params[:username].empty? && !params[:password].empty?
      $usersDB.map do |user|
        if params[:username] == user[:username]
          pass_t = user[:password_hash]
          if test_password(params[:password], pass_t) || !totp.verify(params[:password]).nil?
            session.clear
            session[:user_id] = user[:id]
            redirect '/'
          else
            @error = "Invalid password."
            erb :login
          end
        end
      end
      session.clear
      @error = 'Username or password was incorrect.'
      redirect '/login'
    else
      @error = "Complete all fields on the form."
      redirect '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  helpers do
    def current_user
      if session[:user_id]
         $usersDB.each do |user|
           session[:user_id] == user[:id]
         end
      else
        nil
      end
    end
  end

  not_found do
    status 404
    redirect '/'
  end

  run!
end
