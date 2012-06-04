/**
* UJS CheckBox Visibility Toggler
* ===============================
*
* Copyright (C) 2011 Jan Graichen
*
* A jQuery extension thats allows a input check box to show or hide other side
* elements depending on if it is checked or not. It uses unobtrusive JavaScript
* via HTML5 compatible attributes.
*
* Example:
*
* <input type="checkbox" data-vtoggle="#container" />
*
* The check box above toggle the visibility of element "#container". If the
* check box is not checked the container will be hidden.
*
* Second example:
*
* <input type="checkbox" data-vtoggle-hide="img, .hide-with-images" />
*
* This check box will hide all IMG-tags and all element with the CSS class
* "hide-with-images" when check box is checked.
*
*
* This plugin can also be used to create own check box handler by using
* the checkboxToggle function added to jQuery:
*
* $(element).checkboxToggle(function(checked) {
* ...
* });
*
* Another helper can be used to simply set the visibility of an element:
*
* $(element).setVisibility(true);
*
*
* @author Jan Graichen <jan.graichen@altimos.de>
*
*/

$.fn.checkboxToggle = function(func) {
  $(this).each(function() {
    $(this).bind('click', function() {
      func($(this).attr('checked'));
    });
    func($(this).attr('checked'));
  });
}

$.fn.setVisibility = function(visible) {
  $(this).each(function() {
    visible ? $(this).show() : $(this).hide()
  });
}

$(function() {
  $('input[data-vtoggle]').each( function() {
    var input = $(this);
    $.each($(this).attr('data-vtoggle').split(','), function(index, element) {
      if(element != '') input.checkboxToggle(function(checked) {
        $(element).each(function() {
          $(this).setVisibility(checked);
        });
      });
    });
  });
  $('input[data-vtoggle-hide]').each( function() {
    var input = $(this);
    $.each($(this).attr('data-vtoggle-hide').split(','), function(index, element) {
      if(element != '') input.checkboxToggle(function(checked) {
        $(element).each(function() {
          $(this).setVisibility(!checked);
        });
      });
    });
  });
});