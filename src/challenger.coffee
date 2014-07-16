Move = require './move'

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

  moveChoices: (chalkCircle) -> [
    new Move('One')
    new Move('Two')
    new Move('Three')
  ]

module.exports = Challenger
