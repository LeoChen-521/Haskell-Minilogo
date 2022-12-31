% Group members:Huayue Sun, Xiaoru Chen, Chun-Han Chen
%  * Huayue Sun (ID:934068509) 
%  * Xiaoru Chen (ID:934339052)
%  * Chun-Han Chen (ID:934333221)
%
% Grading notes: 10pts total
%  * Part 1: 6pts (1pt each)
%  * Part 2: 4pts (3pts for cmd, 1pt for prog)


% Part 1. It's a bird-eat-bug world out there!

% A small database of animals. Each relation gives the animal's name,
% it's habitat, and its biological class.
animal(cranefly, trees, insects).
animal(duck, ponds, birds).
animal(minnow, ponds, fish).
animal(scrubjay, trees, birds).
animal(squirrel, trees, mammals).
animal(waterstrider, ponds, insects).
animal(woodpecker, trees, birds).

% A small database capturing what each animal eats. Note that most animals eat
% more than one kind of food, but craneflies don't eat anything after they
% reach adulthood!
diet(scrubjay, insects).
diet(scrubjay, seeds).
diet(squirrel, nuts).
diet(squirrel, seeds).
diet(duck, algae).
diet(duck, fish).
diet(duck, insects).
diet(minnow, algae).
diet(minnow, insects).
diet(waterstrider, insects).
diet(woodpecker, insects).

% A binary predicate that includes all of the animals and where they live.
habitat(Animal, Where) :- animal(Animal, Where, _).

% A binary predicate that includes each animal and its biological class.
class(Animal, Class) :- animal(Animal, _, Class).


% 1. Define a predicate neighbor/2 that determines whether two animals live
%    in the same habitat. Note that two animals of the same kind always
%    live in the same habitat.
neighbor(X, Y) :- habitat(X,Where), habitat(Y,Where).


% 2. Define a predicate related/2 that includes all pairs of animals that
%    are in the same biological class but are not the same kind of animal.
related(X, Y) :- class(X, Class), class(Y, Class), X \= Y.

% 3. Define a predicate competitor/3 that includes two kinds of animals and
%    the food they compete for. Two animals are competitors if they live in
%    the same place and eat the same food.
competitor(X, Y, Food) :- neighbor(X, Y), diet(X, Food), diet(Y, Food).

% 4. Define a predicate would_eat/2 that includes all pairs of animals where
%    the first animal would eat the second animal (because the second animal
%    is a kind of food it eats), if it could.
would_eat(X,Y) :- diet(X,Food), class(Y,Class),Food = Class.


% 5. Define a predicate does_eat/2 that includes all pairs of animals where
%    the first animal would eat the second, and both animals live in the same
%    place, so it probably does.
does_eat(X,Y) :- would_eat(X, Y), neighbor(X, Y).

% 6. Define a predicate cannibal/1 that includes all animals that might eat
%    their own kind--eek!
cannibal(X) :- would_eat(X,X).


% Part 2. Implementing a stack language

% A slightly larger example program to use in testing.
example(P) :-
  P = [ 2, 3, 4, lte,            % [tru, 2]
        if([5, 6, add], [fls]),  % [11, 2]
        3, swap,                 % [11, 3, 2]
        4, 5, add,               % [9, 11, 3, 2]
        lte, if([tru], [mul]),   % [6]
        "whew!", swap,           % [6, "whew!"]
        "the answer is" ].       % ["the answer is", 6, "whew!"]

% 1. Define the predicate `cmd/3`.

cmd(C, S1, S2) :- number(C), S2 = [C|S1].
cmd(C, S1, S2) :- string(C), S2 = [C|S1].
cmd(X,Y,[X|Y]):- X \= dup, X \= swap, X \= add, X \= mul, X \= lte, X \= if(_,_).

cmd(add, [X, Y|T], S2) :- S2 = [Sum|T], Sum is X + Y.
cmd(mul, [X, Y|T], S2) :- S2 = [Product|T], Product is X * Y.

cmd(lte, [X, Y|T], S2) :- S2 = [tru|T], X >= Y.
cmd(lte, [X, Y|T], S2) :- S2 = [fls|T], X < Y.

cmd(dup, [X|T], S2) :- S2 = [X,X|T].
cmd(swap, [X, Y|T], S2) :- S2 = [Y,X|T].

cmd(if(P1,_),[tru|T],S2) :- prog(P1,T,S2).
cmd(if(_,P2),[fls|T],S2) :- prog(P2,T,S2).

% 2. Define the predicate `prog/3`.
%
prog([Cmd], S1, S2) :- cmd(Cmd, S1, S2).
prog([Cmd|Cmds], S1, S3) :- cmd(Cmd, S1, S2), prog(Cmds, S2, S3).
