module.exports = (data)->
  if typeof data == 'string'
    space = / /gi
    quote = /'/gi
    doublequote = /"/gi
    return data
    .replace space, '\\ '
    .replace quote, "\\'"
    .replace doublequote, '\\"'
  data
