React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

organizeTimeColumns = (time) ->
  _.zip time.samples, time.rate

expressRowIndex = (rowIndex, barLength, subLength, subModulus) =>
  rowIndexExpression = (rowIndex // barLength) + ''
  while rowIndexExpression.length < 5
    rowIndexExpression = '0' + rowIndexExpression
  rowIndexExpression += '.' + (rowIndex % barLength)
  rowIndexExpression

OptionsClass = React.createClass

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'options'

      div {className: 'row'},
        div {className: 'column double'},
          p
            className: 'point'
            @props.title

        div {className: 'column'},
          input
            className: 'submit'
            type: 'submit'
            value: 'Save'

      div {className: 'row'},
        div {className: 'column double'},
          input
            className: 'input double'
            placeholder: '<piece name>'

        div {className: 'column'},
          input
            className: 'submit'
            type: 'submit'
            value: 'Open'

Options = React.createFactory OptionsClass

module.exports = Options