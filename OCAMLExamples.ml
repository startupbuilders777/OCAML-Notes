(*
Exercise 1. Write a function dup of type ’a → (’a ∗ ’a) that, 
given a value, returns a
pair with the input value as both first and second elements.

Exercise 2. Write a function curry of type ((’ a ∗ ’b) → ’c) → ’a → ’b → ’c, that, given
a function that uses a pair to encode parameters, returns a currified function.

Exercise 3. Write a function decurry of type (’ a → ’b → ’c) → (’a ∗ ’b) → ’c that performs
the opposite operation.

Exercise 4. The function List .map of type (’ a → ’b) → ’a list → ’b list takes a function
and a list and returns the list obtained by applying the function to each element of the
initial list. Write a function add1 that takes a list and adds 1 to each element of this list.
*)

