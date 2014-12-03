React = require 'react'
_ = require 'lodash'

{a, div, input, p} = React.DOM

getRowsAndColumns = (voices, dimension) ->
  _.zip _.map voices, (voice, voiceIndex) ->
    _.map voice.score, (note) ->
      note?[dimension]

expressRowIndex = (rowIndex, barLength, subLength, subModulus) =>
  rowIndexExpression = (rowIndex // barLength) + ''
  while rowIndexExpression.length < 5
    rowIndexExpression = '0' + rowIndexExpression
  rowIndexExpression += '.' + (rowIndex % barLength)
  rowIndexExpression

convertToReactElements = (rowsAndColumns, barLength, subLength, subModulus, cellChangeFunction) =>
  _.map rowsAndColumns, (row, rowIndex) =>
    inputClassName = 'input half'
    if (rowIndex % barLength) is 0
      inputClassName += ' verySpecial'
    else 
      barLength = parseInt barLength
      subLength = parseInt subLength
      subModulus = parseInt subModulus
      if (((rowIndex % barLength) + subModulus) % subLength) is 0
        inputClassName += ' special'
    div {className: 'row'},
      div {className: 'column half'},
        p
          className: 'point'
          expressRowIndex rowIndex, barLength, subLength, subModulus
      _.map row, (cell, cellIndex) =>
        div {className: 'column half'},
          input
            className: inputClassName
            onChange: cellChangeFunction
            value: cell ? ''
            'data-voice': cellIndex
            'data-note':  rowIndex

unshiftNoteIndex = (rowsAndColumns, barLength, subLength) ->
  noteIndex = 0
  while noteIndex < rowsAndColumns.length
    rowsAndColumns[noteIndex].unshift noteIndex
    noteIndex++
  rowsAndColumns

DimensionClass = React.createClass
  handleDimensionName: (event) ->
    @props.onNameChange @props.pageIndex, event.target.value

  noteChange: (event) ->
    voiceIndex = event.target.getAttribute 'data-voice'
    noteIndex = event.target.getAttribute 'data-note'
    value = event.target.value
    @props.onNoteChange voiceIndex, noteIndex, value, @props.dimensionKey

  appendBar: ->
    @props.onAppendBar()

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p
            className: 'point'
            @props.pageName

      div {className: 'row'},
        div {className: 'column half'},
          p {className: 'point'},
            ''
        _.map (_.pluck @props.voices, 'name'), (name) ->
          div {className: 'column half'},
            p
              className: 'point'
              name

      convertToReactElements (getRowsAndColumns @props.voices, @props.dimensionKey),
        @props.barLength
        @props.subLength
        @props.subModulus
        @noteChange


Dimension = React.createFactory DimensionClass

module.exports = Dimension