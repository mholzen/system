log = require '../log'

module.exports = (data, options)->

  if data instanceof Buffer   # TODO: how do we genericize this
    data = data.toString()

  name = options.name ? 'value'

  return
    [name]: data