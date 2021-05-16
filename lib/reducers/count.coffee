module.exports = (memo, value)->
  memo ?= 0
  # log.debug 'count', {memo, value}
  if value?
    memo += 1
  memo