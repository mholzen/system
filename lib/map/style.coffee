log = require '../log'

style = (data)->
  console.log 'style', {data}
  if typeof data == 'string'
    re = /<html> <body>/smg

    console.log 'style', {match: data.match re}
    # log.debug 'style', {r: data.replace , "<html><head><link style/></head>$1</html>"}
    data = data.replace re, '<html><head><link rel="stylesheet" type="text/css" href="/type/css/mappers/text/files/test/artifacts/marchome/develop/mholzen/dj-vonholzen.com/files/index.css"/></head><body>'

  return data

module.exports = style
