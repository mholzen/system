###
augment is probably a reducer, that takes an array of values to assign into an object, much like Object.assign

###

_ = require 'lodash'
{NotFound} = require '../errors'
log = require '../log'

value = require './value'
identify = require './identify'
getFunction = require './function'

getObject = (name, options)->
  if name instanceof Array
    name = name.join '.'
  if typeof name == 'string'
    object = _.get options, name
    if object?
      return object
  if typeof name == 'object'
    return name

  throw new NotFound name, options

getNewName = (name, newData, options)->
  if typeof options?.name == 'string'
    return options.name

  if typeof name == 'string'
    return name

  if typeof name == 'function'
    return name.name

  identify newData

create = (fn, options)->
  (data, options)->
    value = fn data
    name = identify fn
    data[name] = value
    data

augment = (data, name, options)->
  # log {data, name, options}

  try
    newData = getObject name, options
  catch e
    if not e instanceof NotFound
      throw e
    log.warn 'unnessary lookup', {name, options}
    fn = getFunction name, options
    newData = fn data #, options

  newName = getNewName name, newData, options

  if typeof data != 'object'
    currentName = identify data, options
    data = [currentName]: data

  if data instanceof Array
    data =
      array: data
  Object.assign data, [newName]: newData

module.exports = Object.assign augment, {create}
