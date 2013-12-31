module Mongoid
	module Flaggable
		module ClassMethods
			def flag_frequency
				aggregation = collection.aggregate([
					{
						'$match' => {
							'flag_array' => {
								'$ne' => nil
							}
						}
					},
					{
						'$project' => {
							'flag_array' => 1
						}
					},
					{
						'$unwind' => '$flag_array'
					},
					{
						'$group' => {
							'_id' => '$flag_array',
							'count' => {
								'$sum' => 1
							}
						}
					}
				])
				aggregation.map!(&:values)
				aggregation.sort_by! do |value|
					value.last * -1
				end
				Hash[aggregation]
			end

			def by_all_flags(*flags)
				flags.flatten!
				where(:flag_array.all => flags)
			end
			alias_method :by_flag, :by_all_flags
			alias_method :by_flags, :by_all_flags

			def by_any_flags(*flags)
				flags.flatten!
				where(:flag_array.in => flags)
			end

			def flag_count(*flags)
				flags.flatten!
				if flags.size == 1
					where(:flag_array => flags.first).count
				else
					by_all_flags(flags).count
				end
			end

			def bulk_add_flag!(flag, conditions = {})
				where(conditions).add_to_set(:flag_array, flag.to_s)
			end

			def bulk_remove_flag!(flag, conditions = {})
				where(conditions).pull(:flag_array, flag.to_s)
			end

			def distinct_flags
				distinct :flag_array
			end
		end
	end
end
