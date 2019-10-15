stream = require './stream'

strings = (data)->
  new Promise (resolve, reject)->
    stream.strings(data)
    .errors (err, push)->
      reject err
    .toArray (items)->
      resolve items

module.exports = strings
