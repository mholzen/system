score = (a,b) ->
  first_numerical_column = 1
  b[1] - a[1]   # highest score first

sort = (data, options)->
  if data instanceof Array
    if typeof data[0] == 'string'
      return data.sort()    # TODO: generalize sort order to:semantic
    return data.sort score
  throw new Error "cannot sort #{log.print data}"

module.exports = Object.assign sort, score
