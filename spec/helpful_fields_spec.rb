require File.expand_path('spec/spec_helper')

describe HelpfulFields do
  it "has a VERSION" do
    HelpfulFields::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end
end
