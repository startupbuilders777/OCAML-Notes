(*
Exercise 1. Write a function dup of type ’a → (’a ∗ ’a) that, 
given a value, returns a
pair with the input value as both first and second elements.
*)

let pairify a = (a,a) ;;
pairify 2 ;; 


(*
Exercise 2. Write a function curry of type ((’ a ∗ ’b) → ’c) → ’a → ’b → ’c, that, given
a function that uses a pair to encode parameters, returns a currified function.
*)


let sum (a,b) = a + b ;;
sum (1,2) ;; 

let currify pairEncodedFunction = fun a b -> pairEncodedFunction(a,b) ;;

let currifiedSum = currify sum ;;

let currifiedSumWith4 = currifiedSum 4 ;;

let () = Printf.printf "currifier: %d\n" (currifiedSumWith4 6);; 


(*
Exercise 3. Write a function decurry of type (’ a → ’b → ’c) → (’a ∗ ’b) → ’c that performs
the opposite operation.
*)

let decurry curriedFunction = 
    let pairedFunction (a, b) = curriedFunction a b in
    pairedFunction;;


(*
Exercise 4. The function List .map of type (’ a → ’b) → ’a list → ’b list takes a function
and a list and returns the list obtained by applying the function to each element of the
initial list. Write a function add1 that takes a list and adds 1 to each element of this list.
*)

let addOneToList lst = List.map(fun a -> a + 1) lst;;

let poop = 1::2::3::[];;
let poopPlus1 = addOneToList poop;;

List.iter (fun x -> print_int x) poopPlus1;;



(*
Exercise 5. Write a function fibonacci such that fibonacci n 
returns the nth term of the
Fibonacci sequence.
*)

let rec fibn n =
    match n<=2 with
    | true -> 1
    | false -> fibn(n-2) + fibn(n-1);;

fibn 4;;


(*
Exercise 6. Test your Fibonacci function with n = 5, then n = 400. 
If this does not
terminate within a reasonable time, improve your function!
*)

let rec fibni n prevAccum currAccum =
    if n = 0 
    then prevAccum + currAccum
    else 
    fibni((n-1) currAccum (prevAccum + currAccum));;

fibni 7 0 1;;

(*
Exercise 7. Define a type that can represent propositional formulæ with the Not, And,
and Or connectives and a Var constructor for variable names (using strings for names).
The interest of sum types lies with pattern matching. You can use the following
constructions to filter x based on its type:
# match ( x ) with
> | Fi r s t C a s e [ ( v1 ) ] → . . .
> . . .
> | LastCase [ ( vn ) ] → . . .
An extremely useful construction is function x, which is syntactic sugar for fun x → match x with.

Exercise 8. A propositional formula is in negative normal form if the negation operator
is only applied to propositions.
Define a fonction nnf that turns a propositional formula into an equivalent formula
in negative normal form.
Exercise 9. A litteral is either a variable or the negation of a variable. A propositional
formula is in conjunctive normal form if it is of the form:
^
i
_
j
`i,j (where `i,j are litterals)
Define a function cnf that turns a propositional formula into an equivalent expression
in conjunctive normal form.

Exercise 10. A list of variable assignements can be given in the following form (this
uses the Caml notation for lists):
# l e t a s s o c = [ ( ”x” , true ) ; ( ”y” , f a l s e ) ; ( ” z ” , true ) ] ; ;
val a s s o c : ( s t r i n g ∗ b o ol ) l i s t = h val i
Define a function eval of type ( string ∗ bool) list → propform → bool that evaluates a
propositional formula given a variable assignement. You might want to use the function
List .assoc; check its documentation using man List.

Exercise 11. Define a function fv that, given a propositional formula, returns the list
of variables that appear inside, without duplicates.

Exercise 12. Define a function compile that, given a propositional formula, prints on the
standard output a Caml function that has the behaviour of the formula. For example,
you should be able to have something like:
# c ompile (And(Or ( Var ”x” , Var ”y” ) , Or ( Var ”x” , Var ” z ” ) ) ) ; ;
fun x y z → ( ( x ) | | ( y ) ) && ( ( x ) | | ( z ) )
− : u ni t


Exercise 13. Translate the following functions into Caml by trying to stick as close as
possible to C style.
int
f a c t o r i e l l e ( int n )
{
int y = 1 , r e s = 1 ;
while ( y <= n )
{
r e s ∗= y ;
y++;
}
return r e s ;
}
int
findmax ( int [ ] a r ray , int l e n g t h )
{
int max, i = 1 ;
a s s e r t ( l e n g t h > 0 ) ;
max = a r r a y [ 0 ] ;
while ( i < l e n g t h )
{
i f ( a r r a y [ i ] > max)
max = a r r a y [ i ] ;
i ++;
}
return max ;
}

Exercise 14. Rewrite these functions in Caml style (use a list instead of an array for
findmax).

*)

