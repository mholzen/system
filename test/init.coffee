chai = require 'chai'
chai.use require 'chai-string'
chai.use require 'chai-arrays'
global.expect = chai.expect

global.exec = require '../lib/exec'

global.log = require '@vonholzen/log'

global._ = require 'lodash'

global.system = require "../index"
