function displayErrorMessage(str) {
    alert("Error: " + str);
}

function displayErrorOnAjaxCallback(xhr, status, err) {
    displayErrorMessage(status + " " + err.toString() + ": " + xhr.responseText);
}

function ajax(dict) {
    // dict is the ajax dict
    // provide default args but override what was passed
    var args = {
        dataType: "json",
        cache: false,
        error: displayErrorOnAjaxCallback
    };
    $.extend(args, dict);
    $.ajax(args);
}

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

function getPlayerId() {
    // Return the player id of the player who is playing the game.
    // This is super jank for now.
    var id = getParam("playerId");
    if (id == null) {
        alert("Error must provide player id");
        return;
    }
    return id;
}

var RESOURCE_KIND_WOOD = "wood";
var RESOURCE_KIND_ROCK = "rock";

var TileMessage = React.createClass ({


    formatDate: function(timeStr) {
        // Format date as: 13:23:44 09/08/15
        function padInt(n) {
            var s = n.toString();
            if (n < 10) {
                return '0' + s;
            } else {
                return s;
            }
        };
        var d = new Date(Date.parse(timeStr));
        var s = "";
        s += padInt(d.getHours()) + ":" + padInt(d.getMinutes()) + ":" + padInt(d.getSeconds());
        s += " ";
        s += padInt((d.getMonth() + 1)) + "/" + padInt(d.getDate()) + "/" + d.getFullYear().toString().substring(2,4);
        return s;
    },
    render: function() {
        return (
            <li>
                {this.formatDate(this.props.date)} {this.props.authorName} {this.props.text}
            </li>
        );
    }
});

var TileMessages = React.createClass ({
    render: function() {
        var messageNodes = this.props.messages.map(function (message) {
            return (
                <TileMessage date={message.time}
                             authorName={message.playerName}
                             text={message.text} />
            );
        });
        return (
            <ul className="messages">
                {messageNodes}
            </ul>
        );
    }
});

var TileDescription = React.createClass ({
    render: function() {
        return (
            <div className="tileDescription">
                {this.props.desc}
            </div>
        );
    }
});

var PlayerStatus = React.createClass ({
    render: function() {
        return (
            <div className="playerStatus">
                <span>&gt;&gt;&gt; wood: <span id="wood">{this.props.wood}</span></span>
                <span> rock: <span id="rock">{this.props.rock}</span></span>
            </div>
        );
    }
});

var PlayerMenu = React.createClass ({
    render: function() {
        return (
            <div className="menu">
                <span><a href="#" onClick={function(e){ this.props.onHarvest(e, RESOURCE_KIND_WOOD);}.bind(this)}>harvest</a></span>
                <span> . <a href="#" onClick={function(e){ this.props.onHarvest(e, RESOURCE_KIND_ROCK);}.bind(this)}>mine</a></span>
                <span> . build</span>
                <span> . attack</span>
                <span> . talk</span>
                <span> . enter</span>
            </div>
        );
    }
});

var Map = React.createClass ({
    componentDidMount: function() {
        //setupCompass(); // Just once!
    },
    componentDidUpdate: function() {
        var canvas = React.findDOMNode(this);
        var ctx = canvas.getContext("2d");
        ctx.fillStyle="rgb(255,0,0)";
        ctx.fillRect(1, 1, 200, 200);
        drawMap(canvas, this.props.mapData, this.props.playerPosn); // XXX
    },
    render: function () {
        return(<canvas width={500} height={500}></canvas>);
    }
});

var UNKNOWN_PLAYER_POSITION = -1;

var PlayerPage = React.createClass ({
    handleHarvestSubmit: function(e, resourceKind) {
        e.preventDefault();
        ajax({
            method: "GET",
            url: "/harvest",
            data: { lat: this.state.lat,
                    long: this.state.long,
                    playerId: this.props.playerId,
                    kind: resourceKind
            },
            success: function(data) {
                this.setState({mapData: data.tiles});
            }.bind(this)
        });
    },
    getMap: function() {
        ajax({
            method: "GET",
            url: "/board",
            data: {playerId: this.props.playerId},
            success: function(data) {
                this.setState({mapData:data.tiles,
                               playerPosn:{x:data.player[0],
                                           y:data.player[1]}
                });
            }.bind(this)
        });
    },
    getInitialState: function() {
        // Random coords for default location for now.
        // Makes debugging a lot easier
        return {lat: 40.632408,
                long: -73.9652639,
                mapData: [],
                playerPosn:{x:UNKNOWN_PLAYER_POSITION,
                            y:UNKNOWN_PLAYER_POSITION},
                data:{
                    player:{wood:"-",rock:"-"},
                    tile: {messages: [],
                           desc:"A grove of sycamore trees stands a few feet away. Near to your feet are deep black rocks. A matte grey fortress sits a bit behind the trees."}
                }
        };
    },
    updateLocation: function(lat, long) {
        // Update the location if it has changed
        // Update the server and wait for that to flow back
        // to update the ui.
        console.log("updateLocation: " + lat + " " + long);
        console.log("updateLocation: " + this.state.lat + " " + this.state.long);
        if ((lat != this.state.lat) || (long != this.state.long)) {
            ajax({
                method: "GET",
                url: "/player",
                data: { lat: lat,
                        long: long,
                        playerId: this.props.playerId
                },
                success: function(data) {
                    this.setState({lat: lat,
                                   long: long,
                                   playerPosn: data.player.posn,
                                   data: data}); // TODO clean this payload up
                }.bind(this)
            });
        }
    },
    getLocation: function() {
        // Use the location api to get the user's current location
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                function (position) {
                    // We got the location... update state but
                    // only if we have moved.
                    var lat = position.coords.latitude;
                    var long = position.coords.longitude;
                    this.updateLocation(lat, long);
                }.bind(this),
                function (error) {
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
    },
    componentDidMount: function() {
        // Update every 10 s
        this.getLocation();
        // Get initial player map (note that we currently don't update it again
        // as a whole map)
        this.getMap();
        setInterval(this.getLocation, this.props.locationPollInterval);
    },
    handleMessageSubmit: function (e) {
        e.preventDefault();
        var text = React.findDOMNode(this.refs.text).value.trim();
        ajax({
            method: "GET",
            url: "/message",
            data: { lat: this.state.lat,
                    long: this.state.long,
                    playerId: this.props.playerId,
                    message: text
            },
            success: function(data) {
                this.setState({data: data});
            }.bind(this)
        });
    },
    handleSubmit: function(e) {
        ajax({
            method: "GET",
            url: "/player",
            data: { lat: this.state.lat,
                    long: this.state.long,
                    playerId: this.props.playerId
            },
            success: function(data) {
                this.setState({data: data});
            }.bind(this)
        });
    },
    render: function() {
        return (
            <div>
                <PlayerMenu onHarvest={this.handleHarvestSubmit} />
                <PlayerStatus wood={this.state.data.player.wood}
                              rock={this.state.data.player.rock} />
                <TileDescription desc={this.state.data.tile.desc} />
                <div className="menu">messages
                    <form className="talkForm" onSubmit={this.handleMessageSubmit}>
                        <input type="text" ref="text" />
                        <input type="Submit" value="Talk" />
                    </form>
                </div>
                <TileMessages messages={this.state.data.tile.messages} />
                <Map playerPosn={this.state.playerPosn} mapData={this.state.mapData} />
                <a href="#" onClick={this.handleSubmit}>Send Location</a>
            </div>
        );
    }
});

React.render(
    <PlayerPage playerId={getPlayerId()} locationPollInterval={10000} />,
    document.getElementById("container")
);
