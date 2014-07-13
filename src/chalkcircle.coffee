Match = require './match'
Challenger = require './challenger'

# Track global state for the hammersport game: the challenger index, matches in progress, and the
# attack index. Manages persistence to and from the brain.
#
class ChalkCircle

  constructor: (robot) ->
    @name = robot.name
    @match = null

  botName: -> @name

  challengeTimeout: -> 300000 # 5 minutes

  roundTimeout: -> 300000 # 5 minutes

  # Public: Initiate a new match.
  #
  # challengerNames - Sanitized names of each prospective Challenger. Initiator is first.
  #
  startMatch: (challengerNames...) ->

  endMatch: (match) -> @match = null if @match is match

  # Public: Invoke a callback function with the active Match, if one exists. Report an error
  # otherwise.
  #
  withActiveMatch: (msg, callback) ->
    if @match?
      callback(@match)
    else
      msg.reply "You can't do that when there's no match underway!"

module.exports = ChalkCircle
