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

function displayDescriptionResponse(obj) {
    // Response object from the server parsed.
    // Should have desc and messages fields
    var tile = obj.tile;
    var player = obj.player;
    $("#game-text").text(tile.desc);
    var s = "";
    for (var i = 0; i < tile.messages.length; i++) {
	var msg = tile.messages[i];
	s += "<li>"
	// Format date as: 13:23:44 09/08/15
	var d = new Date(Date.parse(msg.time));
	s += padInt(d.getHours()) + ":" + padInt(d.getMinutes()) + ":" + padInt(d.getSeconds());
	s += " ";
	s += padInt((d.getMonth() + 1)) + "/" + padInt(d.getDate()) + "/" + d.getFullYear().toString().substring(2,4);
	s += " ";
	s += msg.playerName
	s += ": ";
	s += msg.text;
	s += "</li>";
    }
    var msgs = $("#messages");
    msgs.empty();
    msgs.append($(s));
    // After appending messages, scroll to the bottom
    if (msgs.length) {
	msgs.scrollTop(msgs[0].scrollHeight - msgs.height());
    }

    // Update player status
    $("#wood").text(player.wood);
    $("#rock").text(player.rock);
}

function get_posn() {
    return {long:$("#x").val(),
	    lat:$("#y").val()}
}

function make_player_request_dict () {
    var posn = get_posn();
    return {lat : posn.lat,
	    long : posn.long,
	    playerId : PLAYER_ID}
}

function updateErrorDisplay (errorObj) {
    alert("Error: " + errorObj.msg);
}

var RESOURCE_KIND_WOOD = "wood";
var RESOURCE_KIND_ROCK = "rock";

function doHarvest(kind) {
    // Kind is a string, use constants
    var data = make_player_request_dict();
    data['kind'] = kind
    $.ajax({
	method:"GET",
	url:"/harvest",
	data: data,
	success: function(data, status, jqXHR) {
	    var obj = jQuery.parseJSON(data);
	    displayDescriptionResponse(obj);
	},
	error: function(jqXHR, textStatus, errorThrown) {
	    if (errorThrown == "Bad Request") {
		var errorObj = jQuery.parseJSON(jqXHR.responseText);
		updateErrorDisplay(errorObj);
	    }
	}
    });
}

function sendLocation() {
    $.ajax({
	method:"GET",
	url:"/player",
	data:make_player_request_dict(),
	success: function(data, status, jqXHR) {
	    var obj = jQuery.parseJSON(data)
	    displayDescriptionResponse(obj);
	}
    });
}

function padInt(n) {
    var s = n.toString();
    if (n < 10) {
	return '0' + s;
    } else {
	return s;
    }
}

function sendMessage() {
    var data = make_player_request_dict();
    data['message'] = $("#message").val();
    // TODO assert all the above are valid
    $.ajax({
	method:"GET",
	url:"/message",
	data: data,
	success: function(data, status, jqXHR) {
	    var obj = jQuery.parseJSON(data);
	    displayDescriptionResponse(obj);
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
