_ = require 'lodash'
{traverse} = require '../generators'
{stream} = require '../'

module.exports = (data, options)->
  stream traverse data
