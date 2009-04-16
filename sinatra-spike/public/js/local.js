$(document).ready(function() {
  $("#tabs").tabs();

  // submit buttons
  $("button[type='submit']").hover(
    function(){$(this).addClass("ui-state-hover"); },
    function(){$(this).removeClass("ui-state-hover"); }
  ).mousedown(function(){
    $(this).parents('.fg-buttonset-single:first').find(".fg-button.ui-state-active").removeClass("ui-state-active");
    if( $(this).is('.ui-state-active.fg-button-toggleable, .fg-buttonset-multi .ui-state-active') ){
      $(this).removeClass("ui-state-active");
    } else {
      $(this).addClass("ui-state-active");
    }
  }).mouseup(function(){
    if(! $(this).is('.fg-button-toggleable, .fg-buttonset-single .fg-button, .fg-buttonset-multi .fg-button') ){
      $(this).removeClass("ui-state-active");
    }
  });

  // more options accordion
  $(".moreoptions").accordion({
    collapsible: true,
    active: false
  });

  $('.accordion .head').click(function() {
    $(this).next().toggle('slow');
    return false;
  }).next().hide();
});