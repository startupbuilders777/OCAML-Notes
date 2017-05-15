# OCAML-Notes
Notes and Completed Exercises for the OCAML Programming Language 


The and keyword is used either to avoid multiple let 
(first example, I never use it for this but why not) or for 
mutually recursive definitions of types, functions, modules...

As you can see in your second example :

let rec debug stack env (r, ty) =
   ...
   | Tunresolved tyl -> o "intersect("; debugl stack env tyl; o ")"
   ...

 and debugl stack env x =
   ...
   | [x] -> debug stack env x
   ...
debug calls debugl and vice versa. So the and is allowing that.

[EDIT] It bothered me not to give a proper example so here is one example that you'll often see :

 let rec is_even x =
   if x = 0 then true else is_odd (x - 1)
 and is_odd x =
   if x = 0 then false else is_even (x - 1)
(You can find this example here)

For mutually recursive types, it's harder to find a configuration but following this wikipedia 
page we would define trees and forests as follow

 type 'a tree = Empty | Node of 'a * 'a forest
 and 'a forest = Nil | Cons of 'a tree * 'a forest
As an example, a forest composed of the empty tree, the singleton tree labeled 'a' and a 
two nodes tree with labels 'b' and 'c' would then be represented as :

 let f1 = Cons (Empty, (* Empty tree *)
             Cons (Node ('a',  (* Singleton tree *)
                         Nil), (* End of the first tree *)
                   Cons (Node ('b', (* Tree composed by 'b'... *)
                               Cons (Node ('c', (* and 'c' *)
                                           Nil), 
                                     Nil)
                           ),
                         Nil (* End ot the second tree *)
                     )
               )
         );;
And the size function (counting the number of nodes in the forest) would be :

let rec size_tree = function
  | Empty -> 0
  | Node (_, f) -> 1 + size_forest f
and size_forest = function
  | Nil -> 0
  | Cons (t, f) -> size_tree t + size_forest f
And we get

# size_forest f1;;
- : int = 3
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////


Local "variables" (really local expressions)

Let's take the average function and add a local variable in C. (Compare it to the first definition we had above).

double average (double a, double b)
{
  double sum = a + b;
  return sum / 2;
}
Now let's do the same to our OCaml version:

# let average a b =
    let sum = a +. b in
    sum /. 2.0;;
val average : float -> float -> float = <fun>
The standard phrase let name = expression in is used to define a named local expression, and name can then be used later on in the function instead of expression, till a ;; which ends the block of code. Notice that we don't indent after the in. Just think of let ... in as if it were a statement.

