---
permalink: "/{{ year }}/{{ month }}/{{ day }}/solving-crime-with-logic"
title: "Solving crime with logic"
published_date: "2018-12-24 16:00:00 +0100"
layout: post.liquid
data:
  route: blog
---

Yesterday I came across a short article titled [Solving murder with Prolog][prologpost].
[Ahmed (xmonader)][ahmed] presents his solution to a puzzle using Prolog.

I am currently learning [Alloy][alloy], a language and analyzer for software modeling and wanted to take a try on this puzzle.

[prologpost]: https://xmonader.github.io/prolog/2018/12/21/solving-murder-prolog.html
[ahmed]: https://twitter.com/xmonader
[alloy]: http://alloytools.org/

## The puzzle

To discover who killed Mr. Boddy, you need to learn where each person was, and what weapon was in the room. Clues are scattered throughout the quiz (you cannot solve question 1 until all 10 are read).

* To begin, you need to know the suspects. There are three men (George, John, Robert) and three women (Barbara, Christine, Yolanda). Each person was in a different room (Bathroom, Dining Room, Kitchen, Living Room, Pantry, Study). A suspected weapon was found in each room (Bag, Firearm, Gas, Knife, Poison, Rope). Who was found in the kitchen?
* Clue 1: The man in the kitchen was not found with the rope, knife, or bag. Which weapon, then, which was not the firearm, was found in the kitchen?
* Clue 2: Barbara was either in the study or the bathroom; Yolanda was in the other. Which room was Barbara found in?
* Clue 3: The person with the bag, who was not Barbara nor George, was not in the bathroom nor the dining room. Who had the bag in the room with them?
* Clue 4: The woman with the rope was found in the study. Who had the rope?
* Clue 5: The weapon in the living room was found with either John or George. What weapon was in the living room?
* Clue 6: The knife was not in the dining room. So where was the knife?
* Clue 7: Yolanda was not with the weapon found in the study nor the pantry. What weapon was found with Yolanda?
* Clue 8: The firearm was in the room with George. In which room was the firearm found?
* It was discovered that Mr. Boddy was gassed in the pantry. The suspect found in that room was the murderer. Who, then, do you point the finger towards?

## Alloy 101

I'm skipping an introduction to Alloy, but there is a nice little [online tutorial for Alloy](http://alloytools.org/tutorials/online/) available.
That should give you a background for declarative modeling with Alloy, its syntax and features.

## The crime

Let's solve crime with logic!

We know that there are six suspects (George, John, Robert, Barbara, Christine, Yolanda), six rooms (Bathroom, Dining Room, Kitchen, Living Room, Pantry, Study) and six weapons (Bag, Firearm, Gas, Knife, Poison, Rope).

### The domain

Let's model every item in our domain.
First the persons, of which everyone has exactly one weapon.

```
abstract sig Person {
    weapon: one Weapon
}
```

These are separate into men and women.

```
abstract sig Man extends Person { }
abstract sig Woman extends Person {}
```

The uniojn of all men and women are all persons we know.
We also know exactly which persons exist in our little story.

```
one sig George, John, Robert extends Man {}
one sig Barbara, Christine, Yolanda extends Woman {}
```

Next we have 6 rooms, each one with one person inside:

```
abstract sig Room {
    contains: one Person,
}
one sig Bathroom, Diningroom, Kitchen, Livingroom, Pantry, Study extends Room {}
```

And six weapons:

```
abstract sig Weapon {}
one sig Bag, Firearm, Gas, Knife, Poison, Rope extends Weapon {}
```

The above already guarantuees that there is one person per room and one weapon per person,
but it has nothing to guarantue that everyone holds a different weapon.

```
fact SinglePersonPerRoom {
    all r, r': Room | r != r' implies r.contains != r'.contains
}
fact SingleWeaponPerPerson {
    all p, p': Person | p != p' implies p.weapon != p'.weapon
}
```

### Model

When run as is Alloy will try to find an assignment such that all facts are satisfied.
This leads to a random assignment such as this:

![random assignment of weapons and rooms](https://tmp.fnordig.de/blog/2018-12-24-random-assignment.png)

Now we put every clue into a fact to refine the solution. The final assignment with all clues should lead us to the killer.

#### Clue 1

The man in the kitchen was not found with the rope, knife, or bag.
Which weapon, then, which was not the firearm, was found in the kitchen?

```
fact Clue1 {
    Kitchen.contains in Man
    Kitchen.contains.weapon not in Rope + Knife + Bag + Firearm
}
```

#### Clue 2

Barbara was either in the study or the bathroom; Yolanda was in the other.
Which room was Barbara found in?

As we guarantue exactly one person per room and no one anywhere twice we can specify this clue by stating that Barbara is in either of the rooms and when taking both rooms we have both women.

```
fact Clue2 {
    Study.contains = Barbara or Bathroom.contains = Barbara
    (Study + Bathroom).contains in Barbara+Yolanda
}
```

#### Clue 3

The person with the bag, who was not Barbara nor George, was not in the bathroom nor the dining room.
Who had the bag in the room with them?

Stating that neither Barbara nor George have the bag is the easy part.
For the rest we ensure that the person with the bag is not in either the bathroom or dining room.

```
fact Clue3 {
    Barbara.weapon != Bag
    George.weapon != Bag
    all p: Person, r: Room | p.weapon = Bag and r.contains in p
                                implies not r in Bathroom+Diningroom
}
```

#### Clue 4

The woman with the rope was found in the study. Who had the rope?

```
fact Clue4 {
    Study.contains in Woman
    Study.contains.weapon = Rope
}
```

#### Clue 5

The weapon in the living room was found with either John or George. What weapon was in the living room?

```
fact Clue5 {
    Livingroom.contains in John + George
}
```

#### Clue 6

The knife was not in the dining room. So where was the knife?

```
fact Clue6 {
    Diningroom.contains.weapon != Knife
}
```


#### Clue 7

Yolanda was not with the weapon found in the study nor the pantry. What weapon was found with Yolanda?

```
fact Clue7  {
    not Yolanda in (Study + Pantry).contains
}
```

#### Clue 8

The firearm was in the room with George. In which room was the firearm found?
```
fact Clue8 {
    George.weapon = Firearm
}
```

#### Clue 9

It was discovered that Mr. Boddy was gassed in the pantry.
The suspect found in that room was the murderer. Who, then, do you point the finger towards?

```
fact Clue9 {
    Pantry.contains.weapon = Gas
}
```


### Who killed Mr. Boddy?

When putting the above model into Alloy and running it, it gets to this solution:

![murder solution: Christine killed Mr. Boddy](https://tmp.fnordig.de/blog/2018-12-24-crime-solution.png)

The killer is Christine!

The full code is available in a [new puzzles repository](https://github.com/badboy/puzzles/blob/58df4177f0b82bd615265d993f1f2ff688332228/crime.als).
I am just learning Alloy and I am pretty sure there might be better ways to model this.
