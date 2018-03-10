;------------------------
;PiratesIRC by mruno
;------------------------
;
;ADMIN CMDS
;
;------------------------------------------------------ LOCAL ALIASES 
alias EPirate.ADMIN $iif($EPirate.ADMIN.Nick,$EPirate.ADMIN.Nick,mruno)
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


on 999:TEXT:!p *:?:{
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  if ($network != $EPirate.network) return
  if ($nick != $EPirate.ADMIN.Nick) return
  if ($2- == restart tv) || ($2- == restart teamviewer) {
    if ($timer(RestartTV)) { epirate.notice $nick Too Soon | return }
    ;.timerRestartTV 1 120 noop
    epirate.notice $nick Restarting TV. Will be back in ~10 seconds.
    run " $+ $scriptdir $+ restarttv.cmd $+ "
  }
}
on 999:TEXT:!p *:#:{
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  var %chan $EPirate.Chan
  if ($chan != %chan) || ($network != $EPirate.network) || ($nick != $EPirate.ADMIN.Nick) return
  var %file $EPirate.save.dir(playerdata.dat), %cmd $iif($EPirate.Reduce.SPAM,epirate.notice %player1,epirate.public.msg)
  if ($2 == admin) {
    var %nickname $epirate.nick($nick)
    if ($3 == level) {
      if ($4) {
        var %player $4
        if (!$epirate.isuser(%player)) && (%player) { EPirate.notice $nick %player ain't a hand o' th' crew. | return }
        hdel EPirate.Daily levelup. $+ %player
        epirate.pay %player $calc($EPirate.Level.Check(%player) + 1) admin.bonus
        EPirate.Level.Check %player
        EPirate.Public.MSG Th' Admin, %nickname $NICK $+ $chr(44) has promoted %player $+ !
      }
      else EPirate.Notice $nick Specify a player.
    } 
    elseif ($3 == status) epirate.notice $nick $ip
    elseif ($3 == captcha) {
      var %player $4
      if (!$epirate.isuser(%player)) { EPirate.notice $nick %player ain't a hand o' th' crew. | return }
      if (%player) { epirate.notice $nick captcha added to %player | EPirate.Captcha.Check %player manual }
      else epirate.notice $nick who do ye want to captcha?
    }
    elseif ($3 == party) epirate.party.start
    elseif ($3 == sail complete) epirate.sail.complete
    elseif ($3 == monster) EPirate.Monster.Encounter admin
    elseif ($3-4 == epic monster) epirate.epic.monster.attack.START admin
    elseif ($3-4 == mass find) EPirate.Mass.Find 1
    elseif ($3 == attack) EPirate.Ship.Attack admin
    elseif ($3 == storm) EPirate.Storm admin
    elseif ($3 == fire) EPirate.Ship.Fire.Event admin
    elseif ($3 == topic) {
      if ($EPirate.Topic) {
        if ($me isop %chan) topic %chan $EPirate.Topic
        else EPirate.Notice $nick I am not @!
      }
      else EPirate.Notice $nick Thar be no topic to set!
    }
    elseif ($3-4 == change nickname) {
      var %player $5
      if (!$epirate.isuser(%player)) && (%player) {
        EPirate.notice $nick %player ain't a hand o' th' crew.
        return
      }
      ;writeini -n %file %player nickname $6-
      hadd EPirate.Players.Nicknames %player $6-
      EPirate.Public.Msg %player $+ 's new nickname be ' $+ $6- $+ '
    }
    elseif (bug == $3) || (debug == $3) {
      var %player $4
      if (!$epirate.isuser(%player)) && (%player) {
        EPirate.notice $nick %player ain't a hand o' th' crew.
        return
      }
      echo -at Done: EPirate.Achievement %player bugfixer
      EPirate.Achievement %player bugfixer
    }
    elseif ($3 == random) EPirate.Player.random.event
    elseif ($3 == enlist) {
      ;/EPirate.NewUser <player> <sex> <nationality>
      if ($hget(EPirate.Players.All,$4)) { EPirate.Notice $nick $4 is already part o' the crew! | return }
      if ($4 ison %chan) {
        if ($5 == male) || ($5 == female) {
          var %faction $6
          if (%faction == bot) set %faction Custom»Bot
          elseif (%faction == English) || (%faction == French) || (%faction == Spanish) || (%faction == Native) || (%faction == Jesuit) || (%faction == Dutch) noop
          elseif (!%faction) set %faction Jesuit
          else { epirate.notice $nick What faction? <Bot,Dutch,English,French,Jesuit,Native,Spanish> | return }
          ;.timerEPirate.NewUser. $+ $4 1 1 EPirate.NewUser $4 $5 Jesuit
          EPirate.NewUser $4 $5 %faction
          if ($6 == bot) .timer 1 4 if ($readini($epirate.playerdata,$4,start)) writeini $epirate.playerdata $4 faction Custom»Bot
          .timer 1 1 hdel EPirate.Options nomemo. $+ $4
          .timer 1 1 hdel EPirate.Options nomsg. $+ $4
          EPirate.Personal.Msg $4 Ye 'ave been forced to join the crew!
          EPirate.Public.Msg $4 has forceably joined the crew!
        }
        else EPirate.Notice $nick Incorrect syntax: !p $1-3 <Name> <Male,Female> <Bot,Dutch,English,French,Jesuit,Native,Spanish>
      }
      else EPirate.notice $nick $4 is not here or incorrect syntax: !p Admin Enlist <Name> <Male,Female> <Bot,Dutch,English,French,Jesuit,Native,Spanish>
    }
    elseif ($3 == quest) {
      EPirate.Ship.Quest
      EPirate.Notice $nick Ship quest started!
    }
    elseif ($3 == take) {
      var %player $4
      if (!$epirate.isuser(%player)) && (%player) {
        EPirate.notice $nick %player ain't a hand o' th' crew.
        return
      }

      if ($5 isnum) {
        EPirate.Public.MSG Th' Admin, %nickname $NICK $+ $chr(44) has given' %player a penalty o' $epirate.round($5) doubloons!
        epirate.pay $4 - $+ $5 penalty
      }
      else EPirate.Notice $nick How much? !Pirates admin take $4 <amount>
    }
    elseif ($3 == title) || ($3 == nickname) || ($3 == nick) {
      var %player $4
      if (!$epirate.isuser(%player)) && (%player) {
        EPirate.notice $nick %player ain't a hand o' th' crew.
        return
      }
      if (!$5) { epirate.notice $nick what do ye want their nickname to be? | return }
      ;writeini -n %file %player nickname $5
      hadd EPirate.Players.Nicknames %player $5
      epirate.public.msg $4 now be known as ' $+ $5- $+ '.
    }
    elseif ($3 == free) || ($3 == unjail) || ($3 == unbrig) {
      var %player $4
      if (!$epirate.isuser(%player)) && (%player) {
        EPirate.notice $nick %player ain't a hand o' th' crew.
        return
      }
      if ($EPirate.Jail(%player)) EPirate.Jail.Remove %player
      else EPirate.Notice %player is not in the brig.
    }
    elseif ($3 == brig) || ($3 == jail) {
      var %player $4
      if (!$epirate.isuser(%player)) && (%player) {
        EPirate.notice $nick %player ain't a hand o' th' crew.
        return
      }
      if (!$6) || ($5 !isnum) EPirate.Notice $nick Format is $1-4 <Duration.In.Mins> <Reason>
      else EPirate.Jail %player $5 $6-
    }
    elseif ($3 == give) || ($3 == bonus) {
      var %player $4
      if (!$epirate.isuser(%player)) && (%player) {
        EPirate.notice $nick %player ain't a hand o' th' crew.
        return
      }

      if ($5 isnum) {
        EPirate.Public.MSG Th' Admin, %nickname $NICK $+ $chr(44) has given %player a bonus o' $epirate.round($5) doubloons!
        epirate.pay $4 $5 $iif($6,$6-,admin.bonus)
      }
      else EPirate.Notice $nick How much? !Pirates admin give $4 <amount>

    }
    elseif ($3 == gun) {
      if (!$4) { EPirate.Notice $nick Who gets the gun? !Pirates gun <player> | return }
      var %player $4
      if (!$epirate.isuser(%player)) { EPirate.notice $nick %player ain't a hand o' th' crew. | return }
      var %level $epirate.player.level(%player)
      var %gun $readini(%file,%player,gun)
      set %gun $Epirate.gun(%level)
      remini %file %player gun.uses
      writeini -n %file %player gun %gun
      EPirate.Public.MSG Th' Admin, %nickname $NICK $+ $chr(44) has given %player %gun $+ !
    }
    elseif ($3 == sword) {
      if (!$4) { EPirate.Notice $nick Who gets the sword? !Pirates sword <player> | return }
      var %player $4
      if (!$epirate.isuser(%player)) { EPirate.notice $nick %player ain't a hand o' th' crew. | return }
      var %level $epirate.player.level(%player)
      var %sword $readini(%file,%player,sword)
      set %sword $Epirate.sword(%level)
      writeini -n %file %player sword %sword
      remini %file %player sword.uses
      EPirate.Public.MSG Th' Admin, %nickname $NICK $+ $chr(44) has given %player %sword $+ !
    }
    elseif ($3 == riddle) epirate.riddle.event.start
    elseif ($3 == find) EPirate.Random.Find $4-
    elseif ($3 == mass.find) EPirate.Mass.Find 1
    elseif ($3 == setlevel) {
      if (!$4) { Epirate.notice $nick $1-3 player level | return }
      if ($epirate.isuser($4)) {
        if ($5 isnum) {
          epirate.notice $nick Setting $4 $+ 's level to $5
          EPirate.SetLevel $4 $5
        }
        else epirate.ntice $nick $5 is not num! $1-3 player level
      }
      else EPirate.notice $nick $4 is not a pirate! $1-3 player level
    }
    ;list o' cmds
    else EPirate.Notice $nick Commands: attack, captcha, enlist, epic monster, find, fire, gun, give, level, mass find, monster, nickname, setlevel, storm, sword, take, unjail. !Pirates admin <command>
  }
}
alias EPirate.SetLevel {
  ;/EPirate.SetLevel player level reason
  ;debug /EPirate.SetLevel $1-
  var %player $1, %level $2
  if (!$epirate.isuser($1)) { EPirate.WARNING.ECHO $1 is not a user! | return }
  if ($2 !isnum) || ($2 < 1) || ($2 > 28) { EPirate.WARNING.ECHO $2 is not a good level! | return }
  var %file $epirate.save.dir(playerdata.dat)
  writeini -n %file %player level $calc(%level - 1)
  var %doubloons.needed $EPirate.Level.Check(%player)
  var %percent $calc(3 / 100)
  var %sum $round($calc(%doubloons.needed * %percent),0)
  var %doubloons $calc(%sum + %doubloons.needed)
  ;hadd EPirate.Players.All %player $rand(10,1000)
  if (- !isin %doubloons) epirate.pay %player %doubloons $iif($3,$3,admin)
  EPirate.Advance.Level %player %level 1
}
alias EPirate.Admin.SetLevel {
  ;/EPirate.Admin.SetLevel player level reason
  ;debug /EPirate.SetLevel $1-
  var %player $1, %level $2
  if (!$epirate.isuser($1)) { EPirate.WARNING.ECHO $1 is not a user! | return }
  if ($2 !isnum) || ($2 < 1) || ($2 > 28) { EPirate.WARNING.ECHO $2 is not a good level! | return }
  if ($3 == yes) {
    var %file $epirate.save.dir(playerdata.dat)
    writeini -n %file %player level $calc(%level - 1)
    var %doubloons.needed $EPirate.Level.Check(%player)
    var %percent $calc(3 / 100)
    var %sum $round($calc(%doubloons.needed * %percent),0)
    var %doubloons $calc(%sum + %doubloons.needed)
    ;hadd EPirate.Players.All %player $rand(10,1000)
    if (- !isin %doubloons) epirate.pay %player %doubloons $iif($3,$3,admin)
    EPirate.Advance.Level %player %level 1
  }
  else epirate.debug Are ye sure ye want set %player to level $2 ? /EPirate.Admin.SetLevel %player %level YES
}
alias epirate.admin.level.player.OLD {
  var %player $1
  if (!$epirate.isuser(%player)) && (%player) { EPirate.INFO.ECHO %player ain't a hand o' th' crew. | return }
  hdel EPirate.Daily levelup. $+ %player
  epirate.pay %player $calc($EPirate.Level.Check(%player) + 1) admin.bonus
  EPirate.Level.Check %player
}
alias epirate.admin.bonus.player {
  :/epirate.admin.bonus.player <player> <sum>
  if (!$epirate.isuser($1)) { EPirate.INFO.ECHO $1 is not a user! | return }
  var %sum $EPirate.Convert.Wager($2)
  if (%sum !isnum) { EPirate.WARNING.ECHO %sum is not a number! | return }
  EPirate.Public.MSG Th' Admin, $epirate.admin $+ $chr(44) has given $1 bonus o' $epirate.round(%sum) doubloons!
  epirate.pay $1 %sum $iif($6,$6-,admin.bonus)
}
alias epirate.admin.fakebonus.player {
  :/epirate.admin.bonus.player <player> <sum> - this is used to circumvent players who try to lose on purpose by making large and unnecessary purchases
  if (!$epirate.isuser($1)) { EPirate.INFO.ECHO $1 is not a user! | return }
  var %player $1, %sum $EPirate.Convert.Wager($2)
  if (%sum !isnum) { EPirate.WARNING.ECHO %sum is not a number! | return }
  var %msg, %nickname $epirate.player.nickname(%player), %r $rand(1,5)
  if (%r == 1) set %msg %nickname %player wins wins $epirate.round(%sum) doubloons in the longest time without a bath contest!
  elseif (%r == 2) set %msg %nickname wins $epirate.round(%sum) doubloons in the best shipmate o' the day contest!
  elseif (%r == 3) set %msg %nickname %player sure does have a purty mouth 'n wins $epirate.round(%sum) doubloons in a booty contest!
  elseif (%r == 4) set %msg %nickname %player wins $epirate.round(%sum) doubloons in a sword measurin' contest!
  else set %msg %nickname %player found $epirate.round(%sum) doubloons while cleanin' the Captain's cabin!

  EPirate.Public.MSG %msg
  epirate.pay $1 %sum $iif($6,$6-,random)
}
alias epirate.admin.level.player {
  ;/epirate.admin.level.player <player>
  if (!$2) || ($2 != yes) { epirate.debug Are ye sure ye want to level up $1 ? /epirate.admin.level.player $1 YES | return }
  if (!$epirate.isuser($1)) { EPirate.WARNING.ECHO $1 is not a user! | return }
  var %player $1
  hdel EPirate.Daily levelup. $+ %player
  epirate.pay %player $calc($EPirate.Level.Check(%player) + 100) admin.bonus
  EPirate.Level.Check %player
  EPirate.Public.MSG Th' Admin, $epirate.admin $+ $chr(44) has promoted %player $+ !
}
