var user = $_GET['user'];

if(user == undefined)
    window.location.replace("/");

$("#name").text(user);
$(".user").val(user);
$("#changepassword").hide();
$("#picedit").hide();
$("#bioedit").hide();
$("#delform").hide();
$("#rate").hide();
$("#user").val(user);

function addRating(){
    $("#rate").show();
}

function sameUser(){
    $("#changepassword").show();
    $("#picedit").show();
    $("#bioedit").show();
    $("#delform").show();
}

function ratings(){
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function(){
	if(this.readyState == 4 && this.status == 200){
	    var obj = JSON.parse(this.responseText);
	    $("#pic").attr("src", obj.user[0].image);
	    $("#rating").text("Reputation: " + obj.user[0].rep);
	    $("#bio").text(obj.user[0].bio);

	    var canrate = obj.user[0].same == "0";
	    if(canrate){
		addRating();
	    }else{
		sameUser();
	    }
	}
    };
    
    xhttp.open("GET", "/profile?user=" + user, true);
    xhttp.send();
}

function load(){
    ratings();
}

function confirmSame(e){
    var newpass = $("newpass").val();
    var confirm = $("confirm").val();
    if(newpass != confirm){
	alert("Passwords do not match");
	e.preventDefault();
    }
}

window.onload = load;
$("#newpasssubmit").click(confirmSame);

$(".point").click(function(){
    $(this).next().fadeToggle("slow");
});

$(".point").next().hide();
