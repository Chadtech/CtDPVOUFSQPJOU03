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

convertToReactElements = (rowsAndColumns, barLength, subLength, subModulus, cellChangeFunction, insertBarFunction, removeBarFunction, removeValues) =>
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

      if (rowIndex % barLength) is 0
        div {className: 'column half'},
          input
            className: 'submit half'
            onClick: insertBarFunction
            type: 'submit'
            value: '+ bar'
            'data-note': rowIndex

      if (rowIndex % barLength) is 1
        div {className: 'column half'},
          input
            className: 'submit half'
            onClick: removeBarFunction
            type: 'submit'
            'data-note': rowIndex 
            value: removeValues[rowIndex // barLength]

unshiftNoteIndex = (rowsAndColumns, barLength, subLength) ->
  noteIndex = 0
  while noteIndex < rowsAndColumns.length
    rowsAndColumns[noteIndex].unshift noteIndex
    noteIndex++
  rowsAndColumns

DimensionClass = React.createClass
  getInitialState: ->
    removeValues = []
    beatIndex = 0
    while beatIndex < @props.voices[0].score.length
      if (beatIndex % @props.barLength) is 0
        removeValues.push 'xx'
      beatIndex++

    return removeValues: removeValues

  handleDimensionName: (event) ->
    @props.onNameChange @props.pageIndex, event.target.value

  noteChange: (event) ->
    voiceIndex = event.target.getAttribute 'data-voice'
    noteIndex = event.target.getAttribute 'data-note'
    value = event.target.value
    @props.onNoteChange voiceIndex, noteIndex, value, @props.dimensionKey

  appendBar: ->
    @props.onAppendBar()
    @state.removeValues.push 'xx'
    @setState removeValues: @state.removeValues

  insertBar: (event) ->
    noteIndex = event.target.getAttribute 'data-note'
    @state.removeValues.splice noteIndex, 0, 'xx'
    @setState removeValues: @state.removeValues
    @props.onInsertBar noteIndex

  removeBar: (event) ->
    noteIndex = event.target.getAttribute 'data-note'
    if @state.removeValues[noteIndex // @props.barLength] is 'xx'
      @state.removeValues[noteIndex // @props.barLength] = 'x'
      @setState removeValues: @state.removeValues
    else
      console.log 'A', noteIndex
      @state.removeValues.splice (noteIndex // @props.barLength), 1
      @setState removeValues: @state.removeValues
      @props.onRemoveBar (noteIndex - 1)

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
        @insertBar
        @removeBar
        @state.removeValues

      div {className: 'row'},
        div {className: 'column half'},
          input
            className: 'submit half'
            type: 'submit'
            value: '+ bar'
            onClick: @appendBar

Dimension = React.createFactory DimensionClass

module.exports = Dimension