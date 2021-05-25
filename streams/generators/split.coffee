split = (data, opts)->
  sep = opts?[0] ? '\n'
  data.split '\n'
