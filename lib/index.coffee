if not Array.prototype.last
  Array.prototype.last = -> @[@length - 1]

requireDir = require 'require-dir'
module.exports = requireDir './'
