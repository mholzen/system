{createQuery, Query} = require './query'
log = require '@vonholzen/log'

urls =
  google: 'http://google.com/search?q=#{query}'

  # ookla
  omail: 'https://mail.google.com/mail/u/0/#search/#{query}'
  ocal: 'http://www.google.com/calendar/hosted/ookla.com/'
  odrive: 'https://drive.google.com/a/ookla.com/#search?q=#{query}'
  jira: 'https://ooklanm.atlassian.net/secure/QuickSearch.jspa?searchString=#{query}'
  wiki: 'https://ooklanm.atlassian.net/wiki/dosearchsite.action?queryString=#{query}'

  # vonholzen.org
  vmail: 'https://mail.google.com/mail/u/1/#search/#{query}'
  vcal: 'http://www.google.com/calendar/hosted/vonholzen.org/'
  vdrive: 'https://drive.google.com/a/vonholzen.org/#search?q=#{query}'
  workflowy: 'https://workflowy.com/#?q=#{query}'

search = (query, out)->
  if not (query instanceof Query)
    query = createQuery query

  return if query.type? and not types.includes query.type

  if query.depth == 0
    out.write this
    out.end
    return

  Object.keys(urls).map (name)-> {name: name, url: urls[name]}
  .forEach (url)->
    remaining = query.nonMatches url
    log 'urlQuery', remaining.matches.length, query.matches.length
    if remaining.matches.length < query.matches.length
      # partial match
      url.url = url.url.replace '#{query}', remaining.toString()
      out.write url


module.exports =
  name: 'urlQueries'
  items: Object.keys(urls).map (k)-> {name: k, url: urls[k]}
