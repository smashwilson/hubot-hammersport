# Internal: The current state of an active hammersport match.
#
class State

  constructor: (@match) ->

  challengeAccepted: (msg) -> @_badState "accept a challenge", msg

  challengeDeclined: (msg) -> @_badState "decline a challenge", msg

  challengeTimeout: (msg) ->

  chooseMove: (msg) -> @_badState "choose a move", msg

  # Internal: A command has been attempted in the wrong state. Report an error and do nothing.
  #
  _badState: (actionName, msg) -> @match.wth "You can't #{actionName} now!"

# Internal: A challenge has been offered. If *accepted*, the round will begin and the match will
# advance to AwaitingMoveState. If *declined* or *timedout*, the match is over.
#
class ChallengeOfferedState extends State

  constructor: (match) ->
    super match
    @accepted =
      match.challengers.first.id: true

  challengeAccepted: (msg) ->
    uid = msg.message.user.id

    if @accepted[uid]
      @match.wtf msg, "You've already accepted!"
      return

    @accepted[uid] = true

    if Object.keys(@accepted).length < @match.challengers.length
      @match.intermediateAccept msg
    else
      @match.itBegins msg
      @match.startRound msg

  challengeDeclined: (msg) ->
    @accepted[msg.message.user.id] = false

    # FIXME need a response to call here.

# Internal: A round is active and the Challengers have been issued lists of potential moves. One
# or both Challengers have yet to select a move. When a *move* is chosen, if not all Challengers
# have chosen, remain in AwaitingMoveState; when all moves are chosen, enact each chosen Move,
# report the round results, and see if there's a winner. If there is, end the Match and report
# the match results. If there isn't, clear the choices and keep going.
#
class AwaitingMoveState extends State

  constructor: (match, @moveMap) ->
    super match
    @choices = {}

  chooseMove: (msg) ->

# Public: An active match of hammersport. Implemented as a state machine that maps *commands* to
# *actions* that mutate the Match or Challengers.
#
class Match

  # Public: Initial a new match from a challenge.
  #
  # chalkCircle - A reference to global state.
  # challengers - An Array of the two Challengers who will participate.
  #
  constructor: (@chalkCircle, @challengers) ->
    @round = 1
    @state = new ChallengeOfferedState(this)
    @challengerIds = (c.id() for c in @challengers)

  # ACTIONS
  # These methods are invoked by user interactions and dispatched to the appropriate State.

  # Public: Action - the first Challenger has issued the challenge.
  #
  challengeOffered: (msg) -> @throwDownTheGlove(msg)

  # Public: Action - the second Challenger has accepted an issued challenge.
  #
  challengeAccepted: (msg) ->
    @_validateUser(msg) and @state.challengeAccepted msg

  # Public: Action - the second Challenger has declined an issued challenge.
  #
  challengeDeclined: (msg) ->
    @_validateUser(msg) and @state.challengeDeclined msg

  # Public: Action - the second Challenger has failed to respond before the challenge timed out.
  #
  challengeTimeout: (msg) -> @state.challengeTimeout msg

  # Public: Action - a Challenger has chosen a Move from the offered list.
  #
  chooseMove: (msg) ->
    @_validateUser(msg) and @state.chooseMove msg

  # RESPONSES
  # State subclasses invoke these methods to report progress and advance.

  # Internal: Issue the challenge! Tell the other Challenger how to accept or decline and wait
  # for a response.
  #
  throwDownTheGlove: (msg) ->
    [first, rest...] =  @challengers
    challenge = (c.displayName() for c in rest).join(", ")
    challenge += (if rest.length > 1 then 'have' else 'has')
    challenge += " been challenged by #{first.displayName()}!
      `#{@chalkcircle.botName()} hammersport accept` to accept the challenge.
      `#{@chalkcircle.botName()} hammersport decline` to wuss out."
    msg.send challenge

  # Internal: Some Challengers have accepted, but others have not. Print a message to accept.
  #
  intermediateAccept: (msg) -> msg.reply "You're in. Waiting for the rest..."

  # Internal: All Challengers have accepted. Print a message before the first round starts.
  #
  itBegins: (msg) -> msg.send 'IT BEGINS!'

  # Internal: Choose the next batch of attacks from the attack registry and report them to each
  # challenger.
  #
  startRound: (msg) ->
    message = (c.displayName() for c in @challengers).join(' vs. ')
    message += ", round #{@round}. Choose your moves.\n\n"

    moveMap = {}
    for c in @challengers
      message += "#{c.displayName()}:\n"

      choices = c.moveChoices(@chalkCircle)
      for i in [0...choices.length]
        message += "  [#{i}] #{choices[i].name()}\n"

      moveMap[c.id()] = choices

    @state = new AwaitingMoveState(this, moveMap)
    @msg.send message

  # Internal: Accept an attack for a Challenger while there are others pending.
  #
  intermediateAttack: (msg) ->

  # Internal: Enact all chosen attacks and report their results.
  #
  endRound: (msg) ->

  # Internal: Someone tried a command in the wrong State. Chastise them appropriately.
  #
  wth: (msg, text) -> msg.reply text

  # UTILITIES
  # For use by multiple responses.

  # Internal: Ensure that the user who's running a command is actually participating.
  #
  _validateUser: (msg) ->
    if msg.message.user.id in @match.challengerIds
      true
    else
      @match.wth msg, "You're just spectating right now."
      false

module.exports = Match