Now comparing C local variables and these named local expressions is a sleight of hand. In fact they are somewhat different. The C variable sum has a slot allocated for it on the stack. You can assign to sum later in the function if you want, or even take the address of sum. This is NOT true for the OCaml version. In the OCaml version, sum is just a shorthand name for the expression a +. b. There is no way to assign to sum or change its value in any way. (We'll see how you can do variables whose value changes in a minute).

Here's another example to make this clearer. The following two code snippets should return the same value (namely (a+b) + (a+b)²):

# let f a b =
    (a +. b) +. (a +. b) ** 2.;;
val f : float -> float -> float = <fun>
# let f a b =
    let x = a +. b in
    x +. x ** 2.;;
val f : float -> float -> float = <fun>
The second version might be faster (but most compilers ought to be able to perform this step of "common subexpression elimination" for you), and it is certainly easier to read. x in the second example is just shorthand for a +. b.

Global "variables" (really global expressions)

You can also define global names for things at the top level, and as with our local "variables" above, these aren't really variable at all, just shorthand names for things. Here's a real (but cut-down) example:

let html =
  let content = read_whole_file file in
  GHtml.html_from_string content
  ;;

let menu_bold () =
  match bold_button#active with
  | true -> html#set_font_style ~enable:[`BOLD] ()
  | false -> html#set_font_style ~disable:[`BOLD] ()
  ;;

let main () =
  (* code omitted *)
  factory#add_item "Cut" ~key:_X ~callback: html#cut
  ;;
In this real piece of code, html is an HTML editing widget (an object from the lablgtk library) which is created once at the beginning of the program by the first let html = statement. It is then referred to in several later functions.

Note that the html name in the code snippet above shouldn't really be compared to a real global variable as in C or other imperative languages. There is no space allocated to "store" the "html pointer". Nor is it possible to assign anything to html, for example to reassign it to point to a different widget. In the next section we'll talk about references, which are real variables.

Let-bindings

Any use of let ..., whether at the top level (globally) or within a function, is often called a let-binding.

References: real variables

What happens if you want a real variable that you can assign to and change throughout your program? You need to use a reference. References are very similar to pointers in C/C++. In Java, all variables which store objects are really references (pointers) to the objects. In Perl, references are references - the same thing as in OCaml.

Here's how we create a reference to an int in OCaml:

# ref 0;;
- : int ref = {contents = 0}
Actually that statement wasn't really very useful. We created the reference and then, because we didn't name it, the garbage collector came along and collected it immediately afterwards! (actually, it was probably thrown away at compile-time.) Let's name the reference:

# let my_ref = ref 0;;
val my_ref : int ref = {contents = 0}
This reference is currently storing a zero integer. Let's put something else into it (assignment):

# my_ref := 100;;
- : unit = ()
And let's find out what the reference contains now:

# !my_ref;;
- : int = 100
So the := operator is used to assign to references, and the ! operator dereferences to get out the contents. Here's a rough-and-ready comparison with C/C++:

OCaml

# let my_ref = ref 0;;
val my_ref : int ref = {contents = 0}
# my_ref := 100;;
- : unit = ()
# !my_ref;;
- : int = 100
C/C++

int a = 0; int *my_ptr = &a;
*my_ptr = 100;
*my_ptr;
References have their place, but you may find that you don't use references very often. Much more often you'll be using let name = expression in to name local expressions in your function definitions.

Nested functions

C doesn't really have a concept of nested functions. GCC supports nested functions for C programs but I don't know of any program which actually uses this extension. Anyway, here's what the gcc info page has to say about nested functions:

A "nested function" is a function defined inside another function. (Nested functions are not supported for GNU C++.) The nested function's name is local to the block where it is defined. For example, here we define a nested function named 'square', and call it twice:

foo (double a, double b)
{
  double square (double z) { return z * z; }

  return square (a) + square (b);
}
The nested function can access all the variables of the containing function that are visible at the point of its definition. This is called "lexical scoping". For example, here we show a nested function which uses an inherited variable named offset:

bar (int *array, int offset, int size)
{
  int access (int *array, int index)
    { return array[index + offset]; }
  int i;
  /* ... */
  for (i = 0; i < size; i++)
    /* ... */ access (array, i) /* ... */
}
You get the idea. Nested functions are, however, very useful and very heavily used in OCaml. Here is an example of a nested function from some real code:

# let read_whole_channel chan =
    let buf = Buffer.create 4096 in
    let rec loop () =
      let newline = input_line chan in
      Buffer.add_string buf newline;
      Buffer.add_char buf '\n';
      loop ()
    in
    try
      loop ()
    with
      End_of_file -> Buffer.contents buf;;
val read_whole_channel : in_channel -> string = <fun>
Don't worry about what this code does - it contains many concepts which haven't been discussed in this tutorial yet. Concentrate instead on the central nested function called loop which takes just a unit argument. You can call loop () from within the function read_whole_channel, but it's not defined outside this function. The nested function can access variables defined in the main function (here loop accesses the local names buf and chan).

The form for nested functions is the same as for local named expressions: let name arguments = function-definition in.

You normally indent the function definition on a new line as in the example above, and remember to use let rec instead of let if your function is recursive (as it is in that example).


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Module Option


module Option: sig .. end
Functions for the option type.
Options are an Ocaml standard type that can be either None (undefined) or Some x where x can be any value. 
Options are widely used in Ocaml to represent undefined values (a little like NULL in C, but in a type and
memory safe way). This module adds some functions for working with options.
val may : ('a -> unit) -> 'a option -> unit
may f (Some x) calls f x and may f None does nothing.
val map : ('a -> 'b) -> 'a option -> 'b option
map f (Some x) returns Some (f x) and map None returns None.
val default : 'a -> 'a option -> 'a
default x (Some v) returns v and default x None returns x.
val map_default : ('a -> 'b) -> 'b -> 'a option -> 'b
map_default f x (Some v) returns f v and map_default f x None returns x.
val is_none : 'a option -> bool
is_none None returns true otherwise it returns false.
val is_some : 'a option -> bool
is_some (Some x) returns true otherwise it returns false.
val get : 'a option -> 'a
get (Some x) returns x and get None raises No_value.
exception No_value
Raised when calling get None.

FUNCTIONS:
Functions are values just like any other value in OCaml. What does that mean exactly? This means 
that we can pass functions around as arguments to other functions, that we can store functions in 
data structures, that we can return functions as a result from other functions. 

let double (x : int) : int = 2 * x
let square (x : int) : int = x * x

let quad (x : int) : int = double (double x)
let fourth (x : int) : int = square (square x)

There is an obvious similarity between these two functions: what they do is apply a given function twice to a value. By passing in the function to another function twice as an argument, we can abstract this functionality and thus reuse code:

let twice ((f : int -> int), (x : int)) : int = f (f x)
let quad (x : int) : int = twice (double, x)
let fourth (x : int) : int = twice (square, x)

To avoid polluting the top-level namespace, it can be useful to define the function locally to pass in as an argument. For example:

let fourth (x : int) : int =
  let square (y : int) : int = y * y in
    twice (square, x)

ANONYMOUS FUNCTIONS

let fourth (x : int) : int = twice (fun (y : int) -> y * y, x)

The fun expression creates an anonymous function: a function without a name. The type makes things actually clearer. The return type of an anonymous function is not declared (and is inferred automatically). 

What is the type of 
fun (y : int) -> y = 3 ?
Answer: int -> bool

Notice that the declaration 

let square : int -> int = fun (y : int) -> y * y

has the same effect as

let square (y : int) : int = y * y

In fact, the declaration without fun is just syntactic sugar for the more tedious long definition. (This isn't true for recursive functions, however.)

CURRYING

Anonymous functions are useful for creating functions to pass as arguments to other functions, but are also useful for writing functions that return other functions. Let us rewrite the twice function to take a function as an argument and return a new function that applies the original function twice:

let twice (f : int -> int) =
  fun (x : int) -> f (f x)

let fourth = twice (fun (x : int) -> x * x)
let quad = twice (fun (x : int) -> 2 * x)

Functions that return other functions are so common in functional programming that OCaml provides a special syntax for them.  For example, we could write the twice function above as

let twice (f : int -> int) (x : int) : int = f (f x)


The "second argument" x here is not an argument to twice, but rather an argument to twice f.  The function twice takes only one argument, namely a function f, and returns another function that takes an argument x and returns an int.  The distinction here is critical.

This device is called currying after the logician H. B. Curry. At this point you may be worried about the efficiency of returning an intermediate function when you're just going to pass all the arguments at once anyway. Run a test if you want (you should find out how to do this), but rest assured that curried functions are entirely normal in functional languages, so there is no speed penalty worth worrying about.

The type of twice is (int -> int) -> int -> int.  The -> operator is right associative, so this is equivalent to (int -> int) -> (int -> int).  Notice that if we had left out the parentheses on the type of f, we would no longer long have a function that took in another function as an argument, since int -> int -> int -> int is equivalent to int -> (int -> (int -> int)).

Here are more examples of useful higher-order functions that we will leave you to ponder (and try out at home):

let compose ((f, g) : (int -> int) * (int -> int)) (x : int) : int = f (g x)

let rec ntimes ((f, n) : (int -> int) * int) =
  if n = 0
  then (fun (x : int) -> x)
  else compose (f, ntimes (f, n - 1))

///////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
LIST FUNCTIONS

module List: sig .. end
List operations.
Some functions are flagged as not tail-recursive. A tail-recursive function uses constant stack space, while a non-tail-recursive function uses stack space proportional to the length of its list argument, which can be a problem with very long lists. When the function takes several list arguments, an approximate formula giving stack usage (in some unspecified constant unit) is shown in parentheses.

The above considerations can usually be ignored if your lists are not longer than about 10000 elements.

val length : 'a list -> int
Return the length (number of elements) of the given list.

val cons : 'a -> 'a list -> 'a list
cons x xs is x :: xs

Since 4.03.0

val hd : 'a list -> 'a
Return the first element of the given list. Raise Failure "hd" if the list is empty.

val tl : 'a list -> 'a list
Return the given list without its first element. Raise Failure "tl" if the list is empty.

val nth : 'a list -> int -> 'a
Return the n-th element of the given list. The first element (head of the list) is at position 0. Raise Failure 
"nth" if the list is too short. Raise Invalid_argument "List.nth" if n is negative.

val rev : 'a list -> 'a list
List reversal.

val append : 'a list -> 'a list -> 'a list
Concatenate two lists. Same as the infix operator @. Not tail-recursive (length of the first argument).

val rev_append : 'a list -> 'a list -> 'a list
List.rev_append l1 l2 reverses l1 and concatenates it to l2. This is equivalent to List.rev l1 @ l2, but rev_append is tail-recursive and more efficient.

val concat : 'a list list -> 'a list
Concatenate a list of lists. The elements of the argument are all concatenated together (in the same order) to give the result. Not tail-recursive (length of the argument + length of the longest sub-list).

val flatten : 'a list list -> 'a list
An alias for concat.

Iterators

val iter : ('a -> unit) -> 'a list -> unit
List.iter f [a1; ...; an] applies function f in turn to a1; ...; an. It is equivalent to begin f a1; f a2; ...; f an; () end.

val iteri : (int -> 'a -> unit) -> 'a list -> unit
Same as List.iter, but the function is applied to the index of the element as first argument (counting from 0), and the element itself as second argument.
Since 4.00.0

val map : ('a -> 'b) -> 'a list -> 'b list
List.map f [a1; ...; an] applies function f to a1, ..., an, and builds the list [f a1; ...; f an] with the results returned by f. Not tail-recursive.

val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
Same as List.map, but the function is applied to the index of the element as first argument (counting from 0), and the element itself as second argument. Not tail-recursive.
Since 4.00.0

val rev_map : ('a -> 'b) -> 'a list -> 'b list
List.rev_map f l gives the same result as List.rev (List.map f l), but is tail-recursive and more efficient.

val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
List.fold_left f a [b1; ...; bn] is f (... (f (f a b1) b2) ...) bn.

val fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
List.fold_right f [a1; ...; an] b is f a1 (f a2 (... (f an b) ...)). Not tail-recursive.

Iterators on two lists

val iter2 : ('a -> 'b -> unit) -> 'a list -> 'b list -> unit
List.iter2 f [a1; ...; an] [b1; ...; bn] calls in turn f a1 b1; ...; f an bn. Raise Invalid_argument if the two lists are determined to have different lengths.

val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
List.map2 f [a1; ...; an] [b1; ...; bn] is [f a1 b1; ...; f an bn]. Raise Invalid_argument if the two lists are determined to have different lengths. Not tail-recursive.

val rev_map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
List.rev_map2 f l1 l2 gives the same result as List.rev (List.map2 f l1 l2), but is tail-recursive and more efficient.

val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b list -> 'c list -> 'a
List.fold_left2 f a [b1; ...; bn] [c1; ...; cn] is f (... (f (f a b1 c1) b2 c2) ...) bn cn. Raise Invalid_argument if the two lists are determined to have different lengths.

val fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
List.fold_right2 f [a1; ...; an] [b1; ...; bn] c is f a1 b1 (f a2 b2 (... (f an bn c) ...)). Raise Invalid_argument if the two lists are determined to have different lengths. Not tail-recursive.

List scanning

val for_all : ('a -> bool) -> 'a list -> bool
for_all p [a1; ...; an] checks if all elements of the list satisfy the predicate p. That is, it returns (p a1) && (p a2) && ... && (p an).

val exists : ('a -> bool) -> 'a list -> bool
exists p [a1; ...; an] checks if at least one element of the list satisfies the predicate p. That is, it returns (p a1) || (p a2) || ... || (p an).

val for_all2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
Same as List.for_all, but for a two-argument predicate. Raise Invalid_argument if the two lists are determined to have different lengths.

val exists2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
Same as List.exists, but for a two-argument predicate. Raise Invalid_argument if the two lists are determined to have different lengths.

val mem : 'a -> 'a list -> bool
mem a l is true if and only if a is equal to an element of l.

val memq : 'a -> 'a list -> bool
Same as List.mem, but uses physical equality instead of structural equality to compare list elements.

List searching

val find : ('a -> bool) -> 'a list -> 'a
find p l returns the first element of the list l that satisfies the predicate p. Raise Not_found if there is no value that satisfies p in the list l.

val filter : ('a -> bool) -> 'a list -> 'a list
filter p l returns all the elements of the list l that satisfy the predicate p. The order of the elements in the input list is preserved.

val find_all : ('a -> bool) -> 'a list -> 'a list
find_all is another name for List.filter.

val partition : ('a -> bool) -> 'a list -> 'a list * 'a list
partition p l returns a pair of lists (l1, l2), where l1 is the list of all the elements of l that satisfy the predicate p, and l2 is the list of all the elements of l that do not satisfy p. The order of the elements in the input list is preserved.

Association lists

val assoc : 'a -> ('a * 'b) list -> 'b
assoc a l returns the value associated with key a in the list of pairs l. That is, assoc a [ ...; (a,b); ...] = b if (a,b) is the leftmost binding of a in list l. Raise Not_found if there is no value associated with a in the list l.

val assq : 'a -> ('a * 'b) list -> 'b
Same as List.assoc, but uses physical equality instead of structural equality to compare keys.

val mem_assoc : 'a -> ('a * 'b) list -> bool
Same as List.assoc, but simply return true if a binding exists, and false if no bindings exist for the given key.

val mem_assq : 'a -> ('a * 'b) list -> bool
Same as List.mem_assoc, but uses physical equality instead of structural equality to compare keys.

val remove_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list
remove_assoc a l returns the list of pairs l without the first pair with key a, if any. Not tail-recursive.

val remove_assq : 'a -> ('a * 'b) list -> ('a * 'b) list
Same as List.remove_assoc, but uses physical equality instead of structural equality to compare keys. Not tail-recursive.

Lists of pairs

val split : ('a * 'b) list -> 'a list * 'b list
Transform a list of pairs into a pair of lists: split [(a1,b1); ...; (an,bn)] is ([a1; ...; an], [b1; ...; bn]). Not tail-recursive.

val combine : 'a list -> 'b list -> ('a * 'b) list
Transform a pair of lists into a list of pairs: combine [a1; ...; an] [b1; ...; bn] is [(a1,b1); ...; (an,bn)]. Raise Invalid_argument if the two lists have different lengths. Not tail-recursive.

Sorting

val sort : ('a -> 'a -> int) -> 'a list -> 'a list
Sort a list in increasing order according to a comparison function. The comparison function must return 0 if its arguments compare as equal, a positive integer if the first is greater, and a negative integer if the first is smaller (see Array.sort for a complete specification). For example, compare is a suitable comparison function. The resulting list is sorted in increasing order. List.sort is guaranteed to run in constant heap space (in addition to the size of the result list) and logarithmic stack space.
The current implementation uses Merge Sort. It runs in constant heap space and logarithmic stack space.

val stable_sort : ('a -> 'a -> int) -> 'a list -> 'a list
Same as List.sort, but the sorting algorithm is guaranteed to be stable (i.e. elements that compare equal are kept in their original order) .
The current implementation uses Merge Sort. It runs in constant heap space and logarithmic stack space.

val fast_sort : ('a -> 'a -> int) -> 'a list -> 'a list
Same as List.sort or List.stable_sort, whichever is faster on typical input.

val sort_uniq : ('a -> 'a -> int) -> 'a list -> 'a list
Same as List.sort, but also remove duplicates.
Since 4.02.0

val merge : ('a -> 'a -> int) -> 'a list -> 'a list -> 'a list
Merge two lists: Assuming that l1 and l2 are sorted according to the comparison function cmp, merge cmp l1 l2 will return a sorted list containting all the elements of l1 and l2. If several elements compare equal, the elements of l1 will be before the elements of l2. Not tail-recursive (sum of the lengths of the arguments).

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

Defining constants and functions in Caml is done through the let keyword.
• let x = 2;; defines a constant x with value 2.
• let double a = 2 ∗ a;; defines a function double that returns the double of its parameter.

Another possible syntax is let double = fun a → 2 ∗ a;;.
• let x = <value> in <expr>;; binds x to value, but only in expr.

2 The OCaml interpreter
The command ocaml (without parameters) launches the Caml interpreter. You can type
Caml instructions inside and immediately get their result—it is highly recommended to
use the ledit command with ocaml as argument to make interacting with this interpreter
bearable.

For instance, you can type:
# let x = 2 ;;
val x : int = 2
# let double = fun a → 2 ∗ a ;;
val ouble : int → int = <fun>
The shell returns information about the newly defined object in the form 
val <name> : <type> = <value>.

Function types are of the form <type_param> → <type_result>.

You may want to import a source file in the interpreter. You can do so by using the
command #use ”file.ml”;;. You can also directly run a file outside the interpreter by:
ocaml file.ml. If you are using an external module, you might need to provide the
ocaml command with a path, e.g. ocaml -I +labltk to add the LablTK library.


3 Polymorphism, Pairs
Let us look at the identity function:
# let id = fun x → x
val id : ’ a → ’ a = <fun>

This is a polymorphic function. It can take any type as input, and returns a value
of the same type.
Given x and y, a pair can be built by using the notation (x, y). If x is of type ’a and
y of type ’b, then (x, y) is of product type ’a ∗ ’b.

4 Curryfication
Let us redefine addition:
# let addition x y = x + y ;;
val addition : int → int → int = <fun>
# addition 2 ;;
− : int → int = <fun>
Defined like this, addition is a function of type int → (int → int), that is, a function
that takes an integer and returns ‘a function that takes an integer and returns an integer’.
This is called curryfication. This is the preferred way of defining functions with more
than one parameter (instead of using pairs).

5 Recursion
If you want to define a recursive function, 
then the rec keyword must be added:

# let f x = if x = 0 then 0 else ( 1 + f ( x − 1 ) ) ;;
Error : Unbound value f
# let rec f x = if x=0 then 0 else ( 1 + f ( x − 1 ) ) ;;
val f : int → int = <fun>

6 Sum Types, Pattern Matching
A sum type can be defined by the following syntax:
# type sumtype = FirstCase [of type] |
> SecondCase [of type] . . . |
> LastCase [of type]

This can be recursive. For example, Caml lists could be defined by:
# type ’a list = Nil | Cons of ’a ∗ ’a list
Then, you could build a list by using the syntax Cons(1, Cons(2, Nil)).

7 References
Up to now, we only used constants, and never mutable variables. So, how can we modify
a variable value? A possible answer could be that you should never use mutable variables
in Caml, but their use can sometimes be justified. To define a mutable variable (called
a reference), do:
# let x = ref (0) ;;
val x : int ref = { contents = 0}
You can assign and retrieve the value of a reference by using := and !:
# x := 1 ;;
# !x ;;
− int = 1

Syntax
Implementations are in .ml files, interfaces are in .mli files.
Comments can be nested, between delimiters (*...*)
Integers: 123, 1_000, 0x4533, 0o773, 0b1010101
Chars: ’a’, ’\255’, ’\xFF’, ’\n’ Floats: 0.1, -1.234e-34

Data Types
unit Void, takes only one value: ()
int Integer of either 31 or 63 bits, like 32
int32 32 bits Integer, like 32l
int64 64 bits Integer, like 32L
float Double precision float, like 1.0
bool Boolean, takes two values: true or false
char Simple ASCII characters, like ’A’
string Strings of chars, like "Hello"
’a list Lists, like head :: tail or [1;2;3]
’a array Arrays, like [|1;2;3|]
t1 * ... * tn Tuples, like (1,"foo", ’b’)

Constructed Types
type record = new record type
{ field1 : bool; immutable field
mutable field2 : int; } mutable field
type enum = new variant type
| Constant Constant constructor
| Param of string Constructor with arg
| Pair of string * int Constructor with args

Constructed Values
let r = { field1 = true; field2 = 3; }
let r’ = { r with field1 = false }
r.field2 <- r.field2 + 1;
let c = Constant
let c’ = Param "foo"
let c’’ = Pair ("bar",3)

References, Strings and Arrays
let x = ref 3 integer reference (mutable)
x := 4 reference assignation
print_int !x; reference access
s.[0] string char access
s.[0] <- ’a’ string char modification
t.(0) array element access
t.(0) <- x array element modification

Imports — Namespaces
open Unix;; global open
let open Unix in expr local open
Unix.(expr) local open

Functions
let f x = expr function with one arg
let rec f x = expr recursive function
apply: f x
let f x y = expr with two args
apply: f x y
let f (x,y) = expr with a pair as arg
apply: f (x,y)
List.iter (fun x -> e) l anonymous function
let f= function None -> act function definition
| Some x -> act by cases
apply: f (Some x)
let f ~str ~len = expr with labeled args
apply: f ~str:s ~len:10
apply (for ~str:str): f ~str ~len
let f ?len ~str = expr with optional arg (option)
let f ?(len=0) ~str = expr optional arg default
apply (with omitted arg): f ~str:s
apply (with commuting): f ~str:s ~len:12
apply (len: int option): f ?len ~str:s
apply (explicitely ommited): f ?len:None ~str:s
let f (x : int) = expr arg has constrainted type
let f : ’a ’b. ’a*’b -> ’a function with constrainted
= fun (x,y) -> x polymorphic type

Modules
module M = struct .. end module definition
module M: sig .. end= struct .. end module and signature
module M = Unix module renaming
include M include items from
module type Sg = sig .. end signature definition
module type Sg = module type of M signature of module
let module M = struct .. end in .. local module
let m = (module M : Sg) to 1st-class module
module M = (val m : Sg) from 1st-class module
module Make(S: Sg) = struct .. end functor
module M = Make(M’) functor application
Module type items:
val, external, type, exception, module, open, include,
class

Pattern-matching
match expr with
| pattern -> action
| pattern when guard -> action conditional case
| _ -> action default case
Patterns:
| Pair (x,y) -> variant pattern
| { field = 3; _ } -> record pattern
| head :: tail -> list pattern
| [1;2;x] -> list-pattern
| (Some x) as y -> with extra binding
| (1,x) | (x,0) -> or-pattern

Conditionals
Structural Physical
= == Polymorphic Equality
<> != Polymorphic Inequality
Polymorphic Generic Comparison Function: compare
x < y x = y x > y
compare x y -1 0 1
Other Polymorphic Comparisons : >, >=, <, <=
Loops
while cond do ... done;
for var = min_value to max_value do ... done;
for var = max_value downto min_value do ... done;
Exceptions
exception MyExn new exception
exception MyExn of t * t’ same with arguments
exception MyFail = Failure rename exception with args
raise MyExn raise an exception
raise (MyExn (args)) raise with args
try expression
with Myn -> ...
catch MyException if raised
in expression
Objects and Classes
class virtual foo x = virtual class with arg
let y = x+2 in init before object creation
object (self: ’a) object with self reference
val mutable variable = x mutable instance variable
method get = variable accessor
method set z =
variable <- z+y mutator
method virtual copy : ’a virtual method
initializer init after object creation
self#set (self#get+1)
end
class bar = non-virtual class
let var = 42 in class variable
fun z -> object constructor argument
inherit foo z as super inheritance and ancestor reference
method! set y = method explicitely overriden
super#set (y+4) access to ancestor
method copy = {< x = 5 >} copy with change
end
let obj = new bar 3 new object
obj#set 4; obj#get method invocation
let obj = object .. end immediate object
Polymorphic variants
type t = [ ‘A | ‘B of int ] closed variant
type u = [ ‘A | ‘C of float ]
type v = [ t | u | ] union of variants
let f : [< t ] -> int = function argument must be
| ‘A -> 0 | ‘B n -> n a subtype of t
let f : [> t ] -> int = function t is a subtype
| ‘A -> 0 | ‘B n -> n | _ -> 1 of the argument


Side effects

Up until now, we have only shown you pure functional programming.  But in certain cases, imperative programming is unavoidable.  One such case is printing a value to the screen.  By now you may have found it difficult to debug your OCaml code without any way to display intermediate values on the screen.  OCaml provides the function print_string : string -> unit to print a string to the screen.
Printing to the screen is called a side-effect because it alters the state of the computer.  Until now we have been writing functions that do not change any state but merely compute some value.  Later on we will show you more examples of side-effects, but printing will suffice for now.
Because of OCaml's type system, print_string is not overloaded like Java's System.out.println.  To print an int, float, bool, etc, you must first convert it to a string.  Fortunately, there are built-in functions to do this conversion. For example, string_of_int converts an int to a string.  So to print 3, we can write print_string (string_of_int 3).  The parentheses are needed here bacause OCaml evaluates expressions left to right.
So how can you put print statements in your code?  There are two ways.  The first is with a let expression. These can be placed inside other let expressions, allowing you to print intermediate values.
let x = 3 in
  let () = print_string ("Value of x is " ^ (string_of_int x)) in
  x + 1
  
There is a second way as well.  For this we introduce new syntax.
e ::= ...  |  ( e1; ... ; en )
This expression tells OCaml to evaluate expressions e1,...,en in order and return the result of evaluating en.  So we could write our example as
let x = 3 in
  (print_string ("Value of x is " ^ (string_of_int x));
   x + 1)
Exceptions

To handle errors, OCaml provides built in exceptions, much like Java.  To declare an exception named Error, you write
exception Error
Then to throw the exception, we use the raise keyword.  An example using the square root function is
let sqrt1 (x : float) : float =
  if x < 0 then raise Error
  else sqrt x
The type of an exception matches the code in which the exception is thrown.  So for example, in the sqrt1 function, the type of Error will be float since the expression must evaluate to a real.
Exceptions can also carry values.  An example is the built-in exception Failure, defined as
exception Failure of string
To raise this exception, we write
raise (Failure "Some error message")
We can also catch exceptions by use of the try-with keywords.  It is important not to abuse this capability.  Excessive use of exceptions can lead to unreadable spaghetti code.  For this class, it will probably never be necessary to handle an exception.  Exceptions should only be raised in truly exceptional cases, that is, when some unrecoverable damage has been done.  If you can avoid an exception by checking bounds or using options, this is far preferable.  Refer to the OCaml style guide for more examples and info on how to use exceptions properly.

PATTERN Matching
	

Quick Solution

You just need to add parentheses (or begin/end) around the inner match:

let rec filter exp =
    match exp with
    | Var v -> Var v
    | Sum (e1, e2) -> Sum (e1, e2)
    | Prod (e1, e2) -> Prod (e1, e2)
    | Diff (e1, e2) ->
            (match e2 with
             | Sum (e3, e4) -> filter (diffRule e2)
             | Diff (e3, e4) -> filter (diffRule e2)
             | _ -> filter e2)
    | Quot (e1, e2) ->
            (match e2 with
             | Quot (e3, e4) -> filter (quotRule e2)
             | Prod (e3, e4) -> filter (quotRule e2)
             | _ -> filter e2)
;;

Simplifications

In your particular case there is no need for a nested match. You can just use bigger patterns. You can also eliminate the duplication in the nested rules using "|" ("or") patterns:

let rec filter exp =
    match exp with
    | Var v -> Var v
    | Sum (e1, e2) -> Sum (e1, e2)
    | Prod (e1, e2) -> Prod (e1, e2)
    | Diff (e1, (Sum (e3, e4) | Diff (e3, e4) as e2)) -> filter (diffRule e2)
    | Diff (e1, e2) -> filter e2
    | Quot (e1, (Quot (e3, e4) | Prod (e3, e4) as e2)) -> filter (quotRule e2)
    | Quot (e1, e2) -> filter e2
;;

You can make it even more readable by replacing unused pattern variables with _ (underscore). This also works for whole sub patterns such as the (e3,e4) tuple:

let rec filter exp =
    match exp with
    | Var v -> Var v
    | Sum (e1, e2) -> Sum (e1, e2)
    | Prod (e1, e2) -> Prod (e1, e2)
    | Diff (_, (Sum _ | Diff _ as e2)) -> filter (diffRule e2)
    | Diff (_, e2) -> filter e2
    | Quot (_, (Quot _ | Prod _ as e2)) -> filter (quotRule e2)
    | Quot (_, e2) -> filter e2
;;

In the same way, you can proceed simplifying. For example, the first three cases (Var, Sum, Prod) are returned unmodified, which you can express directly:

let rec filter exp =
    match exp with
    | Var _ | Sum _ | Prod _ as e -> e
    | Diff (_, (Sum _ | Diff _ as e2)) -> filter (diffRule e2)
    | Diff (_, e2) -> filter e2
    | Quot (_, (Quot _ | Prod _ as e2)) -> filter (quotRule e2)
    | Quot (_, e2) -> filter e2
;;

Finally, you can replace e2 by e and replace match with the function shortcut:

let rec filter = function
    | Var _ | Sum _ | Prod _ as e -> e
    | Diff (_, (Sum _ | Diff _ as e)) -> filter (diffRule e)
    | Diff (_, e) -> filter e
    | Quot (_, (Quot _ | Prod _ as e)) -> filter (quotRule e)
    | Quot (_, e) -> filter e
;;

OCaml's pattern syntax is nice, isn't it?

up vote
53
down vote
accepted
	

Quick Solution

You just need to add parentheses (or begin/end) around the inner match:

let rec filter exp =
    match exp with
    | Var v -> Var v
    | Sum (e1, e2) -> Sum (e1, e2)
    | Prod (e1, e2) -> Prod (e1, e2)
    | Diff (e1, e2) ->
            (match e2 with
             | Sum (e3, e4) -> filter (diffRule e2)
             | Diff (e3, e4) -> filter (diffRule e2)
             | _ -> filter e2)
    | Quot (e1, e2) ->
            (match e2 with
             | Quot (e3, e4) -> filter (quotRule e2)
             | Prod (e3, e4) -> filter (quotRule e2)
             | _ -> filter e2)
;;

Simplifications

In your particular case there is no need for a nested match. You can just use bigger patterns. You can also eliminate the duplication in the nested rules using "|" ("or") patterns:

let rec filter exp =
    match exp with
    | Var v -> Var v
    | Sum (e1, e2) -> Sum (e1, e2)
    | Prod (e1, e2) -> Prod (e1, e2)
    | Diff (e1, (Sum (e3, e4) | Diff (e3, e4) as e2)) -> filter (diffRule e2)
    | Diff (e1, e2) -> filter e2
    | Quot (e1, (Quot (e3, e4) | Prod (e3, e4) as e2)) -> filter (quotRule e2)
    | Quot (e1, e2) -> filter e2
;;

You can make it even more readable by replacing unused pattern variables with _ (underscore). This also works for whole sub patterns such as the (e3,e4) tuple:

let rec filter exp =
    match exp with
    | Var v -> Var v
    | Sum (e1, e2) -> Sum (e1, e2)
    | Prod (e1, e2) -> Prod (e1, e2)
    | Diff (_, (Sum _ | Diff _ as e2)) -> filter (diffRule e2)
    | Diff (_, e2) -> filter e2
    | Quot (_, (Quot _ | Prod _ as e2)) -> filter (quotRule e2)
    | Quot (_, e2) -> filter e2
;;

In the same way, you can proceed simplifying. For example, the first three cases (Var, Sum, Prod) are returned unmodified, which you can express directly:

let rec filter exp =
    match exp with
    | Var _ | Sum _ | Prod _ as e -> e
    | Diff (_, (Sum _ | Diff _ as e2)) -> filter (diffRule e2)
    | Diff (_, e2) -> filter e2
    | Quot (_, (Quot _ | Prod _ as e2)) -> filter (quotRule e2)
    | Quot (_, e2) -> filter e2
;;

Finally, you can replace e2 by e and replace match with the function shortcut:

let rec filter = function
    | Var _ | Sum _ | Prod _ as e -> e
    | Diff (_, (Sum _ | Diff _ as e)) -> filter (diffRule e)
    | Diff (_, e) -> filter e
    | Quot (_, (Quot _ | Prod _ as e)) -> filter (quotRule e)
    | Quot (_, e) -> filter e
;;

OCaml's pattern syntax is nice, isn't it?

/////////////////////////////////////////////////////////////////////////

ocaml main.ml => runs file

ocamlc -o main main.ml => Compiles file so you can run it by typing
./main

let () = Printf.printf "Hello World"

(* This is a comment *)

(*
* (*This is a nested comment*)
*)

main.mli interface file (mli file contains interfaces and types)
val main: unit -> unit

TO compile;

ocamlc -o main main.mli main.ml
You can ask compiler to get interface file
If you dont want some helpers to expose, or protect yourself, write interface file

main.ml file ###############################

let main () =
(   Printf.printf "HelloWorld \n"
    ; Printf.printf "Hello CS240E\n"
    3 (* Return this from main*)
)

let () = 
    main ()
