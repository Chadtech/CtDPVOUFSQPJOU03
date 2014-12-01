React = require 'react'
_ = require 'lodash'

{a, div, input, p, select, option} = React.DOM

types = ['sine', 'saw']

VoicesClass = React.createClass
  typeChangeHandle: (event) ->
    console.log 'A', event.target, event.target.getAttribute 'data-index'
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    type = event.target.value
    console.log voiceIndex, type
    @props.onVoiceTypeChange voiceIndex, type
  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'Voices'

      div {className: 'row'},
        div {className: 'column'},
          _.map @props.voices, (voice, voiceIndex) =>
            div {},
              input
                value: voice.name
              select
                defaultValue: voice.attributes.type
                onChange: @typeChangeHandle
                'data-index': voiceIndex
                className: 'sumptn '+voiceIndex
              ,
                _.map types, (type) ->
                  console.log 'type', type, voice.attributes.type
                  option {}, type




Voices = React.createFactory VoicesClass

module.exports = Voices