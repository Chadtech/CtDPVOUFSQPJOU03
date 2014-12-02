React = require 'react'
_ = require 'lodash'

{a, div, input, p} = React.DOM

PropertiesClass = React.createClass

  beatLengthChangeHandle: (event) ->
    newBeatLength = event.target.value
    @props.onBeatLengthChange newBeatLength

  scaleAdd: ->
    @props.onScaleAdd()

  scaleDestroy: ->
    @props.onScaleDestroy()

  noteChangeHandle: (event) ->
    stepIndex = parseInt event.target.getAttribute 'data-index'
    newStep = event.target.value
    @props.onStepChange stepIndex, newStep

  tonicChangeHandle: (event) ->
    newTonic = event.target.value
    @props.onTonicChange newTonic

  barLengthChangeHandle: (event) ->
    newBarLength = event.target.value
    @props.onBarLengthChange newBarLength

  subLengthChangeHandle: (event) ->
    newSubLength = event.target.value
    @props.onSubLengthChange newSubLength

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'properties'

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'beat length'

        div {className: 'column'},
          input
            className: 'input'
            value: @props.beatLength
            onChange: @beatLengthChangeHandle

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'scale'

        _.map @props.scale, (step, stepIndex) =>
          div {className: 'column half'},
            input
              className: 'input half'
              onChange: @noteChangeHandle
              value: @props.scale[stepIndex]
              'data-index': stepIndex

        div {className: 'column half'},
          input
            className: 'submit half'
            type: 'submit'
            onClick: @scaleAdd
            value: '+'

        div {className: 'column half'},
          input
            className: 'submit half'
            type: 'submit'
            onClick: @scaleDestroy
            value: 'xx'

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'remove'

        _.map @props.dimensions, (dimension, dimensionIndex) =>
          div {className: 'column'},
            input
              className: 'submit'
              type: 'submit'
              value: dimension

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'tonic'

        div {className: 'column'},
          input
            className: 'input'
            onChange: @tonicChangeHandle
            value: @props.tonic

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'bar length'

        div {className: 'column'},
          input
            className: 'input'
            onChange: @barLengthChangeHandle
            value: @props.barLength

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'sub length'

        div {className: 'column'},
          input
            className: 'input'
            onChange: @subLengthChangeHandle
            value: @props.subLength










Properties = React.createFactory PropertiesClass

module.exports = Properties