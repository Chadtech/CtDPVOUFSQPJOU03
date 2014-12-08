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

  getInitialState: ->
    openFileName: ''

  save: ->
    @props.save()

  open: ->
    @props.open @state.openFileName

  openFileNameChangeHandle: (event) ->
    @state.openFileName = event.target.value
    @setState openFileName: @state.openFileName

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
            onClick:   @save
            type:      'submit'
            value:     'save'

      div {className: 'row'},
        div {className: 'column double'},
          input
            className:   'input double'
            value:       @state.openFileName
            onChange:    @openFileNameChangeHandle
            placeholder: '<piece name>'

        div {className: 'column'},
          input
            className: 'submit'
            type:      'submit'
            onClick:   @open
            value:     'open'

Options = React.createFactory OptionsClass

module.exports = Options