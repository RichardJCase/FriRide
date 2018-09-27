/*function myMapFrom(){
    var mapProp = {
	center: new google.maps.LatLng(51.508742,-0.120850),
	zoom: 5,
    };

    var map = new google.maps.Map(document.getElementById("googleMapTo"), mapProp);
    var infoWindow = new google.maps.InfoWindow;
    
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            var pos = {
		lat: position.coords.latitude,
		lng: position.coords.longitude
            };

            infoWindow.setPosition(pos);
            infoWindow.setContent('Location found.');
            infoWindow.open(map);
            map.setCenter(pos);
        }, function(){
	    alert("Error in geolocation.");
	});
    }else{
	alert("Your browser sucks.");
    }
    
    myMapTo();
}


function myMapTo(){
    var mapProp = {
	center: new google.maps.LatLng(51.508742,-0.120850),
	zoom: 5,
    };
    
    var map = new google.maps.Map(document.getElementById("googleMapTo"), mapProp);
    }*/


if(navigator.geolocation){
    navigator.geolocation.getCurrentPosition(function(position){
	document.getElementById("from").value = position.coords.latitude + ", " +
	    position.coords.longitude;
    });
}
