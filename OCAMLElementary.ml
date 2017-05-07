let rec mylength list =
(* DEBUG *)
let () = Printf.printf "mylength here, null list: %b\n%!" (list = [])
in
(* DEBUG *)
    match list with
    | [] -> 0
    | _ :: rest -> 1 + mylength rest

(*///////////////////////////////////////////////////////////////*)

let square x = x * x ;;

square 3 ;;

let rec fact x = 
    if x <= 0 then 1 else x * fact (x-1) ;; 

let factDebug = fact 5;;

let squareDebug = square 120;;

let () = Printf.printf "Fact: %d\n" factDebug
let () = Printf.printf "SquareDebug: %d\n" squareDebug   

(*
Automatic memory management

All allocation and deallocation operations are fully automatic. 
For example, let us consider simply linked lists.

Lists are predefined in OCaml. The empty list is written []. 
The constructor that allows prepending an element to a list is 
written :: (in infix form).

*)

let li = 1 :: 2 :: 3 :: [] ;; 
(* val li : int list = [1; 2; 3] *)

let a = [1; 2; 3; 4; 5];;

[1; 2; 3] ;;
(* - : int list = [1; 2; 3] *)

5 ::  li ;;
(* - : int list = [5; 1; 2; 3] *)
  
(*
Polymorphism: 
Insertion sort is defined using two recursive functions.

Note that the type of the list elements remains unspecified: 
it is represented by a type variable 'a. Thus, sort can be 
applied both to a list of integers and to a list of strings.

*)

let rec sort = function 
    | [] -> []
    | x :: l -> insert x (sort l)
and insert elem = function
    | [] -> [elem]
    | x :: l -> if elem < x then elem :: x :: l
                else x :: insert elem l ;;


