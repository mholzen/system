#TODO: refactor with ./streams
highland = require 'highland'
isIterable = require './mappers/isIterable'

stream = highland

toStream = (data)->
  if not (isPromise data) and not (isIterable data)
    data = Promise.resolve data
  highland data 

module.exports = Object.assign stream,
  highland: highland
  stream: stream
