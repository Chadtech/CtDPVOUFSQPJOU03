fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'

gen = Nt.generate

enormousAndStatement = (statements) ->
  output = false
  for statement in statements
    output = output and statement
  output

zeroPadder = (number, numberOfZerosToFill) ->
  numberAsString = number + ''
  while numberAsString.length < numberOfZerosToFill
    numberAsString = '0' + numberAsString
  numberAsString

scaleSystemToFrequencies = (scale, tonic, note) ->
  octave = note.substr 0, note.length - 1
  note = note.substr note.length - 1
  scaleIndex = parseInt note, scale.length
  octave = 2 ** parseInt octave

  tonic * scale[scaleIndex] * octave

dimensionToIndex = (dimensions) ->
  dimensions = _.map dimensions, (dimension) ->
    dimension
  theirIndex = _.map dimensions, (dimension, dimensionIndex) ->
    dimensionIndex
  
  _.zipObject dimensions, theirIndex

writeAllBits = (project) =>
  for voice in project.piece.voices
    for beatIndex in [0..(voice.score.length - 1)] by 1
      beat = voice.score[beatIndex]
      thisNote = _.clone voiceProfiles[voice.attributes.type].defaultValues
      if beat['tone']?
        for key in _.keys beat
          if beat[key]?
            thisNote[key] = beat[key]
        thisNote = voiceProfiles[voice.attributes.type].generate thisNote
        thisNote = Nt.convertTo64Bit thisNote
      else
        thisNote = []
      noteFileName = voice.name + zeroPadder(beatIndex, 10) + '.wav'
      pathToThisNote = './' + project.title + '/' + noteFileName
      Nt.buildFile pathToThisNote, [thisNote]

assembleAllBits = (project, saveAsFile) =>
  voices = _.clone project.piece.voices
  for voice in voices
    voice.score = _.map voice.score, (beat, beatIndex) =>
      pathToFile = project.title + '/'
      pathToFile += voice.name + zeroPadder(beatIndex, 10) + '.wav'
      thisBeat = Nt.open pathToFile
      thisBeat = thisBeat[0]
      thisBeat

  performanceLength = 0
  momentsInTime = []
  beatLength = parseInt project.piece.beatLength
  for beat in project.piece.time.rate
    momentsInTime.push performanceLength
    performanceLength += beatLength
    beatLength = beatLength * parseFloat beat


  DurationsOfEachVoicesLastNote = _.map voices, (voice) ->
    voice.score[voice.score.length - 1].length

  longestLastNote = _.max DurationsOfEachVoicesLastNote

  performanceLength += longestLastNote

  performance = gen.silence sustain: performanceLength

  for voice in voices
    voice.score = _.zip momentsInTime, voice.score

  for voice in voices
    for beat in voice.score
      if beat[1]?
        performance = Nt.mix beat[1], performance, beat[0]

  pathToPiece = project.title + '/' + 'piece.wav'

  Nt.buildFile pathToPiece, [performance]

module.exports = 
  read: (projectTitle) ->
    if fs.existsSync projectTitle
      projectJSON = projectTitle + '/' + projectTitle + '.json'
      project = fs.readFileSync projectJSON, 'utf8'
      project = JSON.parse project
      dimensionIndexDictionary = 
        dimensionToIndex project.dimensions

      # Convert tone dimension of each beat to frequency 
      project.piece.voices = 
        _.map project.piece.voices, (voice, voiceIndex) =>
          voice.score = 
            _.map voice.score, (beat, beatIndex) =>
              if beat?['tone']
                convertedTone = 
                  scaleSystemToFrequencies project.piece.scale,
                    project.piece.tonic
                    beat['tone']
                beat['tone'] = convertedTone
              beat
          voice

      # Convert all dimension values to numbers
      project.piece.voices =
        _.map project.piece.voices, (voice, voiceIndex) =>
          voice.score =
            _.map voice.score, (beat, beatIndex) =>
              _.mapValues beat, (value) =>
                parseFloat value
          voice

      project

  assemble: (project) ->
    writeAllBits project
    assembleAllBits project

  judgeNewest: (project) ->
    project = JSON.parse project

    projectTitle = project.title
    pathToPrior = projectTitle + '/' + projectTitle + '.json'
    prior = fs.readFileSync pathToPrior, 'utf8'
    prior = JSON.parse prior

    reconstructFromScratch = not fs.existsSync projectTitle + '/piece.wav'
    reconstructFromScratch = reconstructFromScratch

    console.log 'TIME', project.time, prior.time

    DontReconstructIf = [
      fs.existsSync projectTitle + '/piece.wav'
      _.isEqual project.pages, prior.pages
      _.isEqual (_.map project.piece.voices, (voice) -> voice.attributes),
        (_.map prior.piece.voices, (voice) -> voice.attributes)
      _.isEqual project.piece.time, prior.piece.time
      _.isEqual project.piece.scale, prior.piece.scale
      _.isEqual project.piece.tonic, prior.piece.tonic
      _.isEqual project.piece.beatLength, prior.piece.beatLength
    ]

    if not enormousAndStatement DontReconstructIf
      @assemble @read projectTitle






