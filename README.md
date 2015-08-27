Getting started
---------------

```bash
# You'll need ocaml and opam installed
git clone https://github.com/trevorsummerssmith/adventure-game
cd adventure-game
make install-deps
make
# Make a new game
./gen-gam.native -p 2 my-game.sexp
# Play the game
./adventure.native -p 8000 my-game.sexp
# Go to your browser:
http://localhost:8000
```