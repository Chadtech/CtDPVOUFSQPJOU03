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
        for voice in assessment.difference
          for beat in voice
            if typeof beat isnt 'string'
              console.log 'A', beat.current, beat.prior

        priorsToRemove = _.clone assessment.difference, true
        priorsToRemove.piece.voices = 
          _.map priorsToRemove.piece.voices, (voice, voiceIndex) ->
            voice.score = _.map voice.score, (beat, beatIndex) ->
              unless beat is 'same'
                beat = beat.prior
              beat
            voice

        console.log 'PRIORS TO REMOVE', priorsToRemove.piece.voices[0].score

        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded