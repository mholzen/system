module.exports = (data)->
  data = data.replace /\(l:/, '(http://localhost:3001/'
  data
