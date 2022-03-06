[%%import "/src/config.mlh"]

open Snark_params.Tick

module Auth_required : sig
  [%%versioned:
  module Stable : sig
    module V2 : sig
      type t = None | Either | Proof | Signature | Impossible
      [@@deriving sexp, equal, compare, hash, yojson, enum]
    end
  end]

  val to_input : t -> Field.t Random_oracle_input.Chunked.t

  val check : t -> Control.Tag.t -> bool

  [%%ifdef consensus_mechanism]

  module Checked : sig
    type t

    val if_ : Boolean.var -> then_:t -> else_:t -> t

    val to_input : t -> Field.Var.t Random_oracle_input.Chunked.t

    val eval_no_proof : t -> signature_verifies:Boolean.var -> Boolean.var

    val eval_proof : t -> Boolean.var

    val spec_eval :
         t
      -> signature_verifies:Boolean.var
      -> Boolean.var * [ `proof_must_verify of Boolean.var ]
  end

  val typ : (Checked.t, t) Typ.t

  [%%endif]
end

module Poly : sig
  [%%versioned:
  module Stable : sig
    module V2 : sig
      type ('bool, 'controller) t =
        { stake : 'bool
        ; edit_state : 'controller
        ; send : 'controller
        ; receive : 'controller (* TODO: Consider having fee *)
        ; set_delegate : 'controller
        ; set_permissions : 'controller
        ; set_verification_key : 'controller
        ; set_snapp_uri : 'controller
        ; edit_sequence_state : 'controller
        ; set_token_symbol : 'controller
        ; increment_nonce : 'controller
        ; set_voting_for : 'controller
        }
      [@@deriving sexp, equal, compare, hash, yojson, hlist, fields]
    end
  end]
end

[%%versioned:
module Stable : sig
  module V2 : sig
    type t = (bool, Auth_required.Stable.V2.t) Poly.Stable.V2.t
    [@@deriving sexp, equal, compare, hash, yojson]
  end
end]

(** if [auth_tag] is provided, the generated permissions will be compatible with
    the corresponding authorization
*)
val gen : auth_tag:Control.Tag.t -> t Core_kernel.Quickcheck.Generator.t

val to_input : t -> Field.t Random_oracle_input.Chunked.t

[%%ifdef consensus_mechanism]

module Checked : sig
  type t = (Boolean.var, Auth_required.Checked.t) Poly.Stable.Latest.t

  val to_input : t -> Field.Var.t Random_oracle_input.Chunked.t

  val constant : Stable.Latest.t -> t

  val if_ : Boolean.var -> then_:t -> else_:t -> t
end

val typ : (Checked.t, t) Typ.t

[%%endif]

val user_default : t

val empty : t

(* This type definition was generated by hovering over `deriver` in permissions.ml and copying the type *)
(* TODO write this more concisely *)
val deriver :
     (< contramap :
          ((bool, Auth_required.t) Poly.t -> (bool, Auth_required.t) Poly.t) ref
      ; graphql_arg :
          (   unit
           -> (bool, Auth_required.t) Poly.t
              Fields_derivers_graphql.Schema.Arg.arg_typ)
          ref
      ; graphql_arg_accumulator :
          (bool, Auth_required.t) Poly.t
          Fields_derivers_snapps.Graphql.Args.Acc.T.t
          ref
      ; graphql_creator : ('a -> (bool, Auth_required.t) Poly.t) ref
      ; graphql_fields :
          (bool, Auth_required.t) Poly.t
          Fields_derivers_snapps.Graphql.Fields.Input.T.t
          ref
      ; graphql_fields_accumulator :
          (bool, Auth_required.t) Poly.t
          Fields_derivers_snapps.Graphql.Fields.Accumulator.T.t
          list
          ref
      ; graphql_query : string option ref
      ; graphql_query_accumulator : (string * string option) list ref
      ; map :
          ((bool, Auth_required.t) Poly.t -> (bool, Auth_required.t) Poly.t) ref
      ; nullable_graphql_arg :
          (unit -> 'b Fields_derivers_graphql.Schema.Arg.arg_typ) ref
      ; nullable_graphql_fields :
          (bool, Auth_required.t) Poly.t option
          Fields_derivers_snapps.Graphql.Fields.Input.T.t
          ref
      ; of_json :
          (   [> `Assoc of (string * Yojson.Safe.t) list ]
           -> (bool, Auth_required.t) Poly.t)
          ref
      ; of_json_creator : Yojson.Safe.t Core_kernel.String.Map.t ref
      ; to_json :
          (   (bool, Auth_required.t) Poly.t
           -> [> `Assoc of (string * Yojson.Safe.t) list ])
          ref
      ; to_json_accumulator :
          (string * ((bool, Auth_required.t) Poly.t -> Yojson.Safe.t)) list ref
      ; .. >
      as
      'a)
  -> 'a
