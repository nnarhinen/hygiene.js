exports.string = (property, value, messages, callback) ->
  if typeof value != 'string'
    return callback(undefined, messages.type(property))
  if value.length == 0
    return callback(undefined, messages.required(property))
  return callback(undefined, null)

exports.number = (property, value, messages, callback) ->
  if typeof value != 'number' && isNaN(value)
    return callback(undefined, messages.type(property))
  return callback(undefined, null)

exports.stringList = (property, value, messages, callback) ->
  if typeof value != 'string'
    return callback(undefined, messages.type(property))
  if value.length == 0
    return callback(undefined, messages.required(property))
  return callback(undefined, null)
