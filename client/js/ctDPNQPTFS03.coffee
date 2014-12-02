React = require 'react'
_ = require 'lodash'
Properties = require './properties'
Dimension = require './dimension'
Voices = require './voices'

{a, p, div, input} = React.DOM


project =
  title: ''
  pages: ['properties', 'voices', 'amplitude', 'tone']
  piece:
    voices: [
      {
        name: 'voice0'
        attributes:
          type: 'sine'
          xpos: '0'
          ypos: '0'
          seed: undefined
        score: [
          {
            '2': '0.5'
            '3': '50'
          }
          {}
          {}
          {}
          {}
          {}
          {}
          {}
        ]
      }
      {
        name: 'voice1'
        attributes:
          type: 'saw'
          xpos: '0'
          ypos: '0'
          seed: undefined
        score: [
          {
            '2': '0.5'
            '3': '44'
          }
          {}
          {}
          {}
          {}
          {}
          {}
        ]
      }
    ]
    scale: []
    tonic: '25'
    beatLength: '22050'
    barLength: '8'
    subLength: '2'
    convolveSeed: undefined
  time: {}

AppClass = React.createClass
  getInitialState: ->
    project: @props.project
    pageIndex: 0
    currentTab: 0

  componentDidMount: ->
    window.getState = =>
      @state.project

  onPieceUpdate: (piece) ->
    @state.project.piece = piece
    @setState project: @state.project

  pieceTitleHandle: (event) ->
    @state.project.title = event.target.value
    @setState project: @state.project
    
  addTab: (newPage) ->
    newDimensionName = '0'
    while ('dimension ' + newDimensionName) in @state.project.pages
      newDimensionName = parseInt(newDimensionName) + 1 + ''
    @state.project.pages = @state.project.pages.concat(['dimension ' + newDimensionName])
    @setState project: @state.project

  tabClick: (event) ->
    pageIndex = @state.project.pages.indexOf(event.target.value)
    @setState pageIndex: pageIndex

  determineCurrentPage: (props) ->
    switch @state.pageIndex
      when 0
        return Properties props
      when 1
        return Voices props
      else
        return Dimension props

  dimensionNameChange: (dimensionIndex, newName) ->
    @state.project.pages[dimensionIndex] = newName
    @setState project: @state.project

  voiceTypeChange: (voiceIndex, newType) ->
    @state.project.piece.voices[voiceIndex].attributes.type = newType
    @setState project: @state.project

  voiceNameChange: (voiceIndex, newName) ->
    @state.project.piece.voices[voiceIndex].name = newName
    @setState project: @state.project

  voiceSeedChange: (voiceIndex, newSeed) ->
    @state.project.piece.voices[voiceIndex].attributes.seed = newSeed
    @setState project: @state.project

  voiceXposChange: (voiceIndex, newXpos) ->
    @state.project.piece.voices[voiceIndex].attributes.xpos = newXpos
    @setState project: @state.project

  voiceYposChange: (voiceIndex, newYpos) ->
    @state.project.piece.voices[voiceIndex].attributes.ypos = newYpos
    @setState project: @state.project

  voiceAdd: () ->
    newName = '0'
    allTheNames = _.pluck @state.project.piece.voices, 'name'
    while 'voice' + newName in allTheNames
      newName = parseInt newName
      newName++
      newName += ''
    newVoice = 
      name: 'voice' + newName
      attributes:
        type: 'sine'
      score: []
    @state.project.piece.voices.push newVoice
    @setState project: @state.project

  seedAdd: (voiceIndex) ->
    @state.project.piece.voices[voiceIndex].attributes.seed = ''
    @setState project: @state.project

  beatLengthChange: (beatLength) ->
    @state.project.piece.beatLength = beatLength
    @setState project: @state.project

  scaleAdd: ->
    @state.project.piece.scale.push ''
    @setState project: @state.project

  scaleDestroy: ->
    @state.project.piece.scale = []
    @setState project: @state.project

  stepChange: (stepIndex, newStep) ->
    @state.project.piece.scale[stepIndex] = newStep
    @setState project: @state.project

  tonicChange: (newTonic) ->
    @state.project.piece.tonic = newTonic
    @setState project: @state.project

  barLengthChange: (newBarLength) ->
    @state.project.piece.barLength = newBarLength
    @setState project: @state.project

  subLengthChange: (newSubLength) ->
    @state.project.piece.subLength = newSubLength
    @setState project: @state.project

  appendBar: ->
    for voice in @props.project.piece.voices
      extraBeatIndex = 0
      while extraBeatIndex < @props.project.piece.barLength
        voice.score.push {}
        extraBeatIndex++

    @setState project: @state.project


  onNoteChange: (voiceIndex, beatIndex, value) ->
    beat = @state.project.piece.voices[voiceIndex].score[beatIndex] ? {}
    beat[@state.pageIndex] = value
    @state.project.piece.voices[voiceIndex].score[beatIndex] = beat
    @setState project: @state.project

  render: ->
    div {},
      div {className: 'spacer'}
      div {className: 'indent'},
        div {className: 'container'}
          div {className: 'row'},
            div {className: 'column double'},
              p
                className: 'point'
                'CtDPNQPTFS03:NFE'
            div {className: 'column double'},
              input
                className: 'input wide'
                value: @state.project.title
                onChange: @pieceTitleHandle
                placeholder: '<piece name>'
                spellCheck: 'false'

          div {className: 'row'},
            for page in @state.project.pages
              div {className: 'column'},
                input
                  className: 'submit'
                  type: 'submit'
                  value: page
                  onClick: @tabClick

            div {className: 'column'},
              input
                className: 'submit'
                type: 'submit'
                onClick: @addTab
                value: '+'

          @determineCurrentPage
            pageIndex: @state.pageIndex
            pageName: @state.project.pages[@state.pageIndex]
            onNameChange: @dimensionNameChange

            voices: @state.project.piece.voices
            onVoiceTypeChange: @voiceTypeChange
            onVoiceNameChange: @voiceNameChange
            onVoiceSeedChange: @voiceSeedChange
            onVoiceXposChange: @voiceXposChange
            onVoiceYposChange: @voiceYposChange
            onSeedAdd: @seedAdd
            onVoiceAdd: @voiceAdd

            scale: @state.project.piece.scale
            onScaleAdd: @scaleAdd
            onScaleDestroy: @scaleDestroy
            onStepChange: @stepChange
            tonic: @state.project.piece.tonic
            onTonicChange: @tonicChange
            barLength: @state.project.piece.barLength
            subLength: @state.project.piece.subLength
            onBarLengthChange: @barLengthChange
            onSubLengthChange: @subLengthChange
            beatLength: @props.project.piece.beatLength
            onBeatLengthChange: @beatLengthChange
            dimensions: _.filter @props.project.pages, (page) ->
              if page is 'properties'
                return false
              if page is 'voices'
                return false
              return true

            onAppendBar: @appendBar


            onNoteChange: @onNoteChange


App = React.createFactory AppClass

ctdpnqptfs = new App
  project: project

element = document.getElementById 'content'
React.render ctdpnqptfs, element