;PirateIRC roulette minigame by mruno
;
alias EPirate.Roulette.Installed return $true
alias rr.logo return 

;------------------------------------------------------ LOCAL ALIASES 
alias -l percent $iif(($isid) && ($1) && ($2),return $calc($1 / $2 * 100) $+ $iif($prop == suf,%))
alias -l debug {
  if ($1) {
    if (!$window(@Pirates)) window -n1e3 @Pirates
    aline -p @Pirates $time $+ : $1-
    ECHO -st $1-
    write $epirate.dir($+(Pirates.Log.,$EPirate.Network,.,$time(mmm),.,$time(yyyy),.log)) $date $time - $strip($1-)
  }
}
alias -l short.dur {
  var %a $duration($1)
  return $remove(%a,$wildtok(%a,*sec*,1,32),$wildtok(%a,*min*,1,32))
}
alias -l b return  $+ $1-
alias -l u return  $+ $1-
alias -l c return  $+ $1-
alias -l o return  $+ $1-
alias -l iseven return $iif(2 // $1,$true,$false)
alias -l isodd return $iif(!$iseven($1),$true,$false)
alias -l ord.num return $ord($1-)
alias paren return $chr(40) $+ $1- $+ $chr(41)
alias -l backwards {
  ;used during april 1
  set %bk.result $null
  var %i $len($1-)
  while (%i) {
    if ($chr(32) == $mid($1-,%i,1)) { %bk.result = %bk.result $+ / }
    %bk.result = %bk.result $+ $mid($1-,%i,1)
    dec %i
  }
  return $replace(%bk.result,/,$chr(32))
}
alias -l rainbow {
  var %string $1-
  var %count 0
  var %color 1
  while (%count < $len($1-)) {
    var %color2 $gettok(04.07.08.09.03.12.06,%color,46)
    var %output %output $+ $iif($left(%string,1) != $chr(32), $+ $iif($left(%string,1) isnum,%color2,$remove(%color2,0)) $+ $iif(%output,$null,$chr(44) $+ 01) $+ $left(%string,1),$chr(32) $+ $chr(32))
    if ($left(%string,1) != $chr(32)) var %color $iif(%color == 7,1,$calc(%color + 1))
    var %string $right(%string,-1)
    inc %count
  }
  return %output $+ 
}
'----------------------------- end local aliases



on *:TEXT:*:#: {
  if ($1-2 == !pirates pull) || ($1-2 == !pirate pull) || ($1-2 == !p pull) || ($1 == !pull) {
    var %chan $EPirate.Chan
    if ($chan != %chan) || ($chr(37) isin $1-) || ($chr(36) isin $1-) return

    if ($EPirate.Jail($nick)) { epirate.notice $nick Thar be no fun allowed in the brig! | return }

    if ($timer(EPirate.Flood).secs) { EPirate.Flood.Check $nick | return }
    else .timerEPirate.Flood -m 1 1000 noop
    EPirate.Flood.Check $nick

    if (!%rr.status) return
    if ($nick == %rr.nick.pull) russian.roulette.pull $chan %rr.nick.pull %rr.nick.wait
    elseif ($nick == %rr.nick.wait) .timer 1 1 epirate.notice $nick Wait fer %rr.nick.pull to pull the trigger.
    else .timer 1 1 .notice $nick Wait fer %rr.nick.wait and %rr.nick.pull to finish their game.
  }
  if (!pr == $1) || (!rr == $1) russian.roulette.start $nick $2 $3
}
alias EPirate.Bot.Game.roulette.Start {
  ;/EPirate.Bot.Game.roulette.Start <player> - bot challenges the player specified to a game o' roulette
  var %player $1
  if ($timer(Russian.rr.timeout)) || (%rr.nick.wait) || ($hget(epirate.daily,Games.Played. $+ %player) >= $EPirate.Max.Games.Per.Day) return
  if ($hget(EPirate.Expenses.Today,%player $+ .games) > $epirate.player.percentage(%player,$EPirate.Max.Percentage.Daily.Games)) return
  if ($epirate.bot) && ($epirate.isuser(%player)) {
    var %wager $epirate.player.percentage(%player,$calc($rand(5,50) / 100))
    if (%wager >= 1) && (%wager isnum) EPirate.Game.roulette.Start $epirate.bot %player %wager
  }
}
alias EPirate.Game.roulette.Start russian.roulette.start $1-
alias russian.roulette.start {
  ;/russian.roulette.start <player1> <player2> <wager> - starts a game of PIRATE roulette
  var %file $epirate.save.dir(playerdata.dat), %player1 $1, %player2 $2, %chan %EPirate.Chan

  if (!$2) { epirate.notice %player1 $rr.logo  %player1 choose another pirate to join ye!  !PR <pirate> <wager> | halt }
  if ($2 == $me) { epirate.notice %player1 $rr.logo Thanks for the invite %player1 $+ $chr(44) but I am not in the mood to whip ye butt. | halt }
  if ($2 == %player1) { epirate.notice %player1 $rr.logo  %player1 don't play wit' yourself, play wit' someone else! | halt }
  if ($2 !ison %chan) { epirate.notice %player1 $rr.logo  %player1 choose another pirate that is on %chan to play with. !Pirates Roulette <pirate> <wager> | return }
  if (!$epirate.isuser($2)) { epirate.notice %player1 $2 is not a crewmember. | return }

  var %wager 0
  ;if ($3 == max) set %wager $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Wager)
  if ($3 == max) set %wager $epirate.determine.max.wager(%player1,%player2)
  else set %wager $EPirate.Convert.Wager($3)

  if (%wager !isnum) { epirate.notice %player1 How much do ye want to wager? !Pirates Roulette <pirate> <wager> | return }
  if ($EPirate.IsClone(%player1)) { epirate.notice %player1 Ye cannot do this. | return }
  if ($EPirate.ChannelBot($2)) || ($EPirate.IsClone($2)) { epirate.notice %player1 $2 cannot do this. | return }
  else {
    var %player2 $2
    if ($hget(EPirate.Games,played. $+ %player1) >= $Epirate.Games.Before.Bribe.Needed) {
      epirate.notice %player1 Th' Cap'n will catch ye if ye keep playin' those games 'n nah scrubbin' th' poop deck. Play later, ye blaggard!
      epirate.notice %player1 I may be able t' help ye play some more games. Type !Pirates Store Bribe
      halt
    }
    if ($hget(EPirate.Games,played. $+ %player2) >= $Epirate.Games.Before.Bribe.Needed) {
      epirate.notice %player1 %player2 be playin' too many games. Tell 'em to buy a bribe. !Pirates Store Bribe
      halt
    }
    if ($EPirate.Jail(%player2)) { epirate.notice %player1 %player2 cannot play games from the brig! | return }
    var %player1.nickname $hget(EPirate.Players.Nicknames,%player1)
    var %player2.nickname $hget(EPirate.Players.Nicknames,%player2)
    var %cmd $iif($EPirate.Reduce.SPAM,epirate.notice %player1,epirate.public.msg)
    if (%player1 != $epirate.bot) {
      if (!%player1.nickname) {
        %cmd %player1 ain't a hand o' th' crew.
        epirate.notice %player1 Learn how to join by typing: !pirates help 
        return
      }
      if (!$hget(EPirate.Players.Current,%player1)) { epirate.notice %player1 Ye not be aboard! Identify wit' Nickserv (/ns identify <password>) and then !Pirates Identify | return }
    }
    if (!$hget(EPirate.Players.Current,%player2)) { epirate.notice %player2 not be aboard! | return }
    if (!%player2.nickname) {
      %cmd %player2 ain't a hand o' th' crew.
      epirate.notice %player2 Learn how to join by typing: !pirates help 
      return
    }
    if (!$hget(EPirate.Players.ALL,%player2)) { %cmd %player2 ain't a hand o' th' crew. | return }
    if (%player2 !ison %chan) { %cmd %player2 ain't onboard. | return }
    if (%player1 != $epirate.bot) {
      ;if ($hget(epirate.daily,Games.Played. $+ %player1) >= $EPirate.Max.Games.Per.Day) { epirate.notice %player1 Ye played enough games today! New day starts in $EPirate.Time.Until.New.Day | return }
      if ($hget(EPirate.Expenses.Today,%player1 $+ .games) > $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice %player1 Ye 'ave earned too much doubloons from games today! New day starts in $EPirate.Time.Until.New.Day | return }
    }
    ;if ($hget(epirate.daily,Games.Played. $+ %player2) >= $EPirate.Max.Games.Per.Day) { epirate.notice %player2 %player2 Ye played enough games today! New day starts in $EPirate.Time.Until.New.Day | return }
    if ($hget(EPirate.Expenses.Today,%player2 $+ .games) > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice %player1 %player2 earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }

    var %player1.doubloons $hget(EPirate.Players.ALL,%player1)
    var %player2.doubloons $hget(EPirate.Players.ALL,%player2)
    var %player1.level $readini(%file,%player1,level)
    var %player2.level $readini(%file,%player2,level)
    var %player1.nickname $epirate.nick(%player1)
    var %player2.nickname $epirate.nick(%player2)

    if (%player1 == %player2) { epirate.notice %player1 Ye can nah duel yourself, ye Blaggard! | return }
    if (%player1 != $epirate.bot) {
      if (!%player1.nickname) { EPirate.Public.MSG %player1 ain't a hand o' th' crew. !Pirates Enlist | return }
      if (%wager > $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Wager)) {
        epirate.notice %player1 That wager be too high! Try $EPirate.Round($v2) doubloons or less.
        return
      }
    }
    if (!%player2.nickname) { EPirate.Public.MSG %player2 ain't a hand o' th' crew. !Pirates Enlist | return }
    if (%player1.level < 2) || (%player2.level < 2) { epirate.notice %player1 Both pirates need be at least level $v2 $+ . | return }
    if (%wager !isnum) { epirate.notice %player1 Ye have t' choose a number. | return }
    if (%wager < 1) || (- isin %wager) || (. isin %wager) || ($len(%wager) > 25) { epirate.notice %player1 I don't like that wager. | return }
    var %percent $calc(%$EPirate.Max.Percentage.Wager / 100)
    var %doubloon $hget(EPirate.Players.ALL,%player1)
    var %sum $EPirate.Round($calc(%doubloon * %percent))
    if (%wager > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Wager)) {
      epirate.notice %player1 That wager be too high fer %player2 $+ ! Try $EPirate.Round($v2) doubloons or less.
      epirate.notice %player2 That wager be too high fer %player2 $+ ! Try $EPirate.Round($v2) doubloons or less.
      return
    }

    if ($timer(russian.r.trigger)) return
    else .timerrussian.r.trigger 1 120 noop

    if ($timer(rr.nick. $+ %player1)) && (%player1 != mruno) return
    else .timerrr.nick. $+ %player1 1 120 noop

    .timer 1 45 EPirate.Task.Check %player1 play.game
    if (%wager < $epirate.player.percentage(%player1,0.1)) EPirate.Achievement %player1 Game.Low.Wager

    set %EPiRATE.RR.Wager %wager
    set %EPirate.RR.Player1 %player1
    set %EPirate.RR.Player2 %player2

    if (!%rr.status) {
      set %rr.nick.pull %player1
      set %rr.nick.wait $2
      set %rr.chan %chan
      set %rr.status 1
      if (%player1 != $epirate.bot) {
        if (!$timer(EPirate.Party)) hinc EPirate.Games played. $+ %player1
        if (!$timer(EPirate.Party)) hinc EPirate.Games played. $+ %player2
        epirate.notice %player1 Reminder: Only 1 duel per 2 minutes.
      }

      EPirate.Achievement %player1 game
      hinc EPirate.Stats ship.games
      EPirate.Achievement %player2 game

      var %time 90
      if (%player1 == $epirate.bot) inc %time 200
      .timerRussian.rr.timeout 1 %time russian.rr.timeout
      var %r $rand(1,3)
      if (%r == 1) russian.rr.msg %player1.nickname %player1 pulls out a musketoon, and points at %player2.nickname $2 $+ ...
      elseif (%r == 2) russian.rr.msg %player1.nickname %player1 starts a game o' !Pirate Roulette wit' %player2.nickname $2 $+ !
      elseif (%r == 3) russian.rr.msg %player1.nickname %player1 pulls out a musket, places one round in it, and spins the cylinder... Pirate Roulette!
      .timer 1 2 epirate.notice $2 %player1 has challenged ye to a game o' Pirate Roulette for $epirate.round(%wager) doubloons!
      if (%player1 != $epirate.bot) {
        .timer 1 3 epirate.notice %player2 $rr.logo The wager be $epirate.round(%wager) doubloons! Type !pull to start!
      }
      else .timer 1 8 russian.roulette.pull %chan %rr.nick.pull %rr.nick.wait
    }
  } 
}
alias russian.roulette.pull {
  ;chan pull.nick wait.nick
  var %chan $EPirate.Chan
  if ($3) {
    var %r 
    if (%rr.status == 6) set %r $rand(18,21)
    else set %r $rand(1,19)
    inc %rr.status

    ;inc %EPiRATE.RR.Wager $calc(%EPiRATE.RR.Wager * 0.001)
    ;set %EPiRATE.RR.Wager $round(%EPiRATE.RR.Wager,0)

    inc %rr.nick.pulls
    .timerrussian.pull.timeout 1 60 russian.pull.timeout

    if (%r == 1) russian.rr.msg CLICK! $2 got lucky!
    elseif (%r == 2) russian.rr.msg The gun jammed, $2 got lucky. $3 $+ 's turn...
    elseif (%r == 3) russian.rr.msg CLICK CLICK. Good job $2 $+ .
    elseif (%r == 4) russian.rr.msg CLICK CLICK. Shhhhheewwwwww!
    elseif (%r == 5) russian.rr.msg CLICK. ClICK. Whoa. You survived. GJ $2 $+ . $3 $+ 's turn...
    elseif (%r == 6) russian.rr.msg CLICK! $3 $+ 's turn...
    elseif (%r == 7) { russian.rr.msg $2 spins the cylinder $+ ... CLICK! | set %rr.status $rand(1,6) }
    elseif (%r == 8) russian.rr.msg $2 picks up the gun and places it against his head... Click!
    elseif (%r == 9) russian.rr.msg $2 shakily pulls the trigger $+ ... CLICK!
    elseif (%r == 10) russian.rr.msg $2 stares at $3 while pulling the trigger $+ ... Click!
    elseif (%r == 11) russian.rr.msg $2 confidently pulls the trigger $+ ... Click.
    elseif (%r == 12) russian.rr.msg CLICK! $3 $+ 's turn...
    elseif (%r == 13) russian.rr.msg CLICK! $3 $+ 's turn...
    elseif (%r == 14) russian.rr.msg CLICK! $3 $+ 's turn...
    elseif (%r == 15) russian.rr.msg $2 picks up the gun and places it against his head... Click!
    elseif (%r == 16) russian.rr.msg $2 stares at $3 while pulling the trigger $+ ... Click!

    elseif (%r == 17) {
      var %nick $hget(EPirate.Players.Current,$rand(1,$hget(EPirate.Players.Current,0).item)).item
      while (%nick != %EPirate.RR.Player1) && (%nick == %EPirate.RR.Player2) set %nick $hget(EPirate.Players.Current,$rand(1,$hget(EPirate.Players.Current,0).item)).item
      russian.rr.msg 5The gun misfires, blowing %nick $+ 's head off.. oh well, until next game.
      russian.rr.end %nick
      halt
    }

    elseif (%r == 18) { russian.rr.msg 4BANG! $3 watches $2 $+ 's brain splatter all over the wall. $3 wins $epirate.round(%EPiRATE.RR.Wager) doubloons! | russian.rr.end | halt }
    elseif (%r == 19) { russian.rr.msg 4*KABOOM* $2 be dead... $3 survives for another game n' wins $epirate.round(%EPiRATE.RR.Wager) doubloons! | russian.rr.end | halt }
    elseif (%r == 20) { russian.rr.msg 4*BOOM* $2 dies! $3 wins $epirate.round(%EPiRATE.RR.Wager) doubloons! | russian.rr.end | halt }
    elseif (%r == 21) { russian.rr.msg 4*KABOOM* $2 be dead... $3 survives for another game n' wins $epirate.round(%EPiRATE.RR.Wager) doubloons! | russian.rr.end | halt }

    .timerRussian.rr.timeout 1 120 russian.rr.timeout
    set %rr.nick.pull $3
    set %rr.nick.wait $2
    if (%rr.nick.pull == $epirate.bot) {
      .timer 1 6 describe %chan pulls the trigger...
      .timer 1 8 russian.roulette.pull %chan %rr.nick.pull %rr.nick.wait
    }
    else .timerRR.PULL 1 1 epirate.notice %rr.nick.pull It is your turn. Type !pull
  }
}
alias russian.rr.msg if (%rr.chan) .timer 1 1 epirate.public.msg $1-
alias russian.pull.timeout {
  ;if player has pulled earlier but quit because scared to lose this times them out
  if (%rr.nick.pulls < 2) return
  .timerrussian.pull.timeout off
  var %player1 %rr.nick.wait, %player2 %rr.nick.pull, %msg, %r $rand(1,3)
  if (%r == 1) set %msg %player1 gets tired o' waitin' on %player2 n' grabs the gun n' shoots %player2 in the head! %player1 grabs $epirate.round(%EPiRATE.RR.Wager) doubloons!
  elseif (%r == 2) set %msg %player1 seizes the moment n' jabs %player2 wit a sword n' steals $epirate.round(%EPiRATE.RR.Wager) doubloons!
  else set %msg %player2 falls asleep n' %player1 shoots 'em n' takes the $epirate.round(%EPiRATE.RR.Wager) doubloons!
  epirate.public.msg %msg 
  russian.rr.end
}
alias russian.rr.end {
  ;/russian.rr.end <if nick> then bystander died> - ends the game. no msgs
  .timerrussian.pull.timeout off
  if ($1) {
    Russian.rr.stats.write lost $1
    russian.rr.msg $1 has died $Russian.rr.stats.read(lost,$1) times.
  }
  else {
    Russian.rr.stats.write lost %rr.nick.pull
    Russian.rr.stats.write won %rr.nick.wait

    var %player1 %rr.nick.wait
    var %player2 %rr.nick.pull
    var %tax
    if (%rr.nick.wait != $epirate.bot) {
      if (%EPiRATE.RR.Wager > $epirate.player.percentage(%rr.nick.wait,$EPirate.Max.Percentage.Bonus)) {
        inc %tax
        set %wager $v2
        .timer 1 5 epirate.notice %rr.nick.wait Ye payout be reduced due to taxes!
      }
      epirate.pay %rr.nick.wait %EPiRATE.RR.Wager games
    }
    if (%rr.nick.pull != $epirate.bot) {
      if (%EPiRATE.RR.Wager > $epirate.player.percentage(%rr.nick.pull,$EPirate.Max.Percentage.Bonus)) {
        inc %tax
        set %wager $v2
        .timer 1 5 epirate.notice %rr.nick.pull Ye payout be reduced due to taxes!
      }
      epirate.pay %rr.nick.pull - $+ %EPiRATE.RR.Wager games
    }

    if ($hget(EPirate.Players.Skills,%player1 $+ .learning) == Luck) .timerEPirate.Skills.Check.Luck. $+ %player1 1 30 EPirate.Skills.Check %player1 Luck
    if ($hget(EPirate.Players.Skills,%player2 $+ .learning) == Luck) .timerEPirate.Skills.Check.Luck. $+ %player2 1 30 EPirate.Skills.Check %player2 Luck

    russian.rr.msg %rr.nick.pull has died $Russian.rr.stats.read(lost,%rr.nick.pull) times and %rr.nick.wait has survived $Russian.rr.stats.read(won,%rr.nick.wait) games.
  }
  .timerRussian.* off
  unset %rr.*
  unset %EPiRATE.RR.*
}
alias Russian.rr.stats.write {
  var %cat $1
  var %nick $2
  var %file $epirate.save.dir(Russian.rr.Stats.ini)
  var %past $readini(%file,$1,$2)
  writeini -n %file $1 $2 $iif(!%past,1,$calc(%past + 1))
}
alias Russian.rr.stats.read {
  var %cat $1
  var %nick $2
  var %file $epirate.save.dir(Russian.rr.Stats.ini)
  var %result $readini(%file,%cat,%nick)
  return $iif(%result,%result,0)
}
alias russian.rr.timeout {
  epirate.notice %rr.nick.pull The roulette game timed out. 
  epirate.notice %rr.nick.wait The roulette game timed out. 
  .timer 1 2 unset %rr.*
  .timer 1 2 unset %EPirate.RR.*
}
