exports.toStringSanitizer = (value, cb) ->
  cb(undefined, value.toString())

exports.numberSanitizer = (value, cb) ->
  cb(undefined, Number(value))

exports.booleanSanitizer = (value, cb) ->
  cb(undefined, !!value)

exports.stringListSanitizer = (value, cb) ->
  cb(undefined, value.split(','))
