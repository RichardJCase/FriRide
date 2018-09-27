(function(){
    if(window.location.href != "https://friride.ddns.net/home.html")
	window.location.href = "https://friride.ddns.net/home.html";
    $("#status").hide();
    $("#ride").hide();
    $("#drive").hide();
    $("#riderate").hide();
    $("#driverate").hide();
    $("#ridelabel").hide();
    $("#drivelabel").hide();

    $("#rateride").click(function(){
	$("#rideform").attr("action", "/rate");
    });

    $("#cancelride").click(function(){
	$("#rideform").attr("action", "/cancel");
    });

    $("#ratedrive").click(function(){
	$("#driveform").attr("action", "/rate");
    });

    $("#canceldrive").click(function(){
	$("#driveform").attr("action", "/cancel");
    });
})();

function valid(formname){
    if(typeof $("input[name='user']:checked").val() == "undefined"){
	$("#status").show("slow");
	return false;
    }

    return true;
}
