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
