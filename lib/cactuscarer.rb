require_relative "cactuscarer/user.rb"
require_relative "cactuscarer/cactus.rb"
require_relative "cactuscarer/cactuslist.rb"
require_relative "cactuscarer/commandhandler.rb"

module CactusCarer
	DB = Mongo::Client.new(ENV["mongourl"], database: "cactus_care_skill")[:users]

	module CustomErrors
		class IdError < StandardError; end
		class UnownedError < StandardError; end
		class DuplicateError < StandardError; end
	end
end