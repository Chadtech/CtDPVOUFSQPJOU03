fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'

zeroPadder = (number, numberOfZerosToFill) ->
  numberAsString = number + ''
  while numberAsString.length < numberOfZerosToFill
    numberAsString = '0' + numberAsString
  return numberAsString

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

assmbleAllBits = (project) =>
  performanceLength = 0
  beatLength = project.piece.beatLength
  for beatDuration in project.piece.time.rate
    performanceLength += beatLength
    beatLength = beatLength * parseFloat beatDuration


module.exports = 
  read: (projectTitle, message) ->
    fs.exists projectTitle, (exists) ->
      if exists
        projectJSON = projectTitle + '/' + projectTitle + '.json'
        fs.readFile projectJSON, 'utf8', (error, project) ->
          unless error
            project = JSON.parse project
            dimensionIndexDictionary = 
              dimensionToIndex project.dimensions

            # Convert tone dimension of each beat to frequency 
            project.piece.voices = 
              _.map project.piece.voices, (voice, voiceIndex) =>
                voice.score = 
                  _.map voice.score, (beat, beatIndex) =>
                    if beat['tone']?
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
            
            #console.log 'A', project.piece.voices[0].score
            writeAllBits project





