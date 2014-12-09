Nt = require './Nt/noitech'
gen = Nt.generate
eff = Nt.effect

module.exports = 
  sine: (note) ->

    defaultValues:
      amplitude: 0.5
      length: 22050
      tone: 404

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = gen.sine expression
      output = eff.ramp output
      output = eff.fadeOut output

      output

