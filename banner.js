(function(){
    var url = document.location.toString();
    var instrs = ['home', 'profile', 'rides'];
    var templateStr = '<ul id="banner"><li><a href="index.html">About</a></li><li><a href="login.html">Log in</a></li><li><a href="download.html">Download</a></li><li><a href="contact.html">Contact</a></li><li><a href="api.html">API</a></li></ul>';
    
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function(){
	if(this.readyState == 4 && this.status == 200){
	    var loggedIn = false;
	    if(this.responseText != "{}" && this.responseText != '{"name": ""}'){
		loggedIn = true;
		templateStr = '<ul id="banner"><li><a href="home.html">Home</a></li><li><a href="rides.html">Rides</a></li><li><a id="profileLink">Profile</a></li><li><a href="logout">Log out</a></li></ul>';
	    }

	    Vue.component('banner', {
		template: templateStr
	    });

	    new Vue({
		el: '#app'
	    });

	    if(loggedIn) getUser();
	}
    };
    
    xhttp.open("GET", "/username", true);
    xhttp.send();
})();
