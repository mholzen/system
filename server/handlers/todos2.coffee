### can a pipe be expressed more effectively (with type checking and other quality guarantees) in code? what about discoverability?
files 'cwd', 'lib'
.generate 'stats'
.map (x)->
  x.lines = generate 'lines', x
  .filter 
###

module.exports = [
  'files',
  # 'lib',   # TEST only
  'test/artifacts/small-directory/a',   # DEBUG only


  'generators', 'stats',

  # 'map', 'augment', [
  #   'generators', 'lines',
  #   'transform', 'filter', 'includes:TODO'
  # ]

  'map', [
    'apply', 'content',
    'apply', 'lines',
    'apply', 'filter'  #, 'includes:TODO'
  ],

  'apply', 'resolve'
]

