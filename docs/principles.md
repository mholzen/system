# Principles

Here are the principles I used to develop the System Web Server.

## Discoverable

This System should be easy to discover, learn and use.

### Everything is a resource

The resource should describe itself.

### Consistent way to find what is possible given a resource

Search for ... in a resource:  `.../generate,search`

Examples:
- search for html vizualization (tables, graphs) for a csv file: `/test/artifacts/data.csv/generate,search,html`


## REST

Everything is a resource.  Standard REST operations are useable everywhere. (GET to describe, POST to add to a collection, etc...#TODO: elaborate)

All functions are discovered and inspected at `/functions`.

They are organized by the number of arguments they expect:
  * Generators expect no arguments: they generate data from scratch.
  * Mappers expect 1: they take one argument (the input data) and produce another.  They map the input data onto the output data.
  * Reducers expect 2: they take one argument (the data), incorporate it into the second argument (the memo) and return result
  * Handlers expect 3: a request (the data) and a response (the memo), and a callback used to indicate its work is complete.

Here are examples for each category:
  - `/functions/generators/os/homedir`    - returns the home directory of the user running the server   # TODO: transform markdown with templates to avoid repeating localhost:3001
  - `/functions/mappers/increment`        - add 1 to the input
  - `/functions/reducers/count`           - count the number of items in a collection
  - `/functions/handlers/files`           - navigates directories and streams file contents

Specific handlers are used to call functions on data:
  - `call`: executes a resource, if it is a function
  - `apply`: applies a function to data as a single object
  - `transform`: applies a function to data as a collection

Examples:
  - `/functions/generators/os/homedir/call`    - executes the function os.homedir()
  - [`/files/apply,mappers.yaml`](http://localhost:3001/files/apply,mappers.yaml) - directory content in yaml
  - [`/files/transform,transformers.head`](http://localhost:3001/files/transform,transformers.head) - 10 first files
  - [`/files/docs/principles.md/apply,mappers.html`](http://localhost:3001/files/docs/principles.md/apply,mappers.html) - this file

Handlers can be combined to create _pipes_:
  ```
  /<resource>/<handler>/<handler>/...
  ```

Arguments can be passed to a function using this syntax:

  ```
  /<handler>[,<argument1>[,<argument2>,...]]/
  ```

Example:

  `http://localhost:3001/functions/generators/process/cwd/call/apply,mappers.content/map,mappers.stat/apply,mappers.resolve/map,mappers.get,size/reduce,reducers.sum`

Each step is a equivalent to an http request (with full headers that can be used for type or error handling, an advantage over regular Unix pipes)

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


## Configurable

List of imported collections define namespaces:

`/handlers/apply/imports`


## Extensible

### Related Data and Code should be close

Use code in data directories

Examples:
`/files/test/artifacts/dir/map,dir.json`
function.coffee should use path lookup to find dir handler and pass it .json


Files in the same directory as a resource modify the context for that resource.

Examples:
  - `/files/test/artifacts/names.ext`  - uses .ext in `/files/test/artifacts/` or above   # TODO
  - `/files/docs/principles.md/apply,urls`  - uses urls.coffee in that directory or above   # TODO: search for an item in a list of locations (find)

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

### Type "expansion"

Examples:
  - `/files/test/artifacts/names.csv/transform,transformers.head` - apply `transform,transformers.lines` because of the content-type


## Data driven

- data should drive behaviour: e.g. name -> resource list -> stat list -> link link -> html

- JSON schema describes everything

## Functional

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
