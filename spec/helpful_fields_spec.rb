require File.expand_path('spec/spec_helper')

describe HelpfulFields do
  it "has a VERSION" do
    HelpfulFields::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe 'core ext' do
    describe :value_from_nested_key do
      it "accesses normal keys" do
        {:x => 1}.value_from_nested_key(:x).should == 1
        {'x' => 1}.value_from_nested_key('x').should == 1
      end

      it "can access deep values" do
        {'x' => {'y' => {'z' => 1}}}.value_from_nested_key('x[y][z]').should == 1
      end

      it "returns nil for unfound keys" do
        {'x' => 1}.value_from_nested_key('x[y][z]').should == nil
      end

      it "can get values from xxx[]" do
        {'x' => {'y' => [1,2,3]}}.value_from_nested_key('x[y][]').should == [1,2,3]
        {'x' => [1,2,3]}.value_from_nested_key('x[]').should == [1,2,3]
      end

      it "does not mess up with escaped =" do
        {'x=y' => 1}['x=y'].should == 1
      end
    end
  end
end
