module.exports = (data)->
  # log.debug 'lines', {data}

  # TODO: get content?
  data.split '\n'
  .filter (line) -> line.length > 0
