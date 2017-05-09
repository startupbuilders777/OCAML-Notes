(*
Write a function last : 'a list -> 'a option that returns the last element of a list. (easy)
*)

let rec last lst =
    match lst with
    | [] -> None
    | [a] -> Some a
    | _ :: tl -> last tl;;

last ["a" , "b", "c", "d"];; (* DO NOT DO THIS LIST IS SEPERATED BY SEMICOLONS*)
last ["a"; "b"; "c" ; "d"];; 

(*
Find the last but one (last and penultimate) elements of a list. (easy)
# last_two [ "a" ; "b" ; "c" ; "d" ];;
- : (string * string) option = Some ("c", "d")
# last_two [ "a" ];;
- : (string * string) option = None
*)

let rec last_two lst = 
    match lst with 
    | [] -> None
    | [a] -> None
    | [ a; b ] -> Some [a;b]
    | hd :: tl -> last_two tl;;
last_two [ "a" ; "b" ; "c" ; "d" ];;
last_two [ "a" ];;

(*
Find the k'th element of a list. (easy)
# # at 3 [ "a" ; "b"; "c"; "d"; "e" ];;
- : string option = Some "c"
# at 3 [ "a" ];;
- : string option = None

- : string option = Some "c"
# at 3 [ "a" ];;
- : string option = None
*)

let rec at k = function
    | [] -> None
    | hd::tl -> if k = 1 then Some hd else at (k-1) tl;;
    

let x = at 3 [ "a" ; "b"; "c"; "d"; "e" ];;

(*

13
down vote
accepted
The traditional way to obtain the value inside any kind of constructor in OCaml is with pattern-matching. 
Pattern-matching is the part of OCaml that may be most different from what you have already seen in 
other languages, so I would recommend that you do not just write programs the way you are used to 
(for instance circumventing the problem with ocaml-lib) but instead try it and see if you like it.
*)

match x with 
| None ->  Printf.printf "saw nothing at all\n"
| Some a -> Printf.printf "Fact: %s\n" a;;

(*
Find the number of elements in a list
# length [ "a" ; "b" ; "c"];;
- : int = 3
# length [];;
- : int = 0
*)

let length lst = 
    let rec length_rec counter = function
    | [] -> counter
    | hd::tl -> length_rec (counter+1) tl in
    length_rec 0 lst ;;

(*
OCaml standard library has List.rev but we ask that you reimplement it.
# rev ["a" ; "b" ; "c"];;
- : string list = ["c"; "b"; "a"]
*)

let rev list =
    let rec aux acc = function
      | [] -> acc
      | h::t -> aux (h::acc) t in
    aux [] list;;

(*

Find out whether a list is a palindrome. (easy)

HINT: a palindrome is its own reverse

# is_palindrome [ "x" ; "a" ; "m" ; "a" ; "x" ];;
- : bool = true
# not (is_palindrome [ "a" ; "b" ]);;
- : bool = true
*)

let isPalindrome lst = lst =  List.rev lst ;;

(*
Flatten a nested list structure. (medium)

(* There is no nested list type in OCaml, so we 
need to  define one
first. A node of a nested list is either an element, or 
a list of nodes. *)

  type 'a node =
    | One of 'a 
    | Many of 'a node list;;

type 'a node = One of 'a | Many of 'a node list

# flatten [ One "a" ; Many [ One "b" ; Many [ One "c" ; One "d" ] ; One "e" ] ];;
- : string list = ["a"; "b"; "c"; "d"; "e"]

*) 



