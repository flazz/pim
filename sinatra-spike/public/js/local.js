$(document).ready(function() {

    // Align options button '+' correctly in FF
	jQuery.each(jQuery.browser, function(i) {		
		if($.browser.mozilla){
			$("#options").css("left","-2em");
		}
	});
    
	
	// more options
	$(".moreoptions .head").click(function(){
		$(this).next().toggle('fast');
	});

	// tabs
	$("#tabs").tabs({ 
		fx: { opacity: 'toggle', duration: 'fast'} 
	});

	// submit & toggle buttons
	$("button[type='submit'], .moreoptions .head").hover(
		function(){$(this).addClass("ui-state-hover"); },
		function(){$(this).removeClass("ui-state-hover"); }
	).mousedown(function(){
		$(this).parents('.fg-buttonset-single:first').find(".fg-button.ui-state-active").removeClass("ui-state-active");
		if( $(this).is('.ui-state-active.fg-button-toggleable, .fg-buttonset-multi .ui-state-active') ){
			$(this).removeClass("ui-state-active");

			// toggle -+
			$(this).children(".ui-icon").removeClass("ui-icon-minus").addClass("ui-icon-plus");
		} else {
			$(this).addClass("ui-state-active");
			
			// toggle +-
			$(this).children(".ui-icon").removeClass("ui-icon-plus").addClass("ui-icon-minus");

		}
	}).mouseup(function(){
		if(! $(this).is('.fg-button-toggleable, .fg-buttonset-single .fg-button, .fg-buttonset-multi .fg-button') ){
			$(this).removeClass("ui-state-active");
		}
	});

});
