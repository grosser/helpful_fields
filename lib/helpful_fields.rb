require 'helpful_fields/core_ext/hash'

class HelpfulFields
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip

  def self.check_box_checked?(params, name, value)
    in_params = params.value_from_nested_key(name).presence
    if in_params.is_a?(Array)
      in_params.map(&:to_s).include?(value.to_s)
    else
      in_params.to_s == value.to_s
    end
  end

  module TagHelper
    def params_text_field_tag(name, options={})
      text_field_tag name, params.value_from_nested_key(name), options
    end

    def params_text_area_tag(name, options={})
      text_area_tag name, params.value_from_nested_key(name), options
    end

    def params_hidden_field_tag (name, options={})
      hidden_field_tag name, params.value_from_nested_key(name), options
    end

    def radio_button_with_label(name, value, checked, label, options={})
      label_for = if options[:id]
        options[:id]  # when id was changed, label has to be for this id
      else
        # name[hello][world] -> name_hello_world_
        # name[hello][] -> name_hello_world__
        # name -> name_
        clean_name = name.to_s.gsub('[]','_').gsub('][','_').gsub(/[\]\[]/,'_')
        clean_name += '_' unless clean_name =~ /_$/
        clean_name + value.to_s.downcase
      end
      radio_button_tag(name, value, checked) + label_tag(label_for, label)
    end

    def params_check_box_tag(name, value, options={})
      check_box_tag(name, value, HelpfulFields.check_box_checked?(params, name, value), options)
    end

    def check_box_with_label(name, value, checked, label, options={})
      label_for = options[:id] || name
      check_box_tag(name, value, checked, options) + label_tag(label_for, label)
    end

    def params_check_box_with_label(name, value, label, options={})
      check_box_with_label(name, value, HelpfulFields.check_box_checked?(params, name, value), label, options)
    end

    def select_options_tag(name, list, options={})
      list = list.map{|x| x.is_a?(Array) ? [x[0],h(x[1])] : h(x) } # stringify values from lists
      selected = h(options[:value] || params.value_from_nested_key(name))
      select_tag(name, options_for_select(list,selected), options.except(:value))
    end
  end

  module FormBuilder
    def check_box_with_label(field, label, options={})
      check_box(field, options) + label(field, label, options)
    end

    def radio_button_with_label(field, value, label, options={})
      radio_button(field, value, options) + label("#{field}_#{value}", label, options)
    end
  end
end

if defined?(ActionView)
  ActionView::Base.send(:include, HelpfulFields::TagHelper)
  ActionView::Helpers::FormBuilder.send(:include, HelpfulFields::FormBuilder)
end
