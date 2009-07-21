$(document).ready(function() {
	
	$("#inputchoice a:contains('uri')").addClass("active")
	

	$("#inputchoice a").click(function() {
		
		var old_choice = $("#inputchoice a.active");
		var old_pane = $(old_choice.attr("href"));
		
		var new_choice = $(this);
		var new_pane = $(new_choice.attr("href"));

		old_choice.removeClass("active");
		new_choice.addClass("active");
		
		old_pane.fadeOut("fast", function () {
			new_pane.fadeIn("fast");
		});
				
	});
});
