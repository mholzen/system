log = require '../log'

module.exports = (data, options)->
  log.here {data, options}
  name = options.name ? 'value'

  return
    [name]: data