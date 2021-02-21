get = require '../../streams/transformers/get'

module.exports =
  create: (path, options)->
    get = get.flatMapper path
    (memo, data)->
      memo ?= {} 
      return memo if not data?
      key = (get data)[0]   # get always returns an array

      datas = memo[key] ? []
      datas.push data
      memo[key] = datas

      memo

