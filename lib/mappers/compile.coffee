pug = require './pug'

compile = (data, options)->
  if options?.language == 'javascript'
    return Function('"use strict";return (' + data + ')')

  if options?.language == 'pug'
    return pug.create template: data

module.exports = compile