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

writeAllBits = (project) ->
  for voice in project.piece.voices
    for beatIndex in [0..voice.score.length] by 1
      beat = voice.score[beatIndex]
      thisNote = _.clone voiceProfiles[voice.attributes.type].defaultValues
      for key in _.keys beat
        thisNote[key] = beat[key]
      thisNote = voiceProfiles[voice.attributes.type].generate thisNote
      thisNote = Nt.convertTo64Bit thisNote
      noteFileName = voice.name + zeroPadder(beatIndex, 10) + '.wav'
      pathToThisNote = './' + project.title + '/' + noteFileName
      Nt.buildFile pathToThisNote, [thisNote]

for i in [0..n.length] by 1


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
                    if beat[dimensionIndexDictionary['tone']]?
                      convertedTone = 
                        scaleSystemToFrequencies project.piece.scale,
                          project.piece.tonic
                          beat[dimensionIndexDictionary['tone']]
                      beat[dimensionIndexDictionary['tone']] = 
                        convertedTone
                    beat
                voice

            # Convert beats into objects with dimensions as keys
            # and their value as values
            project.piece.voices =
              _.map project.piece.voices, (voice, voiceIndex) =>
                voice.score =
                  _.map voice.score, (beat, beatIndex) =>
                    keys = _.keys beat
                    keys = _.map keys, (key) =>
                      project.dimensions[parseInt key]
                    values = _.map beat, (dimensionValue) ->
                      dimensionValue

                    _.zipObject keys, values
                voice

            console.log 'A', project.piece.voices[0]
            console.log 'B', project.piece.voices[1]





