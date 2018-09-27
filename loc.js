var coords;

(function(){
    var loc = document.getElementById("loc");
    navigator.geolocation.getCurrentPosition(function(l){
	coords = l.coords.latitude + " ";
	coords += l.coords.longitude;

	if(typeof loc != "undefined" && loc != null)
	    loc.value = coords;
    });
})();
