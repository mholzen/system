log = require '../log'

style = (data)->
  if typeof data == 'string'
    re = /<html> <body>/smg

    data = data.replace re, '<html><head><link rel="stylesheet" type="text/css" href="/index.css"/></head><body>'

  return data

module.exports = style
