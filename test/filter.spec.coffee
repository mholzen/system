# TODO: if needed then "move to /lib"
queries =
  keys:
    url:  /^(url|href)$/i
    path: /^path(name)*$/i
  values:
    url: /^(https?|file|mailto):\/\//i

mappers =
  keys: (data)->Object.keys data
  values: (data)->Object.values data

mappers.keys.url = (data)->
  mappers.keys data
  .filter (key)->queries.keys.url.test key

mappers.values.url = (data)->
  k = mappers.keys.url data
  .find (k)->queries.values.url.test data[k]
  if k?
    data[k]

describe 'queries and mappers', ->
  a = url: 'http://ab.com/'
  b = URL: 'http://b.com'
  c =
    url: 'http://c1.com'
    href: 'http://c2.com'
  d = foo: 1

  describe 'keys', ->
    it 'url', ->
      expect(mappers.keys.url(a)).eql ['url']
      expect(mappers.keys.url(b)).eql ['URL']
      expect(mappers.keys.url(c)).eql ['url', 'href']
      expect(mappers.keys.url(d)).eql []

  describe 'values', ->
    it 'url', ->
      expect(queries.values.url.test a.url).true
      expect(mappers.values.url(a)).eql a.url
      expect(mappers.values.url(b)).eql b.URL
      expect(mappers.values.url(c)).eql c.url
      expect(mappers.values.url(d)).eql undefined
