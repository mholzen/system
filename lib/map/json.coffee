module.exports = (opts)->
  (data)->
    # TODO: use augment?
    # if opts?
    #   output = {}
    #   output[opts] = value
    # output = data
    JSON.stringify data, opts?.replacer
