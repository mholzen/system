stream = require './stream'
{Readable} = require 'stream'
log = require './log'

csvParse = require 'csv-parse/lib/sync'

count = (char, value)->
  re = '('+char+')(?=(?:[^"]|"[^"]*")*$)'
  re = new RegExp re, 'g'
  # log.debug 'parse.count', {match: value.match re}

  value.match(re)
  ?.length

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
  if not value?
    throw new Error "no data to parse"

  if value instanceof Buffer
    value = value.toString()

  if typeof value == 'string'
    if ['[', '{'].includes value?[0]
      return JSON.parse value

    d = delimiter value
    if d?
      if d == ','
        columns = context?.columns ? null
        # columns = 
        rows = csvParse value #, columns: columns
        # log.debug 'parse', {delimter: d, value, rows}
        return rows[0]

      return value.split d

    # single quoted value
    if ['"'].includes value?[0]
      return JSON.parse value

    # log.debug 'parse', {value}
    return value

  if value instanceof Readable
    # log.debug 'parse readable'
    return stream value
      .split()
      .filter (line) -> line.length > 0
      .map parse

  throw new Error "cannot parse #{log.print value}"

class Parser
  constructor: (options)->
    @headers = null
    @first = true

  parse: (value)->
    if @first
      @first = false
      first = parse value

    parse value, {columns: @headers}

parse.Parser = Parser

parse.parseValue = (data)->
  if /true|false/i.test data
    return /true/i.test data

  number = parseInt data
  if not isNaN number
    return number
  data

parse.delimiter = delimiter

module.exports = parse
