{stream} = require '../stream'
{create} = require '../traverse'

module.exports =
  create: (options)->
    traverse = create options
    (data)->
      stream traverse data
