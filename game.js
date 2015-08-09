var SERVER_URL = "http://localhost:8000";

function getParam(key) {
    // Janky get param. Returns the first match.
    // Seems there isn't an easier to to get this in jquery...?
    if (window.location.search == "") { return null; }
    var uriParts = window.location.search.split("?");
    // Remove the '?'
    var splits = uriParts[1].split("&");
    if (splits == null) { return null; }
    for (var i=0; i < splits.length; i++) {
	var str = splits[i];
	var keyVal = str.split("=");
	console.log(keyVal[0] + keyVal[1]);
	console.log(key);
	if (keyVal[0] == key) {
	    return keyVal[1];
	}
    }
    return null;
}

function server(endpoint, successCB) {
    $.ajax({
	url: SERVER_URL + endpoint,
	success:successCB
    });
}

function helloCallback(msg, txtStatus, jqXHR) {
    console.log("Hello callback, received from server: ");
    console.log(msg);
}

function getLocation() {
    if (navigator.geolocation) {
	navigator.geolocation.getCurrentPosition(function (position) {
	    $("#x").val(position.coords.longitude);
	    $("#y").val(position.coords.latitude);
	}, function (error) {
	    switch(error.code) {
	    case error.PERMISSION_DENIED:
		alert("User denied the request for Geolocation.")
		break;
	    case error.POSITION_UNAVAILABLE:
		alert("Location information is unavailable.")
		break;
	    case error.TIMEOUT:
		alert("The request to get user location timed out.")
		break;
	    case error.UNKNOWN_ERROR:
		alert("GeoLocation: An unknown error occurred.")
		break;
	    }
	});
    } else {
	alert("Cannot do geolocation in your browser");
    }
}

function sendLocation() {
    var x = $("#x").val();
    var y = $("#y").val();
    $.ajax({
	method:"GET",
	url:"/player",
	data: {lat : y, long: x, playerId: PLAYER_ID},
	success: function(data, status, jqXHR) {
	    $("#game-text").text(data);
	}
    });
}

var PLAYER_ID = null;
function startGame() {
    var id = getParam("playerId");
    if (id == null) {
	alert("Error must provide player id");
	return;
    }
    console.log("id: " + id);
    PLAYER_ID = id;
}

function selectCharacter(id) {
    var path = "/game?playerId=" + id;
    window.location.assign(SERVER_URL + path);
}

function loginPage() {
    server("/players", function(msg){
	var obj = jQuery.parseJSON(msg);
	var s = "";
	$.each(obj.players, function(key, value) {
	    s += "<li><a href=\"#\" onclick=\"selectCharacter('" + key + "')\">" + value + "</a></li>";
	});
	$("#players").empty();
	$("#players").append($(s));
    });
}
