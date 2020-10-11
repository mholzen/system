class ComparableSet extends Set
  constructor: (compare)->
    super()
    @compare = compare ? _.isEqual

  has: (value)->
    for v of @values()
      return true if @compare(value, v)

  add: (value)->
    if not @has value
      super value

  find: (where)->


class SimpleGraph
  constructor: (data)->
    if data?.length == 2
      [@_nodes, @_edges] = data

    @_nodes = data?.nodes ? new ComparableSet()
    @_edges = data?.edges ? new ComparableSet()

  nodes: ->
    (node for node from @_nodes.values())

  nodeList: ->
    Array.from @_nodes.values(), (node, i)->
      {id: i, value: node, label: node?.first}

  edges: ->
    for link from @_edges.values()
      # TODO: used findIndex
      from = nodes.indexOf link.from
      to = nodes.indexOf link.to
      {from, to}

  add: (s,p,o)->
    if not o?
      o = p
      p = undefined

    @_nodes.add s
    if o?
      @_nodes.add o
      @_edges.add {from: s, to: o}

  toJSON: ->
    nodes = (node for node from @_nodes.values())
    nodes: nodes
    edges: for link from @_edges.values()
      # TODO: used findIndex
      from = nodes.indexOf link.from
      to = nodes.indexOf link.to
      {from, to}

graph = (value, opts)->
  if typeof value == 'object'
    if value.nodes? and value.edges?
      return new SimpleGraph value

module.exports = Object.assign graph, {SimpleGraph}