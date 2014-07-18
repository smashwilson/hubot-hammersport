Move = require './move'
_ = require 'underscore'

# A participant in the hammersportening.
#
class Challenger

  constructor: (@user, @storage) ->
    @storage.hp ?= 50
    @storage.maxHP ?= 50
    @storage.exp ?= 0

  id: -> @user.id

  hp: -> @storage.hp

  maxHP: -> @storage.maxHP

  exp: -> @storage.exp

  # Public: amount of HP recovered per second.
  #
  healingRate: -> 2

  damage: (amount) -> @storage.hp -= amount

  heal: (amount) -> @storage.hp += amount

  levelUp: (amount) -> @storage.exp += amount

  # Public: Revive this Challenger with full HP.
  #
  respawn: -> @storage.hp = @maxHP()

  # Public: Begin the healing process.
  #
  healOverTime: ->
    return if @hp() >= @maxHP()
    fn = =>
      @healInt = null
      @storage.hp = Math.min(@maxHP(), @hp() + @healingRate())
      @healInt = setTimeout(fn, 1000) if @hp() < @maxHP()
    @healInt = setTimeout fn, 1000

  # Public: Halt the healing process begun with `healOverTime`. Important so you don't heal during
  # a Match!
  #
  stopHealing: -> clearTimeout(@healInt) if @healInt?

  displayName: -> "@#{@user.name}"

  moveChoices: (chalkCircle) ->
    c = this
    available = _.filter chalkCircle.moves, (m) -> m.isAvailableTo(c)
    _.sample available, 3

module.exports = Challenger
