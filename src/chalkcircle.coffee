# Track global state for the hammersport game: the challenger index, matches in progress, and the
# attack index. Manages persistence to and from the brain.
#
class ChalkCircle

  constructor: (robot) ->
    @name = robot.name
    @match = null

  botName: -> @name

module.exports = ChalkCircle
