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

(*
val sort : 'a list -> 'a list = <fun>
val insert : 'a -> 'a list -> 'a list = <fun>
*)

sort [2; 1; 0];;
(* - : int list = [0; 1; 2] *)
let sortedList = sort ["yes"; "ok"; "sure"; "ya"; "yep"];;
(* - : string list = ["ok"; "sure"; "ya"; "yep"; "yes"] *)

List.iter (fun x -> print_string x) sortedList;;

(*
Let us encode polynomials as arrays of integer coefficients. 
Then, to add two polynomials, we first allocate the result array, 
then fill its slots using two successive for loops.



*)

let add_polynom p1 p2 = 
    let n1 = Array.length p1
    and n2 = Array.length p2 in
    let result = Array
.create (max n1 n2) 0 in
    for i = 0 to n1 - 1 do result.(i) <- p1.(i) done;
    for i = 0 to n2 - 1 do result.(i) <- result.(i) + p2.(i) done;
    result;;

add_polynom [| 1; 2 |] [| 1; 2; 3 |];;

(*
OCaml offers updatable memory cells, called references: 
ref init returns a new cell with initial contents init, 
!cell returns the current contents of cell, and cell := v 
writes the value v into cell.

We may redefine fact using a reference cell and a for loop:

*)

let fact n = 
    let result = ref 1 in 
    for i = 2 to n do 
        result := i * !result
    done;
    !result ;;

fact 5;; 

(*HIGHER ORDER FUNCTIONS 
There is no restriction on functions, which may thus 
be passed as arguments to other functions. Let us define a 
function sigma that returns the sum of the results of applying 
a given function f to each element of a list:

///////////////////////////////////*)

let rec sigma f = function
    | [] -> 0
    | x :: l -> f x + sigma f l ;;
(* val sigma : ('a -> int) -> 'a list -> int = <fun> *)

let yummy = sigma (fun x -> x*x) [1;2;3];;
let () = Printf.printf "\nYUmmy: %d\n" yummy

let compose f g = fun x -> f (g x)
let square_o_fact = compose square fact ;; 

let composedValue = square_o_fact 5;;

let () = Printf.printf "composedValue: %d\n" composedValue

(* You are on power of functions *)


(*PRINTING STUFF /////////////////////////////////////////*)

let print_list f lst = 
    let rec print_elements = function
        | [] -> ()
        | h :: t -> f h; print_string ";"; print_elements t
    in
    print_string "[";
    print_elements lst;
    print_string "]";;

print_list print_int [3;6;78;5;2;34;7];;