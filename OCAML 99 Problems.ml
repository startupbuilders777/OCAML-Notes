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
