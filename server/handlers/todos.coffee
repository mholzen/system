request = require '../request'
module.exports = (req, res, router)->
  # TODO: implement search in order to find todos
  # req.data = request 'files/cwd/apply/search,todo'
  req.data = request 'literals/cwd/generators/stats/map/augment,content/transform/filter,contains:todo'
