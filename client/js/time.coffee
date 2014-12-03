React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

TimeClass = React.createClass

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'time'

Time = React.createFactory TimeClass

module.exports = Time