module CactusCarer
	class CactusList
		def initialize(cacti=[])
			@cacti = cacti.map { |cactus| Cactus.new(cactus) }
		end

		def list_names
			@cacti.map { |cactus| cactus.name }
		end
		
		def include?(cactus_name)
			@cacti.any? { |cactus| cactus.name == cactus_name }
		end

		def remove(cactus_name)
			@cacti.reject! { |cactus| cactus.name == cactus_name }
		end

		def length
			@cacti.length
		end
		
		def [](cactus_name)
			@cacti.select { |cactus| cactus.name == cactus_name}[0]
		end

		def <<(cactus)
			@cacti << cactus
		end

		def to_a
			@cacti
		end

		def each
			@cacti.each { |cactus| yield cactus }
		end

		def map
			@cacti.map { |cactus| yield cactus }
		end
	end
end