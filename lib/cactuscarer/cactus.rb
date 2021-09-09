module CactusCarer
	class Cactus
		attr_reader :name, :last_watered, :last_fed

		@@WATER_INTERVAL = 7
		@@FEED_INTERVAL = 30

		def initialize(data)
			@name = data[:name]
			@last_watered = data[:last_watered]
			@last_fed = data[:last_fed]
		end

		def change_name(new_name)
			@name = new_name
		end

		def needs_water?
			next_watering == 0
		end

		def needs_food?
			next_feeding == 0
		end

		def water(time=Time.now.to_i, feed: false, update_watered: true)			
			@last_watered = time if update_watered
			@last_fed = time if feed
		end

		def next_watering
			days = @@WATER_INTERVAL - (Time.now.to_i - @last_watered) / 86400
			days < 0 ? 0 : days
		end

		def next_feeding
			raw_days = @@FEED_INTERVAL - (Time.now.to_i - @last_fed) / 86400
			water_days = ((raw_days <= 0 ? 1 : raw_days) / @@WATER_INTERVAL.to_f).ceil * @@WATER_INTERVAL - (@@WATER_INTERVAL - next_watering) # syncing water and feed day
			water_days += @@WATER_INTERVAL if water_days < raw_days
			water_days
		end

		def to_h
			{
				name: @name, 
				last_watered: @last_watered,
				last_fed: @last_fed
			}
		end
	end
end