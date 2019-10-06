stream = require 'highland'

class ForwardDays
  constructor: ->
    @date = new Date()
  next: ->
    @date.setDate(@date.getDate()+1)

    return
      done: false
      value: @date

class Dates
  constructor: ->
    @name = 'dates'
    date = new Date()
    @items = stream (push, next)->
      date.setDate date.getDate()+1
      push null, new Date date    # send a new object every time
      # TODO: This class should probably be an iterator, not a stream
      process.nextTick next

  toString: -> 'name: dates'

  toJSON: ->
    name: 'dates'
    future: ''
    past: ''

dates = ->
  new Dates()

module.exports = dates
