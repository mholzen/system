stream = require '../../lib/stream'
count = require './count'

module.exports = (data, options)->

  mod = options?.mod || 10
  min = 0
  max = 256
  f = Math.sin

  data
  .through (x)-> count(x, {mod})
  .map (x)->
    x = parseInt x
    ( f( 2.0 * Math.PI * x / mod ) + 1 ) / 2 * max