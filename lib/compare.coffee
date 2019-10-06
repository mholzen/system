log = require '@vonholzen/log'
_ = require 'lodash'

recent = ->
  (a,b)-> a.date_added.localCompare b.date_added

compare = {
  recent
}
module.exports = compare
