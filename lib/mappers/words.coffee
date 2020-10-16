module.exports = (data)->
  if typeof data == 'string'
    return data
      .split /[\s,.:;!?'\/+-=]+/    # TODO: consider using \W+
      .filter (w)->w.length > 0

