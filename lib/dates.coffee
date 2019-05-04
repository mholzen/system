log = require '@vonholzen/log'
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

    # @items = stream()
    # date = new Date()
    # @items.write date
    # @items.end()
    date = new Date()

    # @items = stream new ForwardDays()

    @items = stream (push, next)->
      push null, date
      log 'dates', {date}
      date.setDate(date.getDate()+1)
      setTimeout (-> next() ), 10   # TODO: WRONK
      # next()


  toString: -> 'name: dates'

  toJSON: ->
    name: 'dates'
    future: ''
    past: ''

dates = ->
  new Dates()

module.exports = dates
