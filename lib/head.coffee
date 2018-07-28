_ = require 'lodash'
log = require '@vonholzen/log'

head = (stream, wait)->
  new Promise (resolve, reject)->
    setTimeout ->
      resolve stream.toArray()
    , wait

module.exports = {
  head
}
