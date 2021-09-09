module CactusCarer
	class User
		attr_reader :user_id, :user_code, :cacti, :hemisphere

		def initialize(user_id, is_user_code: false, new_user: false)
			raise CustomErrors::IdError, "New users must be created with their amazon_id" if is_user_code && new_user

			if new_user
				@user_id = user_id
				@user_code = gen_user_code
				@hemisphere = "north"
				@cacti = CactusList.new

				DB.insert_one({
					_id: @user_id,
					user_code: @user_code,
					hemisphere: @hemisphere,
					cacti: []
				})
			else
				data = !is_user_code ? DB.find({_id: user_id}).first : DB.find({user_code: user_id}).first
				
				if data != nil
					@user_id = data[:_id]
					@user_code = data[:user_code]
					@cacti = CactusList.new(data[:cacti])
					@hemisphere = data[:hemisphere]
				else
					@user_id = nil
				end				
			end
		end

		def set_hemisphere(hemisphere)
			DB.update_one({_id: @user_id}, {"$set" => {hemisphere: hemisphere}})

			puts hemisphere
			@hemisphere = hemisphere
		end

		def is_growing_season?
			([3, 4, 5, 6, 7, 8].include?(Time.new.month) && @hemisphere == "north") || ([9, 10, 11, 12, 1, 2].include?(Time.new.month) && @hemisphere == "south")
		end

		def add_cactus(cactus_name)
			raise CustomErrors::DuplicateError, "User already has a cactus with the name #{cactus_name}" if @cacti.include?(cactus_name)

			data = {
				name: cactus_name,
				last_watered: 0,
				last_fed: 0
			}

			DB.update_one({_id: @user_id}, {"$push" => {cacti: data}})

			@cacti << Cactus.new(data)
		end

		def change_cactus_name(old_name, new_name)
			return nil if old_name == new_name

			raise CustomErrors::UnownedError, "User does not own a cactus with the name #{old_name}" unless @cacti.include?(old_name)
			raise CustomErrors::DuplicateError, "Cactus names must be unique" if @cacti.include?(new_name)
			
			DB.update_one({_id: @user_id, "cacti.name" => old_name}, {"$set" => {"cacti.$.name" => new_name}})

			@cacti[old_name].change_name(new_name)
		end

		def remove_cactus(cactus_name)
			raise CustomErrors::UnownedError, "User does not own a cactus with the name #{cactus_name}" unless @cacti.include?(cactus_name)

			DB.update_one({_id: @user_id}, {"$pull" => {cacti: {name: cactus_name}}})

			@cacti.remove(cactus_name)
		end

		def watered_cactus(cactus_name, time: Time.new.to_i, fed: false)
			raise CustomErrors::UnownedError, "User does not own a cactus with the name #{cactus_name}" unless @cacti.include?(cactus_name)

			day = (time / 86400.0).floor * 86400 # rounds down to the start of the day

			cactus = @cacti[cactus_name]

			last_watered = cactus.last_watered
			last_fed = cactus.last_fed
			
			last_watered = day if !fed || (fed && day > cactus.last_watered)
			last_fed = day if fed

			DB.update_one({_id: @user_id, "cacti.name" => cactus_name}, {"$set" => {"cacti.$.last_watered" => last_watered, "cacti.$.last_fed" => last_fed}})
			
			cactus.water(day, feed: fed, update_watered: !fed || (fed && day > cactus.last_watered))
		end

		def delete
			DB.delete_one({_id: @user_id})
		end


		def self.exist?(user_id)
			DB.find({_id: user_id}).first != nil
		end

		private

		def gen_user_code
			code = Array.new(6) { (rand(65..90)).chr }.join("")
			until DB.find({user_code: code}).first == nil
				code = Array.new(6) { (rand(65..90)).chr }.join("")
			end
			code
		end
	end
end