# Principles

## data driven, as much as possible

- data should drive behaviour: e.g. name -> resource list -> stat list -> link link -> html


## functional, as much as possible



# Functions

  l is a literal; synchronous response
  s is a stream; stream here implies async response; the stream may have many, 1 or 0 element

## Functions that take a Literal

  mappers        f(literal) -> literal
  mappers.async  f(literal) -> literal async
  generators     f(literal) -> stream

## Functions that take a Stream

  reducers       f(stream) -> literal
  transformers   f(stream) -> stream

## Usages of a mapper function
  apply     (mapper, literal)   -> literal
  map       (mapper, stream)    -> stream

## Reducer functions
  reduce    (reducer, stream) -> literal

## Transformer functions
  transform (transformer, stream) -> stream

## Generator functions
  generate  (generator, literal) -> stream

## Composite functions

  flatmap (mapper, stream)->stream

  map   (generator, stream)  -> stream   # can be composed with `flatten`

  flatten
