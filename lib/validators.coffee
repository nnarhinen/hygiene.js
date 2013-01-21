exports.string = (options, value, messages, callback) ->
  if typeof value != 'string'
    return callback(undefined, messages.type(options.property))
  if value.length == 0 && options.required
    return callback(undefined, messages.required(options.property))
  return callback(undefined, null)

exports.number = (options, value, messages, callback) ->
  if typeof value != 'number' && isNaN(value)
    return callback(undefined, messages.type(options.property))
  return callback(undefined, null)

exports.stringList = (options, value, messages, callback) ->
  if typeof value != 'string'
    return callback(undefined, messages.type(options.property))
  if value.length == 0
    return callback(undefined, messages.required(options.property))
  return callback(undefined, null)

exports.stringArray = (options, value, messages, callback) ->
  if typeof value.forEach != 'function'
    return callback(undefined, messages.type(options.property))
  success = true
  value.forEach (one) ->
    success = success && typeof one == 'string'
  return callback(null, messages.type(options.property)) unless success
  return callback()

exports.boolean = (options, value, messages, callback) ->
  if typeof value != 'boolean' && value != 1 && value != 0
    return callback(undefined, messages.type(options.property))
  return callback(undefined, null)
