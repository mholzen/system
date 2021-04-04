log = require '../log'

defaultSep = new RegExp '(?:,|\n|^)("(?:(?:"")*[^"]*)*"|[^",\n]*|(?:\n|$))' # csv
defaultSep = ','

separators =
  dashes: new RegExp ' +- +'

module.exports = (data, options)->
  sep = if options?.sep of separators
    separators[options?.sep]
  else
    options?.sep ? options?[0] ? defaultSep
  # log.debug 'split', {data}

  if typeof data == 'string'
    # log.debug 'split return', {r: data.split sep}
    return data.split sep

  data.map (x)->
    if typeof x == 'string'
      return x.split sep
    
    x.splitBy sep
