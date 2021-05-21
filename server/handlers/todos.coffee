request = require '../request'
module.exports = (req, res, router)->
  # TODO: request is async making the handler async. understand.
  request 'files/cwd/apply/search,todo'
