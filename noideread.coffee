fs = require 'fs'

zeroPadder = (number, numberOfZerosToFill) ->
  numberAsString = number + ''
  while numberAsString.length < numberOfZerosToFill
    numberAsString = '0' + numberAsString
  return numberAsString

module.exports = 
  read: (projectTitle, message) ->
    fs.exists projectTitle, (exists) ->
      if exists
        projectJSON = projectTitle + '/' + projectTitle + '.json'
        fs.readFile projectJSON, 'utf8', (error, data) ->
          unless error
            console.log 'A', data


