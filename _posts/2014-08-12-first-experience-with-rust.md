---
permalink: "/{{ year }}/{{ month }}/{{ day }}/first-experience-with-rust"
title: first experience with Rust
published_date: "2014-08-12 13:25:00 +0200"
layout: post.liquid
data:
  route: blog
---
------

**tl;dr:** Rust code for the SIMPLE language available [in a git-repo][git-repo].

------


I had some spare time yesterday after I finished my last-ever bachelor exam (yey!) so I took my chances and started to write some [Rust][].
Just two days ago I also started to read [Tom Stuart][tomstuart]'s book ["Understanding Computation"][computationbook].
In Chapter 1, "The Meaning of Programs", he introduces a small and simple programming language called SIMPLE. By using a small-step approach and Ruby as the language of implementation he builds up the virtual machine to execute an already built AST. Go read the first chapter, it's in the sample (and thus free) to get a better idea.
The [original code](https://github.com/tomstuart/computationbook/tree/master/the_meaning_of_programs) is some simple to understand Ruby, just under 200 lines.

It has:

* Numbers
* Booleans
* Variables
* Assignments
* Addition and Multiplication
* less-than comparison
* if-else clause
* while loop

That's nearly all it takes for a programming language.
Usage of the Ruby code looks like this:

~~~ruby
>> Machine.new(
    Sequence.new(
      Assign.new(:x, Number.new(3)),
      Assign.new(:res, Add.new(Add.new(Number.new(38), Variable.new(:x)), Variable.new(:y)))
    )
    { :y => Number.new(1) }
  ).run
x = 3; res = 38 + x + y, {:y=>«1»}
do-nothing; res = 38 + x + y, {:y=>«1», :x=>«3»}
res = 38 + x + y, {:y=>«1», :x=>«3»}
res = 38 + 3 + y, {:y=>«1», :x=>«3»}
res = 41 + y, {:y=>«1», :x=>«3»}
res = 41 + 1, {:y=>«1», :x=>«3»}
res = 42, {:y=>«1», :x=>«3»}
do-nothing, {:y=>«1», :x=>«3», :res=>«42»}
=> nil
~~~

Because we build the AST by ourself instead of taking a lexer/parser to do the job, the example takes a bit more code than you would think.
But it still is simple enough to grasp.

Now the same small sample "programm" in Rust:

~~~rust
let mut env = HashMap::new();
env.insert("y".to_string(), number!(1));

let mut m = Machine::new(
    sequence!(
        assign!("x", number!(3)),
        assign!("res", add!(add!(number!(38), variable!("x")), variable!("y")))
        
      ),
    env);

m.run();
// Add this point `res` in the HashMap will be `Number(42)`
~~~

Yep, not much of a difference. It will even output the same steps as above (but without the environment hash).
The full code is available in [a git repository][git-repo].

I don't want to explain each and every peace of that code, but instead focus on what I learned about Rust.

## Use the docs

There are [API docs][apidocs] as well as a [Reference Manual][refman] and even more [general documentation][gendoc]
(all links are the nightly versions as I use that).
But Rust is in active development. Things are changing fast. Documentation on features might be outdated (especially older blog posts or StackOverflow answers) or even missing (but it gets better with [Steven Klabnik][stevenklabnik] working full-time at it).
Get familiar with the Standard Library and its docs. Often you need to read that to fully understand how to use a certain data structure or how to implement a specific trait for your code.

Document your code. Rust makes that real easy. Comments are parsed as markdown (you know that already, don't you?) and `rustdoc` generates a static HTML site from your code (all the API docs are generated this way).

## Don't fear the errors

The error and warning messages of the Rust compiler are great. Most often they actually find simple mistakes (wrong variable name, missing self) and actually tell you how to fix it.
Other times, even though the message is quite clear, it's not clear how to properly fix your code to compile.
But _when_ it compiles, it actually did what I wanted it to do.
Most of my errors or "design mistakes" were caught by the explicit type system and safeness checks.
Everytime I googled an error message I ended up in the GitHub issue tracker of Rust. Sometimes this helped as it clearly discussed the problem and gave useful answers.

## Test your stuff

Rust comes with in-built test support. Simply tag code with `#[test]` and it will only be compiled and run if you pass the `--test` flag to the compiler (or use `cargo test`).
It was the first time that I actually ended up doing TDD: First a small test, see it fail, fix the code, see the test pass, refactor if needed. Extend tests.
Just super convenient, but make sure to extract your tests in larger code bases (huge files won't help anyone).

## Use language features

Pattern matching is nice. It often saves you one or two more if statements. Just deconstruct your object right in the pattern match.
Macros are a nice addition, too. The pure Rust syntax might be a little bit verbose sometimes, so just save some keystrokes for your convenience and use a short macro (please, don't over-do it, the docs explicitely say that macros are harder to debug than pure Rust code).
Make sure you're editor has proper language support, [rust.vim][] worked quite good for me and did everything right from the start.

I still need to learn about a few Rust features.

* I still don't know how to properly seperate your stuff in modules and seperate source files
* I have no idea about proper pointer borrowing and other safety features
* I've got no idea how lifetimes work and the syntax is not the best in my opinion (`'` as the marker to indicate a lifetime name).


## Summing it all up

Yes, Rust is more verbose than Ruby. Yes, it's much more strict than C or Ruby. Yes, it's not yet ready and changing fast.

But its concepts are nice. More safe and robust code just by more explicit type checks and immutable by default make you think more about the actual application design. They catch errors before you even run the code and make it easy to explicitely state the intent of your code ("code should be self-documenting" ;)).

I don't see me writing lots of Rust code in the near future, but it certainly helps to once in a while have a look at different systems to learn.

[rust]: http://www.rust-lang.org/
[tomstuart]: https://twitter.com/tomstuart
[computationbook]: http://computationbook.com/
[git-repo]: https://github.com/badboy/small-step-simple-rust

[apidocs]: http://doc.rust-lang.org/std/index.html
[refman]: http://doc.rust-lang.org/reference.html
[gendoc]: http://doc.rust-lang.org/index.html
[stevenklabnik]: https://twitter.com/steveklabnik
[rust.vim]: https://github.com/wting/rust.vim
