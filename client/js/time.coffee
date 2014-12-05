React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

organizeTimeColumns = (time) ->
  _.zip time.samples, time.rate

TimeClass = React.createClass

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'time'

      div {className: 'row'},
        div {className: 'column'},
          p
            className: 'point'
            'display bars'

        div {className: 'column half'},
          input
            className: 'submit half'
            type: 'submit'
            value: '<'

        div {className: 'column half'},
          input
            className: 'input half'
            onChange: @displayBarChangeHandle
            value: @props.displayBar

        div {className: 'column half'},
          input
            className: 'submit half'
            type: 'submit'
            value: '>'

      div {className: 'row'},
        div {className: 'column'}
        div {className: 'column'},
          p
            className: 'point'
            'samples'

        div {className: 'column'},
          p
            className: 'point'
            'tempo change'

      _.map organizeTimeColumns(@props.time), (row, rowIndex) ->
        console.log 'A', rowIndex, row
        div {className: 'row'},
          div {className: 'column half'},
            p
              className: 'pont'
              '**'

          for columnItem in row
            div {className: 'column'},
              input
                className: 'input'
                value: columnItem

Time = React.createFactory TimeClass

module.exports = Time