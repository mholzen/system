_ = require 'lodash'
log = require '../log'

module.exports = (value, options)->
  options.name = options?.name ? options[0]
  if typeof options.name != 'string'
    throw new Error 'cannot find name for augment'

  if not options.root?
    throw new Error 'no root'

  if typeof options.mapper != 'function'
    mapperOptions = _.omit options, ['name', 'addSource']
    mapperCreator = options.root.mappers.mappers[options.name]
    if not mapperCreator?
      throw new Error "cannot find '#{options.name}' in '#{Object.keys(options.root.mappers)}'"
    mapper = mapperCreator mapperOptions
  options.addSource ?= false

  if options.addSource
    source = options.root.mappers.mappers.source()

  if typeof value != 'object'
    value =
      value: value
    # throw new Error 'cannot agument a non-object type'

  output = await mapper value

  log 'augment', {type: typeof output, value, output}
  value[options.name] = output

  if options.addSource
    if not value?.source?
      value.source = source(value)
    value.source = "/map/#{options.name}#{value.source}"

  value
