open Core.Std

(** Basic 'atomic' types that are used as Props *)

type percent_complete =
  (** When something is being built *)
  | Building of int
  (** 0...99 inclusive. *)
  | Complete with sexp, compare

type kind =
  (** Bad name. Currently only used for things being built. *)
  | Artifact of Entity.Id.t with sexp_of
