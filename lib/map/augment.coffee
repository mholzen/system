_ = require 'lodash'

module.exports = (options)->
  options.name = options.name ? options[0]
  if typeof options.name != 'string'
    throw new Error 'cannot find name for augment'

  if not options.root?
    throw new Error 'no root'

  if typeof options.mapper != 'function'
    mapperOptions = _.omit options, ['name', 'addSource']
    console.log options.root.mappers
    mapper = options.root.mappers[options.name] mapperOptions
    if not mapper?
      throw new Error "cannot find '#{options.name}' in '#{Object.keys(mappers)}'"
  options.addSource = options.addSource ? true

  if options.addSource
    source = mappers.source()

  (value)->
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
