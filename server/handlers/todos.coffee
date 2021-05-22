request = require '../request'
module.exports = (req, res, router)->
  # TODO: implement search in order to find todos
  # req.data = request 'files/cwd/apply/search,todo'
  req.data = request 'generators/stat/cwd/map/augment,content/transform/filter,contains:todo'
