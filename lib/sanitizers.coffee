exports.toStringSanitizer = (value, cb) ->
  cb(undefined, value.toString())

exports.numberSanitizer = (value, cb) ->
  cb(undefined, Number(value))

exports.stringListSanitizer = (value, cb) ->
  cb(undefined, value.split(','))
