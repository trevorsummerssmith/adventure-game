.PHONY: all
all: server gen_game

server: adventure.ml
	ocamlbuild adventure.native -pkg core -pkg async -pkg uri -pkg cohttp -pkg cohttp.async -pkg conduit -tag thread -use-ocamlfind -plugin-tag "package(ocamlbuild_atdgen)" -pkg atdgen \
	-syntax camlp4o -pkg sexplib.syntax,comparelib.syntax

gen_game: gen_game.ml
	ocamlbuild gen_game.native -syntax camlp4o -pkg sexplib.syntax,comparelib.syntax,fieldslib.syntax -pkg core -pkg async -pkg uri \
	-pkg cohttp -pkg cohttp.async -pkg conduit -tag thread -use-ocamlfind -plugin-tag "package(ocamlbuild_atdgen)" -pkg atdgen

.PHONY: clean
clean:
	ocamlbuild -clean

.PHONY: tests
tests:
	ocamlbuild tests/test_runner.native -Is tests -Is . -pkg core -pkg async -pkg uri -pkg cohttp -pkg cohttp.async -pkg conduit -tag thread -use-ocamlfind -syntax camlp4o -pkg sexplib.syntax,comparelib.syntax -pkg oUnit && ./test_runner.native
