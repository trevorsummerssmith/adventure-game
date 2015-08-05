.PHONY: all
all: server

server: adventure.ml
	ocamlbuild adventure.native -pkg core -pkg async -pkg uri -pkg cohttp -pkg cohttp.async -pkg conduit -tag thread -use-ocamlfind

.PHONY: clean
clean:
	ocamlbuild -clean
