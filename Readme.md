Many helpful field helpers e.g. check_box_with_label

Install
=======
    sudo gem install helpful_fields

    rails plugin install git://github.com/grosser/helpful_fields.git


Usage
=====

    # text field filled from params
    <%= params_text_field_tag 'search[category]' %>

    # check box with label selected if field is in params
    <%= params_check_box_with_label 'search[with_user]', 1, 'Search with users' %>

    # radio button with label selected if field is in params
    <%= params_radio_button_with_label 'search[type]', 'product', 'by Product' %>
    <%= params_radio_button_with_label 'search[type]', 'shop', 'by Shop' %>

    # select tag filled via array(single or key/value), and preselected from params(or :value)
    <%= params_select_tag :type, ['', ['0','none']] %>

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
