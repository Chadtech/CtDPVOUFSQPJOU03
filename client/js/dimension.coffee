React = require 'react'
_ = require 'lodash'

{a, div, input, p} = React.DOM

DimensionClass = React.createClass
  handleDimensionName: (event) ->
    @props.onNameChange @props.pageIndex, event.target.value

  onNoteChange: (event) ->
    voiceIndex = event.target.getAttribute 'data-voice'
    noteIndex = event.target.getAttribute 'data-note'
    value = event.target.value

    @props.onNoteChange voiceIndex, noteIndex, value

  appendBar: ->
    @props.onAppendBar()

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p
            className: 'point'
            @props.pageName

Dimension = React.createFactory DimensionClass

module.exports = Dimension