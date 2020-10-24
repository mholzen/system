# Principles

## data driven, as much as possible

- data should drive behaviour: e.g. name -> resource list -> stat list -> link link -> html


## functional, as much as possible



# Functions

  l is a literal; synchronous delivery
  s is a stream; stream here implies async delivery; the stream may have many, 1 or 0 element

## Literal functions

  mappers        f(literal) -> literal
  generators     f(literal) -> stream

TODO: should we distinguish between sync and async mappers?
    mappers.async

## Stream functions

  reducers       f(stream) -> literal
  transformers   f(stream) -> stream

## Mapper functions
  apply     (mapper, literal)   -> literal
  map       (mapper, stream)    -> stream
  map       (mapper, iterable)    -> stream
  applyresolve (mapper, literal)   -> literal

## Generator functions
  generate  (generator, literal) -> stream
  flatmap   (generator, stream) -> stream   # can be composed with `flatten`

## Reducer functions
  reduce    (reducer, stream) -> literal

## Transformer functions

  transform (transformer, stream) -> stream

  filter