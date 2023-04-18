require_relative('app/controllers/controller')

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def test_password(password, hash)
  BCrypt::Password.new(hash) == password
end

class MyServer < Sinatra::Base
  register Sinatra::Namespace

  enable :sessions
  enable :inline_templates

  configure do
    set :run            , 'true'
    set :public_folder  , 'public'
    set :views          , 'app/views'
    set :port           , '80'
    set :bind           , '0.0.0.0'
    set :show_exceptions, 'true' #Those are errors
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

  get '/locations' do
    @css = ["locations-styles"]
    erb :locations
  end

  get '/find' do
    location = request[:loc]
    if location.nil?
      results = detailed_search("")
    else
      results = location_serch(request[:loc])
    end
    @js = ["searching-js", "filter-js"]
    @css = ["welcome-styles", "search-styles"]
    #p results
    erb :search, locals: { results: results, location: location }
  end

  get '/add-element' do
    @js = ["add-element-js"]
    @css = ["add-element-styles"]
    @item = select_item(request[:id])
    if current_user
      erb :add_element, locals: { item: @item}
    else
      redirect '/'
    end
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
      @item = select_item(request[:item])
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

  get '/delete' do
    if params[:id].nil?
      @error = "Błędny argument!"
    else
      @item = select_item(params[:id])
      #This is required to find single record!
      if @item.nil?
        @error = "Błędne ID!"
      else
        if current_user
          delete_item(params[:id])
        else
          @error = "Tylko dla zalogowanych użytkowników!"
        end
      end
    end
    @js = ["searching-js"]
    @css = ["welcome-styles", "login-partial"]
    erb :welcome
  end

  post '/edit' do\
    p params
    if params[:id].nil?
      @error = "Błędny argument!"
      @js = ["searching-js"]
      @css = ["welcome-styles", "login-partial"]
      erb :welcome
    else
      @js = ["show-element-js"]
      @css = ["show-element-styles"]
      @item = select_item(params[:id])
      if @item.nil?
        @error = "Błędne ID!"
      else
        edit_item(request.params)
      end
      @item = select_item(params[:id])
      erb :show_element, locals: { item: @item}
    end
  end

  post '/add-element' do
    @js = ["show-element-js"]
    @css = ["show-element-styles"]
    if (request[:added_quantity].to_i != 0)
      change_quantity(request[:item_id], request[:added_quantity])
    else
      @error = "Wprowadzono niewłaściwą wartość!"
    end
    @item = select_item(request[:item_id])
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
    @sortDirection = params[:sort]||""
    @location = params[:location]||""
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
    results = detailed_search(@inputVal, filterElem: @filters, valueMin: @valueMin, valueMax: @valueMax, sortDirection: @sortDirection, filterLocation: @location)
    erb :search, locals: { results: results, location: @location }
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
      p '[{"name":"<image src=\"images/easters/rafe.png\" alt=\"Rafe pedalarz xD\" id=\"easter-egg\"></image>"}]'
    else
      @suggestionsArr = find_querys(@phrase)
      @suggestionsArr.uniq!
      if !@suggestionsArr.empty?
        @suggestionsArr.sort_by!(&:values)
      end
      if @suggestionsArr.length < 9
        @suggestionsArr = find_querys(@phrase, false)
        sort_by_first_char(@suggestionsArr, @phrase)
      end
      p @suggestionsArr.uniq[0..9].to_json
    end
  end

  post '/create-new-item' do
    @js = ["add-element-js"]
    @css = ["add-element-styles"]
    @item = select_item(request[:id])
    @linkId = create_new_item_object(params)
    if @error
      erb :add_element, locals: { item: @item }
    else
      redirect "show?item=#{@linkId}"
    end
  end

  post '/multiple-delete' do
    @js = ["filter-js", "searching-js"]
    @css = ["welcome-styles", "search-styles"]
    delete_multiple_items(params)
    redirect '/find'
  end

  post '/multiple-export' do
    filename = export_to_csv(params[:items_to_export])
    send_file "./public/temp/#{filename}.csv", :filename => filename+".csv", :type => 'Application/octet-stream'
  end

  post '/qr' do
    @fileName = params[:locname].to_s
    unless File.exists?("./public/QR#{@fileName}.png")
      qrcode = RQRCode::QRCode.new("barry.multi.ovh/find?loc=#{@fileName}")
      png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 0,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: "black",
        file: nil,
        fill: "white",
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 120
      )
      IO.binwrite("./public/QR/#{@fileName}.png", png.to_s)
    end
    send_file "./public/QR/#{@fileName}.png", :filename => @fileName+".png", :type => 'Application/octet-stream'
  end

  get '/new-location' do
    erb :new_location
  end

  namespace '/api' do
    before do
      content_type 'application/json'
    end

    helpers do
      def halt_if_not_found!
        halt 402, {'Content-Type' => 'application/json'}, { error: 'Item Not Found' }.to_json unless item
      end

      def item
        @item ||= select_item(params[:id])
      end

      def json_params
        begin
          JSON.parse(request.body.read)
        rescue
          halt 400, { error:'Invalid JSON' }.to_json
        end
      end
    end

    get '/items' do
      @name = params[:name] ? params[:name] : ""
      @items = detailed_search(@name)
      if @items.length == 0
        @items = [{ error: 'Item Not Found'}]
      end
      return @items.uniq.to_json
    end

    get '/items/:id' do
      halt_if_not_found!
      return @item.to_json
    end

    post '/items' do
      @linkId = create_new_item_object(params)
      if @linkId.is_a? Numeric
        response.headers['Location'] = "/api/items/#{@linkId}"
        status 201
      else
        halt(422, @linkId.to_json)
      end
    end

    patch '/items/:id' do
      halt_if_not_found!
      if @item
        itemID = edit_item(request.params)
        @item = select_item(itemID)
        @item = @item.nil? ? itemID : @item
        return @item.to_json
      else
        status 422
      end
    end

    post '/add-element' do
      @item = select_item(request[:item_id])
      if @item.nil?
        @error = "Błędne ID!"
        return {error: @error}.to_json
      end
      if (request[:added_quantity].to_i != 0)
        @item = change_quantity(request[:item_id], request[:added_quantity])
      else
        @error = "Wprowadzono niewłaściwą wartość!"
        return {error: @error}.to_json
      end
      return @item.to_json
    end

    delete '/items/:id' do
      halt_if_not_found!
      delete_item(params[:id]) if @item
      status 204
    end

    get '/quick-find' do
      if params[:phrase] == nil || params[:phrase].gsub(" ","") == ""
        @phrase = "%"
      else
        @phrase = params[:phrase]
      end
      if params[:phrase].downcase == "rafe"
        p '[{"name":"<image src=\"images/easters/rafe.png\" alt=\"Rafe pedalarz xD\" id=\"easter-egg\"></image>"}]'
      else
        @suggestionsArr = find_querys(@phrase)
        @suggestionsArr.uniq!
        if !@suggestionsArr.empty?
          @suggestionsArr.sort_by!(&:values)
        end
        if @suggestionsArr.length < 9
          @suggestionsArr = find_querys(@phrase, false)
          sort_by_first_char(@suggestionsArr, @phrase)
        end
        return @suggestionsArr.uniq[0..9].to_json
      end
    end

    post '/login' do
      if !params[:username].empty? && !params[:password].empty?
        $usersDB.map do |user|
          if params[:username] == user[:username]
            pass_t = user[:password_hash]
            if test_password(params[:password], pass_t)
              session.clear
              session[:user_id] = user[:id]
              @error = "Successful login on: #{params[:username]}"
              #Logowanie jednak musi zwracać API Key
              return {error: @error}.to_json
            else
              @error = "Invalid password."
            end
          end
        end
        session.clear
        @error = 'Username or password was incorrect.'
      else
        @error = "Complete all fields on the form."
      end
      return {error: @error}.to_json
    end

  end

  helpers do
    def current_user
      if session[:user_id]
        $usersDB.where(:id => session[:user_id]).all[0]
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
