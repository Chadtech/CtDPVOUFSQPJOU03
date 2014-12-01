React = require 'react'
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
        score: [
          {
            '2': 1
            '3': 400
          }
        ]
      }
      {
        name: 'voice1'
        attributes:
          type: 'saw'
        score: [
          {'2': 1}
          {
            '2': 0.5
            '3': 400
          }
        ]
      }
    ]
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
            onNoteChange: @onNoteChange

App = React.createFactory AppClass

ctdpnqptfs = new App
  project: project

element = document.getElementById 'content'
React.render ctdpnqptfs, element