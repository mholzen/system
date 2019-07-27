_ = require 'lodash'


root = require '../searchers'

module.exports = (options)->

  (data)->
    if typeof data != 'object'
      return data

    if data?.path?
      return _.get root, data.path.slice 0,-2

    throw new Error "no path in data of type #{typeof data}"
