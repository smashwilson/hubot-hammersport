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

  endMatch: (match) -> @match = null if @match is match

module.exports = ChalkCircle
