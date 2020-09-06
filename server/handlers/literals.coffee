module.exports = (req, res, router)->
  if not (req.remainder?.length > 0)
    throw new Error "no items in req.remainder"

  req.data = req.remainder.shift()

  if req.data.includes ','
    req.data = req.data.split ','
