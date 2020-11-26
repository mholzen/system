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
    nodes = @nodes()
    console.log {nodes}
    for edge from @_edges.values()
      source = nodes.indexOf edge.from
      target = nodes.indexOf edge.to
      {source, target}

  add: (s,p,o)->
    if p? and not o?
      o = p
      p = undefined

    if s? and not p? and not o?
      p = s.predicate
      o = s.object ? s.target
      s = s.subject ? s.source

    @_nodes.add s
    if o?
      @_nodes.add o
      @_edges.add {from: s, to: o}

  toJSON: ->
    nodes = (node for node from @_nodes.values())
    nodes: nodes
    edges: for link from @_edges.values()
      # TODO: used findIndex
      source = nodes.indexOf link.from
      target = nodes.indexOf link.to
      {source, target}

graph = (value, opts)->
  if typeof value == 'object'
    if value.nodes? and value.edges?
      return new SimpleGraph value

module.exports = Object.assign graph, {SimpleGraph}