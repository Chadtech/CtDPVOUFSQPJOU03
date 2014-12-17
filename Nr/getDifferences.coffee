module.exports = (current, prior) ->
  differences = _.map current.piece.voices, (voice, voiceIndex) ->
    voice.score = _.map voice.score, (beat, beatIndex) ->
      current: beat
      prior: prior.piece.voices[voiceIndex].score[beatIndex]
    voice

  differences = _.map differences, (voice, voiceIndex) ->
    voice.score

  differences = _.map differences, (voice, voiceIndex) ->
    _.map voice, (beat, beatIndex) ->
      if _.isEqual beat.current, beat.prior
        beat = 'SAME'
      beat
  ###
  areIdentical = _.map differences, (voices, voiceIndex) ->
    _.reduce voice, (beat, beatIndex) ->
  ###


  areIdentical = true
  for voice in differences
    for beat in voice.score
      if _.isEqual beat.current, beat.prior
        beat = 'SAME'
      else
        areIdentical = false