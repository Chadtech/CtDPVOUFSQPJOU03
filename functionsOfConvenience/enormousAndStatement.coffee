module.exports = (statements) ->
  output = true
  for statement in statements
    output = output and statement
  output