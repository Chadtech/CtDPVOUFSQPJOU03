fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'
{enormousAndStatement, zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require './functionsOfConvenience'
{assemble, read, subtract, write, compare} = require './Nr'

gen = Nt.generate
eff = Nt.effect
speedOfSound = 0.0078

assembleAll = (project) ->
  project = read project
  write.all project
  assemble project

module.exports = 
  assembleAll: assembleAll

  handleLatest: (project) ->
    project = JSON.parse project

    pathToPrior = project.title + '/' + project.title + '.json'
    prior = JSON.parse fs.readFileSync pathToPrior, 'utf8'

    assessment = compare project, prior

    switch assessment.msg

      when 'reconstruct'
        console.log 'RECONSTRUCT'
        assembleAll project
        return Nt.convertToFloat Nt.open project.title + '/piece.wav'
      
      when 'identical'
        console.log 'IDENTICAL'
        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded

      when 'not identical'
        console.log 'NOT IDENTItCAL',
        console.log assessment.differences