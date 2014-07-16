Move = require './move'
_ = require 'underscore'

# A participant in the hammersportening.
#
class Challenger

  constructor: (@user, @storage) ->
    @storage.hp ?= 50
    @storage.exp ?= 0

  id: -> @user.id

  hp: -> @storage.hp

  exp: -> @storage.exp

  damage: (amount) -> @storage.hp -= amount

  heal: (amount) -> @storage.hp += amount

  levelUp: (amount) -> @storage.exp += amount

  displayName: -> "@#{@user.name}"

  moveChoices: (chalkCircle) -> _.filter chalkCircle.moves, (m) -> m.isAvailableTo(@)

module.exports = Challenger
