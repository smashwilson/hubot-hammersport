# A participant in the hammersportening.
#
class Challenger

  constructor: (@user) ->
    @hp = 50

  id: -> @user.id

  displayName: -> "@#{@user.name}"

  moveChoices: (chalkCircle) -> [
    new Move('One')
    new Move('Two')
    new Move('Three')
  ]

module.exports = Challenger
