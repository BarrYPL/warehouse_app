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
      @css = ["welcome-styles", "login-partial"]
      erb :welcome
    end
  end

  get '/login' do
    @css = ["login-styles"]
    erb :login
  end

  get '/find' do
    @js = ["searching-js", "filter-js"]
    @css = ["welcome-styles", "search-styles"]
    results = detailedSearch("")
    erb :search, locals: { results: results }
  end

  get '/add-element' do
    @js = ["add-element-js"]
    @css = ["add-element-styles"]
    erb :add_element
  end

  post '/find' do
    @js = ["filter-js", "searching-js"]
    @css = ["welcome-styles", "search-styles"]
    @inputVal = params[:"search-input"]||params[:"input-value"]
    @filters = params[:element]||""
    @sort_direction = params[:sort]||""
    if !params[:valuemin].nil? && params[:valuemin] != ""
      @valueMin = params[:valuemin].to_i
    else
      @valueMin = 0
    end
    if !params[:valuemax].nil? && params[:valuemax] != ""
      @valueMax = params[:valuemax].to_i
    else
      @valueMax = 10**12
    end
    if @valueMin > @valueMax
      @valueMin, @valueMax = @valueMax, @valueMin
    end
    results = detailedSearch(@inputVal, filterTab: @filters, valueMin: @valueMin, valueMax: @valueMax, sort_direction: @sort_direction)
    erb :search, locals: { results: results }
  end

  post '/login' do
    user_key = $usersDB.where(:username => params[:username]).all
    if !params[:username].empty? && !params[:password].empty?
      $usersDB.map do |user|
        if params[:username] == user[:username]
          pass_t = user[:password_hash]
          if test_password(params[:password], pass_t)
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
    redirect '/'
  end

  post '/quick-find' do
    if params[:phrase] == nil || params[:phrase] == ""
      @phrase = "%"
    else
      @phrase = params[:phrase]
    end
    if params[:phrase].downcase == "rafe"
      p '[{"":"<image src=\"images/easters/rafe.png\" alt=\"error\" id=\"easter-egg\"></image>"}]'
    else
      @suggestionsArr = findQuerys(@phrase)
      @suggestionsArr.uniq!
      if !@suggestionsArr.empty?
        @suggestionsArr.sort_by!(&:values)
      end
      if @suggestionsArr.length < 9
        @suggestionsArr = findQuerys(@phrase, false)
        sortByFirstChar(@suggestionsArr, @phrase)
      end
      p @suggestionsArr.uniq[0..9].to_json
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

  def detailedSearch(phrase, filterTab: "", valueMin: 0, valueMax: 10**12, sort_key: "value", sort_direction: "asc")
    @phrase = phrase.strip.gsub(/ /, '%')
    $detailedArr = []
    @partArr = []
    if sort_direction == ""
      sort_direction = "asc"
    end
    case filterTab
    when 'resistors'
      @dbTablesArray = [$resistorsDB]
    when 'capacitors'
      @dbTablesArray = [$capacitorsDB]
    when 'inductors'
      @dbTablesArray = [$inductorsDB]
    when 'others'
      @dbTablesArray = [$othersDB]
    else
      @dbTablesArray = [$capacitorsDB, $inductorsDB, $resistorsDB]
    end
    @dbTablesArray.each do |table|
      #Find by phrase no filters
      @partArr << table.where(Sequel.like(:name, "%#{@phrase}%", case_insensitive: true)).or(Sequel.like(:localid, "%#{@phrase}%", case_insensitive: true)).order(:value).all
      #Value filters here
      if valueMax != 10**12
        if valueMax.is_a? String then valueMax.strip! end
        if valueMax.is_a? String
          unit = valueMax[-1]
          valueMax = valueMax.to_i.to_database_num(unit).to_f
        end
      end
      if valueMin != 0
        if valueMin.is_a? String then valueMin.strip! end
        if valueMin.is_a? String
          unit = valueMin[-1]
          valueMin = valueMin.to_i.to_database_num(unit).to_f
        end
      end
      #p "ValueMin: #{valueMin} valueMax: #{valueMax}"
      @partArr = @partArr.flatten & table.where(value: valueMin..valueMax).all
      @partArr = sortTable(@partArr, sort_direction)
      if @partArr.count > 0
        $detailedArr << @partArr
      end
      @partArr = []
    end
    return $detailedArr.flatten.uniq
  end

  def sortTable(arr, direction)
    return arr.sort_by{ |w| if direction == "asc" then w[:value] else w[:value]*-1 end }
  end
  def sortByFirstChar(arr, phrase)
    #arr.sort_by! { |el| el.values[0] }
    regexp = Regexp.new("^" + phrase.strip)
    if arr.all? { |w| !w.values[0].match(regexp) }
      arr.sort_by!(&:values)
    else
      arr.sort_by! { |w| w.values[0].match?(regexp) ? 0 : 1 }
    end
    return arr
  end

  run!
end
