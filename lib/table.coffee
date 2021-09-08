log = require './log'
_ = require 'lodash'
html = require './mappers/html'
isLiteral = require './mappers/isLiteral'

fit = (item, width)->
  item = if typeof item != 'string' then '' else item
  padding = Math.max(Math.floor(width)-item.length, 0)
  # TODO: consider trimming from the right
  item[0..width-1] + Array(padding).join(' ') + ' '

# TODO: refactor with mapprs.isProperty
isProperty = (data)->
  if typeof data == 'string'
    if data.toLowerCase().startsWith('bank of')
      return false

    if data.match /\w+/
      return true

isHeader = (data)->
  if Array.isArray data
    for columnData in data
      return false if not isProperty columnData
    return true

class Table
  constructor: (datas, options)->
    {@width = 80, @header = false} = options ? {}
    @setData datas

  setData: (datas)->
    # log.debug 'table.setData', {datas}
    if isHeader datas?[0]
      @_keys = if datas?[0] instanceof Array then datas.shift() else null

    @datas = datas ? []

  keys: (newKeys)->
    # log.debug 'table.keys', {newKeys}
    if newKey?
      @_keys = newKeys

    if @_keys?
      return @_keys

    keys = {}
    for row in @datas
      continue if isLiteral row

      _.keys(row).forEach (key)->
        keys[key] = 1

    Object.keys keys

  rows: (keys...)->
    rows = []
    keys = if keys.length > 0 then keys else @keys()

    if keys.length == 0
      for data in @datas
        rows.push data
      return rows

    for data in @datas
      # if data instanceof Array
      #   rows.push data
      #   continue

      row = []
      for key, i in keys
        index = if data instanceof Array then i else key
        row.push data[index]
        # log {key, i, index, data, row}
      rows.push row
    rows

  column: (key)->   # TODO: can column() be defined as map pick
    # log.debug 'column', {key}
    index = @keys().indexOf (key ? 0)
    if index < 0
      index = 0
      # throw new RangeError()
    data[index] for data in @datas

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

    td = (data)->
      "<td>#{html.body(data)}</td>"

    tr = (data)->
      if isLiteral data
        data = [data]

      "<tr>" +
      data.map(td).join('\n') +
      "</tr>"

    "<body>" +
    "<table>" +
    "<tr>" + header + "</tr>" +
    @rows().map(tr).join('\n') +
    "</table>" +
    "</body>"

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
