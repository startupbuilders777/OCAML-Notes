let rec mylength list =
(* DEBUG *)
let () = Printf.printf "mylength here, null list: %b\n%!" (list = [])
in
(* DEBUG *)
    match list with
    | [] -> 0
    | _ :: rest -> 1 + mylength rest

let square x = x * x ;;

square 3 ;;

let rec fact x = 
    if x <= 0 then 1 else x * fact (x-1) ;; 

let factDebug = fact 5;;

let squareDebug = square 120;;

let () = Printf.printf "Fact: %d\n" factDebug
let () = Printf.printf "SquareDebug: %d\n" squareDebug   

