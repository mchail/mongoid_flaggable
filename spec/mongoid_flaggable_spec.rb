require 'spec_helper'

class MyModel
	include Mongoid::Document
	include Mongoid::Flaggable

	field :val, type: Integer, default: nil
end

describe Mongoid::Flaggable do
	it "should be able to save a model with Mongoid::Flaggable included" do
		model = MyModel.create
		model.persisted?.should be_true
	end

	it "should include the flag_array field in the model" do
		MyModel.fields.keys.should include "flag_array"
	end

	it "should have an empty flag_array field by default" do
		model = MyModel.new
		model.flag_array.should be_nil
	end

	it "should return an empty array via the flags accessor" do
		model = MyModel.new
		model.flags.should eq []
	end

	describe "class methods" do
		describe "flag_frequency" do
			it "should return an empty hash if no models have flags" do
				MyModel.flag_frequency.should eq Hash.new
			end

			it "should count frequencies" do
				m1 = MyModel.create
				m1.add_flag! :flag1
				m2 = MyModel.create
				m2.add_flag! :flag2
				m3 = MyModel.create
				m3.add_flag! :flag2

				freq = MyModel.flag_frequency
				freq['flag1'].should == 1
				freq['flag2'].should == 2
			end

			it "should correctly unwind multiple flags on one document" do
				m1 = MyModel.create
				m1.add_flag! :flag1
				m2 = MyModel.create
				m2.add_flag! :flag2
				m3 = MyModel.create
				m3.add_flag! :flag1
				m3.add_flag! :flag2

				freq = MyModel.flag_frequency
				freq['flag1'].should == 2
				freq['flag2'].should == 2
			end
		end

		describe "finders and counters" do
			before(:each) do
				MyModel.create.add_flag!(:flag1)
				MyModel.create.add_flag!(:flag2)
				m = MyModel.create
				m.add_flag! :flag1
				m.add_flag! :flag2
			end

			it "should find instances of a single flag" do
				MyModel.by_flag(:flag1).count.should == 2
			end

			it "should find instances of multiple (any) flags" do
				MyModel.by_any_flags(:flag1, :flag2).count.should == 3
				MyModel.by_any_flags(%w(flag1 flag2)).count.should == 3
			end

			it "should find instances of multiple (all) flags" do
				MyModel.by_all_flags(:flag1, :flag2).count.should == 1
				MyModel.by_all_flags(%w(flag1 flag2)).count.should == 1
			end

			it "should count flags correctly" do
				MyModel.flag_count(:flag1).should == 2
				MyModel.flag_count(:flag1, :flag2).should == 1
				MyModel.flag_count(%w(flag1 flag2)).should == 1
			end
		end

		it "should be able to return distinct flags on model" do
			MyModel.create.add_flag! :flag1
			MyModel.create.add_flag! :flag2
			MyModel.create.add_flag! :flag3
			MyModel.create.add_flag! :flag3
			MyModel.create.add_flag! :flag4

			MyModel.distinct_flags.sort.should == %w(flag1 flag2 flag3 flag4)
		end

		describe "bulk operations" do
			it "should be able to add flag to all models" do
				10.times{ MyModel.create }
				MyModel.bulk_add_flag! :flag1
				MyModel.flag_count(:flag1).should == 10
			end

			it "should be able to add flag to multiple models with specific criteria" do
				10.times{|i| MyModel.create(val: i) }
				MyModel.bulk_add_flag! :flag1, {:val.lt => 4}
				MyModel.where(val: 0).first.flag?(:flag1).should be_true
				MyModel.where(val: 9).first.flag?(:flag1).should be_false
				MyModel.flag_count(:flag1).should == 4
			end

			it "should be able to delete flag from entire collection" do
				10.times{ MyModel.create.add_flag! :flag1 }
				MyModel.flag_count(:flag1).should == 10
				MyModel.bulk_remove_flag! :flag1
				MyModel.flag_count(:flag1).should == 0
			end

			it "should be able to delete flag from multiple models with specific criteria" do
				10.times{|i| MyModel.create(val: i).add_flag! :flag1 }
				MyModel.bulk_remove_flag! :flag1, {:val.gte => 4}
				MyModel.where(val: 0).first.flag?(:flag1).should be_true
				MyModel.where(val: 9).first.flag?(:flag1).should be_false
				MyModel.flag_count(:flag1).should == 4
			end
		end
	end

	describe "instance methods" do
		let(:unsaved) do
			MyModel.new
		end
		let(:saved) do
			MyModel.create
		end
		let(:unsaved_with_flag) do
			m = MyModel.new
			m.add_flag(:flag1)
			m
		end
		let(:saved_with_flag) do
			m = MyModel.create
			m.add_flag!(:flag1)
			m
		end
		let(:dual_citizenship) do
			m = MyModel.create
			m.add_flag!(:flag1)
			m.add_flag!(:flag2)
			m
		end

		it "should be able to add a flag to unpersisted model without saving" do
			m = unsaved
			m.persisted?.should be_false
			m.flags.should == []
			m.add_flag :flag1
			m.flags.should == %w(flag1)
			m.persisted?.should be_false
		end

		it "should be able to add a flag to a persisted model without saving" do
			m = saved
			m.persisted?.should be_true
			m.flags.should == []
			m.add_flag :flag1
			m.flags.should == %w(flag1)
			m.reload
			m.flags.should == []
		end

		it "should save an unpersisted model when add_flag! is called" do
			m = unsaved
			m.persisted?.should be_false
			m.add_flag!(:flag1)
			m.persisted?.should be_true
		end

		it "should save a persisted model when add_flag! is called" do
			m = saved
			m.persisted?.should be_true
			m.flags.should == []
			m.add_flag!(:flag1)
			m.reload
			m.flags.should == %w(flag1)
		end

		it "should be able to add with either string or symbol" do
			m1 = MyModel.create
			m1.add_flag! :flag1
			m2 = MyModel.create
			m2.add_flag! "flag1"
			m1.flags.should eq m2.flags
		end

		it "should add flags idempotently" do
			m = saved
			m.add_flag(:flag1)
			m.flags.should == %w(flag1)
			m.add_flag(:flag1)
			m.flags.should == %w(flag1)
		end

		it "should not return error when removing a flag that isn't set" do
			m = unsaved
			m.flags.should == []
			m.remove_flag :not_there
			m.flags.should == []
		end

		it "should be able to remove a flag" do
			m = unsaved_with_flag
			m.flags.should == %w(flag1)
			m.remove_flag :flag1
			m.flags.should be_empty
		end

		it "should be able to remove a flag with a string" do
			m = unsaved_with_flag
			m.flags.should == %w(flag1)
			m.remove_flag("flag1")
			m.flags.should be_empty
		end

		it "should be able to remove a flag with a symbol" do
			m = unsaved_with_flag
			m.flags.should == %w(flag1)
			m.remove_flag(:flag1)
			m.flags.should be_empty
		end

		it "should be able to remove a flag without saving" do
			m = unsaved_with_flag
			m.persisted?.should be_false
			m.remove_flag(:flag1)
			m.persisted?.should be_false
		end

		it "should be able to remove a flag from a persisted document and immediately save" do
			m = saved_with_flag
			m.flags.should == %w(flag1)
			m.remove_flag! :flag1
			m.reload
			m.flags.should be_empty
		end

		it "should remove flags idempotently" do
			m = dual_citizenship
			m.flags.should == %w(flag1 flag2)
			m.remove_flag(:flag2)
			m.flags.should == %w(flag1)
			m.remove_flag(:flag2)
			m.flags.should == %w(flag1)
		end

		it "should be able to clear all flags" do
			m = dual_citizenship
			m.flags.size.should be > 0
			m.clear_flags!
			m.flags.should be_empty
			m.reload
			m.flags.should be_empty
		end

		it "should be able to return flags after they are set" do
			m = saved
			m.add_flag(:flag1)
			m.flags.should == %w(flag1)
			m.add_flag(:flag2)
			m.flags.should == %w(flag1 flag2)
		end

		it "should be able to test for the existence of a single flag" do
			m = saved
			m.flag?(:flag1).should be_false

			m = saved_with_flag
			m.flag?(:flag1).should be_true
		end

		it "should be able to test for the existence of multiple (OR) flags" do
			m = saved_with_flag
			m.any_flags?(:flag1, :flag2).should be_true
			m.any_flags?(%w(flag1 flag2)).should be_true
			m.any_flags?(:flag2, :flag3).should be_false
			m.any_flags?(%w(flag2 flag3)).should be_false
		end

		it "should be able to test for the existence of multiple (AND) flags" do
			m = dual_citizenship
			m.all_flags?(:flag1, :flag2).should be_true
			m.all_flags?(%w(flag1 flag2)).should be_true
			m.all_flags?(:flag2, :flag3).should be_false
			m.all_flags?(%w(flag2 flag3)).should be_false
		end
	end
end
