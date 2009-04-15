$(document).ready(function(){

  $(document).ready(function(){
    $(".menu > li").click(function(e){
      switch(e.target.id){
      case "uri":
        //change status & style menu
        $("#uri").addClass("active");
        $("#upload").removeClass("active");
        $("#input").removeClass("active");

        //display selected division, hide others
        $("div.uri").fadeIn();
        $("div.upload").css("display", "none");
        $("div.input").css("display", "none");
        break;

      case "upload":
        $("#uri").removeClass("active");
        $("#upload").addClass("active");
        $("#input").removeClass("active");

        //display selected division, hide others
        $("div.uri").css("display", "none");
        $("div.upload").fadeIn();
        $("div.input").css("display", "none");
        break;
        
      case "input":
        $("#uri").removeClass("active");
        $("#upload").removeClass("active");
        $("#input").addClass("active");

        //display selected division, hide others
        $("div.uri").css("display", "none");
        $("div.upload").css("display", "none");
        $("div.input").fadeIn();
        break;
      }

      alert(e.target.id);
      return false;
    });
  });

  // submit the selected form
  $("a#submit-button").click(function(event){
    alert("Submit the selected form");
    event.preventDefault();
  });

});
