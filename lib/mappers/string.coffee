isRequest = require './isRequest'
_ = require 'lodash'
dayjs = require 'dayjs'
lines = require './lines'

module.exports = (data)->
  if typeof data == 'function'
    return Object.assign {},
      code: lines data.toString()
      ([k]: v for k, v of data)...

  if isRequest data
    data = _.pick data, ['method', 'path', 'protocol', 'ip']
    data.timestamp = dayjs().format('YYYY-MM-DD HH:mm:ss.SSS')

  if data instanceof Buffer
    return data.toString()

  if typeof data == 'object'
    if typeof data?.toJSON == 'function'
      data = data.toJSON()

    if data instanceof Set
      data = data.values()

    data = JSON.stringify data
  data
