getTemplate = require '../mappers/template2'

inject = (data, template, options)->  # TODO: in a reducer, the template should logically be the first argument
  # log {template}
  if typeof template.substitute != 'function'
    template = await getTemplate template, options

  if options?.res?.type?
    options.res.type 'text/html'

  template.substitute data

module.exports = Object.assign inject,
  type: 'reducer'