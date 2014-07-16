Move = require './move'
_ = require 'underscore'

# A DSL used to create individual Moves within a MoveSetBuilder.
#
class MoveBuilder

  constructor: (@_name) ->
    @_performCallback = null
    @_users = null
    @_minEXP = 0

  # Public: Provide your own, custom logic to create an attack that can affect anything in
  # the global game state.
  #
  # cb - A callback that will be executed bound to the Move instance that should perform the
  #      the move. It will be invoked with a context object containing the following keys:
  #       chalkCircle - A reference to the global state.
  #       match - The current Match.
  #       attacker - The initiator of the move.
  #       target - The other combatant.
  #       output - A callback that should be invoked to report the move's results.
  #
  execute: (cb) -> @_performCallback = cb

  # Public: Specify an array of user IDs who should have access to this Move.
  #
  users: (ids...) -> @_users = ids

  # Public: Specify the EXP level at which this Move becomes available.
  #
  unlocksAt: (exp) -> @_minEXP = exp

  # Public: Create a move that deals damage chosen at random between a minimum and maximum.
  #
  # minDamage - The minimum damage, inclusive.
  # maxDamage = The maximum damage, inclusive.
  #
  uniform: (minDamage, maxDamage) ->
    @_performCallback = ({attacker, target, output}) ->
      amount = _.random minDamage, maxDamage
      target.damage amount
      output [
        "#{attacker.displayName()} uses #{@name()} for #{amount} damage."
        "#{target.displayName()} is left at #{target.hp()} HP."
      ].join(' ')

  # Public: Create a move that performs an exact amount of damage each time.
  #
  exact: (amount) ->
    @_performCallback = ({attacker, target, output}) ->
      target.damage amount
      output [
        "#{attacker.displayName()} uses #{@name()} for #{amount} damage."
        "#{target.displayName()} is left at #{target.hp()} HP."
      ].join(' ')

  _asMove: -> new Move(@_name, @_performCallback, @_users, @_minEXP)

# A DSL used to create sets of Moves in the file specified by "HUBOT_HAMMERSPORT_ATTACKS".
#
class MoveSetBuilder

  constructor: ->
    @moves = []

  move: (name, callback) ->
    mb = new MoveBuilder(name)
    callback(mb)
    @moves.push mb._asMove()

module.exports = MoveSetBuilder
