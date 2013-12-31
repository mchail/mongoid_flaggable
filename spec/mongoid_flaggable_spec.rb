require 'spec_helper'

describe Mongoid::Flaggable do
	it "should be able to save a model with Mongoid::Flaggable included" do
		class MyModel
			include Mongoid::Document
			include Mongoid::Flaggable
		end

		model = MyModel.create
		model.persisted?.should be_true
	end
end
