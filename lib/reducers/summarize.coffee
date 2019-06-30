log = require '@vonholzen/log'
_ = require 'lodash'
name = require '../map/name'

names = name()

summarize = (options)->
  reducer = (summary, data)->
    summary.count = (summary.count ? 0) + 1

    if n = names data
      n = n
      .map (x)->x.value.name
      .slice 0, 10
      summary.names = summary.names ? []
      if summary.names.length < 10
        summary.names.push n

    summary

  [{}, reducer]

module.exports = summarize
