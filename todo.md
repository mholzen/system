# solve problems for others
  - finish principles.md
    - demonstrate discoverability
      - search functions that accept a resource description
        - [x] refactor multiple traverse into one and fix paths
        - [x] search functions /functions/iterate,traverse
        - [ ] filter to accepting a resource  /functions/iterate,functions.iterators.traverse/transform,transformers.filter,mappers.accept,.foo.bar
          - [ ] make path arguments in function calls handle async functions (eg to .files.test...)


# develop faster
  - prioritize by potential for compounding effect
    - so that: more people use my software
    - need: dir | traverse files | transform filter invert isGit | transform filter isSource | map augment content | filter todo | filter sothat
      - need:
        - [x] reduce list of function names into a function
          - eg: f = [transform filter invert isGit].reduce functionByName, root
        - [ ] refactor `path` into a `get` reducer.  perhaps it's not a reducer because it can stop in the middle
        - [ ] use `get` reducer to lookup function names and pass remainder of a path to the function when a function is reached
        - [ ] handlers to make use of the reducer
    - see: server/handlers/todos2.coffee
    - need: composable handler pipes
  - write test code more quickly
  - debug
    - need: separate logs by source sothat: test logs don't impede server logs
  - keep functions short
  - minimize number of concepts
  - fail verbosily

# search
  - find todos in order to sort them
    - traverse should handle async edges function
  - bookmarks
  - search for directories from command line
  - interface for searchers
    - file/network searcher is a stream
    - in-memory data can be searched too
      - why return a stream when we can return the entire object in memory
    - an in-memory object is data, a Map, has entries
    - a value of a map can be a searcher
    - when a value is a stream, match stream could return a stream as the match.value

    - query.match stream
      - what if the data is a stream
      - a match can be a stream

  - how to express `search ... where ...`
  - search within content (file or response)
    - filter results from context queries (eg file = search context.source file "$@") to replace defining recursion level
      - you care to filter results based on who generated them, not only what they contain (which could be faked)
    - honer defaultPathQuery to avoid traversing directories (following references)
  - search ^/<dir> should only search in that directory?
  - order by custom order in .search.order in each directories
  - search in . before other directories
    - use inode map to avoid searching in . twice
  - support case insensitive search
  - interactively pick one of several if multiple
  - order search results
    - order files based on "relevance" (eg. a query "foo" should first return names matching query entirely: ["foo", "abcfoodef"])
  - store search results in temporary files to be able to access the content again

# transform
  - use directory structure to define imports
    - eg: `.import.coffee|json|cson` contains statements that import mappers, reducers, etc...
  - sort todos based on whether they contribute towards a goal () in order to help prioritize
  - sort todos higher if they have a location in an existing file
  - sort todos lower if they have a question mark or the word 'consider' in order to encourage 'defining the work'
  - order by most used
  - order by last modified
  - filter (eg. /files/data/people/transform/filter-out,directories )
  - head/tail, for x milliseconds
  - extract rows from html table to scrape from web page
  - reduce to a set (e.g. transactions.csv/reduce/table/account-names/reduce/set )
  - `get` use cat or curl or open depending on type
  - `echo google.com | transform response`.  transforms are functions that all input and can generate multiple outputs
  - research how to convert an object into a variety of outputs.
    - consume a graph (from csv, ttl) to node-edges or triples or (p(s,o))
      or should we just do `reduce graph.triples`
  - interpret input (with hints as to nature) then push results onto output
  - see http://highlandjs.org/#consume

  - $ get people | reduce graph | transform triples

  f='./test.txt'
  stream([f]).map(content).reduce(graph).transform(graph.nodeEdges)

  perhaps relates to the concept of type hierarchy (starting to take form in search?)
  - reduce accepts n items or n seconds worth
  - use "reduce one" to display a selector and let the user pick on
  - "reduce join, sort, unique" while retaining context so that you can get a list of unique items, while retaining where they came from. eg: "files duration:1000 data/people | map content  | sort  -u" replaced with "... | map augment content | parse content | reduce join sort unique"
  - join streams, so that I can merge two resources together, so that I can merge remote resources
  - replace .value with .match
  - build mapper to replace (.match, .path) with .value
  - integrate todo into software engineering process


# infrastructure, design, code quality
  - [ ] use <mapper>.create to support a chain of mappers (e.g: transform,transformers.filter,mappers.invert,mappers.isGit)
    - separate mappers that need a .create (mappers that return mappers) from mappers that return data
    - reduce a list of function names into a function `[transform filter invert isGit].reduce lookup, root`
  - clean up mappers for single use and mappers for repeated use
  - define conventions to get data about arguments to a function
    Arguments.Signature
  - use NODE_PATH or equivalent to set test/*.spec to root
  - integration tests that fail should show stderr

# test infrastructure
  - mocha should default "it with no describe" to "describe <filename>"

# data
  - can a graph have no edges? and only have nodes?
    what does mapping an Array of strings to a graph mean?
      nodes with literals but no edges

# server
  - add ?expand or /expands/<url> to redirect (302) with rewrites expanded, to troubleshoot/modify
  - support ?help or perhaps /help/ (might even be a rewrite rule)
    - list templates with substitutions containing a string
 


# visualize, edit
  - table editor
    - either small cells (eg. spreadsheet)
    - full width and height, (eg presentations)
  - nested visualization
    - eg: a table inside of a node of a graph, a graph inside another graph
  - time series
