highland = require 'highland'
parse = require './parse'
log = require './log'
_ = require 'lodash'
html = require './mappers/html'

fit = (item, width)->
  item = if typeof item != 'string' then '' else item
  padding = Math.max(Math.floor(width)-item.length, 0)
  # TODO: consider trimming from the right
  item[0..width-1] + Array(padding).join(' ') + ' '

class Table
  constructor: (datas, options)->
    {@width = 80, @header = false} = options ? {}
    @setData datas

  setData: (datas)->
    log.debug {datas}
    @_keys = if datas?[0] instanceof Array then datas.shift() else null
    @datas = datas ? []

  keys: ->
    if @_keys
      return @_keys

    keys = {}
    for row in @datas
      _.keys(row).forEach (key)->keys[key] = 1
    Object.keys(keys)

  rows: ->
    rows = []
    for data in @datas
      if data instanceof Array
        rows.push data
        continue

      row = []
      for key in @keys()
        row.push data[key]
      rows.push row
    rows


  setHeader: (row)->
    @keys = Object.keys row

  updateHeader: (row)->
    for key of row
      if not @keys.includes key
        @keys.push key

  add: (value)->
    return if not @_keys and value instanceof Array
      @_keys = value

    @datas.push value

  toString: (options)->
    @rows().map (row)=>
      row.map (cell)=>
        fit(cell, @width / @keys.length)
      .join ''
    .join '\n'

  map: (item)->
    if @keys.length == 0
      @setHeader item
    item[key] for key in @keys

  mapString: (row)=>
    @map(row)
    .map (item)-> log.print item
    .map (item)=>
      fit(item, @width / @keys.length)
    .join ''

  toHtml: ->
    header = @keys().map (key)-> "<th>#{key}</th>"
      .join '\n'

    "<table>" +
      "<tr>" + header +
      "</tr>" +
      @rows().map((row)->"<tr>" + row.map((value)->
        "<td>#{html(value)}</td>").join('\n') + "</tr>").join('\n') +
    "</table>"

table = (datas, options)->
  new Table datas, options

table.Table = Table

table.map = (item, options)->
  result = new Table options
  result.map item

table.mapString = (item, options)->
  result = new Table options
  result.mapString item

module.exports = table
