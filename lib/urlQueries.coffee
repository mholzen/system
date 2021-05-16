{create} = require './mappers/template'

urls =
  google: 'http://google.com/search?q=${query}'
  workflowy: 'https://workflowy.com/#?q=${query}'

  # work
  omail: 'https://mail.google.com/mail/u/0/#search/${query}'
  ocal: 'http://www.google.com/calendar/hosted/ookla.com/'
  odrive: 'https://drive.google.com/a/ookla.com/#search?q=${query}'
  jira: 'https://ooklanm.atlassian.net/secure/QuickSearch.jspa?searchString=${query}'
  wiki: 'https://ooklanm.atlassian.net/wiki/dosearchsite.action?queryString=${query}'

  # vonholzen.org
  vmail: 'https://mail.google.com/mail/u/1/#search/${query}'
  vcal: 'http://www.google.com/calendar/hosted/vonholzen.org/'
  vdrive: 'https://drive.google.com/a/vonholzen.org/#search?q=${query}'

  bookmarks: 'chrome://bookmarks/?id=${id}'

urlGenerators =
  name: 'urlGenerators'
  items: []

for key, value of urls
  u = create value
  urlGenerators[key] = u
  urlGenerators.items.push u

module.exports = urlGenerators
