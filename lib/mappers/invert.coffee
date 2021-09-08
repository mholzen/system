module.exports = (f)->
  -> not f.apply @, arguments
