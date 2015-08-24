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

function drawMap(canvas, mapData, playerPosn) {
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
    ctx.fillRect(x, y, TILE_DIMENSION, TILE_DIMENSION);
}
