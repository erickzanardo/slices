# Slices

Slices is a minimalist state manegement, focused specifically for applications that needs a global
state where different "pieces" of the application watches for change on the same state source.

It is somehow inspired by Redux and relies a lot on immutability and equatability.

## Motivation

This package has a very simple and somehow "naive" implementation of a state manegement, it is
a simple code that was born inside [Fire Atlas Editor](https://github.com/flame-engine/fire-atlas)
and since it worked quite nice for that type of application, the author extracted it to a package
to be used on future applications that will have similar needs.

So keep that in mind if you decide to use this package. Good alternatives for this would be

 - [Fountain](https://github.com/aloisdeniel/fountain): Has a similar idea to this package, but more mature
 - [Flutter Bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc): A very mature and popular state manegement solution in Flutter

## How to use

 Better docs may be available in the future. For now, to see how to use this, check the [example](./example).
