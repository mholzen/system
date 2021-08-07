# Expected Principles

Principles that help improve the velocity of feature development.

## Tested

## Observable

## Consistent


# New Principles
## REST

Everything is a resource:
  /files
  /handlers
  /functions

Important handlers:
  apply: applies a function to the data as a single object
  transform: applies a function to the data as a collection

Important functions:
  generators.homedir
  mappers.stat, mappers.content
  reducers.augment

Combine handlers into _pipes_:
  /<resource>/<handler>/<handler>/...

Examples:
  http://localhost:3001/apply,root2.functions.generators.homedir/apply,mappers.content/transform,functions.mappers.streams.count

  Each step is a equivalent to an http request (with full headers that can be used for type or error handling, an advantage over regular Unix pipes)

Write function calls in the URL:
  /resource/apply,<function>,<argument>, ... /

Resolve arguments from strings to objects
  foo.path:files.bar
  ->
  foo
    path: 'files.bar'
    content: '# content of this file'

POST a pipe to a file:


Other important handlers:
  map
  reduce
  type
  redirect
  cache

## Discoverable

### Consistent way to find what is possible given a resource

Search for ... in a resource:  `.../generate,search`

Examples:
- search for html vizualization (tables, graphs) for a csv file: `/test/artifacts/data.csv/generate,search,html`

### Data and the code to process it should be close

Use code in data directories

Examples:
`/files/test/artifacts/dir/map,dir.json`
function.coffee should use path lookup to find dir handler and pass it .json


## Extensible

## Observability

Observe behavior, change code easily, and understand the effects of a change.

Pipes provide natural points of inspection.
Logs can be viewed as a resource, filtered by source.


## Semantics

Embrace semantics through the Principle of least astonishment (POLA)

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
