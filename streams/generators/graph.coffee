n = 20    # TODO: should this be a mapper?
A = Array(n).fill()

nodes = A.flatMap (x,i)->
  A.map (x,j)->
    "#{i},#{j}"

edges = A.flatMap (x,i)->
  A.flatMap (x,j)->
    r = []
    if i < n-1
      r.push {from: "#{i},#{j}", to: "#{i+1},#{j}"}
    if j < n-1
      r.push {from: "#{i},#{j}", to: "#{i},#{j+1}"}
    r

module.exports = ->
  {nodes, edges}