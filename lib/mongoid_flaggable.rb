require "mongoid"
require "mongoid_flaggable/instance_methods"
require "mongoid_flaggable/class_methods"

module Mongoid
	module Flaggable
		include InstanceMethods

		def self.included(base)
			base.extend(ClassMethods)
			setup(base)
		end

		private

		def self.setup(base)
			base.field :flag_array, type: Array, default: nil
			base.index({
				flag_array: 1
			}, {
				background: true,
				sparse: true
			})
		end
	end
end
