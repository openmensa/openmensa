# This is a manifest file that'll be compiled into including all the files listed below.
# Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
# be included in the compiled file accessible from http://example.com/assets/application.js
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
#= require jquery
#= require jquery_ujs
#= require rails-timeago
#= require om/plugins/jquery.maskedinput-1.3
#= require om/plugins/jquery.placeholder
#= require om/plugins/jquery.vtoggler
#= require om/plugins/jquery.tabs
#= require_tree .
#= require_self

jQuery ->
  $('[data-tab-target]').tabs()

  # UJS for global toolbar drop down menus
  $('.noscript').remove()
  $('.script-only').removeClass 'script-only'
