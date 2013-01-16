# API ROUTES

before '/api*' do
  content_type 'application/json'
end

get '/api/user/:id' do
  content_type :json
  user = User.get(params[:id])
  user.to_json
end

put '/api/user/:id' do 
  puts 'PUT'
  user = User.get(params[:id])
  user.update(json_data)
  user.to_json
end

get '/api/auth/logged_in' do
  if current_user
    status 200
  else
    status 400
  end
end


## AUTHENTICATION

get '/auth/:name/callback' do
  auth = request.env["omniauth.auth"]
  puts auth
  user = User.first_or_create({ :uid => auth["uid"]}, {
    :uid => auth["uid"],
    :nickname => auth["info"]["nickname"], 
    :name => auth["info"]["name"],
    :created_at => Time.now })
  session[:user_id] = user.id
  redirect '/'
end

# any of the following routes should work to sign the user in: 
["/sign_in/?", "/signin/?", "/log_in/?", "/login/?", "/sign_up/?", "/signup/?"].each do |path|
  get path do
    redirect '/auth/twitter'
  end
end

# either /log_out, /logout, /sign_out, or /signout will end the session and log the user out
["/sign_out/?", "/signout/?", "/log_out/?", "/logout/?"].each do |path|
  get path do
    session[:user_id] = nil
    redirect '/'
  end
end



## CONTENT PAGES

get '/' do
  if current_user
    # The following line just tests to see that it's working.
    #   If you've logged in your first user, '/' should load: "1 ... 1";
    #   You can then remove the following line, start using view templates, etc.
    #current_user.id.to_s + " ... " + session[:user_id].to_s
    # @users = User.all
    @current_user = current_user
  end
  haml :index
end

get '/people/' do
  @users = User.all
  halt 404 if @users.nil?
  haml :people
end

get '/:nickname' do
  if current_user
    @current_user = current_user
  end
  @user = User.first(:nickname => params[:nickname])
  halt 404 if @user.nil?
  haml :user
end





