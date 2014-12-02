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

      div {className: 'row'},
        div {className: 'column half'},
          input
            className: 'submit half'
            type: 'submit'
            value: '+'



Voices = React.createFactory VoicesClass

module.exports = Voices