.PHONY: all
all: server gen_game

OCAMLBUILD=ocamlbuild -use-ocamlfind -plugin-tag "package(ocamlbuild_atdgen)"

server: adventure.ml
	$(OCAMLBUILD) adventure.native

gen_game: gen_game.ml
	$(OCAMLBUILD) gen_game.native

.PHONY: clean
clean:
	ocamlbuild -clean

.PHONY: tests
tests:
	$(OCAMLBUILD) -Is tests tests/test_runner.native && ./test_runner.native

# Install ocaml deps
.PHONY: install-ocaml-deps
install-ocaml-deps:
	opam pin add --yes --no-action adventure-game .
	opam install --yes --deps-only adventure-game

#
# Hacky download our dependent js files
#
JS_DEPS=web/react.js web/JSXTransformer.js web/jquery.min.js
web/react.js:
	wget -Oweb/react.js https://fb.me/react-0.13.3.js

web/JSXTransformer.js:
	wget -Oweb/JSXTransformer.js https://fb.me/JSXTransformer-0.13.3.js

web/jquery.min.js:
	wget -Oweb/jquery.min.js http://code.jquery.com/jquery-1.11.3.min.js

install-js-deps: $(JS_DEPS)

# Install deps
install-deps: install-js-deps install-ocaml-deps
