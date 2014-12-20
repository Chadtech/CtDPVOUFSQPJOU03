fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require './functionsOfConvenience'
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
    pathToPrior = project.title + '/' + project.title + '.json'
    prior = JSON.parse fs.readFileSync pathToPrior, 'utf8'

    assessment = compare project, prior

    if assessment.msg is 'reconstruct'
        console.log 'RECONSTRUCT'
        assembleAll project
        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded
    else
      if assessment.difference is null
        console.log 'IDENTICAL'
        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded
      else
        console.log 'NOT IDENTICAL'

        priorsToRemove = _.clone assessment.difference, true
        priorsToRemove.piece.voices = 
          _.map priorsToRemove.piece.voices, (voice, voiceIndex) ->
            voice.score = _.map voice.score, (beat, beatIndex) ->
              unless beat is 'same'
                beat = beat.prior
              beat
            voice

        subtractedPath = project.title + '/subtraction.wav'
        Nt.buildFile subtractedPath, subtract.these priorsToRemove

        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded