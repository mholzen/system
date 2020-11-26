score = (a,b) ->
  first_numerical_column = 1
  b[1] - a[1]   # highest score first

sort = (data, options)->
  if data instanceof Array
    return data.sort score
  throw new Error 'cannot sort'

module.exports = Object.assign sort, score
