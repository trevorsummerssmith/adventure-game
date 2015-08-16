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
