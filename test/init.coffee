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

chai.Assertion.addChainableMethod 'method', null, (name)->
  log.debug 'expect.method received', {object: this._obj, name}
  this._obj = this._obj[name]()
  log.debug 'expect.method returning', {object: this._obj}
