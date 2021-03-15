chai = require 'chai'
chai.use require 'chai-string'
chai.use require 'chai-arrays'

global.expect = chai.expect

global.exec = require '../lib/exec'
global.log = require '../lib/log'
global._ = require 'lodash'
global.system = require "../index"

chai.Assertion.addChainableMethod 'log', null, ->
  log.debug 'expect.log', {object: this._obj}
