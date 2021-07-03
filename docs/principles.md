# Principles

## data driven, as much as possible

- data should drive behaviour: e.g. name -> resource list -> stat list -> link link -> html


## functional, as much as possible


## Embrace semantics through the Principle of least astonishment (POLA)

By embracing conventions for commonly used software and data patterns, we can
increase development velocity.  We already do this for frequently used concepts
such as files, directory, http requests.  Let's embrace it further for concepts
such as searching, people, organizations, addresses, ...

Examples:
  filenames:
  search semantics: query, sources, matches, location, path

Derived concepts such as ordering, filtering become easier (TODO: justify)

We won't get them right the first time around, so they need to be easily modifiable
with well understood consequences

## Observability

We need to be able to discover the semantics, change them easily, and understand the
impact of the changes.

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
