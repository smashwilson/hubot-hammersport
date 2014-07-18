# Description:
#   Battle your way to the top in the chalk circle.
#
# Configuration:
#   HUBOT_HAMMERSPORT_ROOMS - comma-separated list of rooms to restrict hammersport chatter to.
#   HUBOT_HAMMERSPORT_MOVES - path to a file containing available moves.
#
# Commands:
#   hubot hammersport <user> - Challenge another user to a duel
#   hubot hammer accept - Accept a challenge.
#   hubot hammer decline - Decline a challenge.
#   hubot hammer <n> - Choose an attack during a hammersport round.
#   hubot hammeradmin respawn <user>|everyone - Respawn a chosen user at full health.
#   hubot hammeradmin kill <user>|everyone - Instakill a chosen user.
#   hubot hammeradmin dumpstate - Show a summary of all hammersport state. Danger: spammy.
#
# Author:
#   smashwilson

ChalkCircle = require './chalkcircle'

ADMIN_ROLE = 'Hammondsport mayor'

module.exports = (robot) ->

  createTestUser = ->
    someone = robot.brain.userForId '2',
      name: 'someone'
      room: 'thechalkcircle'
    theCircle.getChallenger(someone)

  theCircle = new ChalkCircle(robot)

  robot.respond /hammersport (\S+)/i, (msg) ->
    createTestUser() if process.env.HUBOT_DEBUG?

    challengers = []
    for username in [msg.message.user.name, msg.match[1]]
      username = username.replace /^@/, ''
      user = robot.brain.userForName username
      if user?
        challengers.push theCircle.getChallenger(user)
      else
        msg.reply "I don't know anyone named #{username}!
          Notice that they have to speak first, for me to notice them."
        return

    m = theCircle.startMatch(challengers)
    m.challengeOffered msg

  robot.respond /hammer accept/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.challengeAccepted msg

  robot.respond /hammer decline/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.challengeDeclined msg

  robot.respond /hammer (\d)/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.chooseMove msg

  if process.env.HUBOT_DEBUG?
    robot.respond /dhammer accept/i, (msg) ->
      user = robot.brain.userForName 'someone'
      msg.message.user = user
      theCircle.withActiveMatch msg, (m) -> m.challengeAccepted msg

    robot.respond /dhammer (\d+)/i, (msg) ->
      user = robot.brain.userForName 'someone'
      msg.message.user = user
      theCircle.withActiveMatch msg, (m) -> m.chooseMove msg
