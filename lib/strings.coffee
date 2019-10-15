stream = require './stream'
log = require '@vonholzen/log'

strings = (data)->
  new Promise (resolve, reject)->
    stream.strings(data)
    .errors (err, push)->
      reject err
    .toArray (items)->
      resolve items

module.exports = strings
