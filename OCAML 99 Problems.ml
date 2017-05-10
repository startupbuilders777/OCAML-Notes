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

type 'a node = 
    | One of 'a
    | Many of 'a node list;;


let rec append lst1 lst2 = 
    match (lst1, lst2) with
    | (h1 :: t1, lst2) -> h1 :: append t1 lst2
    | ([], lst2) -> lst2

let rec flatten lst = 
    match lst with
    | [] -> []
    | One a :: t -> a :: flatten t
    | Many a :: t -> append (flatten a) (flatten t) ;;

(* Solution 2*)
let flatten list =
    let rec aux acc = function
      | [] -> acc
      | One x :: t -> aux (x :: acc) t
      | Many l :: t -> aux (aux acc l) t in
    List.rev (aux [] list);;

(* Eliminate consecutive duplicates of list elements. (medium)
# compress ["a";"a";"a";"a";"b";"c";"c";"a";"a";"d";"e";"e";"e";"e"];;
- : string list = ["a"; "b"; "c"; "a"; "d"; "e"]
 *)

(*THis removes all duplicates not even consecutive*)
let rec isItInList elem = function
    | [] -> false
    | h :: t when h = elem -> true
    | _ :: t -> isItInList elem t  ;;

let compress lst = 
    let rec aux acc = function
        | [] -> acc
        | h :: t when not (isItInList h acc) -> aux (h::acc) t
        | _ :: t -> aux acc t  in
    List.rev (aux [] lst)

(* This removes consecutive  *)

let rec compress = function
    | a :: (b :: _ as t) -> if a = b then compress t else a :: compress t
    | smaller -> smaller;;

(*Pack consecutive duplicates of list elements into sublists. (medium) *)

(*
//////////////////////////////////////////////////////////////////////////////
//////////////PLEASE COMPLETE THIS/////////////////////////////////////////
(*///////////////////////////////////////////////////////////////////////////*)
let rec pass lst =
    let rec pass_rec acc lst = 
    match (acc, lst) with
        | ([], []) -> []
        | ([], lsth :: lstt) ->  pass_rec(lsth::acc)(lstt)
        | (acch :: _, lsth::lstt) when acch = lsth -> pass_rec(lsth::acc)(lstt)
        | (acch :: acct, lsth::lstt) when acch <> lsth -> acc::pass_rec([lsth])(lstt)  in
    pass_rec [] lst
*)

(*Run length Encoding Algorithm*)

let encode lst = 
    let rec encode_rec acc currLetter currCounter = function
    | [] when currLetter <> "" -> (currCounter, currLetter) :: acc
    | [] -> acc
    | h :: tl when h = currLetter -> encode_rec(acc)(currLetter)(currCounter + 1)(tl)
    | h :: tl when h <> currLetter -> if currLetter = "" then encode_rec acc h 1 tl 
                                      else encode_rec ((currCounter , currLetter)::acc) h 1 tl in
    List.rev (encode_rec [] "" 0 lst)

(*
Modified run-length encoding. (easy)

Modify the result of the previous problem in such a way that if an 
element has no duplicates it is simply copied into the result list. 
Only elements with duplicates are transferred as (N E) lists.

Since OCaml lists are homogeneous, one needs to define a type to hold 
both single elements and sub-lists.

# encode ["a";"a";"a";"a";"b";"c";"c";"a";"a";"d";"e";"e";"e";"e"];;
- : string rle list =
[Many (4, "a"); One "b"; Many (2, "c"); Many (2, "a"); One "d";
 Many (4, "e")]
*)

 type 'a rle =
    | One of 'a
    | Many of int * 'a;;
(*type 'a rle = One of 'a | Many of int * 'a*)

let encodeX lst = 
    let rec encode_recX acc currLetter currCounter = function
        | [] when currLetter = "" -> acc
        | [] -> if currCounter = 1 then (One currLetter)::acc
                else Many(currCounter, currLetter)::acc 
        | h :: t when h = currLetter -> encode_recX(acc)(currLetter)(currCounter + 1)(t)
        | h :: t when h <> currLetter -> if currLetter = "" then encode_recX acc h 1 t
                                         else if currCounter = 1 then encode_recX((One currLetter)::acc)(h)(1)(t)
                                         else encode_recX((Many(currCounter, currLetter))::acc)(h)(1)(t) in
    List.rev(encode_recX [] "" 0 lst) ;;
 