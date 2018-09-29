transforms =
  compare: (a, b)->
    a < b

transform = (args...)->
  name = args[0]
  if typeof name != 'string'
    throw new Error 'need a name', transforms

  if not (name of transform)
    throw new Error "cannot find #{name} in " + Object.keys(transforms).join(',')

  f = transforms[name]
  if typeof f != 'function'
    throw new Error 'need a function' + transforms

  f

transform.transforms = transforms

module.exports = transform
