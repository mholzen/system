# Principles

Here are the principles I used to develop the System Web Server.

## Discoverable

This System should be easy to discover, learn and use.


## REST

Everything is a resource.  Standard REST operations are useable everywhere. (GET to describe, POST to add to a collection, etc...#TODO: elaborate)

All functions are discovered and inspected at /functions.

They are organized by the number of arguments they expect:

  * Generators expect no arguments: they generate data from scratch.
  * Mappers expect 1: they take one argument and produce another.  They map the input data onto the output data.
  * Reducers expect 2: they take one argument (the data) and incorporate it into another (the memo).
  * Handlers expect 3: a request (the data) and a response (the memo), and a callback used by the function to indicate its work is complete.

Here is one example for each category:  # TODO
  /functions/generators/os/homedir    - returns the home directory of the user running the server
  /functions/mappers/increment        - add 1 to the input
  /functions/reducers/count           - count the number of items in a collection
  /functions/handlers/files           - navigates directories and streams file contents

Specific handlers are used to combine functions:
  apply: applies a function to data as a single object
  transform: applies a function to data as a collection

Examples:
  - (http://localhost:3001/files/apply,mappers.yaml)[directory content in yaml]
  - (http://localhost:3001/files/transform,transformers.head)[10 first files]
  - (http://localhost:3001/files/test/artifacts/names.csv)[10 first lines]


Handlers can be combined to create _pipes_:
  /<resource>/<handler>/<handler>/...

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

  - TODO: visualize logs in browser

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

## Tested

## Consistent


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
