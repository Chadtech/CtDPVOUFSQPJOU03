fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'

gen = Nt.generate
eff = Nt.effect
speedOfSound = 0.0078

enormousAndStatement = (statements) ->
  output = true
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
        console.log '0'
        thisNote = voiceProfiles[voice.attributes.type].generate thisNote
        thisNote = eff.convolve thisNote, 
          factor: 0.1
          seed: Nt.convertToFloat (Nt.open 'artificialBathRoomL.wav')[0]
        console.log '2'
        thisNote = eff.giveSpatiality thisNote, 
          xpos: parseFloat voice.attributes.xpos
          ypos: parseFloat voice.attributes.ypos
        thisNoteL = thisNote[0]
        thisNoteR = thisNote[1]
        thisNoteL = Nt.convertTo64Bit thisNoteL
        thisNoteR = Nt.convertTo64Bit thisNoteR
      else
        thisNoteL = []
        thisNoteR = []
      noteFileName = voice.name + zeroPadder(beatIndex, 10) + '.wav'
      pathToThisNote = './' + project.title + '/' + noteFileName
      Nt.buildFile pathToThisNote, [thisNoteL, thisNoteR]

assembleAllBits = (project, saveAsFile) =>
  voices = _.clone project.piece.voices
  for voice in voices
    voice.score = _.map voice.score, (beat, beatIndex) =>
      pathToFile = project.title + '/'
      pathToFile += voice.name + zeroPadder(beatIndex, 10) + '.wav'
      thisBeat = Nt.open pathToFile
      thisBeatL = thisBeat[0]
      thisBeatR = thisBeat[1]
      [thisBeatL, thisBeatR]

  performanceLength = 0
  momentsInTime = []
  beatLength = parseInt project.piece.beatLength
  for beat in project.piece.time.rate
    beatLength = (beatLength * parseFloat beat) // 1
    momentsInTime.push performanceLength
    performanceLength += beatLength


  DurationsOfEachVoicesLastNote = _.map voices, (voice) ->
    left = voice.score[voice.score.length - 1][0].length
    right = voice.score[voice.score.length - 1][1].length
    if left > right
      return left
    else
      return right

  longestLastNote = _.max DurationsOfEachVoicesLastNote

  performanceLength += longestLastNote

  performanceL = gen.silence sustain: performanceLength
  performanceR = gen.silence sustain: performanceLength

  for voice in voices
    voice.score = _.zip momentsInTime, voice.score

  for voice in voices
    for beat in voice.score
      if beat[1]?
        performanceL = Nt.mix beat[1][0], performanceL, beat[0]
        performanceR = Nt.mix beat[1][1], performanceR, beat[0]

  pathToPiece = project.title + '/' + 'piece.wav'

  Nt.buildFile pathToPiece, [performanceL, performanceR]

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

    console.log 'A'
    if not enormousAndStatement DontReconstructIf
      console.log 'B'
      JSONInPath = project.title + '/' + project.title + '.json'
      fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
      @assemble @read project.title
      
    Nt.convertToFloat (Nt.open projectTitle + '/' + 'piece.wav')[0]
