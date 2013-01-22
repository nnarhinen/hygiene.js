async = require 'async'

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

exports.object = (options, value, messages, callback) ->
  if typeof value != 'object'
    return callback(null, messages.type(options.property))
  options.innerValidator value, (err, result, errorDetails, sanitizedObject) =>
    return callback(err) if err
    return callback() if result
    return callback(null, errorDetails)

exports.objectArray = (options, value, messages, callback) ->
  if typeof value.forEach != 'function'
    return callback(undefined, messages.type(options.property))
  success = true
  value.forEach (one) ->
    success = success && typeof one == 'object'
  return callback(null, messages.type(options.property)) unless success
  async.map value, (one, cb) ->
    options.innerValidator one, (err, result, errorDetails, sanitizedObject) ->
      return cb(err) if err
      return cb() if result
      return cb(null, errorDetails)
  , (err, results) ->
    return callback err if err
    success = true
    results.forEach (one) ->
      success = success && !one
    return callback() if success
    callback null, results
