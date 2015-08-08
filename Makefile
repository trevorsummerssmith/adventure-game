.PHONY: all
all: server

server: adventure.ml
	ocamlbuild adventure.native -pkg core -pkg async -pkg uri -pkg cohttp -pkg cohttp.async -pkg conduit -tag thread -use-ocamlfind \
	-syntax camlp4o -pkg sexplib.syntax,comparelib.syntax

.PHONY: clean
clean:
	ocamlbuild -clean

.PHONY: tests
tests:
	ocamlbuild tests/test_runner.native -Is tests -Is . -pkg core -pkg async -pkg uri -pkg cohttp -pkg cohttp.async -pkg conduit -tag thread -use-ocamlfind -syntax camlp4o -pkg sexplib.syntax,comparelib.syntax -pkg oUnit && ./test_runner.native
