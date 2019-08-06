#!/usr/bin/env coffee
highland = require 'highland'
{Readable} = require 'stream'
log = require './log'

csvParse = require 'csv-parse/lib/sync'

count = (char, value)->
  value.match(new RegExp char, 'g')?.length

# delimiters = ['/', ',', "\n", ':']
delimiters = [',', "\n"]

delimiter = (value)->
  r = delimiters.reduce (result, char)->
    c = count char, value
    if c > (result.max ? 0)
      result.max = c
      result.char = char
    result
  , {}
  r.char

parse = (value, context)->
  # console.log value instanceof Request

  # if value instanceof Request
  #   value = await value
  # throw new Error "cannot parse #{log.toPrettyString value}"

  if value instanceof Buffer
    value = value.toString()

  if typeof value == 'string'
    if ['[', '{'].includes value?[0]
      return JSON.parse value

    d = delimiter value
    if d?
      log 'parse', {delimter: d, value}
      if d == ','
        columns = context?.columns ? null
        rows = csvParse value, columns: columns
        return rows[0]

      return value.split d

    log 'parse', {value}
    return value

  if value instanceof Readable
    log 'parse readable'
    highland(value)
    .split()
    # .filter (line) -> line.length > 0
    # .map parse

  if value instanceof Promise
    throw new Error "cannot parse promise"

  throw new Error "cannot parse #{log.toPrettyString value}"

class Parser
  constructor: (options)->
    @headers = null
    @first = true

  parse: (value)->
    if @first
      @first = false
      first = parse value
      log 'parse first', first
      if first[0] == 'Date'
        @headers = first
        return

    parse value, {columns: @headers}

parse.Parser = Parser

parse.parseValue = (data)->
  if /true|false/i.test data
    return /true/i.test data

  number = parseInt data
  if not isNaN number
    return number

  data


module.exports = parse
