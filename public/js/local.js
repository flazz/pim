$(document).ready(function() {

	$("#inputchoice a").click(function() {
		
		// deactivate all choices & hide forms
		$("#inputchoice a").removeClass("active");
		$("#input-uri").hide();
		$("#input-file").hide();
		$("#input-direct").hide();
				
		// show my form & activate my choice
		$(this).addClass("active");
		switch ($(this).attr("id")) {
			case "choice-uri": $("#input-uri").show(); break;
			case "choice-file": $("#input-file").show(); break;
			case "choice-direct": $("#input-direct").show(); break;
		}
	});

});
