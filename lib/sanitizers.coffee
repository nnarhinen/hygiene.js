exports.toStringSanitizer = (value, options, cb) ->
  value = '' if value == null
  cb(undefined, value.toString())

exports.numberSanitizer = (value, options, cb) ->
  cb(undefined, Number(value))

exports.booleanSanitizer = (value, options, cb) ->
  cb(undefined, !!value)

exports.stringListSanitizer = (value, options, cb) ->
  cb(undefined, value.split(','))

exports.numberArraySanitizer = exports.stringArraySanitizer = (value, options, cb) ->
  cb(undefined, value)

exports.dateTimeSanitizer = (value, options, cb) ->
  XDate = require('xdate')
  date = new XDate value
  if (options.exportFormat)
    cb(null, date.toString options.exportFormat)
  cb(null, date.toDate())
