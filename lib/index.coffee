# Functions
#
# mappers        f(l) -> l
# reducers       f(s) -> l
# generators     f(l) -> s
# transformers   f(s) -> s
#
# where
#   l is a literal
#   s is a stream

# Handlers

# apply   (mappers, literal)->literal
# map     (mappers, stream)->stream

# generate (generators, literal) -> stream
# flatmap  (generators, stream) -> stream

# reduce  (reducers, stream) -> stream

# generate  (transformers, literal)->stream
# transform (transformers, stream)->stream

# Note: reducing a literal doesn't really make sense


if not Array.prototype.last
  Array.prototype.last = -> @[@length - 1]

requireDir = require 'require-dir'
module.exports = requireDir './'
