{create} = require '../iterators/traverse'

module.exports =
  create: (options)->
    traverse = create options
    (data)->
      Array.from traverse data
