_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{enormousAndStatement, zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

module.exports =
  one: (project, voice, beatIndex) =>
    beat = voice.score[beatIndex]
    thisNote = _.clone voiceProfiles[voice.attributes.type].defaultValues
    if beat['tone']?
      for key in _.keys beat
        if beat[key]?
          thisNote[key] = beat[key]
      thisNote = voiceProfiles[voice.attributes.type].generate thisNote
      thisNote = eff.convolve thisNote, 
        factor: 0.1
        seed: Nt.convertToFloat (Nt.open 'artificialBathRoomL.wav')[0]
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

  all: (project) =>
    for voice in project.piece.voices
      for beatIndex in [0..(voice.score.length - 1)] by 1
        writeThisBit project, voice, beatIndex