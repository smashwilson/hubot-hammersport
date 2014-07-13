# Description:
#   Battle your way to the top in the chalk circle.
#
# Configuration:
#   HUBOT_HAMMERSPORT_ROOMS - comma-separated list of rooms to restrict hammersport chatter to.
#   HUBOT_HAMMERSPORT_ATTACKS - path to a file containing available attacks.
#
# Commands:
#   hubot hammersport <user> - Challenge another user to a duel
#   hubot hammer accept - Accept a challenge.
#   hubot hammer decline - Decline a challenge.
#   hubot hammer <n> - Choose an attack during a hammersport round.
#
# Author:
#   smashwilson

ChalkCircle = require './chalkcircle'

module.exports = (robot) ->

  theCircle = new ChalkCircle(robot)

  robot.respond /hammersport (\S+)/i, (msg) ->

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

  robot.respond /hammersport accept/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.challengeAccepted msg

  robot.respond /hammersport decline/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.challengeDeclined msg

  robot.respond /hammer (\d)/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.chooseMove msg
