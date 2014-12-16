_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{enormousAndStatement, zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

module.exports = (current, prior) ->
  priorTimesEqual = true
  for timeIndex in [0..prior.piece.time.rate.length - 1] by 1
    priorTime = prior.piece.time.rate
    currentTime = current.piece.time.rate
    if priorTime[timeIndex] isnt currentTime[timeIndex]
      priorTimeEqual = false


  dontReconstructIf = [
    _.isEqual current.pages, prior.pages
    _.isEqual 
      (_.map current.piece.voices, (voice) -> voice.attributes)
      (_.map prior.piece.voices, (voice) -> voice.attributes)
    priorTimesEqual
    _.isEqual current.piece.scale, prior.piece.scale
    _.isEqual current.piece.tonic, prior.piece.tonic
    _.isEqual current.piece.beatLength, prior.piece.beatLength
  ]

  console.log 'A'
  if not enormousAndStatement dontReconstructIf
    return msg: 'reconstruct'

  else
    differences = _.clone current.piece.voices
    differences = _.map differences, (voice, voiceIndex) =>
      voice.score = _.map voice.score (beat, beatIndex) =>
        current: beat
        prior: prior.piece.voices[voiceIndex].score[beatIndex]
      voice

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
      return 
        msg: 'not identical'
        differences: differences

