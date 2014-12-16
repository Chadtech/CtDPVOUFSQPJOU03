fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'
{enormousAndStatement, zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require './functionsOfConvenience'
{assemble, read, subtract, write} = require './noideread'

gen = Nt.generate
eff = Nt.effect
speedOfSound = 0.0078


module.exports = 
  assembleAll: (project) ->
    project = read project
    write.all project
    assemble project

  handleNewest: (project) ->
    project = JSON.parse project

    projectTitle = project.title
    pathToPrior = projectTitle + '/' + projectTitle + '.json'
    prior = fs.readFileSync pathToPrior, 'utf8'
    prior = JSON.parse prior

    priorTimesEqual = true
    for timeIndex in [0..prior.piece.time.rate.length - 1] by 1
      if prior.piece.time.rate[timeIndex] isnt project.piece.time.rate[timeIndex]
        priorTimesEqual = false

    DontReconstructIf = [
      fs.existsSync projectTitle + '/piece.wav'
      _.isEqual project.pages, prior.pages
      _.isEqual (_.map project.piece.voices, (voice) -> voice.attributes),
        (_.map prior.piece.voices, (voice) -> voice.attributes)
      priorTimesEqual
      _.isEqual project.piece.scale, prior.piece.scale
      _.isEqual project.piece.tonic, prior.piece.tonic
      _.isEqual project.piece.beatLength, prior.piece.beatLength
    ]

    console.log 'A'
    if not enormousAndStatement DontReconstructIf
      console.log 'B'
      JSONInPath = project.title + '/' + project.title + '.json'
      fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
      assemble read project

    else
      diffeentBeats = []
      projectVoices = project.piece.voices
      priorVoices = prior.piece.voices

      eachBeatCompared = _.map projectVoices, (voice, voiceIndex) =>
        voice.score = _.map voice.score, (beat, beatIndex) =>
          [beat, priorVoices[voiceIndex][beatIndex], beatIndex, voice.name]
        voice

      beatsToSubtract = []
      for beatIndex in [0..eachBeatCompared.length - 1] by 1
        thisBeat = eachBeatCompared[beatIndex]
        unless _.isEqual thisBeat[0], thisBeat[1]
          beatsToSubtract.push [thisBeat[3], thisBeat[4]]

      momentsInTime = []
      beatLength = parseInt project.piece.beatLength
      for beat in project.piece.time.rate
        beatLength = (beatLength * parseFloat beat) // 1
        momentsInTime.push performanceLength

      subtract beatsToSubtract, momentsInTime, project.title

    Nt.convertToFloat (Nt.open projectTitle + '/' + 'piece.wav')[0]
