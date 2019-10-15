query = require '../query'
log = require '../log'

module.exports = (options)->
  options ?= {}
  log 'summarize', {options}
  summarize = (data)->
    log 'summarize', {data}
    if typeof data != 'object'
      return data

    length = options.length ? 3
    if data instanceof Array
      if data.length > length
        extra = "...(#{data.length - length} more)"
        data = data.slice 0, length
        data.push extra
      return data.map summarize

    keys = Object.keys data
    log 'summarize', {keys, length}
    if keys.length > length
      extra = "#{keys.length - length} more"
      keys = keys.slice 0, length
      data['...'] = extra
      keys.push '...'
    return Object.assign {}, ...("#{k}":summarize(data[k]) for k in keys)

  summarize
