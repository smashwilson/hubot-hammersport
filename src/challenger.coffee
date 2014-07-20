Move = require './move'
_ = require 'underscore'
moment = require 'moment'

respawnTimeouts = {}
healIntervals = {}

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
      respawnTimeouts[@id()] = setTimeout fn, msDelay

    # Reset the healing timeout if necessary.
    unless healIntervals[@id()]?
      fn = => @healOverTime()
      healIntervals[@id()] = setInterval(fn, 10000)

  id: -> @user.id

  hp: -> @storage.hp

  maxHP: -> @storage.maxHP

  exp: -> @storage.exp

  # Public: amount of HP recovered per second.
  #
  healingRate: -> 2

  # Public: time, in milliseconds, that must elapse before automatically respawning.
  #
  reviveTime: -> 900000 # 15 minutes

  damage: (amount) -> @storage.hp -= amount

  heal: (amount) -> @storage.hp += amount

  levelUp: (amount) -> @storage.exp += amount

  # Public: Simple predicate to determine if this Challenger is alive.
  #
  isAlive: -> @hp() > 0

  # Public: Predicate to determine if this Challenger is in an active Match or not.
  #
  isInCombat: -> @storage.inCombat

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

  # Internal: Invoked every second for each known Challenger. Heal at a fixed rate if applicable.
  #
  healOverTime: ->
    return unless @isAlive()
    return if @isInCombat()
    return if @hp() >= @maxHP()

    @storage.hp = Math.min(@maxHP(), @hp() + @healingRate())

  # Public: Mark this Challenger as being in an active Match.
  #
  startCombat: ->
    @storage.inCombat = true

  # Public: The Match has ended. Resume healing or schedule a respawn.
  #
  stopCombat: ->
    @storage.inCombat = false
    @kill() if @hp() <= 0

  displayName: -> "@#{@user.name}"

  moveChoices: (chalkCircle) ->
    c = this
    available = _.filter chalkCircle.moves, (m) -> m.isAvailableTo(c)
    _.sample available, 3

module.exports = Challenger
