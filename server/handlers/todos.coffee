request = require '../request'
module.exports = (req, res, router)->
  # TODO: implement search in order to find todos
  # req.data = request 'files/cwd/apply/search,todo'
  req.data = request [
    'files', 'cwd',
    'lib',   # TEST only

    'generators', 'stats',

    'map',
    # 'augment,content',    # lines?
    'augment,lines',      # generator lines?
    # 'augment', [ 'generators', 'lines', 'filter', 'includes:TODO' ]

    'apply', 'resolve'
  ]