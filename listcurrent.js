var hasRides = false;

function ride(){
    var table = document.getElementById("ride");
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function(){
	if(this.readyState == 4 && this.status == 200){
	    var obj = JSON.parse(this.responseText);
	    var rides = obj.rides;
	    if(typeof rides == "undefined") return;
	    for(var i = 0; i < rides.length; i++){
		var append = "<tr><td>" + rides[i].from + "</td>";
		append += "<td>" + rides[i].dest + "</td>";
		append += "<td><a href='/profile.html?user=" + rides[i].driver + "'>" + rides[i].driver + "</a></td>";
		if(rides[i].driver != "")
		    append += "<td><input type='radio' name='user' value='" + rides[i].driver + "'/></td>";
		append += "</tr>";
	 	table.innerHTML = append + table.innerHTML;
	    }

	    if(rides.length){
		$("#ride").show();
		$("#riderate").show();
		$("#ridelabel").show();
	    }
	    
	    table.innerHTML = "<th>From</th><th>To</th><th>Driver</th>" + table.innerHTML;
	}
    };
    
    xhttp.open("GET", "/myrides", true);
    xhttp.send();
}

function drive(){
    var table = document.getElementById("drive");
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function(){
	if(this.readyState == 4 && this.status == 200){
	    var obj = JSON.parse(this.responseText);
	    var rides = obj.rides;
	    if(typeof rides == "undefined") return;
	    for(var i = 0; i < rides.length; i++){
		var append = "<tr><td>" + rides[i].from + "</td>";
		append += "<td>" + rides[i].dest + "</td>";
		append += "<td><a href='/profile.html?user=" + rides[i].rider + "'>" + rides[i].rider + "</a></td>";
		if(rides[i].rider != "")
		    append += "<td><input type='radio' name='user' value='" + rides[i].rider + "'/></td>";
		
		append += "</tr>";
	 	table.innerHTML = append + table.innerHTML;
	    }

	    if(rides.length){
		$("#drive").show();
		$("#driverate").show();
		$("#drivelabel").show();
	    }
	    
	    table.innerHTML = "<th>From</th><th>To</th><th>Rider</th>" + table.innerHTML;
	}
    };
    
    xhttp.open("GET", "/mydrives", true);
    xhttp.send();
}

function loaded(){
    ride();
    drive();
}

window.onload = loaded;
