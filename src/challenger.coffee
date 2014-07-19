Move = require './move'
_ = require 'underscore'
moment = require 'moment'

respawnTimeouts = {}
healTimeouts = {}

# A participant in the hammersportening.
#
class Challenger

  constructor: (@user, @storage) ->
    @storage.hp ?= 50
    @storage.maxHP ?= 50
    @storage.exp ?= 0
    @storage.inCombat = false

    # Reset the respawn timeout if necessary.
    if @storage.nextRespawn? and ! respawnTimeouts[@id()]
      msDelay = moment(@storage.nextRespawn).diff(moment())
      fn = => @respawn()
      respawnTimeouts[@id] = setTimeout fn, msDelay

    # Reset the healing timeout if necessary.
    if @hp() > 0 and @hp() < @maxHP() and ! @storage.inCombat and ! healTimeouts[@id()]
      @healOverTime()

  id: -> @user.id

  hp: -> @storage.hp

  maxHP: -> @storage.maxHP

  exp: -> @storage.exp

  # Public: amount of HP recovered per second.
  #
  healingRate: -> 2

  # Public: time, in milliseconds, that must elapse before automatically respawning.
  #
  reviveTime: -> 5000 # 900000 # 15 minutes

  damage: (amount) -> @storage.hp -= amount

  heal: (amount) -> @storage.hp += amount

  levelUp: (amount) -> @storage.exp += amount

  # Public: Revive this Challenger with full HP.
  #
  respawn: ->
    clearTimeout(respawnTimeouts[@id()]) if respawnTimeouts[@id()]?
    @storage.nextRespawn = null
    @storage.hp = @maxHP()

  # Public: Return the next time that this Challenger will automatically respawn.
  #
  nextRespawn: -> moment(@storage.nextRespawn) if @storage.nextRespawn?

  # Public: Reduce this Challenger to zero HP. Schedule an automatic respawn after the appropriate
  # amount of time has elapsed.
  #
  kill: ->
    @storage.hp = 0
    fn = => @respawn()
    clearTimeout(respawnTimeouts[@id()]) if respawnTimeouts[@id()]?
    @storage.nextRespawn = moment().add('ms', @reviveTime()).valueOf()
    respawnTimeouts[@id()] = setTimeout fn, @reviveTime()

  # Public: Begin the healing process.
  #
  healOverTime: ->
    healTimeouts[@id()] = null
    return if @hp() >= @maxHP()
    fn = =>
      @storage.hp = Math.min(@maxHP(), @hp() + @healingRate())
      @healOverTime()
    healTimeouts[@id()] = setTimeout fn, 1000

  # Public: Halt the healing process begun with `healOverTime`. Important so you don't heal during
  # a Match!
  #
  startCombat: ->
    clearTimeout(healTimeouts[@id()]) if healTimeouts[@id()]?
    @storage.inCombat = true

  # Public: The Match has ended. Resume healing or schedule a respawn.
  #
  stopCombat: ->
    @storage.inCombat = false
    if @hp() > 0
      @healOverTime()
    else
      @kill()

  displayName: -> "@#{@user.name}"

  moveChoices: (chalkCircle) ->
    c = this
    available = _.filter chalkCircle.moves, (m) -> m.isAvailableTo(c)
    _.sample available, 3

module.exports = Challenger
