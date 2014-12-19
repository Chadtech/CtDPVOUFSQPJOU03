_ = require 'lodash'

module.exports = (current, prior) ->
  differences = _.map current.piece.voices, (voice, voiceIndex) ->
    voice.score = _.map voice.score, (beat, beatIndex) ->
      beat = 
        current: beat
        prior: prior.piece.voices[voiceIndex].score[beatIndex]
      beat
    voice

  differences = _.map differences, (voice, voiceIndex) ->
    voice.score

  differences = _.map differences, (voice, voiceIndex) ->
    _.map voice, (beat, beatIndex) ->
      if _.isEqual beat.current, beat.prior
        beat = 'same'
      beat

  for voice in differences
    console.log 'A.1', voice
    for beat in voice
      #console.log 'B', beat
      if beat isnt 'same'
        return differences

  null