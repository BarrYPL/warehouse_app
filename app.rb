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

  configure do
    set :run            , 'true'
    set :public_folder  , 'public'
    set :views          , 'app/views'
  end

  get '/' do
    if current_user
      @js = ["searching-js"]
      @css = ["welcome-styles"]
      erb :welcome
    else
      @js = ["searching-js"]
      @css = ["welcome-styles"]
      erb :welcome
      #@css = ["login-styles"]
      #erb :login
    end
  end

  post '/find' do
    @js = ["searching-js"]
    @css = ["welcome-styles", "search-styles"]
    results = detailedSearch(params[:"search-input"])
    erb :search, locals: { results: results }
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

  post '/quick-find' do
    if params[:phrase] != "undefined" && params[:phrase] != nil
      if params[:phrase] != ""
        if params[:phrase].downcase == "rafe"
          p '[{"":"<image src=\"images/easters/rafe.png\" alt=\"error\" id=\"easter-egg\"></image>"}]'
        else
          @suggestionsArr = findQuerys(params[:phrase])
          @suggestionsArr.uniq!
          if !@suggestionsArr.empty?
            @suggestionsArr.sort_by!(&:values)
          end
          if @suggestionsArr.length < 9
            @suggestionsArr = findQuerys(params[:phrase], false)
            sortByFirstChar(@suggestionsArr, params[:phrase])
          end
          p @suggestionsArr.uniq[0..9].to_json
        end
      end
    end
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

  def findQuerys(phrase, restricted=true)
    if restricted == false
      phrase.gsub(/ /, '%')
      phrase = "%" + phrase
    end
    @arr = []
    @dbTablesArray = [$capacitorsDB, $inductorsDB, $resistorsDB]
    @dbTablesArray.each do |table|
      table.where(Sequel.like(:name, "#{phrase}%", case_insensitive: true))
      .or(Sequel.like(:localid, "#{phrase}%", case_insensitive: true)).limit(9).all.each do |k|
        @arr << ({name: k[:name]})
      end
    end
    return @arr
  end

  def detailedSearch(phrase)
    phrase.gsub(/ /, '%')
    @arr = []
    @dbTablesArray = [$capacitorsDB, $inductorsDB, $resistorsDB]
    @dbTablesArray.each do |table|
      @arr << table.where(Sequel.like(:name, "%#{phrase}%", case_insensitive: true)).all
      @arr << table.where(Sequel.like(:localid, "%#{phrase}%", case_insensitive: true)).all
    end
    @arr.each do |el|
      el.sort_by!{ |w| w[:value] }
    end
    return @arr.flatten
  end

  def sortByFirstChar(arr, phrase)
    #arr.sort_by! { |el| el.values[0] }
    regexp = Regexp.new("^" + phrase)
    arr.sort_by! { |w| w.values[0].match?(regexp) ? 0 : 1 }
    return arr
  end

  run!
end
