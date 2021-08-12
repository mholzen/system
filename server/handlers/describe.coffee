describeMap =
  object: (data)->
    res =
      constructor: data.constructor.name
    Object.assign res, if (f = describeMap[res.constructor])?
      f data
    else
      keys: Object.keys data

  number: (data)->
    isInteger: Number.isInteger data

  boolean: (data)->
    value: data
  
  function: (data)->
    code: data.toString()
    name: data.name

  Array: (data)->
    res =
      length: data.length

  Stream: (data)->
    length: data.collect().toPromise(Promise).then (x)->x.length


# TODO: could accept a maxDuration/maxEnergy argument
module.exports = (req, res)->
  input = req.data
  req.data =
    type: typeof input

  if (f = describeMap[typeof input])?
    Object.assign req.data, f input