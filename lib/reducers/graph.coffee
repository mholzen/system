log = require '@vonholzen/log'
_ = require 'lodash'

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
  constructor: (from)->
    @_nodes = new ComparableSet()
    @_edges = new ComparableSet()

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


# rdf = require 'rdf'

class Graph
  constructor: (from)->
    if from instanceof rdf.Graph
      @rdfGraph = from
    else
      @rdfGraph = new rdf.Graph()

  add: (s,p,o)->
    if s? and not p? and not o?
      p = s.predicate
      o = s.object
      s = s.subject

    if typeof s == 'string'
      s = new rdf.NamedNode(s)

    if typeof p == 'string'
      p = new rdf.NamedNode(p)

    if typeof o == 'number'
      o = '"' + o.toString() + '"'

    if typeof o == 'string'
      o =
        if (p.toString() == 'color') or (p.toString() == 'shape') or (p.toString() == 'image') or (o.startsWith '"')
          new rdf.Literal(o)
        else
          new rdf.NamedNode(o)

    triple = new rdf.Triple s, p, o
    @rdfGraph.add triple

  subjects: ()->
    return Object.keys @rdfGraph.indexSOP

  objects: (subjects, predicates)->
    triples = @rdfGraph.match subjects, predicates, null
    return triples.map (triple)->
      return triple.object

  nodes: ()->
    nodes = {}
    @rdfGraph.forEach (triple)->
      nodes[triple.subject] = nodes[triple.subject] ?
          uri: triple.subject.toString()
      if not (triple.object instanceof rdf.Literal) and triple.predicate.toString() != 'url'
        nodes[triple.object] = nodes[triple.object] ?
          uri: triple.object.toString()
      nodes[triple.subject][triple.predicate] = triple.object.toString()
    return nodes

  removeMatches: (subjects, predicates, objects, limit)->
    return @rdfGraph.removeMatches subjects, predicates, objects, limit

  collapseEmptyNodes: ()->
    # find nodes that are empty
    # and have only two vertices
    return null

  toRDF: ->
    @rdfGraph.toArray().map (t)->t.toString()
    .join '\n'

  toJSON: ->
    nodes = {}
    @rdfGraph.forEach (triple)->
      nodes[triple.subject] = nodes[triple.subject] || {}
      nodes[triple.subject][triple.predicate] = triple.object.toString()

    vals = Object.keys(nodes).map((key)->nodes[key])

    links = []
    @rdfGraph.forEach (triple)->
      if nodes[triple.object]?
        links.push
          source: vals.indexOf nodes[triple.subject]
          target: vals.indexOf nodes[triple.object]

    return {
      nodes: vals
      links: links
    }

  toNodesEdges: ->
    nodes = @nodes()
    ids = Object.values nodes
    ids.forEach (node, id)->
      node.id = id

    edges = []
    @rdfGraph.forEach (triple)->
      if not (triple.object instanceof rdf.Literal)
        edges.push
          from: ids.indexOf nodes[triple.subject]
          to: ids.indexOf nodes[triple.object]
          label: triple.predicate.toString()

    return {
      nodes: ids
      edges: edges
    }

graph = (opts)->
  id = opts?.id ? 0
  ref = opts?.ref
  graph = new SimpleGraph()
  count = 0
  reducer = (graph, value)->
    graph.add value
    return graph

  return [graph, reducer]

module.exports = graph
