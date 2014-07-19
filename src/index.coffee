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
#   hubot hammeradmin setexp <user> +n|-n|n - Set a user's current EXP.
#   hubot hammeradmin report <user> - Show a summary of hammersport state. Danger: spammy.
#
# Author:
#   smashwilson

ChalkCircle = require './chalkcircle'
_ = require 'underscore'

ADMIN_ROLE = 'hammondsport mayor'

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

    for challenger in challengers
      unless challenger.hp() > 0
        msg.reply "#{challenger.displayName()} is dead!"
        return

    m = theCircle.startMatch(challengers)
    m.challengeOffered msg

  robot.respond /hammer accept/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.challengeAccepted msg

  robot.respond /hammer decline/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.challengeDeclined msg

  robot.respond /hammer (\d)/i, (msg) ->
    theCircle.withActiveMatch msg, (m) -> m.chooseMove msg

  isAdmin = (msg) ->
    unless robot.auth.hasRole(msg.message.user, ADMIN_ROLE)
      msg.reply "You can't do that! You're not a *#{ADMIN_ROLE}*."
      return false
    return true

  challengersFrom = (msg) ->
    username = msg.match[1]
    if username? and username isnt 'everyone'
      user = robot.brain.userForName username
      unless user?
        msg.reply "I don't know who #{username} is."
        return

      [theCircle.getChallenger(user)]
    else
      theCircle.allChallengers()

  reportAction = (count, action) ->
    if count is 1
      verbPhrase = "challenger has"
    else
      verbPhrase = "challengers have"
    "#{count} hammersport #{verbPhrase} been #{action}."

  robot.respond /hammeradmin respawn @?(\w+)/i, (msg) ->
    return unless isAdmin(msg)
    challengers = challengersFrom(msg)

    c.respawn() for c in challengers
    msg.reply reportAction challengers.length, 'respawned'

  robot.respond /hammeradmin kill @?(\w+)/i, (msg) ->
    return unless isAdmin(msg)
    challengers = challengersFrom(msg)

    c.kill() for c in challengers
    msg.reply reportAction challengers.length, 'killed'

  robot.respond /hammeradmin setexp @?(\w+) ([+-]?\d+)/i, (msg) ->

  robot.respond /hammeradmin report(?: @?(\w+))?/i, (msg) ->
    return unless isAdmin(msg)
    challengers = challengersFrom(msg)

    sorted = _.sortBy challengers, (c) -> c.displayName()

    lines = []
    for c in sorted
      line = "*#{c.displayName()}*: #{c.hp()}/#{c.maxHP()} HP #{c.exp()} EXP"
      if c.nextRespawn()?
        line += " _will respawn #{c.nextRespawn().fromNow()}_"
      lines.push line

    msg.send lines.join("\n")

  if process.env.HUBOT_DEBUG?
    robot.respond /dhammer accept/i, (msg) ->
      user = robot.brain.userForName 'someone'
      msg.message.user = user
      theCircle.withActiveMatch msg, (m) -> m.challengeAccepted msg

    robot.respond /dhammer (\d+)/i, (msg) ->
      user = robot.brain.userForName 'someone'
      msg.message.user = user
      theCircle.withActiveMatch msg, (m) -> m.chooseMove msg
