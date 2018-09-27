function getUser(){
    var plink = document.getElementById("profileLink");
    var link = "profile.html?user=";

    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function(){
	if(this.readyState == 4 && this.status == 200){
	    var obj = JSON.parse(this.responseText);
	    link += obj.name[0].uname;
	    plink.href = link;
	}
    };
    
    xhttp.open("GET", "/username", true);
    xhttp.send();
}
