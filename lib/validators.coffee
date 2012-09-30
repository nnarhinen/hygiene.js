exports.string = (property, value, messages, callback) ->
  if typeof value != 'string'
    return callback(undefined, messages.type(property))
  return callback(undefined, null)

exports.number = (property, value, messages, callback) ->
  if typeof value != 'number' && isNaN(value)
    return callback(undefined, messages.type(property))
  return callback(undefined, null)
