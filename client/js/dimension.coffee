React = require 'react'
_ = require 'lodash'

{a, div, input, p} = React.DOM

getRowsAndCols = (voices, key) ->
  _.zip _.map voices, (voice, voiceIndex) ->
    _.map voice.score, (note) ->
      note?[key]

DimensionClass = React.createClass
  handleDimensionName: (event) ->
    @props.onNameChange @props.pageIndex, event.target.value

  onNoteChange: (event) ->
    event.preventDefault()
    if event.keydown is 8
      return false

    voiceIndex = parseInt event.target.getAttribute 'data-voice'
    beatIndex = parseInt event.target.getAttribute 'data-beat'
    value = parseFloat event.target.value
    @props.onNoteChange voiceIndex, beatIndex, value

  render: ->

    rowsAndCols = getRowsAndCols @props.voices, @props.pageIndex

    inject = (row, toInject) ->
      row.unshift div {className: 'column half'}, toInject
      div {className: 'row'}, 
        row
    injectNothing = (row) ->
      inject row, ''
    injectTimes = (rows) ->
      _.map rows, (row, index) ->
        inject row, p {className: 'point'}, index

    div {},
      div {className: 'row'},
        div {className: 'column'},
          input
            className: 'input'
            value: @props.pageName
            onChange: @handleDimensionName
      injectNothing _.map (_.pluck @props.voices, 'name'), (name) ->
        div {className: 'column half'}, 
          p
            className: 'point'
            name
      div {},
        injectTimes _.map rowsAndCols, (row, beatIndex) =>
          _.map row, (col, voiceIndex) =>
            div {className: 'column half'},
              input
                className: 'input half'
                key: "#{name}-#{col}"
                defaultValue: col ? ''
                'data-voice': voiceIndex
                'data-beat': beatIndex
                onChange: @onNoteChange

Dimension = React.createFactory DimensionClass

module.exports = Dimension