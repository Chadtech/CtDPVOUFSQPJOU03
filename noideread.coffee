fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'
{enormousAndStatement, zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require './functionsOfConvenience'
{assemble, read, subtract, write, compare} = require './noideread'

gen = Nt.generate
eff = Nt.effect
speedOfSound = 0.0078

assembleAll = (project) ->
  project = read project
  write.all project
  assemble project

module.exports = 
  assembleAll: assembleAll

  handleLatest: (project) ->
    project = JSON.parse project

    pathToPrior = project.title + '/' + project.title + '.json'
    prior = JSON.parse fs.readFileSync pathToPrior, 'utf8'

    assessment = compare project, prior

    switch assessment.msg
      when 'reconstruct'
        assembleAll project
        return Nt.convertToFloat Nt.open project.title + '/piece.wav'
      when 'identical'
        return Nt.convertToFloat Nt.open project.title + '/piece.wav'
      when 'not identical'
        console.log assessment.differences