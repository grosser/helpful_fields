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

  describe 'TagHelper' do
    def render(text, params={})
      view = ActionView::Base.new
      view.stub!(:params).and_return params.with_indifferent_access
      view.render(:inline => text)
    end

    describe :params_text_field_tag do
      it "renders empty" do
        render('<%= params_text_field_tag :xxx %>').
          should == "<input id=\"xxx\" name=\"xxx\" type=\"text\" />"
      end

      it "grabs the value from params" do
        render('<%= params_text_field_tag :xxx %>', 'xxx' => 1).
          should == "<input id=\"xxx\" name=\"xxx\" type=\"text\" value=\"1\" />"
      end

      it "renders with nested params" do
        render('<%= params_text_field_tag "foo[bar]" %>').
          should == "<input id=\"foo_bar\" name=\"foo[bar]\" type=\"text\" />"
      end

      it "grabs the value from nested params" do
        render('<%= params_text_field_tag "foo[bar]" %>', :foo => {:bar => 2}).
          should == "<input id=\"foo_bar\" name=\"foo[bar]\" type=\"text\" value=\"2\" />"
      end
    end
  end
end
