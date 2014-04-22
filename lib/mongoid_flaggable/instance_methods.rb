module Mongoid
	module Flaggable
		module InstanceMethods
			def add_flag(flag)
				self.flag_array = [] if flag_array.nil?
				flag_array << flag.to_s
				flag_array.uniq!
			end

			def add_flag!(flag)
				add_flag(flag)
				save
			end

			def remove_flag(flag)
				return if flag_array.nil?
				flag_array.delete(flag.to_s)
			end

			def remove_flag!(flag)
				remove_flag(flag)
				save
			end

			def clear_flags
				self.flag_array = []
			end

			def clear_flags!
				clear_flags
				save
			end

			def flags
				flag_array || []
			end

			def all_flags?(*p_flags)
				p_flags = p_flags.flatten.map(&:to_s).uniq.sort
				(p_flags - flags).empty?
			end
			alias_method :flag?, :all_flags?
			alias_method :flags?, :all_flags?

			def any_flags?(*p_flags)
				p_flags = p_flags.flatten.map(&:to_s)
				(flags & p_flags).any?
			end
			alias_method :any_flag?, :any_flags?
		end
	end
end
