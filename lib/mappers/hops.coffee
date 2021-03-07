log = require '../log'
{uuid} = require 'uuidv4'

module.exports = (data, options)->
  data.hops.reduce (hops, hop)->
    hops ?=
      legs: []

    pings = hop.pings.reduce (memo, ping)->
      memo ?= { time: 0.0, count: 0, pings: [] }

      memo.ip ?= ping.ip   # TODO: verify if changed
      memo.time += parseInt ping.time   # TODO: handle error
      memo.count += 1
      memo.average = memo.time / memo.count
      
      memo.pings.push ping
      memo
    , null

    leg =
      source: (if hops.previous? then hops.previous.target else data.interface?.ip)
      target: (if pings.ip == '*' then uuid() else pings.ip)
      delta: pings.average - ( if hops.previous? then hops.previous.delta else 0 )
      pings: pings

    hops.legs.push leg
    hops.previous = leg
    hops
  , null
