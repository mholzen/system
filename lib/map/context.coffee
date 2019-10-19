_ = require 'lodash'
log = require '../log'

module.exports = (data, options)->
  root = options?.root
  if not root?
    throw new Error 'undefined root'

  if typeof data != 'object'
    return data

  if data?.path instanceof Array
    path = data.path.slice 0,-2
    if path.length == 0
      return root
    return _.get root, path

  throw new Error "no path in '#{typeof data}'"
