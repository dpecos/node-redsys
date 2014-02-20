pad_left = (str, chr, len) ->
  (new Array(len + 1).join(chr) + str).slice(-len)

pad_right = (str, chr, len) ->
  (str + new Array(len + 1).join(chr)).substr(0, len)

format = (str, min, max) ->
  if str
    str = pad_right str, ' ', min if min and str.length < min
    str = str.substr(0, max) if max and str.length > max
  str

formatNumber = (num, min) ->
  num = pad_left num, '0', min if num and min and (num + "").length < min
  num + "" if num
  
module.exports =
  format: format
  formatNumber: formatNumber
