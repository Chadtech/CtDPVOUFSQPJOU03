_ = require 'lodash'
Nt = require '../Nt/noitech'
difference = require './getDifferences'
voiceProfiles = require '../voiceProfiles'
{enormousAndStatement, zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

module.exports = (current, prior) ->
  priorTimesEqual = _.reduce(
    _.map prior.piece.time.rate, (time, timeIndex) ->
      time is current.piece.time.rate[timeIndex]
    (sum, equality) ->
      sum and equality
  )

  dontReconstructIf = [
    _.isEqual current.pages, prior.pages
    _.isEqual (_.map current.piece.voices, (voice) -> voice.attributes),
      (_.map prior.piece.voices, (voice) -> voice.attributes)
    priorTimesEqual
    _.isEqual current.piece.scale, prior.piece.scale
    _.isEqual current.piece.tonic, prior.piece.tonic
    _.isEqual current.piece.beatLength, prior.piece.beatLength
  ]

  reconstruct = not _.reduce dontReconstructIf, (sum, condition) ->
    sum and condition

  if reconstruct
    return msg: 'reconstruct'

  else
    differences = _.clone current.piece.voices
    differences = _.map differences, (voice, voiceIndex) ->
      voice.score = _.map voice.score, (beat, beatIndex) ->
        current: beat
        prior: prior.piece.voices[voiceIndex].score[beatIndex]
      voice

    console.log differences
    console.log _.map differences, (voice, voiceIndex) ->
      voice.score

    areIdentical = true
    for voice in differences
      for beat in voice.score
        if _.isEqual beat.current, beat.prior
          beat = 'SAME'
        else
          areIdentical = false

    if areIdentical
      return msg: 'identical'
    else
      reply = 
        msg: 'not identical'
        differences: differences
      return reply


