re = /#\ TODO:.*(so|to):/
# re = /#\ TODO:/

module.exports = (data)->
  re.test data
