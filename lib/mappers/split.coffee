defaultSep = new RegExp '(?:,|\n|^)("(?:(?:"")*[^"]*)*"|[^",\n]*|(?:\n|$))' # csv
defaultSep = ','

separators =
  dashes: new RegExp ' - '
  colon: new RegExp ':'
  spaces: /\s+/

module.exports = (data, options)->
  sep = if options?.sep of separators
    separators[options?.sep]
  else
    options?.sep ? defaultSep
  
  # log.debug 'split', {options, data, sep}

  if typeof data == 'string'
    # log.debug 'split return', {r: data.split sep}
    return data.split sep

  data.map (x)->
    if typeof x == 'string'
      # log.debug 'spliting array of strings', {r: x.split sep}
      return x.split sep
    
    x.splitBy sep
