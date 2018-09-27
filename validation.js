function loginValid(){
    var form = document.forms["newlogin"];
    var s = form["username"].value;
    var err = false;
   
    var reg = new RegExp("[0-9A-Za-z]+");
    if(s.length > 16 || reg.exec(s) != s){
	form["username"].classList.add("error");;
	err = true;
    }

    s = form["password"].value;
    var reg = new RegExp("[0-9A-Za-z\\s~@#$%^&*()_+-={}\\>\\<?\\[\\]]+");
    if(s.length > 50 || !(reg.exec(s) == s)){
	form["password"].classList.add("error");
	err = true;
    }

    var confirm = form["passwordconfirm"].value;
    if(s != confirm && confirm != ""){
	form["passwordconfirm"].classList.add("error");
	err = true;
    }

    s = form["email"].value;
    slen = s.length;
    var end = s.substring(slen - 10, slen);
    if(reg.exec(s) != s || end != "@gmail.com" || slen > 50){
	form["email"].classList.add("error");
	err = true;
    }

    if(!document.getElementById("accept").checked){
	alert("Please accept the privacy policy."); 
	err = true;
    }

    return !err;
}

function rideValid(){
    var err = false;
    var form = document.forms["newride"];
    if(form["from"].value == ""){
	form["from"].classList.add("error");
	err = true;
    }
    
    if(form["to"].value == ""){
	form["to"].classList.add("error");
	err = true;
    }
    
    if(form["loc"].value == ""){
	alert("Cannot submit form without GPS location.\nPlease enable.");
	err = true;
    }
    
    return !err;
}
