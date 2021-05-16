module.exports =
  create: ->
    (memo, data)->
      if typeof data == 'string'
        memo ?= ''
        memo += data
        return memo

      memo ?= new Array()
      memo.concat data
