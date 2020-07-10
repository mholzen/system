log = require '../log'
pug = require 'pug'

reducer = (options)->
  template = pug.compile options?.template, options
  [{}, template]

reducer.Pug = (options)->
  (data)-> reducer data, options

module.exports = reducer