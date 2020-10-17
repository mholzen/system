module.exports = (data, options)->
  if data instanceof Array
    secondArgNumericalReverse = (a,b) -> b[1] - a[1]
    return data.sort secondArgNumericalReverse
