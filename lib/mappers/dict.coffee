log = require '../log'

module.exports = (data, options)->
  name = options.name ? options[0] ? 'value'

  return
    [name]: data