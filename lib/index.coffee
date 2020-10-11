###

# Functions
  mappers        f(l) -> l
  reducers       f(s) -> l
  generators     f(l) -> s
  transformers   f(s) -> s

where
  l is a literal; synchronous delivery
  s is a stream; stream here implies async delivery; the stream may have many, 1 or 0 element

TODO: should we distinguish between sync and async mappers?

# Handlers
  apply     (mapper, literal)->literal
  map       (mapper, stream)->stream
  generate  (generator, literal) -> stream
  flatmap   (generator, stream) -> stream
  reduce    (reducer, stream) -> literal
  transform (transformer, stream) -> stream

Note: reducing a literal doesn't really make sense
###

if not Array.prototype.last
  Array.prototype.last = -> @[@length - 1]

requireDir = require 'require-dir'
module.exports = requireDir './'
