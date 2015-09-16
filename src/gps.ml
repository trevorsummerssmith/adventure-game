open Core.Std

(*
   Our game board is roughly 2 miles by 2 miles.
   A tile is roughly 30 meters (~98.5ft) per side.
   This means that there are 107 tiles per side of the
   game board.

   We're starting out with the following conversion:

   Made a box 30 meters by 30 meters, its coordinates are:
    top left:    40.632895, -73.965709
    top right:   40.632895, -73.965355
    bottom left: 40.632624, -73.965709
    bottom right:40.632624, -73.965355

   The this box_lat and box_long:
     0.00027099999, 0.000354

   To map from gps to our index we'll do:
     lat_tmp = floor (gps_lat / box_lat)
     x_idx = lat_tmp % tiles_per_side

   Obviously, there are distortion problems with this.
*)

let to_posn ~tiles_per_side ~lat ~long =
  let box_lat = 0.00027099999 in
  let box_long = 0.000354 in
  let lat_tmp = lat /. box_lat |> Float.round_down |> Int.of_float in
  let long_tmp = long /. box_long |> Float.round_down |> Int.of_float in
  let x = lat_tmp % tiles_per_side in
  let y = long_tmp % tiles_per_side in
  x, y
