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

function startGame() {
    var id = getParam("playerId");
    if (id == null) {
	alert("Error must provide player id");
	return;
    }
    console.log("id: " + id);
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
