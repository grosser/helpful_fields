require File.expand_path('spec/spec_helper')

describe HelpfulFields do
  def render(text, params={})
    if ActionPack::VERSION::MAJOR > 2
      text = text.gsub('<% form_for :user, nil,', '<%= form_for @user, :as => :user,')
    end

    view = ActionView::Base.new
    view.stub!(:params).and_return params.with_indifferent_access
    view.stub!(:protect_against_forgery?).and_return false
    result = view.render(:inline => text)
    result = result.gsub("accept-charset=\"UTF-8\" ","")
    result = result.gsub(%r{<div .*?</div>},"")
    result = result.gsub('class="user_new" id="user_new" ',"")
    assert_id_and_for_match(result)
    result
  end

  def assert_id_and_for_match(html)
    if html.include?(' for=') and html.include?(' id=')
      id = html.match(/ id="(.*?)"/)[1]
      _for = html.match(/ for="(.*?)"/)[1]
      id.should_not == nil
      id.should == _for
    end
  end

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

    describe :params_text_area_tag do
      it "renders with value" do
        render('<%= params_text_area_tag "foo[bar]" %>', :foo => {:bar => 2}).
          should == "<textarea id=\"foo_bar\" name=\"foo[bar]\">2</textarea>"
      end
    end

    describe :params_hidden_field_tag do
      it "renders with value" do
        render('<%= params_hidden_field_tag "foo[bar]" %>', :foo => {:bar => 2}).
          should == "<input id=\"foo_bar\" name=\"foo[bar]\" type=\"hidden\" value=\"2\" />"
      end
    end

    describe :params_check_box_tag do
      it "renders with value" do
        render('<%= params_check_box_tag "foo[bar]", "1" %>', :foo => {:bar => 1}).
          should == "<input checked=\"checked\" id=\"foo_bar\" name=\"foo[bar]\" type=\"checkbox\" value=\"1\" />"
      end

      it "is not checked when value does not match" do
        render('<%= params_check_box_tag "foo[bar]", "2" %>', :foo => {:bar => 1}).
          should == "<input id=\"foo_bar\" name=\"foo[bar]\" type=\"checkbox\" value=\"2\" />"
      end

      it "is checked when value is in array" do
        render('<%= params_check_box_tag "foo[bar][]", "1" %>', :foo => {:bar => [1,2,3]}).
          should == "<input checked=\"checked\" id=\"foo_bar_\" name=\"foo[bar][]\" type=\"checkbox\" value=\"1\" />"
      end

      it "is not checked when value is not in array" do
        render('<%= params_check_box_tag "foo[bar][]", "1" %>', :foo => {:bar => [2,3]}).
          should == "<input id=\"foo_bar_\" name=\"foo[bar][]\" type=\"checkbox\" value=\"1\" />"
      end
    end

    describe :check_box_with_label do
      it "adds a label to the checkbox" do
        render('<%= check_box_with_label "foo[bar]", "1", true, "Click it" %>').
          should == "<input checked=\"checked\" id=\"foo_bar\" name=\"foo[bar]\" type=\"checkbox\" value=\"1\" /><label for=\"foo_bar\">Click it</label>"
      end

      it "uses a given id" do
        render('<%= check_box_with_label "foo[bar]", "1", true, "Click it", :id => "xxx" %>').
          should == "<input checked=\"checked\" id=\"xxx\" name=\"foo[bar]\" type=\"checkbox\" value=\"1\" /><label for=\"xxx\">Click it</label>"
      end
    end

    describe :params_check_box_with_label do
      it "its not surprise" do
        render('<%= params_check_box_with_label "foo[bar]", "1", "Click it" %>', :foo => {:bar => 1}).
          should == "<input checked=\"checked\" id=\"foo_bar\" name=\"foo[bar]\" type=\"checkbox\" value=\"1\" /><label for=\"foo_bar\">Click it</label>"
      end
    end

    describe :radio_button_with_label do
      it "adds a simple label to a radio button" do
        render('<%= radio_button_with_label "foo", "1", true, "Click it" %>').
          should == "<input checked=\"checked\" id=\"foo_1\" name=\"foo\" type=\"radio\" value=\"1\" /><label for=\"foo_1\">Click it</label>"
      end

      it "generates labels for nested attributes" do
        render('<%= radio_button_with_label "foo[bar][baz]", "1", true, "Click it" %>').
          should == "<input checked=\"checked\" id=\"foo_bar_baz_1\" name=\"foo[bar][baz]\" type=\"radio\" value=\"1\" /><label for=\"foo_bar_baz_1\">Click it</label>"
      end

      it "generates labels for arrays" do
        render('<%= radio_button_with_label "foo[]", "1", true, "Click it" %>').
          should == "<input checked=\"checked\" id=\"foo__1\" name=\"foo[]\" type=\"radio\" value=\"1\" /><label for=\"foo__1\">Click it</label>"
      end

      it "generates labels for uppercase/weird names" do
        render('<%= radio_button_with_label "fooáßð[]", "UA§§;", true, "Click it" %>').
          should == "<input checked=\"checked\" id=\"foo________UA_____\" name=\"foo\303\241\303\237\303\260[]\" type=\"radio\" value=\"UA\302\247\302\247;\" /><label for=\"foo________UA_____\">Click it</label>"
      end

      it "generates labels for nested attribute-arrays" do
        render('<%= radio_button_with_label "foo[bar][baz][]", "1", true, "Click it" %>').
          should == "<input checked=\"checked\" id=\"foo_bar_baz__1\" name=\"foo[bar][baz][]\" type=\"radio\" value=\"1\" /><label for=\"foo_bar_baz__1\">Click it</label>"
      end
    end

    describe :params_radio_button_tag do
      it "renders normally" do
        render('<%= params_radio_button_tag "foo", "1" %>').
          should == "<input id=\"foo_1\" name=\"foo\" type=\"radio\" value=\"1\" />"
      end

      it "fetches value from params" do
        render('<%= params_radio_button_tag "foo", "1" %>', :foo => 1).
          should == "<input checked=\"checked\" id=\"foo_1\" name=\"foo\" type=\"radio\" value=\"1\" />"
      end

      it "fetches value from nested params" do
        render('<%= params_radio_button_tag "foo[bar]", "1" %>', :foo => {:bar => 1}).
          should == "<input checked=\"checked\" id=\"foo_bar_1\" name=\"foo[bar]\" type=\"radio\" value=\"1\" />"
      end

      it "fetches value from nested params-array" do
        render('<%= params_radio_button_tag "foo[bar][]", "1" %>', :foo => {:bar => [1]}).
          should == "<input checked=\"checked\" id=\"foo_bar__1\" name=\"foo[bar][]\" type=\"radio\" value=\"1\" />"
      end
    end

    describe :params_radio_button_with_label do
      it "its not surprise" do
        render('<%= params_radio_button_with_label "foo", "1", "Click it" %>', :foo => 1).
          should == "<input checked=\"checked\" id=\"foo_1\" name=\"foo\" type=\"radio\" value=\"1\" /><label for=\"foo_1\">Click it</label>"
      end
    end

    describe :params_select_options_tag do
      it "builds from simple list" do
        render('<%= params_select_options_tag "foo", [1] %>').
          should == "<select id=\"foo\" name=\"foo\"><option value=\"1\">1</option></select>"
      end

      it "builds from nested array" do
        render('<%= params_select_options_tag "foo", [[1,2]] %>').
          should == "<select id=\"foo\" name=\"foo\"><option value=\"2\">1</option></select>"
      end

      it "builds from simple list and nested array" do
        render('<%= params_select_options_tag "foo", [1, [2,3]] %>').
          should == "<select id=\"foo\" name=\"foo\"><option value=\"1\">1</option>\n<option value=\"3\">2</option></select>"
      end

      it "builds from hash" do
        render('<%= params_select_options_tag "foo", {1 => 2} %>').
          should == "<select id=\"foo\" name=\"foo\"><option value=\"2\">1</option></select>"
      end

      it "is prefilled" do
        render('<%= params_select_options_tag "foo", [1,2,3] %>', :foo => '3').
          should == "<select id=\"foo\" name=\"foo\"><option value=\"1\">1</option>\n<option value=\"2\">2</option>\n<option value=\"3\" selected=\"selected\">3</option></select>"
      end

      it "is prefilled from :value" do
        render('<%= params_select_options_tag "foo", [1,2,3], :value => 2 %>', :foo => '3').
          should == "<select id=\"foo\" name=\"foo\"><option value=\"1\">1</option>\n<option value=\"2\" selected=\"selected\">2</option>\n<option value=\"3\">3</option></select>"
      end
    end
  end

  describe 'FormBuilder' do
    it "adds check_box_with_label" do
      render('<% form_for :user, nil, :url=> "/xxx" do |f| %> <%= f.check_box_with_label :simple, "Hes so simple" %> <% end %>').
        should == "<form action=\"/xxx\" method=\"post\"> <input name=\"user[simple]\" type=\"hidden\" value=\"0\" /><input id=\"user_simple\" name=\"user[simple]\" type=\"checkbox\" value=\"1\" /><label for=\"user_simple\">Hes so simple</label> </form>"
    end

    it "adds radio_button_with_label" do
      render('<% form_for :user, nil, :url=> "/xxx" do |f| %> <%= f.radio_button_with_label :simple, "yes", "Hes so simple" %> <% end %>').
        should == "<form action=\"/xxx\" method=\"post\"> <input id=\"user_simple_yes\" name=\"user[simple]\" type=\"radio\" value=\"yes\" /><label for=\"user_simple_yes\">Hes so simple</label> </form>"
    end

    it "adds radio_button_with_label for weird names" do
      render('<% form_for :user, nil, :url=> "/xxx" do |f| %> <%= f.radio_button_with_label :simple, "NO.;§", "Hes so simple" %> <% end %>').
        should == "<form action=\"/xxx\" method=\"post\"> <input id=\"user_simple_NO.___\" name=\"user[simple]\" type=\"radio\" value=\"NO.;\302\247\" /><label for=\"user_simple_NO.___\">Hes so simple</label> </form>"
    end

    it "uses given id" do
      render('<% form_for :user, nil, :url=> "/xxx" do |f| %> <%= f.radio_button_with_label :simple, "yes", "Hes so simple", :id => "xxx" %> <% end %>').
        should == "<form action=\"/xxx\" method=\"post\"> <input id=\"xxx\" name=\"user[simple]\" type=\"radio\" value=\"yes\" /><label for=\"xxx\">Hes so simple</label> </form>"
    end
  end
end
