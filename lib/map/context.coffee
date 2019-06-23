_ = require 'lodash'

module.exports = (options)->

  (data)->
    if typeof data != 'object'
      return data

    if data.path? and data.input?
      return _.get data.input, data.path.slice(1,-2)

    throw new Error "cannot get context #{typeof data}"
