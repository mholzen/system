module.exports = (opts)->
  (data)->
    if opts?
      output = {}
      output[opts] = value
    output = data
    JSON.stringify output
