$(document).ready(function() {

	$("#inputchoice a").click(function() {
		
		var old_choice = $("#inputchoice a.active");
		var old_pane = choice_to_pane(old_choice);
		
		var new_choice = $(this);
		var new_pane = choice_to_pane(new_choice);

		new_choice.animate( { color: '#9BBE00' }, 500).addClass("active");
		old_choice.animate( { color: '#797B7A' }, 500).removeClass("active");

		old_pane.fadeOut("fast", function () {
			new_pane.fadeIn("fast");
		});
				
	});
});

function choice_to_pane(choice) {

	var choice_id = choice.attr("id");
	var pane_id;
	switch (choice_id) {
		case "choice-uri": 
		pane_id = "#input-uri"; 
		break;
		
		case "choice-file": 
		pane_id = "#input-file"; 
		break;
		
		case "choice-direct": 
		pane_id = "#input-direct"; 
		break;
	}
	
	return $(pane_id);
}