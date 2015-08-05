var SERVER_URL = "http://localhost:8000";

function server(endpoint, successCB) {
    $.ajax({
	dataType: "json",
	url: SERVER_URL + endpoint,
	success: successCB
    });
}

function helloCallback(msg, txtStatus, jqXHR) {
    console.log("Hello callback, received from server: ");
    console.log(msg);
}

function start() {
    server("/hello", helloCallback);
}
