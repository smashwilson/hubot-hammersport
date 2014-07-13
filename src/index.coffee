# Description:
#   Challenge
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_HAMMERSPORT_ROOMS - comma-separated list of rooms to restrict hammersport chatter to.
#   HUBOT_HAMMERSPORT_ATTACKS - path to a file containing available attacks.
#
# Commands:
#   hubot hammersport challenge <user> - Challenge another user to a duel
#   hubot hammersport accept - Accept a challenge.
#   hubot hammersport decline - Decline a challenge.
#   hubot hammer <n> - Choose an attack during a hammersport round.
#
# Author:
#   smashwilson

ChalkCircle = require './chalkcircle'

module.exports = (robot) ->

  robot.respond /hammersport challenge (\S+)/i, (msg) ->

  robot.respond /hammer (\d)/i, (msg) ->
