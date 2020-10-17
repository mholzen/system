log = require '../log'

module.exports = (data)->
  if typeof data == 'string'
    return
      a:
        href: './' + data
        
