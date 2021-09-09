require "json"
require 'mongo'
require "sinatra"
require "alexa_verifier"
require_relative "lib/cactuscarer.rb"

enable :sessions
set :bind, "0.0.0.0"

CH = CactusCarer::CommandHandler.new(ENV["appId"])

post "/" do
    r = request
    begin
        AlexaVerifier.valid!(request)
    rescue
        return 400
    end
    CH.handle(JSON.parse(r.body.read))
end


get "/" do
	@user = CactusCarer::User.new(session[:user_code], is_user_code: true) if session.include?(:user_code)
	erb :index
end

get "/login" do
	erb :login
end

post "/login" do
	user_code = params[:user_code]

	return 400 if user_code == nil || user_code.length != 6

	user = CactusCarer::User.new(user_code, is_user_code: true)

	return "Incorrect user code" if user.user_id == nil

	session[:user_code] = user_code
	"success"
end

get "/logout" do
	session.delete(:user_code)
	redirect "/"
end

get "/dashboard" do
	return erb :login unless session.include?(:user_code)

	@user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	erb :dashboard
end


post "/api/newcactus" do
	user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	return 401 if user.user_id == nil

	cactus_name = params[:cactus_name]

	return 400 if cactus_name == nil

	cactus_name.downcase!

	return "Cactus names must be unique" if user.cacti.include?(cactus_name)

	user.add_cactus(cactus_name)
	"success"

end

post "/api/changename" do
	user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	return 401 if user.user_id == nil

	old_name = params[:old_name]
	new_name = params[:new_name]

	return 400 if old_name == nil || old_name.length == 0 || new_name == nil || new_name.length == 0

	old_name.downcase!
	new_name.downcase!

	return nil if old_name == new_name
	return 400 if !user.cacti.include?(old_name)
	return "Cactus names must be unique" if user.cacti.include?(new_name)

	user.change_cactus_name(params[:old_name], params[:new_name])
	"success"
end

post "/api/removecactus" do
	user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	return 401 if user.user_id == nil

	cactus_name = params[:cactus_name]

	return 400 if cactus_name == nil

	cactus_name.downcase!

	return 400 unless user.cacti.include?(cactus_name)

	user.remove_cactus(cactus_name)
	200
end

post "/api/watercactus" do
	user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	return 401 if user.user_id == nil

	cactus_name = params[:cactus_name]

	return 400 if cactus_name == nil

	cactus_name.downcase!

	return 400 unless user.cacti.include?(cactus_name)

	user.watered_cactus(cactus_name)
	cactus = user.cacti[cactus_name]
	{
		next_water: cactus.next_watering,
		next_feed: cactus.next_feeding
	}.to_json
end

post "/api/feedcactus" do
	user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	return 401 if user.user_id == nil

	cactus_name = params[:cactus_name]

	return 400 if cactus_name == nil

	cactus_name.downcase!

	return 400 unless user.cacti.include?(cactus_name)

	user.watered_cactus(cactus_name, fed: true)
	cactus = user.cacti[cactus_name]
	{
		next_water: cactus.next_watering,
		next_feed: cactus.next_feeding
	}.to_json
end

post "/api/changehemisphere" do
	user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	return 401 if user.user_id == nil

	hemisphere = params[:hemisphere]

	return 400 if hemisphere == nil

	hemisphere.downcase!

	return 400 unless ["north", "south"].include?(hemisphere)

	user.set_hemisphere(hemisphere)
	200
end

post "/api/deletedata" do
	user = CactusCarer::User.new(session[:user_code], is_user_code: true)

	return 401 if user.user_id == nil

	user.delete
	session.delete(:user_code)
	200
end


get "/privacy" do
	"The only data cactus carer collects is data necessary for its operation. This includes and is limited to: a unique user ID associated with your Amazon account but not linked to your Amazon account (no data of you Amazon account can be aquired from such ID), a unique user code generated by cactus carer, your provided cactus names, and the dates they were last watered and fed. You can also tell cactus carer which hemisphere you live in, in order to get accurate growing season information. Your data is not shared with any thrid parties or visible to anyone outside of cactus carer. If you wish for your data to be deleted, you can ask alexa through the phrase 'Alexa, tell cactus carer to delete all my data'. You can also delete all of you data through the cactus carer website: https://cactus-carer.codingcactus.repl.co." 
end

get "/terms" do
	"Don't misuse the service such as sending large amounts of requests in short spaces of time."
end