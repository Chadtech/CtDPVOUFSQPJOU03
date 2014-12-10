React = require 'react'
_ = require 'lodash'
Properties = require './properties'
Dimension = require './dimension'
Voices = require './voices'
Time = require './time'
Options = require './options'
$ = require 'jquery'

AudioContext = window.audioContext or window.webkitAudioContext
audioContext = new AudioContext

{a, p, div, input} = React.DOM

project =
  title: ''
  pages: ['options', 'properties', 'voices', 'time', 'amplitude', 'tone']
  dimensions: ['amplitude', 'tone']
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
            'amplitude': '0.5'
            'tone': '50'
          }, {}, {}, {}, {}, {}, {}, {}
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
            'amplitude': '0.5'
            'tone': '44'
          }, {}, {}, {}, {}, {}, {}, {}
        ]
      }
    ]
    time:
      rate: ['1','1','1','1','1','1','1','1']
    scale: ['1']
    tonic: '25'
    beatLength: '22050'
    barLength: '8'
    subLength: '4'
    subModulus: '0'
    convolveSeed: undefined

AppClass = React.createClass
  getInitialState: ->
    project: @props.project
    pageIndex: 1
    displayBar: 0
    playSign: 'play'
    playClass: 'submit'

  componentDidMount: ->
    window.getState = =>
      @state.project

  pieceTitleHandle: (event) ->
    @state.project.title = event.target.value
    @setState project: @state.project
    
  addDimension: (newDimensionsName) ->
    nameOfLastResort = '0'
    while ('dimension ' + nameOfLastResort) in @state.project.pages
      nameOfLastResort = parseInt(nameOfLastResort) + 1 + ''
    nameOfLastResort = 'dimension ' + nameOfLastResort
    nameIsInPages = newDimensionsName in @state.project.pages

    if not nameIsInPages
      @state.project.pages = @state.project.pages.concat [newDimensionsName]
      if not (newDimensionsName in @state.project.dimensions)
        @state.project.dimensions.push newDimensionsName
    else
      @state.project.pages = @state.project.pages.concat [nameOfLastResort]
      if not (nameOfLastResort in @state.project.pages)
        @state.project.dimensions.push nameOfLastResort

    @setState project: @state.project

  tabClick: (event) ->
    pageIndex = @state.project.pages.indexOf(event.target.value)
    @setState pageIndex: pageIndex

  determineCurrentPage: (props) ->
    switch @state.pageIndex
      when 0
        return Options props
      when 1
        return Properties props
      when 2
        return Voices props
      when 3
        return Time props
      else
        return Dimension props

  dimensionDestroy: (dimensionName) ->
    for page in @state.project.pages
      if page is dimensionName
        if page isnt 'properties'
          if page isnt 'voices'
            indexToRemove = 
              @state.project.pages.indexOf dimensionName
            @state.project.pages.splice indexToRemove, 1
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

  voiceAdd: ->
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

  voiceDestroy: (voiceIndex) ->
    @state.project.piece.voices.splice voiceIndex, 1
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

  subModulusChange: (newSubModulus) ->
    @state.project.piece.subModulus = newSubModulus
    @setState project: @state.project

  appendBar: ->
    for voice in @state.project.piece.voices
      extraBeatIndex = 0
      while extraBeatIndex < @state.project.piece.barLength
        voice.score.push {}
        extraBeatIndex++

    extraBeatIndex = 0
    while extraBeatIndex < @state.project.piece.barLength
      @state.project.piece.time.rate.push '1'
      extraBeatIndex++

    @setState project: @state.project

  insertBar: (barAt) ->
    for voice in @state.project.piece.voices
      barAtIteration = 0
      while barAtIteration < @state.project.piece.barLength
        voice.score.splice barAt, 0, {}
        barAtIteration++

    barAtIteration = 0
    while barAtIteration < @state.project.piece.barLength
      @state.project.piece.time.rate.splice barAt, 0, '1'
      barAtIteration++

    @setState project: @state.project

  removeBar: (barAt) ->
    for voice in @props.project.piece.voices
      barAtIteration = 0
      while barAtIteration < @props.project.piece.barLength
        voice.score.splice barAt, 1
        barAtIteration++

    barAtIteration = 0
    while barAtIteration < @props.project.piece.barLength
      @props.project.piece.time.rate.splice barAt, 1
      barAtIteration++

    @setState project: @state.project

  noteChange: (voiceIndex, beatIndex, value, dimensionKey) ->
    beat = @state.project.piece.voices[voiceIndex].score[beatIndex] ? {}
    beat[dimensionKey] = value
    @state.project.piece.voices[voiceIndex].score[beatIndex] = beat
    @setState project: @state.project

  displayBarChange: (newDisplayBar) ->
    @state.displayBar = newDisplayBar
    @setState displayBar: @state.displayBar

  tempoChange: (newTempo, tempoIndex) ->
    @state.project.piece.time.rate[tempoIndex] = newTempo
    @setState project: @state.project

  save: ->
    destinationURL = 'http://localhost:8097/api/'
    destinationURL += @state.project.title

    $.post destinationURL, @state.project

  open: (projectName) ->
    destinationURL = 'http://localhost:8097/api/'
    destinationURL += projectName

    $.get destinationURL, (data) =>
      if data.project?
        @setState project: data.project

  playClick: ->
    destinationURL = 'http://localhost:8097/api/play/'
    destinationURL += @state.project.title

    submission =
      playFrom: @state.displayBar

    $.post destinationURL, submission, (data) =>
      numberOfFrames = data.buffer.length
      audioBuffer = audioContext.createBuffer 1, numberOfFrames, 44100

      audioBufferData = audioBuffer.getChannelData 0
      frameIndex = 0
      while frameIndex < numberOfFrames
        audioBufferData[frameIndex] = data.buffer[frameIndex]
        frameIndex++

      source = audioContext.createBufferSource()
      source.buffer = audioBuffer
      source.connect audioContext.destination
      source.start()

    if @state.playSign is 'play'
      @state.playSign = 'playing'
      @state.playClass = 'submit current'
    else
      @state.playSign = 'play'
      @state.playClass = 'submit'

    @setState playSign:  @state.playSign
    @setState playClass: @state.playClass

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
            div {className: 'column oneAndHalf'},
              input
                className:   'input oneAndHalf'
                value:       @state.project.title
                onChange:    @pieceTitleHandle
                placeholder: '<piece name>'
                spellCheck:  'false'

            div {className: 'column half'},
              input
                className: 'submit half'
                type:      'submit'
                value:     'save'
                onClick:   @save

            div {className: 'column'},
              input
                className: 'submit'
                type:      'submit'
                value:     'play'
                onClick:   @playClick

          div {className: 'row'},
            for page in @state.project.pages
              div {className: 'column'},
                input
                  className: 'submit'
                  type:      'submit'
                  value:     page
                  onClick:   @tabClick

          @determineCurrentPage
            displayBar:         @state.displayBar
            onDisplayBarChange: @displayBarChange
            pageIndex:          @state.pageIndex
            dimensionKey:       @state.project.pages[@state.pageIndex]
            pageName:           @state.project.pages[@state.pageIndex]

            voices:              @state.project.piece.voices
            onVoiceTypeChange:   @voiceTypeChange
            onVoiceNameChange:   @voiceNameChange
            onVoiceSeedChange:   @voiceSeedChange
            onVoiceXposChange:   @voiceXposChange
            onVoiceYposChange:   @voiceYposChange
            onSeedAdd:           @seedAdd
            onVoiceAdd:          @voiceAdd
            onVoiceDestroy:      @voiceDestroy

            scale:               @state.project.piece.scale
            onScaleAdd:          @scaleAdd
            onScaleDestroy:      @scaleDestroy
            onStepChange:        @stepChange
            tonic:               @state.project.piece.tonic
            onTonicChange:       @tonicChange
            barLength:           @state.project.piece.barLength
            subLength:           @state.project.piece.subLength
            subModulus:          @state.project.piece.subModulus
            onBarLengthChange:   @barLengthChange
            onSubLengthChange:   @subLengthChange
            onSubModulusChange:  @subModulusChange
            beatLength:          @props.project.piece.beatLength
            onBeatLengthChange:  @beatLengthChange
            dimensions: _.filter @props.project.pages, (page) ->
              if page is 'properties'
                return false
              if page is 'voices'
                return false
              if page is 'time'
                return false
              if page is 'options'
                return false
              return true
            onDimensionDestroy: @dimensionDestroy
            onDimensionAdd:     @addDimension

            onAppendBar:  @appendBar
            onRemoveBar:  @removeBar
            onInsertBar:  @insertBar
            onNoteChange: @noteChange

            time:          @state.project.piece.time
            onTempoChange: @tempoChange

            title: @state.project.title

            save: @save
            open: @open

            playSign:    @state.playSign
            playClass:   @state.playClass
            onPlayClick: @playClick

      div {className: 'spacer'}

App = React.createFactory AppClass

ctdpnqptfs = new App
  project: project

element = document.getElementById 'content'
React.render ctdpnqptfs, element