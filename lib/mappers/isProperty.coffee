module.exports = (data)->
  if not isNaN parseInt data
    # an integer is not a property
    return false

  if data.startsWith '"Date"'
    return true
  if data.startsWith 'subject'
    return true
