React = require 'react'
_ = require 'lodash'

{a, div, input, p, select, option} = React.DOM

types = ['sine', 'saw']

VoicesClass = React.createClass

  typeChangeHandle: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    type = event.target.value
    @props.onVoiceTypeChange voiceIndex, type

  nameChangleHandle: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    name = event.target.value
    @props.onVoiceNameChange voiceIndex, name

  voiceAdd: ->
    @props.onVoiceAdd()

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column half'},
          p {className: 'point'},
            'voices'

      div {className: 'row'},
        div {className: 'column half'},
          p
            className: 'point'
            'name'

        div {className: 'column half'},
          p
            className: 'point'
            'type'

        div {className: 'column half'},
          p
            className: 'point'
            'seed'

        div {className: 'column half'},
          p
            className: 'point'
            'x pos'

        div {className: 'column half'},
          p
            className: 'point'
            'y pos'

        div {className: 'column half'},
          p
            className: 'point'
            'remove'

      _.map @props.voices, (voice, voiceIndex) =>
        div {className: 'row'},
          div {className: 'column half'},
            input
              className: 'input half'
              value: voice.name
              onChange: @nameChangleHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className: 'input half'
              value: voice.attributes.type
              onChange: @typeChangeHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className: 'input half'
              value: voice.attributes.type
              onChange: @typeChangeHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className: 'input half'
              value: 0
              onChange: @typeChangeHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className: 'input half'
              value: 0
              onChange: @typeChangeHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className: 'submit half'
              value: 'x'
              type: 'submit'

      div {className: 'row'},
        div {className: 'column half'},
          input
            className: 'submit half'
            type: 'submit'
            onClick: @voiceAdd
            value: '+'



Voices = React.createFactory VoicesClass

module.exports = Voices