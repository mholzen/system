_ = require 'lodash'
log = require '../log'

module.exports = (options)->
  root = options?.root
  if not root?
    throw new Error 'undefined root'

  (data)->
    if typeof data != 'object'
      return data

    if data?.path instanceof Array
      if data.path.length == 0
        return root
      return _.get root, data.path.slice 0,-2

    throw new Error "no path in '#{typeof data}'"
