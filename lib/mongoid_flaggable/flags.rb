module Mongoid
	module Flaggable
		class Flags
			def initialize(model_class)
				@model_class = model_class
			end
		end
	end
end
