React = require 'react'

{a, div, input, p} = React.DOM

PropertiesClass = React.createClass
  render: ->
    div {className: 'row'},
      div {className: 'column'},
        p {className: 'point'},
          'Properties'

Properties = React.createFactory PropertiesClass

module.exports = Properties