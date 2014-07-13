Match = require './match'
Challenger = require './challenger'

# Track global state for the hammersport game: the challenger index, matches in progress, and the
# attack index. Manages persistence to and from the brain.
#
class ChalkCircle

  constructor: (robot) ->
    @name = robot.name
    @match = null

    # Initialize storage structures.
    @storage = robot.brain.data.hammersport ?= {}
    @storage.challengers ?= {}

  botName: -> @name

  challengeTimeout: -> 300000 # 5 minutes

  roundTimeout: -> 300000 # 5 minutes

  # Public: Initiate a new match.
  #
  # challengers - The Challengers involved in this match, initiator first.
  #
  startMatch: (challengers...) -> @match = new Match(this, challengers)

  # Public: End an active Match.
  #
  # match - The Match to end.
  #
  endMatch: (match) -> @match = null if @match is match

  # Public: Invoke a callback function with the active Match, if one exists. Report an error
  # otherwise.
  #
  withActiveMatch: (msg, callback) ->
    if @match?
      callback(@match)
    else
      msg.reply "You can't do that when there's no match underway!"

  # Public: Access or create a Challenger corresponding to a Hubot User.
  #
  getChallenger: (user) ->
    @storage.challengers[user.id] ?= {}
    new Challenger(user, @storage)

module.exports = ChalkCircle
