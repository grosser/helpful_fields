Many helpful field helpers for Rails(need ActionView)

 - prefilled form elements with values from params (even deep nesting like 'search[foo][bar][]')
 - check boxes/radio buttos with matching labels
 - selects directly filled with values

Install
=======

    sudo gem install helpful_fields
Or

    rails plugin install git://github.com/grosser/helpful_fields.git


Usage
=====

    # text field filled from params
    <%= params_text_field_tag 'search[category]' %>

    # check box with label
    # selected if params[:search][:user] is 1 or is an array that includes 1
    <%= params_check_box_with_label 'search[with_user]', 1, 'Search with users' %>

    # radio button with label, checked when in params
    <%= params_radio_button_with_label 'search[type]', 'product', 'by Product' %>
    <%= params_radio_button_with_label 'search[type]', 'shop', 'by Shop' %>

    # select tag with options, preselected from params(or :value => xxx)
    <%= params_select_options_tag :type, ['', 'none'] %>
    <%= params_select_options_tag :type, [[0,'none'], [1, 'all']] %>
    <%= params_select_options_tag :type, {'none' => 0, 'all' => 1} %>

    # check box/radio with label for forms
    <% f.check_box_with_label :is_admin, 'Can destroy stuff?' %>
    <% f.radio_button_with_label :type, 'evil', 'No so nice' %>

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...<br/>
[![Build Status](https://secure.travis-ci.org/grosser/helpful_fields.png)](http://travis-ci.org/grosser/helpful_fields)
