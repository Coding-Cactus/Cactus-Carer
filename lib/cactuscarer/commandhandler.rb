module CactusCarer
	class CommandHandler
		def initialize(app_id=nil)
			@app_id = app_id
		end

		def handle(req)
			rteurn say "no" if req["session"]["application"]["applicationId"] != @app_id

			return say "Hello!" if req["request"]["type"] == "LaunchRequest"

			@intent = req["request"]["intent"]
			@slots = @intent["slots"]
			@intent_name = @intent["name"]

			puts req

			user_id = req["session"]["user"]["userId"]
			@user = User.new(user_id, new_user: !User.exist?(user_id))
			
			say exec_intent
		end

		private

		def say(text)
			{
				version: "1.0",
				response: {
					outputSpeech: {
						type: "PlainText",
						text: text,   
					}
				}
			}.to_json
		end

		def exec_intent
			case @intent_name
			when "SetHemisphere"
				set_hemisphere
			when "ListCacti"
				list_cacti
			when "NewCactus"
				new_cactus
			when "ChangeName"
				change_name
			when "RemoveCactus"
				remove_cactus
			when "CactusNeeds"
				cactus_needs
			when "WateredCactus"
				watered_cactus
			when "FedCactus"
				fed_cactus
			when "WateredRecently"
				watered_recently
			when "FedRecently"
				fed_recently
			when "ToDo"
				todo
			when "NextWater"
				next_water
			when "NextFeed"
				next_feed
			when "GetUserCode"
				give_user_code
			when "DeleteData"
				delete_user
			else
				"I'm sorry, I do not know what to reply to that."
			end
		end


		def set_hemisphere
			hemisphere = @slots["hemisphere"]["value"]
			hemisphere = hemisphere[0...hemisphere.length-3] if hemisphere[(hemisphere.length-3)...hemisphere.length] == "ern"

			return "That is not a hemisphere, please say either: North, or South." unless ["north", "south"].include?(hemisphere)

			@user.set_hemisphere(hemisphere)

			"Okay, I have saved your hemisphere as #{hemisphere}."
		end

		def list_cacti
			names = @user.cacti.list_names
			num_cacti = @user.cacti.length

			return "You currently do not have any cacti." if num_cacti == 0
			
			if num_cacti == 1
				"The cactus I am taking care of is #{names[0]}."
			else
				"The cacti in my list to take care of are: #{names[0...num_cacti-1].join(", ")}, and #{names[num_cacti-1]}."
			end
		end

		def new_cactus
			cactus_name = @slots["name"]["value"].downcase

			return "You already have a cactus called #{cactus_name}. Please try to be more creative." if @user.cacti.include?(cactus_name)

			@user.add_cactus(cactus_name)

			"Cool! I have added #{cactus_name} to my list of cacti to take care of."
		end

		def change_name
			old_name = @slots["old_name"]["value"].downcase
			new_name = @slots["new_name"]["value"].downcase

			return "You don't have a cactus called #{old_name}." unless @user.cacti.include?(old_name)
			return "I have kept #{old_name}'s name as #{old_name}" if old_name == new_name
			return "You already have a cactus called #{new_name}" if @user.cacti.include?(new_name)

			@user.change_cactus_name(old_name, new_name)

			"I have saved #{old_name}'s name as #{new_name}"
		end


		def remove_cactus
			cactus_name = @slots["name"]["value"].downcase

			return "You din't have a cactus called #{cactus_name} anyway." unless @user.cacti.include?(cactus_name)

			@user.remove_cactus(cactus_name)

			"#{cactus_name} has been removed from my list of cacti to take care of."
		end

		def cactus_needs
			cactus_name = @slots["name"]["value"].downcase

			return "You don't have a cactus called #{cactus_name}." unless @user.cacti.include?(cactus_name)

			return "It is not currently growing season, so #{cactus_name} should only be watered once their soil is completely dry. They do not need to be fed until the growing season starts again in spring." unless @user.is_growing_season?

			cactus = @user.cacti[cactus_name]

			cactus.needs_water? ? "You should water #{cactus.needs_food? ? "and feed " : ""}#{cactus_name}." : "#{cactus_name} doesn't need anything currently."
		end

		def watered_cactus
			cactus_name = @slots["name"]["value"].downcase

			return "You don't have a cactus called #{cactus_name}." unless @user.cacti.include?(cactus_name)
			
			@user.watered_cactus(cactus_name)

			return "Okay, it is currently not growing season, so the next time #{cactus_name} should be watered is when their soil is completely dry. They do not need to be fed until the growing season starts again in spring." unless @user.is_growing_season?

			cactus = @user.cacti[cactus_name]

			"Okay, the next time #{cactus_name} needs to be watered is in around #{cactus.next_watering} day#{cactus.next_watering == 1 ? "" : "s"}. The next time they will need feeding is #{cactus.next_feeding == cactus.next_watering ? "also" : ""} in around #{cactus.next_feeding} day#{cactus.next_feeding == 1 ? "" : "s"}."
		end

		def fed_cactus
			cactus_name = @slots["name"]["value"].downcase

			return "You don't have a cactus called #{cactus_name}." unless @user.cacti.include?(cactus_name)
			
			@user.watered_cactus(cactus_name, fed: true)

			return "Okay, it is currently not growing season, so #{cactus_name} will not need to be fed again until the growing season starts again in spring.. The next time they should be watered is only when their soil is completely dry. " unless @user.is_growing_season?

			cactus = @user.cacti[cactus_name]

			"Okay, the next time #{cactus_name} needs to be fed is in around #{cactus.next_feeding} day#{cactus.next_feeding == 1 ? "" : "s"}. The next time they will need watering is #{cactus.next_feeding == cactus.next_watering ? "also" : ""} in around #{cactus.next_watering} day#{cactus.next_watering == 1 ? "" : "s"}."
		end

		def watered_recently
			cactus_name = @slots["name"]["value"].downcase

			return "You don't have a cactus called #{cactus_name}." unless @user.cacti.include?(cactus_name)
			return "I'm sorry, you needed to have said how many days ago you watered #{cactus_name}" if @slots["num"] == nil

			days_ago = @slots["num"]["value"].to_i

			@user.watered_cactus(cactus_name, time: Time.now.to_i - days_ago * 86400)

			return "Okay, it is currently not growing season, so the next time #{cactus_name} should be watered is when their soil is completely dry. They do not need to be fed until the growing season starts again in spring." unless @user.is_growing_season?

			cactus = @user.cacti[cactus_name]

			"Okay, the next time #{cactus_name} needs to be watered is #{cactus.next_watering == 0 ? "today" : "in around #{cactus.next_watering} day#{cactus.next_watering == 1 ? "" : "s"}"}. The next time they will need feeding is #{cactus.next_feeding == cactus.next_watering ? "also" : ""} #{cactus.next_feeding == 0 ? "today" : "in around #{cactus.next_feeding} day#{cactus.next_feeding == 1 ? "" : "s"}"}."
		end

		def fed_recently
			cactus_name = @slots["name"]["value"].downcase
			
			return "You don't have a cactus called #{cactus_name}." unless @user.cacti.include?(cactus_name)
			return "I'm sorry, you needed to have said how many days ago you fed #{cactus_name}" if @slots["num"] == nil

			days_ago = @slots["num"]["value"].to_i

			@user.watered_cactus(cactus_name, time: Time.now.to_i - days_ago * 86400, fed: true)

			return "Okay, it is currently not growing season, so #{cactus_name} will not need to be fed again until the growing season starts again in spring.. The next time they should be watered is only when their soil is completely dry. " unless @user.is_growing_season?

			cactus = @user.cacti[cactus_name]

			"Okay, the next time #{cactus_name} needs to be fed is #{cactus.next_feeding == 0 ? "today" : "in around #{cactus.next_feeding} day#{cactus.next_feeding == 1 ? "" : "s"}"}. The next time they will need watering is #{cactus.next_feeding == cactus.next_watering ? "also" : ""} #{cactus.next_watering == 0 ? "today" : "in around #{cactus.next_watering} day#{cactus.next_watering == 1 ? "" : "s"}"}."
		end


		def todo
			return "There are no cacti in my list to take care of." if @user.cacti.length == 0

			return "It is not currently growing season, so your cacti should only be watered once their soil is completely dry. They do not need to be fed until the growing season starts again in spring." unless @user.is_growing_season?
			
			msg = ""
			@user.cacti.each { |cactus| msg += "water #{cactus.needs_food? ? "and feed" : ""} #{cactus.name}. " if cactus.needs_water? }
			msg == "" ? "You don't need to do anything for your cacti today." : "Today you should " + msg
		end

		def next_water
			return "There are no cacti in my list to take care of." if @user.cacti.length == 0

			return "It is not currently growing season, so your cacti should only be watered once their soil is completely dry." unless @user.is_growing_season?

			next_cactus = nil
			num_days = nil
			@user.cacti.each do |cactus|
				if num_days == nil || num_days > cactus.next_watering
					next_cactus = cactus.name
					num_days = cactus.next_watering
				end
			end

			"The next cactus that needs to be watered is #{next_cactus} #{num_days == 0 ? "today" : "in #{num_days} day#{num_days == 1 ? "" : "s"}"}."
		end

		def next_feed
			return "There are no cacti in my list to take care of." if @user.cacti.length == 0

			return "It is not currently growing season, so your cacti do not need to be fed until it starts again in the spring." unless @user.is_growing_season?

			next_cactus = nil
			num_days = nil
			@user.cacti.each do |cactus|
				if num_days == nil || num_days > cactus.next_feeding
					next_cactus = cactus.name
					num_days = cactus.next_feeding
				end
			end

			"The next cactus that needs to be fed is #{next_cactus} #{num_days == 0 ? "today" : "in #{num_days} day#{num_days == 1 ? "" : "s"}"}."
		end

		def give_user_code
			"Your user code is #{@user.user_code.split("").join(", ")}."
		end

		def delete_user
			if @intent["confirmationStatus"] == "CONFIRMED"
				@user.delete
				"Your data has been deleted."
			else
				"Okay, I did not delete your data."
			end
		end
	end
end