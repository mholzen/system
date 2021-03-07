query = require '../query'
log = require '../log'

summarize = (data, options)->
  if typeof data != 'object'
    return data

  length = options?.length ? 3
  if data instanceof Array
    if data.length > length
      extra = "...(#{data.length - length} more)"
      data = data.slice 0, length
      data.push extra
    return data.map summarize

  keys = Object.keys data
  # log.debug 'summarize', {keys, length}
  if keys.length > length
    extra = "#{keys.length - length} more"
    keys = keys.slice 0, length
    data['...'] = extra
    keys.push '...'
    # log.debug 'summarize', {keys, data, d: ("#{k}":summarize data[k] for k in keys)}
  return Object.assign {}, ...("#{k}":summarize(data[k]) for k in keys)

module.exports = summarize
