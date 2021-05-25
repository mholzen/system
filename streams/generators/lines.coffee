module.exports = (data)->
  data.split '\n'
  .filter (line) -> line.length > 0
