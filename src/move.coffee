# An action that cay be taken by a Challenger during a hammersport match.
#
class Move

  constructor: (@_name) ->

  name: -> @_name

  perform: (context) ->
    context.target.damage 10
    context.output [
      "#{context.attacker.displayName()} uses #{@_name} for 10 damage."
      "It's super effective!"
      "#{context.target.displayName()} is left at #{context.target.hp()} HP."
    ].join(' ')

module.exports = Move
