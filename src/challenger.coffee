# A participant in the hammersportening.
#
class Challenger

  constructor: (@user) ->

  id: -> @user.id

  displayName: -> "@#{@user.name}"

  moveChoices: (chalkCircle) -> []

module.exports = Challenger
