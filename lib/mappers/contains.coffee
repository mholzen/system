module.exports =
  create: (match, options)->
    log {match, options}
    (data)->
      data.includes match
