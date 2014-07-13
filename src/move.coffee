# An action that cay be taken by a Challenger during a hammersport match.
#
class Move

  constructor: (@name) ->

  name: -> @name

  perform: (context) ->
    context.output "#{context.attacker.displayName()} uses #{@name}. It's super effective!"

module.exports = Move
