# An action that cay be taken by a Challenger during a hammersport match.
#
class Move

  # Internal: Create a new Move. External callers should use a MoveSetBuilder to construct
  # Moves instead.
  #
  constructor: (@_name, @_callback, @_userIDs, @_minEXP) ->

  # Public: Access the Move's name.
  #
  name: -> @_name

  # Public: Return true if this Move is available to a specific Challenger.
  #
  isAvailableTo: (challenger) ->
    if @_userIDs?
      return false unless challenger.id() in @_userIDs
    return false if challenger.exp() < @_minEXP
    true

  # Internal: Invoked during a Match to execute it. See MoveSetBuilder#execute for guidance on
  # the contents of the context object.
  #
  perform: (context) -> @_callback(context)

module.exports = Move
