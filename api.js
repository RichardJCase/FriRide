function funcTitle(s){
    return '<table class="doc"><tr><td class="funcTitle">' + s + '</td></tr>';
}

function desc(s){
    return '<tr><td class="desc">' + s + '</td></tr></table>';
}

function initGET(){
    var get = "";
    get += funcTitle("/user");
    get += desc("<i>user: The user to obtain the profile of.</i><br><br>Returns the available rides.");

    get += funcTitle("/ride");
    get += desc("<i>loc: The GPS coordinates in the form '12.34 56.78'</i><br><br>Returns the available rides.");

    get += funcTitle("/myrides");
    get += desc("Returns the rides where the user is the rider.");

    get += funcTitle("/mydrives");
    get += desc("Returns the rides where the user is the driver.");

    get += funcTitle("/torate");
    get += desc("Returns the driver/ride at the top of the stack.");

    $("#get").html(get);
}

function initPOST(){
    post = funcTitle("/ride");
    //todo: params
    post += desc("Create a new ride request. Perfect for events and such.");

    post += funcTitle("/rate");
    //todo: params
    post += desc("Rate a user that shared a ride.");
    
    $("#post").html(post);
}

function initPUT(){
    put = funcTitle("/ride");
    put += desc("<i>ID: The ID of the ride to update.<br>status: New status of the ride.</i><br><br>Update the status of a ride.");

    $("#put").html(put);
}

function initDEL(){
    del = "There are currently no valid DELETE requests for developers.";
    $("#del").html(del);
}

(function(){
    initGET();
    initPOST();
    initPUT();
    initDEL();
    $(".point").click(function(){
	$(this).siblings().fadeToggle("slow");
    });

    $(".hidden").hide();
})();
