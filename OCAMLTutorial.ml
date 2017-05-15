let s = "Hello World"

let main() =
    Printf.printf "%s" s

let () =
    main()

(* An OCAML File*)

(*
Compile file
ocamlc poopie.ml
*)

(*TESTING


let() = assert(reverse myList = [1;2;3])

*)

(*
TYPES Aliasing
*)
type my_string = string
let (s: my_string) = "Hello World"
let s2 = "Hello"
let (s3: my_string) = s2

(* Algebraic data types *)

type number =
  | Int of int
  | Float of float

let neg n =
  match n with
  | Int n' -> Int (-n')
  | Float n' -> Float (-.n')

let is_int n =
  match n with
  | Int _ -> true
  | _ -> false

(* What does is this underscore doing? *)

type 'a option =
  | Some of 'a
  | None

(* What is this 'a? *)

(* A None is used to represent some sort of failed computation *)

let plus n m =
  match n with
  | Int n' ->
    match m with
    | Int m' ->
      let sum = n' + m' in
      Some (Int sum)
    | _ -> None
  | Float n' ->
    match m with
    | Float m' ->
      let sum = n' +. m' in
      Some (Float sum)
    | _ -> None
  | _ -> None

(*
File "./main06.ml", line 28, characters 2-215:
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Float _
File "./main06.ml", line 39, characters 4-5:
Warning 11: this match case is unused.
File "./main06.ml", line 34, characters 4-12:
Warning 11: this match case is unused.
*)

let minus n m =
  match (n, m) with
  | (Int n', Int m') ->
    let sub = n' - m' in
    Some (Int sub)
  | (Float n', Float m') -> Some (Float (n' -. m'))
  | _ -> None

let times n m =
  match (n, m) with
  | (Int n', Int m') -> Some (Int (n' * m'))
  | (Float n', Float m') -> Some (Float (n' *. m'))
  | _ -> None

type ('a, 'b) my_prod =
  'a * 'b

(* The above shows a dual meaning of *
   In the type world it means Cartesian Product
   In the term world it means integer product
*)

let div n m =
  match (n, m) with
  | (_, Int 0) -> None
  | (_, Float 0.0) -> None
  | (Int n', Int m') -> Some (Int (n' / m'))
  | (Float n', Float m') -> Some (Float (n' /. m'))
  | _ -> None

(* No Exceptions allowed! *)

let op_bind op n m =
  match (n, m) with
  | (Some n, Some m) ->
    op n m
  | _ -> None

let app_neg = function
  | Some n -> Some (neg n)
  | _ -> None

let app_plus = op_bind plus
let app_minus = op_bind minus
let app_times = op_bind times
let app_div = op_bind div

let (~&) = app_neg (* starting a defn with a small letter or ~ or ? means prefix *)
let (+&) = app_plus (* starting a defn with other symbols means infix *)
let (-&) = app_minus
let ( *&) = app_times
let (/&) = app_div

let () =
  ( assert (~& (Some (Int 5)) = Some (Int (-5)))
  ; assert (app_neg None != Some (Int (-5)))
  ; let five = Some (Int 5) in
    let six = Some (Int 6) in
    let zero = Some (Int 0) in
    let none = None in
    let thirty = Some (Int 30) in
    begin
      assert (five +& six *& zero = five);
      assert (five *& six = thirty);
      assert (five /& zero = none);
    end
  )
