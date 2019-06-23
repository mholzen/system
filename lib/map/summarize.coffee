query = require '../query'

module.exports = ->
  (data, context)->
    if typeof data == 'object'
      result = {}
      for key, value of data
        switch key
          when 'date_added', 'date', 'date_modified', 'name', 'url', 'path'
            Object.assign result, "#{key}": value
        if value instanceof Array

          if value[0].Amount?
            sum = (m, v)-> m + parseFloat v.Amount
            average = (m, v)-> (m + parseFloat v.Amount) / value.length
            Object.assign result, "#{key}":
              Amount:
                sum: value.reduce(sum, 0)
                average: value.reduce(average, 0)

      result
