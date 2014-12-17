_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{enormousAndStatement, zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

module.exports = (bitsToSubtract, momentsInTime, projectTitle) ->
  piece = Nt.open projectTitle + '/' + projectTitle + '.wav'
  pieceL = piece[0]
  pieceR = piece[1]

  # [beatIndex, voiceName]
  for bitsToSubtract in bitsToSubtract
    bitFileName = projectTitle + '/' + bitsToSubtract[1]
    bitFileName += zeroPadder 10, bitsToSubtract[0]
    thisBit = Nt.open bitFileName

    thisBit = _.map thisBit, (channel) ->
      eff.invert channel

    pieceL Nt.mix thisBit[0], pieceL, momentsInTime[bitsToSubtract[0]]
    pieceR Nt.mix thisBit[1], pieceR, momentsInTime[bitsToSubtract[1]]

  Nt.buildFile projectTitle + '/' + projectTitle + '.wav', [pieceL, pieceR]
