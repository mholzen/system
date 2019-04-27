chai = require 'chai'
chai.use require 'chai-string'
global.expect = chai.expect
global.log = require '@vonholzen/log'
global._ = require 'lodash'
global.system = require "../index"
