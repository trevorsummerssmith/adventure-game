//
// Draws the player map on the canvas
//

var MAP_COLOR_PLAYERS = "rgb(255,0,0)";
var MAP_COLOR_MESSAGE = "rgb(255,140,0)";
var MAP_COLOR_WOOD = "rgb(0,255,0)";
var MAP_COLOR_ROCK = "rgb(255,255,255)";
var MAP_COLOR_CURRENT_PLAYER = "rgb(255,255,0)";

// Width/height of tile
var TILE_DIMENSION = 4;

// Width of the border
var BORDER_DIMENSION = 1;

// Tile side dimension plus one border side
var TILE_BORDER_DIMENSION = TILE_DIMENSION + BORDER_DIMENSION;

var map_data;
var player_posn;

var setup = false;

function drawMap(canvas, mapData, playerPosn) {
    map_data = mapData;
    player_posn = playerPosn;
    // Draws the tiles
    //
    // for each tile:
    //  - players show red square
    //  - messages show orange square
    //  - trees green
    //  - rock grey
    //  - trees + rock green and grey
    var ctx = canvas.getContext('2d');
    var canvas_width = canvas.width;
    var canvas_height = canvas.height;

    // clear
    ctx.clearRect(0, 0, canvas_width, canvas_height);

    ctx.fillStyle="rgb(255,255,255)";
    // draw vertical lines
    var x = 0;
    var y = 0;
    for (var i = 0; i < 105; i++) {
	      ctx.fillRect(x, 0, BORDER_DIMENSION, canvas_height);
	      ctx.fillRect(0, y, canvas_width, BORDER_DIMENSION);
	      x += TILE_BORDER_DIMENSION;
	      y += TILE_BORDER_DIMENSION;
    }
    //   0 1 2 3 4 5
    // 0 | - - - - |
    // 1 | . . . . |
    // 2 | . . . . |
    // 3 | . . . . |
    // 4 | . . . . |
    // 5 | - - - - |

    ctx.fillStyle="rgb(255,0,0)";
    var half_tile_dimension = TILE_DIMENSION / 2;
    for (var i = 0; i < 100; i++) { // TODO TMP get dimensions
	      for (var j = 0; j < 100; j++) {
	          var tile = mapData[i][j];
	          var x = (i * 5) + 1;
	          var y = (j * 5) + 1;
	          if (tile.p) {
		            ctx.fillStyle = MAP_COLOR_PLAYERS;
		            ctx.fillRect(x, y, TILE_DIMENSION, TILE_DIMENSION);
	          }
	          else if (tile.m) {
		            ctx.fillStyle = MAP_COLOR_MESSAGE;
		            ctx.fillRect(x, y, TILE_DIMENSION, TILE_DIMENSION);
	          }
	          else if (tile.w && tile.r) {
		            // half green half grey
		            ctx.fillStyle = MAP_COLOR_WOOD;
		            ctx.fillRect(x, y, TILE_DIMENSION, half_tile_dimension);
		            ctx.fillStyle = MAP_COLOR_ROCK;
		            ctx.fillRect(x, y+2, TILE_DIMENSION, half_tile_dimension);
	          }
	          else if (tile.w) {
		            ctx.fillStyle = MAP_COLOR_WOOD;
		            ctx.fillRect(x, y, TILE_DIMENSION, TILE_DIMENSION);
	          }
	          else if (tile.r) {
		            ctx.fillStyle = MAP_COLOR_ROCK;
		            ctx.fillRect(x, y, TILE_DIMENSION, TILE_DIMENSION);
	          }
	      }
    }

    // Draw player
    ctx.fillStyle = MAP_COLOR_CURRENT_PLAYER;
    var x = (playerPosn.x * TILE_BORDER_DIMENSION) + BORDER_DIMENSION;
    var y = (playerPosn.y * TILE_BORDER_DIMENSION) + BORDER_DIMENSION;
    console.log(playerPosn.x + " " + playerPosn.y + " >>> " + x + " " + y);
    ctx.fillRect(x, y, TILE_DIMENSION, TILE_DIMENSION);

    if (!setup) { setupCompass(); setup = true; }
}

function compassCB(heading) { // heading is 0 ... 360
    console.log("XXXX " + heading);
    var canvas = $("canvas")[0]; // why is this an array?
    drawMap(canvas, map_data, player_posn); // XXX!
    var ctx = canvas.getContext('2d');
    ctx.save();
    var x = player_posn.x;
    var y = player_posn.y;

    var img = new Image();
    img.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAddJREFUSA2VlE0rRFEYx+feO6OYxAIxH2GMrGRFPoRSs5cFseEjyM7LfA0lycJGNNkrJqUoERaKMk1MY+b63Ttz6jj3ce+ZW8+c5+X//z9zXr1UF5/neUXXdQu+71e6oFlDczT4wN5h5KxZlkAH4SPM79ghPMeSmwxDdEETV03mk5l2iEHW/dVsQO4F+oCdRAwK4ZIpruJ0Or0bQ7UqFRBrKkFh/EElb6UkgRA8EUTVHqjxWOIm5pj+nIV42ATsTKKgCUD83LYBuFOTHxtnMpnpLsTDWcCZkkRdKdlqtVakfFwOzrJUl25jln//BrhXIsTkas1mc5j6l46JzADxWQARcR64J8dx9rAS/rMu0vGzbHbAjf+4oRvC+pdhZTVmP5gLEwd3XcOEbmQGhlAb5LqrOLUwaP9UEVvTYuVGZi41+LOGAbPRaETef3JXSlUbvzU/dCMNWON7E8QRHBdyE2YO7p2Zk+IR1tZ8f84A9mng4KSVjT0I3qUhDfO/C/HAIPus+QOnZBvbwX8068T7kqJ0DwJcHsIlY49EEnJ17sAk+VuzFtmDDuCGcckEx8SL1CLiMfh2iVkUsSqmnmZz/KS2kCiUABhjzbewCmL1wPCvsU14ownc1C+c0K9rApl4ygAAAABJRU5ErkJggg==";
    // this is the compass on a slant img.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAA1klEQVQ4T63UaQ6CMBRG0cueVByixiEqom5J9+SwCYctYUpeCVRaWrB/KYfvDSHif6cHJNEfvAFwBvZA2gWMBUok1BOI24BDgXZGdSnwCAFHAm1r2pSnAzIfcCzQxtHvA3BXz13gBLgA64bBvQA1mMwGTiXRynMDinQmOBNo6Qmpa5V0GpwLtAiA9NVKuqYemn7eo9L5SdcVPAI386s+a6PfKSd8A3092TLaFqxN17Zka7q24Am42jYitOQPoP575sQLPxR0pgstWfXOmS4UVJO19k7X/AXGvyvdD43AIQAAAABJRU5ErkJggg==";

    // Translate to center of square
    var x_1 = x * TILE_BORDER_DIMENSION;
    var y_1 = y * TILE_BORDER_DIMENSION;
    var img_width = 24; // TODO use img
    var img_height = img_width;
    var x_trans = x_1 + (0.5 * img_width);
    var y_trans = y_1 + (0.5 * img_height);
    ctx.translate(x_trans, y_trans);
    ctx.rotate(heading * Math.PI/180); // radians
    ctx.translate(-x_trans, -y_trans);
    ctx.drawImage(img, x_1, y_1);
    // Unrotate
    ctx.restore();
}

function setupCompass() {
    // Now install compass
   Compass.noSupport(function () {
       //alert("no compass!");
       compassCB(180);
    });

    Compass.init(function (method) {
	      //alert('Compass heading by ' + method);
    });

    Compass.watch(compassCB);    
}
