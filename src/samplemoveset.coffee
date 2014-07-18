# This is the moveset that's loaded if you don't specify a custom one via HUBOT_HAMMERSPORT_ATTACKS.
# It's also a guide for showing the options for creating moves!

module.exports = (b) ->

  # Simple attack. Performs damage to the target chosen from a uniform random distribution between
  # the endpoints you provide.
  #
  b.move 'Gentle Tap', (m) -> m.uniform 1, 10

  # Just to get some variety in the default moveset.
  #
  b.move 'Wild Swing', (m) -> m.uniform 10, 20

  # An attack that does a fixed amount of damage.
  #
  b.move 'Precision Bop', (m) -> m.exact 15

  # An attack that's limited to specific users, by ID. Great for in-jokes!
  #
  b.move 'The Personal Touch', (m) ->
    m.users 'U02D23B7J', 'U02D23G6N'
    m.uniform 15, 25

  # An attack that unlocks after a certain amount of EXP is gained.
  #
  b.move 'Higher Education', (m) ->
    m.unlocksAt 10
    m.uniform 20, 30

  # An attack with a fully custom execution callback. This one deals five points of damage to
  # all known Challengers.
  #
  b.move 'Roundhouse Swing', (m) ->
    m.execute ({chalkCircle, attacker, output, target}) ->
      for c in chalkCircle.allChallengers()
        if c isnt attacker
          c.damage 10
      output [
        "#{attacker.displayName()} does 10 damage to EVERYONE."
        "#{target.displayName()} is left at #{target.hp()} HP."
      ].join(' ')
