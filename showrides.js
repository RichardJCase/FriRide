function loaded(){    
    if(typeof coords == "undefined"){
	setTimeout(loaded, 100);
	return;
    }
    
    document.getElementById("status").innerHTML = "Looking for rides...";
    var table = document.getElementById("table");
    var xhttp = new XMLHttpRequest();
    var pre = '<input type="radio" name="ID" value="';
    var post = '" />';
    xhttp.onreadystatechange = function(){
	document.getElementById("status").innerHTML = "";
	var loader = document.getElementById("loader");
	if(loader) loader.remove();
	
	if(this.readyState == 4 && this.status == 200){
	    var obj = JSON.parse(this.responseText);
	    var rides = obj.available_rides;
	    if(typeof rides == "undefined"){
		document.getElementById("status").innerText = "No rides are currently available.";
		return;
	    }

	    document.getElementById("submitbutton").style.display = "";
	    for(var i = 0; i < rides.length; i++){
		var append = "<tr><td>" + rides[i].from + "</td>";
		append += "<td>" + rides[i].dest + "</td>";
		append += "<td><a href='/profile.html?user=" + rides[i].rider + "'>" + rides[i].rider + "</td>";
		append += "<td>" + rides[i].comment + "</td>";
		append += "<td>" + rides[i].payment + "</td>";
		append += "<td style='border:none'>" + pre + rides[i].ID + post + "</td></tr>";
	 	table.innerHTML = append + table.innerHTML;
	    }

	    table.innerHTML = "<th>From</th><th>To</th><th>Rider</th><th>Comment</th><th>Payment</th>" + table.innerHTML;
	}
    };

    xhttp.open("GET", "/ride?loc=" + coords.replace(" ", "%20"), true);
    xhttp.send();
}

window.onload = loaded;

function confirmChecked(e){
    try{
	var val = document.querySelector('input[name = "ID"]:checked').value;
	return true;
    }catch(err){
	alert("Please select a ride.");
	return false;
    }
}
