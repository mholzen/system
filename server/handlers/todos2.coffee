###
files 'cwd', 'lib'
.generate 'stats'
.map (x)->
  x.lines = generate 'lines', x
  .filter 
###

module.exports = [
  'files', 'cwd',
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

