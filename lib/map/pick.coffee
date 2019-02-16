module.exports = (fields)->
  (data)->
    if fields instanceof Array
      _.pick data, fields
    else
      data[fields]
