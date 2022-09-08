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
    @item = selectItem(request[:id])
    erb :add_element, locals: { item: @item}
  end

  get '/show' do
    if request[:item].nil?
      @error = "Błędny argument!"
      @js = ["searching-js"]
      @css = ["welcome-styles", "login-partial"]
      erb :welcome
    else
      @js = ["show-element-js"]
      @css = ["show-element-styles"]
      @item = selectItem(request[:item])
      if @item.nil?
        @error = "Błędne ID!"
      end
      erb :show_element, locals: { item: @item}
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  post '/add_element' do
    @js = ["show-element-js"]
    @css = ["show-element-styles"]
    if (check_string(request[:added_quantity]) && request[:added_quantity].to_i > 0)
      changeQuantity(request[:item_id], request[:added_quantity])
    else
      @error = "Wprowadzono niewłaściwą wartość!"
    end
    @item = selectItem(request[:item_id])
    if @item.nil?
      @error = "Błędne ID!"
    end
    erb :show_element, locals: { item: @item}
  end

  post '/find' do
    @js = ["filter-js", "searching-js"]
    @css = ["welcome-styles", "search-styles"]
    @inputVal = params[:"search-input"]||params[:"input-value"]
    @filters = params[:element]||""
    @sort_direction = params[:sort]||""
    if !params[:valuemin].nil? && params[:valuemin] != ""
      @valueMin = params[:valuemin]
    else
      @valueMin = 0
    end
    if !params[:valuemax].nil? && params[:valuemax] != ""
      @valueMax = params[:valuemax]
    else
      @valueMax = 10**12
    end
    results = detailedSearch(@inputVal, filterTab: @filters, value_min: @valueMin, value_max: @valueMax, sort_direction: @sort_direction)
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
            @css = ["login-styles"]
            @error = "Invalid password."
            erb :login
          end
        end
      end
      session.clear
      @error = 'Username or password was incorrect.'
      @css = ["login-styles"]
      erb :login
    else
      @css = ["login-styles"]
      @error = "Complete all fields on the form."
      erb :login
    end
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

  post '/create-new-item' do
    @js = ["add-element-js"]
    @css = ["add-element-styles"]
    @item = selectItem(request[:id])
    p request.params
    @newItemName = params[:"new-item-name"].strip
    @newTableName = params[:"new-table-name"].strip
    @newItemQuantity = params[:"new-item-quantity"]
    unless params[:"new-item-checkbox"].nil?
      if @newTableName.match(/\A[[:alpha:][:blank:]]+\z/).nil?
        @error = "Nazwa tabeli może składać się tylko z małych znaków a-z i spacji!"
      end
      if @newTableName == ""
        @error = "Nazwa tabeli nie może być pusta!"
      else
        all_tables.each do |tabName|
          if tabName.first_source_alias.to_human_text == @newTableName.to_database_text
            @error = "Nazwa tabeli musi być inna niż istniejące tabele!"
          end
        end
        DB.create_table :"#{@newTableName.to_database_text}" do
          primary_key :id
          String :localid
          String :name
          String :description
          float :value
          int :quantity
          String :location
          String :datasheet
          String :unit
        end
      end
    end
    if params[:element].nil? && params[:"new-item-checkbox"].nil?
      @error = "Wybierz tablę!"
    end
    if @newItemName == "" ||
      @newItemName.nil?
      @error = "Nazwa elementu nie może być pusta!"
    end
    if @newItemName.length > 30 ||
      @newTableName.length > 30
      @error = "Nazwa nie może być dłuższa niż 30 znaków."
    end
    if @newItemQuantity == ""
      @error = "Ilość nie może być pusta!"
    end
    if @newItemQuantity.to_s.match?(/[:alpha]/)
      @error = "W polu ilość mogą znajdować się tylko cyfry."
    end
    if @newItemQuantity.to_i < 0
      p @newQuantity
      @error = "Ilość nie może być ujemna!"
    end
    if params[:IdSelect].nil?
      unless params[:"new-item-localid"].nil? ||
        params[:"new-item-localid"] == ""
        @newLocalId = params[:"new-item-localid"]
      else
        @error = 'Zaznacz "AutoID", jeśli nie chcesz wpisywać!'
      end
    else
      @newLocalId = @newItemName[0..8].gsub(' ','').downcase
    end
    @countingResults = []
    all_tables.each { |tab| @countingResults << tab.where(:localid => @newLocalId).count }
    unless @countingResults.all?(0)
      @error = "Istnieje już element o podanym ID!"
    end
    erb :add_element, locals: { item: @item }
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
    @db_tables_array = all_tables
    @db_tables_array.each do |table|
      table.where(Sequel.like(:name, "#{phrase}%", case_insensitive: true))
      .or(Sequel.like(:localid, "#{phrase}%", case_insensitive: true)).limit(5).all.each do |k|
        @arr << ({name: k[:name]})
      end
    end
    return @arr
  end

  def detailedSearch(phrase, filterTab: "", value_min: 0, value_max: 10**12, sort_key: "value", sort_direction: "asc")
    @phrase = phrase.strip
    if sort_direction == "alfa" || sort_direction == "dalfa"
      @column = "name"
    end
    if @phrase.empty? then @phrase = "%" end
    @detailed_arr = []
    @part_att = []
    if sort_direction == ""
      sort_direction = "asc"
    end
    unless filterTab == ""
      @db_tables_array = [DB[:"#{filterTab}"]]
    else
      @db_tables_array = all_tables
    end
    @db_tables_array.each do |table|
      #Find by phrase no filters
      @phrase.split.each do |partPhrase|
        @part_att << table.where(Sequel.like(:name, "%#{partPhrase}%", case_insensitive: true)).or(Sequel.like(:localid, "%#{partPhrase}%", case_insensitive: true)).order(:value).all
      end
      #Common part of each subarrays
      if @part_att.length > 1
        @tempArr = @part_att[0] & @part_att.last
        @res_arr = []
        (1..@part_att.length-1).each { |el| @res_arr << @tempArr & @part_att[el] }
        @res_arr.uniq!
        @part_att = @res_arr[0]
      end
      #Value filters here
      if value_max != 10**12
        if value_max.is_a? String then value_max.strip! end
        if value_max.is_a? String
          unit = value_max[-1]
          value_max = value_max.to_i.to_database_num(unit).to_f
        end
      end
      if value_min != 0
        if value_min.is_a? String then value_min.strip! end
        if value_min.is_a? String
          unit = value_min[-1]
          value_min = value_min.to_i.to_database_num(unit).to_f
        end
      end
      if value_min > value_max
        value_min, value_max = value_max, value_min
      end
      @part_att = @part_att.flatten & table.where(value: value_min..value_max).all
      #@part_att = sortTable(@part_att, sort_direction)
      if @part_att.count > 0
        @detailed_arr << @part_att
      end
      @part_att = []
    end
    @detailed_arr = sortTable(@detailed_arr.flatten, sort_direction, @column)
    return @detailed_arr
  end

  def selectItem(item_name)
    resultTab = []
    all_tables.each do |table|
      resultTab << table.where(:localid => item_name).all
    end
    return resultTab.flatten[0]
  end

  def sortTable(arr, direction, column)
    if column.nil?
      column = "value"
    end
    if direction == "desc" || direction == "dalfa"
      return arr.sort_by{ |w| w[:"#{column}"] }.reverse
    else
      return arr.sort_by{ |w| w[:"#{column}"] }
    end
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

  def changeQuantity(item_id, added_quantity)
    all_tables.each do |table|
      unless table.where(:localid => item_id).all.empty?
        @actualQuantity = table.where(:localid => item_id).all[0][:quantity]
        @newQuantity = @actualQuantity + added_quantity.to_i
        table.where(:localid => item_id).update(quantity: @newQuantity)
      end
    end
  end

  def check_string(str)
    str !~ /\D/
  end

  run!
end
