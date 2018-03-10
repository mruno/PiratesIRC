;------------------------
;PiratesIRC by mruno
;--------------------------------
;some minigames in this file
;
;Network Specific stuff in C:\EP\Pirates.<NETWORK>.mrc
;Aliases in C:\EP\elitepirates.mrc
;Events in C:\EP\elitepirates2.mrc
;--------------------------------
;
;
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


alias EPirate.Bot.Game.Dice.Start {
  ;/EPirate.Bot.Game.Dice.Start <player> - bot challenges the player specified to a game o' Dice
  var %player $1
  if ($timer(Epirate.Defend.Action)) { epirate.notice %player Ye 'ave no time fer games! Defend the ship!!! | return }
  if ($timer(EPirate.Dice.Timeout)) || (%EPirate.Dice.Player1) || ($hget(epirate.daily,Games.Played. $+ %player) >= $EPirate.Max.Games.Per.Day) return
  if ($hget(EPirate.Expenses.Today,%player $+ .games) > $epirate.player.percentage(%player,$EPirate.Max.Percentage.Daily.Games)) return
  if ($epirate.bot) && ($epirate.isuser(%player)) {
    var %wager $epirate.player.percentage(%player,$calc($rand(5,50) / 100))
    if (%wager isnum) EPirate.Game.Dice.Start $epirate.bot %player %wager
  }
}

alias EPirate.Game.Dice.Start {
  ;/EPirate.Game.Dice.Start <player1> <player2> <wager> - starts the dice game

  var %player1 $1, %player2 $2, %chan %EPirate.Chan
  .timer 1 45 EPirate.Task.Check %player1 play.game
  if ($timer(Epirate.Defend.Action)) { epirate.notice %player1 Ye 'ave no time fer games! Defend the ship!!! | return }
  if (!%player2) { epirate.notice %player1 Who do ye want to play with? $1-3 <pirate> | return }
  if (!$epirate.isuser(%player2)) { epirate.notice %player1 %player2 not be a member o' the crew! | return }
  if ($EPirate.Jail(%player2)) { epirate.notice %player1 %player2 cannot play games from the brig! | return }
  if ($hget(EPirate.Games,played. $+ %player1) >= $Epirate.Games.Before.Bribe.Needed) {
    EPirate.Notice %player1 Th' Cap'n will catch ye if ye keep playin' those games 'n nah scrubbin' th' poop deck. Play later, ye blaggard!
    EPirate.Notice %player1 I may be able t' help ye play some more games. Type !Pirates store bribe
    return
  }
  if ($hget(EPirate.Games,played. $+ %player2) >= $Epirate.Games.Before.Bribe.Needed) {
    EPirate.Notice %player1 Th' Cap'n caught %PLAYER2 playin' games 'n be now scrubbin' th' poop deck. Try again later.
    EPirate.Notice %player2 I may be able t' help ye play some more games. Type !Pirates store bribe
    return
  }
  if (%player2 !ison %chan) && ($hget(epirate.away.nicks,%player2) !ison %chan) {
    EPirate.notice %player1 %player2 ain't onboard. $iif(%player2 ison %chan,%player2 needs to identify wit' nickserv.)
    if (%player2 ison %chan) {
      .timerEPirate.Verify.nick. $+ %player2 1 $calc($timer(0) + 10) EPirate.Verify.nick %player2
      EPirate.Notice %player2 %player1 tried to play a game wit' ye, but ye not identified wit' Nickserv. Identify / $+ $EPirate.Nickserv.Command identify <password> 'n then !Pirates identify
    }
    return
  }

  var %wager 0
  ;if ($3 == max) set %wager $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Wager)
  if ($3 == max) set %wager $epirate.determine.max.wager(%player1,%player2)
  else set %wager $EPirate.Convert.Wager($3)

  var %player1.doubloons $hget(EPirate.Players.ALL,%player1)
  var %player2.doubloons $hget(EPirate.Players.ALL,%player2)
  var %player1.level $readini(%file,%player1,level)
  var %player2.level $readini(%file,%player2,level)
  var %player1.nickname $epirate.nick(%player1)
  var %player2.nickname $epirate.nick(%player2)
  var %cmd $iif($EPirate.Reduce.SPAM,epirate.notice %player1,epirate.public.msg)

  if (%player1 == %player2) { EPirate.Notice %player1 Ye can nah play wit' yerself! | return }
  if (%player1 != $epirate.bot) {
    if (!$epirate.isuser(%player1)) { %cmd %player1 ain't a hand o' th' crew. | return }
    if (%player1.level < 2) || (%player2.level < 2) { EPirate.Notice %player1 Both players need be at least level $v2 $+ . | return }
    if (%wager > $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Wager)) { EPirate.Notice %player1 That wager be too high! Try $EPirate.Round($v2) doubloons or less. | return }
  }
  if (!$epirate.isuser(%player2)) { %cmd %player2 ain't a hand o' th' crew. | return }
  if (%wager !isnum) { EPirate.Notice %player1 Ye have t' choose a number. | return }
  if (%wager < 1) || (- isin %wager) || (. isin %wager) || ($len(%wager) > 25) { EPirate.Notice %player1 I don't like that wager. | return }
  if ($epirate.isuser(%player2)) {
    if (%wager > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Wager)) { EPirate.Notice %player1 That wager be too high fer %player2 $+ ! Try $EPirate.Round($v2) doubloons or less. | return }
    ;if ($hget(epirate.daily,Games.Played. $+ %player1) >= $EPirate.Max.Games.Per.Day) { epirate.notice %player1 Ye played enough games today! New day starts in $EPirate.Time.Until.New.Day | return }
    if ($hget(EPirate.Expenses.Today,%player1 $+ .games) > $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice %player1 Ye 'ave earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }
    hinc epirate.daily Games.Played. $+ %player1
    ;if ($hget(epirate.daily,Games.Played. $+ %player2) >= $EPirate.Max.Games.Per.Day) { epirate.notice %player2 %player2 played enough games today! New day starts in $EPirate.Time.Until.New.Day | return }
    if ($hget(EPirate.Expenses.Today,%player2 $+ .games) > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice %player1 %player2 earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }
    hinc epirate.daily Games.Played. $+ %player2
    EPirate.Public.MSG %player1.nickname %player1 has challenged %player2.nickname %player2 t' a game o' dice fer $EPirate.Round(%wager) doubloons! $iif($hget(epirate.games,dice.pot), $epirate.round($hget(epirate.games,dice.pot)) doubloons already be in the pot!)
    EPirate.Notice %player1 Waitin' on %player2 to accept the game.
    EPirate.Notice %player2 %player1 has challenged ye to a game o' dice fer $EPirate.Round(%wager) $iif($hget(epirate.games,drink.pot),n' $epirate.round($hget(epirate.games,drink.pot)) doubloons already be in the pot!,doubloons.) Ye have 1 minute to accept. Accept by typing  !Pirates dice accept
    set %EPirate.Dice.Wager %wager
    set %EPirate.Dice.Player1 %player1
    set %EPirate.Dice.Player2 %player2
    var %time 90
    if (%player1 == $epirate.bot) inc %time 200
    .timerEPirate.Dice.Timeout 1 %time EPirate.Dice.Timeout
    EPirate.Achievement %player1 game
  }
  else EPirate.Notice %player1 $4 ain't a pirate or currently onboard. !Pirates dice <wager> <Pirate2>
}
alias EPirate.Bot.Game.Drinking.Start {
  ;/EPirate.Bot.Game.Drinking.Start <player> - bot challenges the player specified to a game o' drinkin'
  var %player $1
  if ($timer(Epirate.Defend.Action)) { epirate.notice %player Ye 'ave no time fer games! Defend the ship!!! | return }
  if ($timer(EPirate.Drink.Timeout)) || (%EPirate.Drink.Player1) || ($hget(epirate.daily,Games.Played. $+ %player) >= $EPirate.Max.Games.Per.Day) return
  if ($hget(EPirate.Expenses.Today,%player $+ .games) > $epirate.player.percentage(%player,$EPirate.Max.Percentage.Daily.Games)) return

  if ($epirate.bot) && ($epirate.isuser(%player)) {
    var %wager $epirate.player.percentage(%player,$calc($rand(5,50) / 100))
    if (%wager isnum) EPirate.Game.Drinking.Start $epirate.bot %player %wager
  }
}
alias EPirate.Game.Drinking.Start {
  ;/EPirate.Game.Drinking.Start <player1> <player2> <wager> - starts the drinking game

  var %cmd $iif($EPirate.Reduce.SPAM,epirate.notice %player1,epirate.public.msg)
  var %player1 $1, %chan %EPirate.Chan
  .timer 1 45 EPirate.Task.Check %player1 play.game
  var %player2 $2
  if ($timer(Epirate.Defend.Action)) { epirate.notice %player1 Ye 'ave no time fer games! Defend the ship!!! | return }
  if ($EPirate.Jail(%player2)) { epirate.notice %player1 %player2 cannot play games from the brig! | return }
  if ($hget(EPirate.Games,played. $+ %player1) >= $Epirate.Games.Before.Bribe.Needed) {
    EPirate.Notice %player1 Th' Cap'n will catch ye if ye keep playin' those games 'n nah scrubbin' th' poop deck. Play later, ye blaggard!
    EPirate.Notice %player1 I may be able t' help ye play some more games. Type !Pirates store bribe
    return
  }
  if ($hget(EPirate.Games,played. $+ %player2) >= $Epirate.Games.Before.Bribe.Needed) {
    EPirate.Notice %player1 Th' Cap'n caught %PLAYER2 playin' games 'n be now scrubbin' th' poop deck. Try again later.
    EPirate.Notice %player2 I may be able t' help ye play some more games. Type !Pirates store bribe
    return
  }
  if (%player2 !ison %chan) && ($hget(epirate.away.nicks,%player2) !ison %chan) {
    EPirate.notice %player1 %player2 ain't onboard. $iif(%player2 ison %chan,%player2 needs to identify wit' nickserv.)
    if (%player2 ison %chan) {
      .timerEPirate.Verify.nick. $+ %player2 1 $calc($timer(0) + 10) EPirate.Verify.nick %player2
      EPirate.Notice %player2 %player1 tried to play a game wit' ye, but ye not identified wit' Nickserv. Identify / $+ $EPirate.Nickserv.Command identify <password> 'n then !Pirates identify
    }
    return
  }
  var %wager 0
  ;if ($3 == max) set %wager $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Wager)
  if ($3 == max) set %wager $epirate.determine.max.wager(%player1,%player2)
  else set %wager $EPirate.Convert.Wager($3)
  var %player1.doubloons $hget(EPirate.Players.ALL,%player1), %player2.doubloons $hget(EPirate.Players.ALL,%player2)
  var %player1.level $readini(%file,%player1,level), %player2.level $readini(%file,%player2,level)
  var %player1.nickname $epirate.nick(%player1), %player2.nickname $epirate.nick(%player2)
  var %cmd $iif($EPirate.Reduce.SPAM,epirate.notice %player1,epirate.public.msg)
  if (!$epirate.isuser(%player2)) { %cmd %player2 ain't a hand o' th' crew. | return }
  if (%wager !isnum) { EPirate.Notice %player1 Ye have t' choose a number. | return }
  if (%wager < 1) || (- isin %wager) || (. isin %wager) || ($len(%wager) > 25) { EPirate.Notice %player1 I don't like that wager. | return }
  if (%player1 != $epirate.bot) {
    if (%player1 == %player2) { EPirate.Notice %player1 Ye can nah play wit' yerself, ye Blaggard! | return }
    if (!$epirate.isuser(%player1)) { %cmd %player1 ain't a hand o' th' crew. | return }
    if (%player1.level < 2) || (%player2.level < 2) { EPirate.Notice %player1 Both players need be at least level $v2 $+ . | return }
    if (%wager > $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Wager)) { EPirate.Notice %player1 That wager be too high! Try $EPirate.Round($v2) doubloons or less. | return }
    if ($hget(EPirate.Expenses.Today,%player2 $+ .games) > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice %player1 %player2 has earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }
  }
  if ($hget(EPirate.Players.Current,%player2)) {
    if (%wager > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Wager)) { EPirate.Notice %player1 %player2 be too poor fer tis wager. Try $EPirate.Round($v2) doubloons or less. | return }
    ;if ($hget(epirate.daily,Games.Played. $+ %player1) >= $EPirate.Max.Games.Per.Day) { epirate.notice %player1 Ye played enough games today! New day starts in $EPirate.Time.Until.New.Day | return }
    if ($hget(EPirate.Expenses.Today,%player1 $+ .games) > $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice %player1 Ye 'ave earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }
    hinc epirate.daily Games.Played. $+ %player1
    EPirate.Public.MSG %player1.nickname %player1 has challenged %player2.nickname %player2 t' a game o' drinkin' fer $EPirate.Round(%wager)  $+ $iif($hget(epirate.games,drink.pot),n' $epirate.round($hget(epirate.games,drink.pot)) doubloons already be in the pot!,doubloons.) First scallywag to reach 10 points o' drunkiness loses.
    if (%player1 != $epirate.bot) {
      EPirate.Notice %player1 Waitin' on %player2 to accept the game.
      EPirate.Achievement %player1 game
    }
    EPirate.Notice %player2 %player1 has challenged ye to a game o' Drinkin' fer $EPirate.Round(%wager) doubloons! Ye have 1 minute to accept. Accept by typing  !Pirates Drinking Accept
    set %EPirate.Drink.Wager %wager
    set %EPirate.Drink.Player1 %player1
    set %EPirate.Drink.Player2 %player2
    var %time 90
    if (%player1 == $epirate.bot) inc %time 200
    .timerEPirate.Drink.Timeout 1 %time EPirate.Drink.Timeout
    hinc EPirate.Stats ship.games
    if (%wager < $epirate.player.percentage(%player1,0.1)) EPirate.Achievement %player1 Game.Low.Wager
  }
}



;--------------------------- High/Low Game-------------
; Higher/lower game by CQ 20060731 http://hawkee.com/snippet/2231/
alias EPirate.Bot.Game.HiLo.Start {
  var %h $+(epirate.hl_,$network,$chr(44),%EPirate.Chan)
  if ($hget(%h)) return

  ;/EPirate.Bot.Game.HiLo.Start - bot starts a game o' HiLo
  if (!$epirate.bot) || ($EPirate.Special.Event) || ($timer(EPirate.BlackJack.Start1)) return
  var %sum $epirate.player.percentage($hget(epirate.options,captain),0.01)
  if (!%sum) || (%sum < 10) set %sum $rand(10,1000)
  epirate.hl_init 1- $+ $rand(10,25) 6 90 30 %sum $epirate.bot
}
alias epirate.hl_init {
  var %range = $1, %players = $2, %secs = $3, %timeout = $4, %sum $5, %player $iif($nick,$nick,$6)
  if ($timer(Epirate.Defend.Action)) { epirate.notice %player Ye 'ave no time fer games! Defend the ship!!! | return }
  var %chan $EPirate.Chan
  if (%range == $null) { var %range = $+(1,-,$calc(100 * $rand(1,100))) }
  else { if ($epirate.hl_checkrange(%range) == FAIL) { goto refuse } | var %range = $v1 }
  if (%players !isnum 2-) || ($int(%players) != %players) { var %players = 1, %secs = 0, %timeout = 0 }
  else {
    if (%timeout !isnum 10-60) || ($int(%timeout) != %timeout) { var %timeout = 20 }
    if (%secs !isnum 1-120) || ($int(%secs) != %secs) { set %secs $calc(%players * 5) }
  }
  tokenize 45 %range
  if ($calc($2 - $1) < 2) {
    describe %chan turns out a leg of %player and slaps %player $+ 's skull inwards with it. Range %range - is -that- guessin'??
    return
  }
  goto ok
  :refuse | epirate.notice %player Please use correct format, %player $+ : $epirate.hl_com | return
  :ok
  var %h = $+(epirate.hl_,$network,$chr(44),%chan) | if ($hget(%h)) { hfree %h | .timer $+ $+(epirate.hl_*,$chr(44),$network,$chr(44),%chan) OFF }
  hmake %h 30 | hadd %h maxplayers %players | hadd %h range %range | tokenize 45 %range | hadd %h num $rand($1,$2) | hadd %h timeout %timeout
  hadd %h wager %sum

  if (%player == $me) {
    hadd %h player1, $+ %player %player
    hadd %h botgame 1
  }
  else hadd %h player1, $+ $epirate.hl_site %player
  hinc %h total
  if (%players > 1) { 
    var %tn = $+(epirate.hl_join,$chr(44),$network,$chr(44),%chan) | .timer $+ %tn 1 %secs epirate.hl_jointimeout $network %chan
    epirate.public.msg %player started a game o' HiLo wit' a wager o' $epirate.round(%sum) doubloons! The number to guess be between $gettok(%range,1,45) n' $gettok(%range,2,45) $+ . Up to %players pirates can play n' ye 'ave %secs secs to join in wit' !Pirates HiLo Join | return
  }
  epirate.public.msg The HiLo game has begun! | epirate.hl_next $network %chan
}
alias epirate.hl_jointimeout {
  var %h = $+(epirate.hl_,$1,$chr(44),$2)
  if ($hget(%h,total) == 1) {
    var %player $hget(%h,$hfind(%h,player1*,1,w))
    if ($epirate.spam) epirate.notice %player The HiLo game has timed out without anyone else joinin'!
    else epirate.spam The HiLo game has timed out since no one joined.
    epirate.hl_stop $network %EPirate.Chan
  }
  else {
    if ($me ison $2) { epirate.hl_start $1 $2 The game has started wit': }
    else { hadd %h start 1 }
  }
}
alias epirate.hl_join {
  var %player $nick, %chan %EPirate.Chan, %i 0
  var %h = $+(epirate.hl_,$network,$chr(44),%chan)
  if ($hget(%h,wager) > $epirate.player.percentage(%player,$EPirate.Max.Percentage.Wager)) { EPirate.Notice %player The wager be too much fer ye! Try $EPirate.Round($v2) doubloons or less | return }
  hinc epirate.daily Games.Played. $+ %player
  EPirate.Achievement %player game
  if ($hget(EPirate.Players.Skills,%player $+ .learning) == luck) .timerEPirate.Skills.Check.Luck. $+ %player 1 3 EPirate.Skills.Check %player Luck
  if (!$hget(%h)) { epirate.notice $nick Thar not be a game bein' played! Start one wit' $epirate.hl_com | return }
  var %site = $epirate.hl_site
  var %total 0
  if ($hget(%h,next)) {
    var %com = epirate.notice $nick Guessin' already started, $nick $+ .
    if ($hfind(%h,$+(player*,$chr(44),%site),1,w)) {
      if ($hfind(%h,$+(player,$hget(%h,next),$chr(44),%site),1,w)) { %com It's your turn, please use !guess <number>. }
      elseif ($hfind(%h,$+(player,$hget(%h,next),$chr(44),*),1,w)) { %com It's now $hget(%h,$v1) $+ 's turn. }
      return
    } 
    %com Ye too late to join! | return
  }
  if ($hfind(%h,$+(player*,$chr(44),%site),1,w)) { epirate.notice $nick Ye already joined! | return }
  var %i = 1, %max = 0 | while ($hfind(%h,$+(player*,$chr(44),*),%i,w)) { tokenize 44 $v1 | if ($remove($1,player) > %max) { var %max = $v1 } | inc %i }
  inc %max
  hadd %h $+(player,%max,$chr(44),%site) $nick
  inc %total
  hinc %h total
  if (%total < $hget(%h,maxplayers)) {
    epirate.notice $nick Ye 'ave joined the game!
    return
  }
  .timer $+ $+(epirate.hl_join,$chr(44),$network,$chr(44),%chan) OFF | noop msg %chan Red lantern is $nick $+ ! | epirate.hl_start $network %chan Players:
}
alias epirate.hl_start {
  var %net = $1, %chan = $2, %h = $+(epirate.hl_,$1,$chr(44),$2), %i = 1, %chunk = $3-, %i = 1
  while ($hfind(%h,$+(player*,$chr(44),*),%i,w)) {
    var %new = %chunk $hget(%h,$v1) | if ($len(%new) > 400) { epirate.public.msg %chunk | var %chunk } | else { var %chunk = %new }
    inc %i
  }
  if (%chunk != $null) { epirate.public.msg %chunk }
  if ($hfind(%h,$+(player*,$chr(44),*),0,w) > 1) { noop epirate.public.msg Time to guess: $hget(%h,timeout) seconds... }
  epirate.hl_next %net %chan
}
alias epirate.hl_stop { var %h = $+(epirate.hl_,$1,$chr(44),$2) | if ($hget(%h)) { hfree %h | .timer $+ $+(epirate.hl_*,$chr(44),$1,$chr(44),$2) OFF } }
alias epirate.hl_next {
  var %net = $1, %chan = $2, %h = $+(epirate.hl_,$1,$chr(44),$2), %i = 1, %w = @epirate.hl_temp, %l, %player $iif($nick,$nick,$2) | window -sh %w
  while ($hfind(%h,$+(player*,$chr(44),*),%i,w)) {
    var %hi = $v1, %nick = $hget(%h,%hi) | if (%nick !ison %chan) { inc %i | continue }
    tokenize 44 %hi | var %nr = $base($remove($1,player),10,10,10) | aline %w %nr %hi | inc %i
  }
  var %l
  if ($hget(%h,next) != $null) {
    var %total = $line(%w,0), %i = 1, %l | while (%i <= %total) { tokenize 32 $line(%w,%i) | if ($1 > $hget(%h,next)) { var %l = %i | break } | inc %i }
  }
  if (!%l) { var %l = 1 } | tokenize 32 $line(%w,%l) | window -c %w | var %hi = $2
  tokenize 44 %hi | hadd %h next $remove($1,player) | tokenize 45 $hget(%h,range)
  if ($1 != $2) {
    if ($hget(%h,%hi) == $epirate.bot) {
      var %guess $rand($gettok($hget(%h,range),1,45),$gettok($hget(%h,range),2,45))
      .timer 1 3 describe %chan guesses %guess
      .timer 1 4 epirate.hl_guess %guess $epirate.bot
    }
    else epirate.notice $hget(%h,%hi) It be ye turn n' ye 'ave $hget(%h,timeout) seconds! The number be between $gettok($hget(%h,range),1,45) n' $gettok($hget(%h,range),2,45) $+ ... !Pirates Guess <number>
  }
  else {
    if ($hget(%h,%hi) == $epirate.bot) {
      var %guess $rand($gettok($hget(%h,range),1,45),$gettok($hget(%h,range),2,45))
      .timer 1 3 describe %chan $epirate.bot guesses %guess
      .timer 1 5 epirate.hl_guess %guess $epirate.bot
    }
    else epirate.notice $hget(%h,%hi) Type !Pirates Guess $1
  }
  if ($hget(%h,%hi) != $epirate.bot) && ($hfind(%h,$+(player*,$chr(44),*),0,w) > 1) { .timer $+ $+(epirate.hl_wait,$chr(44),%net,$chr(44),%chan) 1 $hget(%h,timeout) epirate.hl_guesstimeout %net %chan }
}
alias epirate.hl_guesstimeout {
  var %h = $+(epirate.hl_,$1,$chr(44),$2) | if ($me !ison $2) { return }
  var %hi = $hfind(%h,$+(player,$hget(%h,next),$chr(44),*),1,w) | epirate.public.msg $hget(%h,%hi) ran out o' time! 
  hinc %h timeouts
  var %timeouts 10
  if ($hget(%h,botgame)) set %timeouts 4
  if ($hget(%h,timeouts) > %timeouts) {
    epirate.public.msg The game has timed out n' $epirate.round($calc($hget(%h,wager) * $hget(%h,total))) doubloons be abandoned!
    epirate.hl_stop $1 $2
  }
  else { epirate.hl_next $1 $2 }
}
alias epirate.hl_guess {
  var %player $iif($nick,$nick,$2), %chan %EPirate.Chan
  var %h = $+(epirate.hl_,$network,$chr(44),%chan) | if (!$hget(%h)) { epirate.notice %player Thar not be a game bein' played! Start one wit' $epirate.hl_com | return }
  var %site = $epirate.hl_site, %tn = $+(epirate.hl_join,$chr(44),$network,$chr(44),%chan)
  if ($timer(%tn)) {
    if (!$hfind(%h,$+(player*,$chr(44),%site),1,w)) { epirate.notice %player Ye gotta 1) !Pirates Join 2) !Pirates Guess. You have $timer(%tn).secs secs left for step 1) }
    else { epirate.notice %player Wait $timer(%tn).secs secs left before starting! }
    return
  }
  var %higuess = $hfind(%h,$+(player*,$chr(44),%site),1,w), %hiturn = $hfind(%h,$+(player,$hget(%h,next),$chr(44),*),1,w)
  if (%higuess) && (%hiturn) && (%higuess != %hiturn) { noop msg %chan Hey %player $+ , it's $hget(%h,%hiturn) $+ 's turn not yours! | return }
  var %guess = $remove($1,<,>)
  if (%guess !isnum) set %guess $remove($2,<,>)
  hinc %h guesscount
  if (%player != $me) hdec %h timeouts
  tokenize 45 $hget(%h,range)

  if (%guess !isnum $hget(%h,range)) { 
    if ($remove($1,<,>) != $2) { epirate.public.msg The number be between $gettok($hget(%h,range),1,45) n' $gettok($hget(%h,range),2,45) $+ . %player wasted $epirate.hisorher(%player) turn! } | else { describe %chan sighs... }
    goto next
  }
  elseif (%guess > $hget(%h,num)) { epirate.notice %player The number be lower... | dec %guess | hadd %h range $+($1,-,%guess) | goto next }
  elseif (%guess < $hget(%h,num)) { epirate.notice %player The number be higher... | inc %guess | hadd %h range $+(%guess,-,$2) | goto next }
  else {
    ;----- game ends here! -----
    var %sum $calc($hget(%h,wager) * $hget(%h,total))
    var %max $epirate.player.percentage(%player,$EPirate.Max.Percentage.Bonus)
    var %tax
    if (%sum > %max) && (%player != $epirate.bot) {
      inc %tax
      .timer 1 10 epirate.notice %player Ye payout be reduced due to taxes!
      set %sum %max
    }
    epirate.pay %player %sum games
    epirate.public.msg After $hget(%h,guesscount) $iif($hget(%h,guesscount) == 1,guess,guesses) $+ $chr(44) $epirate.nick(%player) %player finds the number to be %guess n' wins $epirate.round(%sum) doubloons $iif(%tax,after taxes!,!)
    var %i 0
    set %sum $hget(%h,wager)
    while ($hfind(%h,player*,0,w) > %i) {
      inc %i
      set %player $hget(%h,$hfind(%h,player*,%i,w))
      epirate.pay %player - $+ %sum games
      if ($EPirate.Pirate.Rank(%player) != 1st) && (!$EPirate.Party) hinc EPirate.Games played. $+ %player
    }
    epirate.hl_stop $network %chan
    return
  }
  :next | epirate.hl_next $network %chan
}

alias epirate.hl_checkrange {
  if ($left($1,1) !isnum) || ($numtok($1,45) > 2) { return FAIL }
  var %n1 = $gettok($1,1,45), %n2 = $gettok($1,2,45)
  if (%n1 < 0) { return FAIL }
  if (%n2 == $null) { var %n2 = %n1 }
  if (%n1 !isnum) || (%n2 !isnum) || ($int(%n1) != %n1) || ($int(%n2) != %n2) { return FAIL }
  if (%n2 < %n1) { var %t = %n1, %n1 = %n2, %n2 = %t }
  return $+(%n1,-,%n2)
}
alias epirate.hl_site return $nick
;alias epirate.hl_site { if ($nick != $me) { return $site } | else { return $gettok($address($me,2),2,64) } }
alias epirate.hl_com { return !Pirates HiLo Start <wager> }
alias epirate.hl_netcid {
  var %total = $scon(0), %i = 1
  while (%i <= %total) { if ($scon(%i).network) == $1) && ($scon(%i).status == connected) { return $scon(%i) } | inc %i }
  return NOTCON 
}
RAW 352:*:{ var %h = $+(epirate.hl_,$network,$chr(44),$2) | if ($hget(%h,inwho)) { haltdef } }
RAW 315:*:{ 
  var %h = $+(epirate.hl_,$network,$chr(44),$2) | if (!$hget(%h,inwho)) || ($me !ison $2) { return } 
  haltdef | hdel %h inwho | if ($hget(%h,start)) { epirate.hl_start $network $2 | hdel %h %hi start | return }
  var %hi = $hfind(%h,$+(player,$hget(%h,next),$chr(44),*),1,w) | if (%hi == $null) { return }
  if ($hget(%h,%hi) != $me) {

    var %tn = $+(epirate.hl_wait,$chr(44),$network,$chr(44),$2) | if (!$timer(%tn)) { epirate.hl_next $network $2 }
  }
}

alias EPirate.Game.Drinking {
  ;/EPirate.Game.Drinking player1 player2 wager
  if ($3 !isnum) return
  .timerEPirate.Drink.Timeout off
  var %file $epirate.save.dir(playerdata.dat), %player1.nickname $EPirate.Nick(%player1), %player2.nickname $EPirate.Nick(%player2)
  var %player1 $1, %player1.score 0, %player2 $2, %player2.score 0, %wager $3
  var %looks woozy drunk groggy befuddled dazed shaky wobbly unsteady
  var %loop 0
  while (%player1.score < 10) && (%player2.score < 10) {
    inc %loop
    var %drink $EPirate.Random.Drink
    inc %player1.score $rand(1,5)
    inc %player2.score $rand(1,5)
    var %look $gettok(%looks,$rand(1,$gettok(%looks,0,32)),32)
    var %actions chug down,drink,consume,gulp,guzzle,slurp,pound
    var %action $gettok(%actions,$rand(1,$gettok(%actions,0,44)),44)
    .timerEPirate.Drink. $+ %loop 1 $calc(%loop * 4) EPirate.Public.MSG Round %loop $+ ! %player1 'n %player2 %action some %drink $+ . $iif(%loop != 1,$iif(%player1.score > %player2.score,%player1 looks %look $+ ...) $iif(%player2.score > %player1.score,%player2 looks %look $+ ...))
  }
  var %action, %random
  set %random $rand(1,8)
  if (%random == 1) set %action passes out
  elseif (%random == 2) set %action pukes all over $epirate.random.pirate
  elseif (%random == 3) set %action $iif($EPirate.Censored,pees,pisses) their pants
  elseif (%random == 4) set %action $iif($EPirate.Censored,poops,shits) 'emselves
  elseif (%random == 5) set %action falls over
  elseif (%random == 6) set %action loses conscious
  elseif (%random == 7) set %action blacks out
  elseif (%random == 8) set %action falls asleep

  if (%player1.score > 9) && (%player2.score > 9) {
    ;both lose
    var %pirate $Epirate.Random.Player
    if (%player1 != $epirate.bot) EPirate.Pay %player1 - $+ %wager games
    EPirate.Pay %player2 - $+ %wager games
    set %wager $calc(%wager * 2)
    if ($hget(epirate.games,drink.pot)) {
      inc %wager $hget(epirate.games,drink.pot)
      ;debug drink.pot no winner: %wager : $hget(epirate.games,drink.pot)
    }
    hadd epirate.games drink.pot %wager
    hinc epirate.games drink.num
    .timerEPirate.Drink. $+ %loop 1 $calc(%loop * 4 + %loop) EPirate.Public.MSG Both %player1 'n %player2 pass out! $epirate.round(%wager) doubloons be in the pot fer the next round o' drinks!
  }
  elseif (%player1.score > 9) {
    ;player2 wins
    if (%player1 != $epirate.bot) EPirate.Pay - $+ %player1 %wager games
    if ($hget(epirate.games,drink.pot)) {
      ;debug drink.pot winner: %player2 : %wager : $hget(epirate.games,drink.pot)
      inc %wager $hget(epirate.games,drink.pot)
      hdel epirate.games drink.pot
      hdel epirate.games drink.num
    }
    if (%wager > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Bonus)) {
      set %wager $v2
      .timer 1 $calc(%loop * 4 + %loop) epirate.notice %player2 Ye payout be reduced due to tariffs!
    }
    EPirate.Pay %player2 %wager games
    .timerEPirate.Drink. $+ %loop 1 $calc(%loop * 4 + %loop) EPirate.Public.MSG %player1 $paren(%player1.score) %action $+ ! %player2 $paren(%player2.score) wins $EPirate.Round(%wager) doubloons!
  }
  else {
    ;player1 wins
    EPirate.Pay %player2 - $+ %wager games
    if ($hget(epirate.games,drink.pot)) {
      ;debug drink.pot winner: %player1 : %wager : $hget(epirate.games,drink.pot)
      inc %wager $hget(epirate.games,drink.pot)
      hdel epirate.games drink.pot
      hdel epirate.games drink.num
    }
    if (%player1 != $epirate.bot) && (%wager > $epirate.player.percentage(%player1,$EPirate.Max.Percentage.Bonus)) {
      set %wager $v2
      .timer 1 $calc(%loop * 4 + %loop) epirate.notice %player1 Ye payout be reduced due to tariffs!
    }
    if (%player1 != $epirate.bot) EPirate.Pay %player1 %wager games
    .timerEPirate.Drink. $+ %loop 1 $calc(%loop * 4 + %loop) EPirate.Public.MSG %player2 $paren(%player2.score) %action $+ ! %player1 $paren(%player1.score) wins $EPirate.Round(%wager) doubloons!
  }
  if (%player1 != $epirate.bot) {
    .timer 1 $calc(%loop * 4 + %loop) EPirate.Achievement %player1 Drunk
    if ($EPirate.Pirate.Rank(%player1) != 1st) && (!$EPirate.Party) hinc EPirate.Games played. $+ %player1
    if ($hget(EPirate.Players.Skills,%player1 $+ .learning) == Luck) .timerEPirate.Skills.Check.Luck. $+ %player1 1 30 EPirate.Skills.Check %player1 Luck
    if ($EPirate.Pirate.Rank(%player2) != 1st) && (!$EPirate.Party) hinc EPirate.Games played. $+ %player2
  }
  .timer 1 $calc(%loop * 4 + %loop) EPirate.Achievement %player2 Drunk
  unset %EPirate.Drink.*
  if ($hget(EPirate.Players.Skills,%player2 $+ .learning) == Luck) .timerEPirate.Skills.Check.Luck. $+ %player2 1 30 EPirate.Skills.Check %player2 Luck
}
alias EPirate.Random.Drink {
  var %random $rand(1,7)
  if (%random == 1) return grog
  elseif (%random == 2) return mead
  elseif (%random == 3) return brandy
  elseif (%random == 4) return wine
  elseif (%random == 5) return rumfustian
  else return rum
}




alias EPirate.Blackjack.Bot.Start {
  ;/EPirate.Blackjack.Bot.Start - bot starts a game o' BJ
  if (!$epirate.bot) || ($EPirate.Special.Event) || ($timer(EPirate.BlackJack.Start1)) return
  set %EPirate.BlackJack.Player1 $epirate.bot
  var %sum $epirate.player.percentage($hget(epirate.options,captain),0.1)
  if (!%sum) || (%sum < 10) set %sum $rand(10,1000)
  set %EPirate.BlackJack.Wager %sum
  .timerEPirate.BlackJack.Start1 1 90 EPirate.BlackJack.Start1
  EPirate.Public.MSG $epirate.bot just started up a game o' BlackJack witha buy-in of12 $EPirate.Round(%EPirate.Blackjack.Wager) $iif($hget(epirate.games,blackjack.pot),n' wit' a pot o' $epirate.round($hget(epirate.games,blackjack.pot)) doubloons!,doubloons.) Join by typin' !Pirates Blackjack Join within the next minute. Up to 6 pirates fer loads o' doubloons!
}
alias EPirate.BlackJack.Start1 {
  .timerEPirate.BlackJack.Start1 off
  if (!%EPirate.BlackJack.Wager) EPirate.WARNING.ECHO No EPirate.BlackJack.Wager
  elseif (!%EPirate.BlackJack.Player1) EPirate.WARNING.ECHO No EPirate.BlackJack.Player1
  elseif (!%EPirate.BlackJack.Player2) {
    EPirate.Notice %EPirate.BlackJack.Player1 Blackjack has timed out without any other players.
    unset %EPirate.Blackjack.*
  }
  else EPirate.BlackJack.Start %EPirate.BlackJack.Wager %EPirate.BlackJack.Player1 %EPirate.BlackJack.Player2 %EPirate.BlackJack.Player3 %EPirate.BlackJack.Player4 %EPirate.BlackJack.Player5 %EPirate.BlackJack.Player6
}
alias epirate.blackjack.draw.card {
  ;$epirate.blackjack.draw.card - loads card list in table, gets a card, and removes from list
  var %card, %error, %r, %i 0
  if (!$hget(EPirate.BJ.Cards)) {
    hmake EPirate.BJ.Cards
    hload -n EPirate.BJ.Cards $Epirate.Dir(cards.txt)
  }
  set %r $rand(1,$hget(EPirate.BJ.Cards,0).data)
  set %card $hget(EPirate.BJ.Cards,%r).data

  ;if ($rand(1,2) == 1) set %card Ace of Spades
  ;iecho card: %card

  while (!%card) {
    inc %i
    set %card $hget(EPirate.BJ.Cards,%r).data
    if (%i > 52) {
      set %error could not find a card after %i attempts!
      set %card $read($Epirate.Dir(cards.txt))
      break
    }
  }

  if (%card) hdel EPirate.BJ.Cards $hget(EPirate.BJ.Cards,%r).item
  else set %card $read($Epirate.Dir(cards.txt))

  if (%error) EPirate.Error.ECHO epirate.blackjack.draw.card: %error 
  return %card
}
alias EPirate.BlackJack.Start {
  ;/EPirate.BlackJack <wager> <player1> <player2...>
  ;verify players are pirates in the ontext
  ;limited to 5 players

  if (!$3) return
  var %file $epirate.save.dir(playerdata.dat)
  var %time 60, %player1 $2, %player2 $3, %player3 $4, %player4 $5, %player5 $6, %table EPirate.Blackjack, %players
  if ($hget(%table)) { EPirate.WARNING.ECHO %table already exists! | return }
  hmake %table
  hadd %table wager $1
  hadd %table players $2-

  if ($hget(EPirate.Players.Skills,%player1 $+ .learning) == Luck) EPirate.Skills.Check %player1 Luck
  var %player1.card1 $epirate.blackjack.draw.card, %player1.card2 $epirate.blackjack.draw.card
  set %players $addtok(%players,%player1,44)
  hadd %table time $ctime
  hadd %table %player1
  hadd %table %player1 $+ .card1 %player1.card1
  hadd %table %player1 $+ .card2 %player1.card2
  if (%player1 == $epirate.bot) {
    if ($EPirate.BlackJack.Check($epirate.bot) >= 17) hadd %table $epirate.bot $+ .status stay
    else hadd %table $epirate.bot $+ .status hit
    .timer 1 3 epirate.public.msg $epirate.bot $hget(%table,$epirate.bot $+ .status) $+ s...
    hinc %table responded
  }
  else {
    hadd %table %player1 $+ .status waiting
    if ($EPirate.Pirate.Rank(%player1) != 1st) && (!$EPirate.Party) && (%player1 != $epirate.bot) hinc EPirate.Games played. $+ %player1
    EPirate.Notice %player1 Ye 'ave been dealt 12 %player1.card1 and12 %player1.card2 $+ . 12Ye have %time seconds to respond (I do not see if ye hit or stay until I respond)!
  }

  if ($hget(EPirate.Players.Skills,%player2 $+ .learning) == Luck) EPirate.Skills.Check %player2 Luck
  var %player2.card1 $epirate.blackjack.draw.card, %player2.card2 $epirate.blackjack.draw.card
  set %players $addtok(%players,%player2,44)
  hadd %table %player2
  hadd %table %player2 $+ .card1 %player2.card1
  hadd %table %player2 $+ .card2 %player2.card2
  hadd %table %player2 $+ .status waiting
  hinc %table wager $1
  if ($EPirate.Pirate.Rank(%player2) != 1st) && (!$EPirate.Party) && (%player1 != $epirate.bot) hinc EPirate.Games played. $+ %player2
  EPirate.Notice %player2 Ye 'ave been dealt 12 %player2.card1 and12 %player2.card2 $+ . 12Ye have %time seconds to respond (I do not see if ye hit or stay until I respond)!!

  if (%player3) {
    if ($hget(EPirate.Players.Skills,%player3 $+ .learning) == Luck) EPirate.Skills.Check %player3 Luck
    var %player3.card1 $epirate.blackjack.draw.card, %player3.card2 $epirate.blackjack.draw.card
    set %players $addtok(%players,%player3,44)
    hadd %table %player3
    hadd %table %player3 $+ .card1 %player3.card1
    hadd %table %player3 $+ .card2 %player3.card2
    hadd %table %player3 $+ .status waiting
    hinc %table wager $1
    if ($EPirate.Pirate.Rank(%player3) != 1st) && (!$EPirate.Party) && (%player1 != $epirate.bot) hinc EPirate.Games played. $+ %player3
    EPirate.Notice %player3 Ye 'ave been dealt 12 %player3.card1 and12 %player3.card2 $+ . 12Ye have %time seconds to respond (I do not see if ye hit or stay until I respond)!!!
  }
  if (%player4) {
    if ($hget(EPirate.Players.Skills,%player4 $+ .learning) == Luck) EPirate.Skills.Check %player4 Luck
    var %player4.card1 $epirate.blackjack.draw.card, %player4.card2 $epirate.blackjack.draw.card
    set %players $addtok(%players,%player4,44)
    hadd %table %player4
    hadd %table %player4 $+ .card1 %player4.card1
    hadd %table %player4 $+ .card2 %player4.card2
    hadd %table %player4 $+ .status waiting
    hinc %table wager $1
    if ($EPirate.Pirate.Rank(%player4) != 1st) && (!$EPirate.Party) && (%player1 != $epirate.bot) hinc EPirate.Games played. $+ %player4
    EPirate.Notice %player4 Ye 'ave been dealt 12 %player4.card1 and12 %player4.card2 $+ . 12Ye have %time seconds to respond (I do not see if ye hit or stay until I respond)!!!!
  }
  if (%player5) {
    if ($hget(EPirate.Players.Skills,%player5 $+ .learning) == Luck) EPirate.Skills.Check %player5 Luck
    var %player5.card1 $epirate.blackjack.draw.card, %player5.card2 $epirate.blackjack.draw.card
    set %players $addtok(%players,%player5,44)
    hadd %table %player5
    hadd %table %player5 $+ .card1 %player5.card1
    hadd %table %player5 $+ .card2 %player5.card2
    hadd %table %player5 $+ .status waiting
    hinc %table wager $1
    if ($EPirate.Pirate.Rank(%player5) != 1st) && (!$EPirate.Party) && (%player1 != $epirate.bot) hinc EPirate.Games played. $+ %player5
    EPirate.Notice %player5 Ye 'ave been dealt 12 %player5.card1 and12 %player5.card2 $+ . 12Ye have %time seconds to respond (I do not see if ye hit or stay until I respond)!!!!!
  }
  if (%player6) {
    if ($hget(EPirate.Players.Skills,%player6 $+ .learning) == Luck) EPirate.Skills.Check %player6 Luck
    var %player6.card1 $epirate.blackjack.draw.card, %player6.card2 $epirate.blackjack.draw.card
    set %players $addtok(%players,%player6,44)
    hadd %table %player6
    hadd %table %player6 $+ .card1 %player6.card1
    hadd %table %player6 $+ .card2 %player6.card2
    hadd %table %player6 $+ .status waiting
    hinc %table wager $1
    if ($EPirate.Pirate.Rank(%player6) != 1st) && (!$EPirate.Party) && (%player1 != $epirate.bot) hinc EPirate.Games played. $+ %player6
    EPirate.Notice %player6 Ye 'ave been dealt 12 %player6.card1 and12 %player6.card2 $+ . 12Ye have %time seconds to respond (I do not see if ye hit or stay until I respond)!!!!!!
  }
  set %players $replace(%players,$chr(44),$chr(44) $chr(32))
  .timer 1 2 EPirate.Public.MSG %players 'ave been dealt th' first two cards. Players 'ave %time seconds to !Pirates Blackjack Hit or !Pirates Blackjack Stay
  .timerEPirate.BlackJack.Waiting 0 $calc(%time + 6) EPirate.BlackJack.Next
}
alias BJ.debug {
  return
  if ($1) {
    if (!$window(@Blackjack)) window -n1e3 @Blackjack
    aline -p @Blackjack $time $+ : $1-
  }
}
alias EPirate.BlackJack.Next {
  ;checks all players status. if their status. if hit or stay. if still waiting set to stay.
  ;.timerEPirate.BlackJack.Waiting off
  .timerEPirate.BlackJack.Waiting 0 66 EPirate.BlackJack.Next
  var %table EPirate.Blackjack
  hdel %table responded
  var %stays 0, %players $gettok($hget(%table,players),0,32)
  BJ.debug Players: %players
  var %players.left, %still.playing, %loop 0
  while (%players > %loop) {
    inc %loop
    if (%loop > $epirate.max.loops) break
    var %player $gettok($hget(%table,players),%loop,32)
    if (!$hget(%table,%player $+ .status)) hadd %table players $remtok($hget(%table,players),%player,32)
    var %status $hget(%table,%player $+ .status)
    if (%status == blackjack) || (%status == waiting) || (%status == stay) {
      inc %stays
      if (%status != waiting) hinc %table responded
      ;if player does not respond. have it stay
      if (%status == waiting) {
        EPirate.Notice %player Ye be set to Stay since ye did not respond.
        hadd %table %player $+ .status stay
      }
    }
    elseif (%status == hit) {
      ;var %check $EPirate.BlackJack.Bust.Check(%player)
      var %check $EPirate.BlackJack.Check(%player)
      if (%check == bust) inc %stays
      elseif (%check == blackjack) inc %stays
      else {
        hadd %table %player $+ .status waiting
        set %still.playing %still.playing %player
      }
    }
    elseif (%status == bust) { inc %stays | hinc %table responded }
  }
  if (%stays == %players) {
    ;-------- everyone stays, so end the game
    .timerEPirate.BJ.Cards.Dealt off
    var %players $gettok($hget(%table,players),0,32), %blackjacks, %wager $hget(%table,wager), %loop 0, %msg
    while (%players > %loop) {
      inc %loop
      var %player $gettok($hget(%table,players),%loop,32)
      var %total $EPirate.BlackJack.Check(%player)
      hadd %table %player %total
      if (%total == blackjack) set %blackjacks $addtok(%blackjacks,%player,44)
    }
    if ($hget(epirate.games,blackjack.pot)) {
      ;debug blackjack.pot winner: %wager : $hget(epirate.games,blackjack.pot)
      inc %wager $hget(epirate.games,blackjack.pot)
      hdel epirate.games blackjack.pot
      hdel epirate.games blackjack.num
    }
    var %loop 0, %total $gettok(%blackjacks,0,44)
    var %payout $calc(%wager / %total)
    while (%total > %loop) {
      inc %loop
      var %payee $gettok(%blackjacks,%loop,44)
      if (%payee == $epirate.bot) continue
      set %payout $calc(%payout * 1)
      if (%payee) {
        if (%payee != $epirate.bot) && (%payout > $epirate.player.percentage(%payee,$EPirate.Max.Percentage.Bonus)) {
          set %payout $v2
          .timer 1 15 epirate.notice %payee Ye payout be reduced due to tariffs!
        }

        EPirate.Pay %payee %payout games
      }
      hinc EPirate.Stats %player $+ .blackjack.wins
    }
    set %blackjacks $replace(%blackjacks,$chr(44),$chr(44) $chr(32))

    if (!%total) {
      ;------ NO one got blackjack. time to see who won! --------
      .timerEPirate.BJ.Cards.Dealt off
      var %scores, %loop 0
      while ($gettok($hget(%table,players),0,32) > %loop) {
        inc %loop
        var %player $gettok($hget(%table,players),%loop,32)
        var %score $EPirate.BlackJack.Check(%player)
        if (%score isnum) {
          if (or isin %score) set %score $gettok(%score,2,32)
          set %scores $addtok(%scores,%score,44)
        }
      }
      var %player.winners, %total 0, %break 0, %highscore 0
      set %scores $sorttok(%scores,44,nr)
      var %loop 0
      while ($gettok(%scores,0,44) > %loop) {
        if (%break) break
        inc %loop
        var %findscore $gettok(%scores,%loop,44)
        set %highscore %findscore
        set %total $hfind(EPirate.blackjack,%findscore,0,W).data
        if ($hget(epirate.games,blackjack.pot)) {
          inc %wager $hget(epirate.games,blackjack.pot)
          hdel epirate.games blackjack.pot
          hdel epirate.games blackjack.num
        }
        var %payout $calc(%wager / %total)
        var %loop2 0
        while (%total > %loop2) {
          inc %loop2
          var %winner $hfind(EPirate.blackjack,%findscore,%loop2,W).data
          if (%winner != wager) set %player.winners $addtok(%player.winners,%winner,32)
          if (%winner == $epirate.bot) continue
          hinc %table %winner %payout
          if (%winner) {
            if (%payout > $epirate.player.percentage(%winner,$EPirate.Max.Percentage.Bonus)) {
              set %payout $v2
              .timer 1 15 epirate.notice %winner Ye payout be reduced due to the Captain's "tax"!
            }
            epirate.pay %winner %payout games
            hinc EPirate.Stats %winner $+ .blackjack.wins
          }
          if (%total == %loop2 ) { inc %break | break }
        }
      }
      var %msg, %delay 5
      if ($gettok(%player.winners,0,32) > 1) {
        .timer 1 %delay EPirate.Public.MSG $replace(%player.winners,$chr(32),$chr(44) $chr(32)) had the highest cards $paren(%highscore) 'n split the pot, each earning $EPirate.Round(%payout) doubloons!
        set %msg $replace(%player.winners,$chr(32),$chr(44) $chr(32)) had the highest cards $paren(%highscore) 'n split the pot, each earning $EPirate.Round(%payout) doubloons!
        BJ.debug ----------------- %player.winners : %highscore --------------------
      }
      elseif (%total == 1) {
        .timer 1 %delay EPirate.Public.MSG %player.winners had the highest cards $paren(%highscore) 'n wins $EPirate.Round(%payout) doubloons!
        set %msg %player.winners had the highest cards $paren(%highscore) 'n wins $EPirate.Round(%payout) doubloons!
        BJ.debug ----------------- %player.winners : %highscore --------------------
      }
      else {
        BJ.debug ----------------- no winners --------------------
        .timer 1 %delay EPirate.Public.MSG No one won the round. $EPirate.Round(%wager) doubloons has been added to the pot fer the next game.
        if ($hget(epirate.games,blackjack.pot)) {
          inc %wager $hget(epirate.games,blackjack.pot)
          debug blackjack.pot no winner: %wager : $hget(epirate.games,blackjack.pot)
        }
        hadd epirate.games blackjack.pot %wager
        hinc epirate.games blackjack.num
        set %msg It be a draw! $EPirate.Round(%wager) doubloons has been added to the pot fer the next hand.
      }
    }
    elseif (%total > 1) {
      .timer 1 5 EPirate.Public.MSG %blackjacks got Blackjack 'n split the pot, each earning $EPirate.Round(%payout) doubloons!
      set %msg %blackjacks got Blackjack 'n split the pot, each earning $EPirate.Round(%payout) doubloons!
    }
    else {
      set %msg %blackjacks got Blackjack 'n won $EPirate.Round(%payout) doubloons!
      .timer 1 5 EPirate.Public.MSG %blackjacks got Blackjack 'n won $EPirate.Round(%payout) doubloons!
    }

    ;notice all players of BJ the results
    if (%msg) {
      var %loop 0
      while ($gettok($hget(%table,players),0,32) > %loop) {
        inc %loop
        inc %delay
        var %player $gettok($hget(%table,players),%loop,32)
        .timer 1 %delay epirate.notice %player %msg
      }
    }



    if ($hget(%table)) hfree %table
    if ($hget(EPirate.BJ.Cards)) hfree EPirate.BJ.Cards
    unset %EPirate.BlackJack*
    .timerEPirate.Blackjack* off
  }
  else {
    ;still have someone that wants a hit, continue game
    var %loop 0
    while ($gettok(%still.playing,0,32) > %loop) {
      inc %loop
      var %player $gettok(%still.playing,%loop,32), %card $EPirate.BlackJack.GetCard, %cards
      var %num $calc(1 + $hfind(EPirate.blackjack,%player $+ .card?,0,w))
      hadd %table %player $+ .card $+ %num %card
      var %loop2 0
      while ($hfind(EPirate.blackjack,%player $+ .card?,0,w) > %loop2) {
        inc %loop2
        set %cards $addtok(%cards,$hget(%table,$hfind(EPirate.blackjack,%player $+ .card?,%loop2,w)),44)
      }
      set %cards $replace(%cards,$chr(44),$chr(44) $chr(32))
      var %time 60
      if (%player == $epirate.bot) {
        ;bot hits or stays
        if ($EPirate.BlackJack.Check($epirate.bot) >= 17) hadd %table $epirate.bot $+ .status stay
        else hadd %table $epirate.bot $+ .status hit
        .timer 1 5 epirate.public.msg $epirate.bot $hget(%table,$epirate.bot $+ .status) $+ s...
        hinc %table responded
        if ($hget(%table,responded) >= $gettok($hget(%table,players),0,32)) .timerEPirate.BlackJack.Waiting 1 3 EPirate.BlackJack.Next
      }
      else EPirate.Notice %player Ye cards now be:12 %cards n' ye have %time seconds!
      ;iecho BJ.debug %player Cards: %cards : $EPirate.BlackJack.Check(%player)

      ;check is player busted
      if (bust isin $EPirate.BlackJack.Check(%player)) {
        hadd %table %player $+ .status bust
        ;set %still.playing $remtok(%still.playing,%player,1,32)
        .timer 1 1 EPirate.Notice %player Ye cards now be:12 %cards n' 4ye busted! Don't tell other pirates so ye 'ave a chance o' gettin' a draw.
        inc %stays
        hinc %table responded
      }
      elseif ($EPirate.BlackJack.Check(%player) == blackjack) {
        hadd %table %player $+ .status blackjack
        ;set %still.playing $remtok(%still.playing,%player,1,32)
        .timer 1 1 EPirate.Notice %player Ye cards now be:12 %cards n' 12ye have BLACKJACK! Don't tell the other pirates.
        inc %stays
        hinc %table responded
      }
    }
    if (%stays >= %still.playing) { set %still.playing 1 | break }
    if (%still.playing) .timerEPirate.BJ.Cards.Dealt 1 3 EPirate.Public.MSG Players 'ave been dealt th' next cards n' 'ave %time seconds to !Pirates Blackjack Hit or !Pirates Blackjack Stay
    else {
      .timerEPirate.BlackJack.Waiting 0 $calc(%time + 6) EPirate.BlackJack.Next
      .timer 1 1 EPirate.BlackJack.Next
    }
  }
}
alias EPirate.BlackJack.GetCard {
  var %loop 0
  while (%loop < 53) {
    inc %loop
    var %card $read($Epirate.Dir(cards.txt))
    if (!$hfind(EPirate.blackjack,%card,0).data) { return %card }
  }
  return %card
}
alias EPirate.BlackJack.Check {
  ;$EPirate.BlackJack.Check(<pirate>) - calculates player's card value 'n determines if bust, blackjack, or under has busted 'n be out.
  ;has BlackJack 'n won $EPirate.Round(%amount) doubloons!
  var %table EPirate.Blackjack, %player $1, %total 0, %total2 0, %value 0, %value2 0, %loop 0, %ace 0, %card
  while ($hfind(EPirate.blackjack,%player $+ .card?,0,w) > %loop) {
    inc %loop
    set %card $hget(%table,$hfind(EPirate.blackjack,%player $+ .card?,%loop,w))
    set %value $EPirate.BlackJack.Value(%card)
    if (Ace of isin %card) {
      inc %ace
      set %value 11
      ;set %value2 11
      ;iecho in ACE
    }
    ;else set %value2 %value
    inc %total %value
    ;inc %total2 %value2
    ;iecho  bj.debug %player - %card : %value : %value2 totals: %total : %total2
  }
  if (%ace) {
    if (%total > 21) dec %total $calc(10 * %ace)
  }
  ;iecho BJ.debug $1 total: %total
  if (%total == 21) return Blackjack
  ;elseif (%total2 == 21) return Blackjack
  elseif (%total > 21) return Bust
  else return %total
}
alias EPirate.BlackJack.Value {
  ;$EPirate.BlackJack.Value(card)
  var %a $gettok($1,1,32)
  if (%a == Ten) || (%a == King) || (%a == Queen) || (%a == Jack) || (%a == Ten) return 10
  elseif (%a == Nine) return 9
  elseif (%a == Eight) return 8
  elseif (%a == Seven) return 7
  elseif (%a == Six) return 6
  elseif (%a == Five) return 5
  elseif (%a == Four) return 4
  elseif (%a == Three) return 3
  elseif (%a == Two) return 2
  elseif (%a == Ace) return 1:11
}



--------------------------------------
;Bomb Minigame for Pirates by mruno
;-------------------------------------
;
;uses some code from http://hawkee.com/scripts/11648461/ (alias epirate.game.bomb.wires)
;
alias epirate.game.bomb.reward.doubloon.percentage return 4
alias epirate.game.bot.max.today return 4

on *:TEXT:!cut *:#: {
  if ($network == $epirate.network) && ($chan == %EPirate.Chan) {
    if ($nick == $hget(epirate.games,bomb.game.player)) {
      if ($EPirate.Jail($nick)) { epirate.notice $nick Sharp objects not be allowed in the brig! | return }
      epirate.game.bomb.command cut $nick $2
    }
  }
}



alias EPirate.Bot.Game.Bomb.Start {
  ;/EPirate.Bot.Game.Bomb.Start <player> - bot starts a game with player
  var %today 0
  if ($hget(epirate.daily,game.bomb.times. $+ $1)) inc %today $hget(epirate.daily,game.bomb.times. $+ $1)
  if ($epirate.bot) && ($epirate.isuser($1)) && (%today <= $epirate.game.bot.max.today) epirate.game.bomb.start $epirate.bot $1
}
alias epirate.game.bomb.command {
  ;/epirate.game.bomb.command <start or cut or help> <player> <player2 or wire color>
  if ($1 == start) epirate.game.bomb.start $2 $iif($3,$3,$2)
  elseif ($1 == cut) epirate.game.bomb.action $2 $3
  else epirate.game.bomb.help $iif($2,$2,$1)
}

alias epirate.game.bomb.start {
  ;/epirate.game.bomb.start <player who set up the bomb> <player to diffuse the bomb>
  var %player1 $1, %player2 $remove($2,<,>), %chan %EPirate.Chan
  if (!%player1) return
  if ($timer(Epirate.Defend.Action)) { epirate.notice %player1 Ye 'ave no time fer games! Defend the ship!!! | return }
  if (!%player2) { epirate.notice %Player1 Who do ye want to set up the bomb on? | return }
  if ($timer(Epirate.Game.Bomb)) { epirate.notice %player1 A bomb is already bein' diffused! | return }

  ;player checks
  if (!$epirate.isuser(%player2)) { epirate.notice %player1 %player2 not be a member o' the crew! | return }
  if ($EPirate.Jail(%player2)) { epirate.notice %player1 %player2 cannot play games from the brig! | return }
  if ($hget(EPirate.Games,played. $+ %player1) >= $Epirate.Games.Before.Bribe.Needed) {
    EPirate.Notice %player1 Th' Cap'n will catch ye if ye keep playin' those games 'n nah scrubbin' th' poop deck. Play later, ye blaggard!
    EPirate.Notice %player1 I may be able t' help ye play some more games. Type !Pirates store bribe
    return
  }
  if ($hget(EPirate.Games,played. $+ %player2) >= $Epirate.Games.Before.Bribe.Needed) {
    EPirate.Notice %player1 Th' Cap'n caught %PLAYER2 playin' games 'n be now scrubbin' th' poop deck. Try again later.
    EPirate.Notice %player2 I may be able t' help ye play some more games. Type !Pirates store bribe
    return
  }
  if (%player2 !ison %chan) && ($hget(epirate.away.nicks,%player2) !ison %chan) {
    EPirate.notice %player1 %player2 ain't onboard. $iif(%player2 ison %chan,%player2 needs to identify wit' nickserv.)
    if (%player2 ison %chan) {
      .timerEPirate.Verify.nick. $+ %player2 1 $calc($timer(0) + 10) EPirate.Verify.nick %player2
      EPirate.Notice %player2 %player1 tried to play a game wit' ye, but ye not identified wit' Nickserv. Identify / $+ $EPirate.Nickserv.Command identify <password> 'n then !Pirates identify
    }
    return
  }
  if ($hget(EPirate.Expenses.Today,%player2 $+ .games) > $epirate.player.percentage(%player2,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice %player1 %player2 has earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }

  if (%player1 != $epirate.bot) && ($hget(epirate.games,bomb.game.cooldown).unset > 1) { epirate.notice %player1 A bomb is still bein' constructed... | return }
  var %all.wires $epirate.game.bomb.wires
  var %num $gettok(%all.wires,1,94), %wires $gettok(%all.wires,2,94), %duds $gettok(%all.wires,3,94), %diffuse $gettok(%all.wires,4,94)
  hdel -w epirate.games bomb.game.*
  hadd epirate.games bomb.game.num %num
  hadd epirate.games bomb.game.wires %wires
  hadd epirate.games bomb.game.duds %duds
  hadd epirate.games bomb.game.diffuse %diffuse
  hadd epirate.games bomb.game.player %player2

  var %msg, %r $rand(1,3), %delay 60
  inc %delay $calc(%num * 7)
  if (%player1 == %player2) {
    if ($epirate.spam) {
      epirate.notice %player2 The bomb has %num wires n' they be: %wires
      epirate.notice %player2 Ye have $duration(%delay) to diffuse the bomb! Use !Pirates Cut <color>
    }
    else epirate.public.msg $epirate.nick(%player2) %player2 has $duration(%delay) to diffuse a bomb wit' %num wires...
  }
  else {
    if (%r == 1) set %msg %player1 has set up the bomb on %player2 $+ !
    elseif (%r == 2) set %msg %player1 sticks a bomb in %player2 $+ 's britches!
    else set %msg %player1 challenges %player2 to a game o' blow up ye fellow pirate wit' a bomb!
    set %msg %msg The bomb has %num wires n' %player2 has $duration(%delay) to diffuse it!
  }

  .timerEpirate.Game.Bomb 1 %delay epirate.game.bomb.end timeout
  hadd epirate.games bomb.game.player1 %player1
  hadd epirate.games bomb.game.player2 %player2

  if (%msg) epirate.public.msg %msg
  epirate.notice %player2 The bomb has %num wires n' they be: %wires
  .timer 1 2 epirate.notice %player2 Ye have $duration(%delay) to diffuse the bomb! Use !Pirates Cut <color>

}
alias epirate.game.bomb.action {
  ;/epirate.game.bomb.action <player> <color> - player cuts or pulls wire to diffuse bomb
  if (!$timer(Epirate.Game.Bomb)) { epirate.notice $1 Thar be no bomb to diffuse! | return }

  var %player $1, %wire $strip($remove($2,<,>)), %wires $hget(EPirate.Games,bomb.game.wires)
  set %wires $strip($remove(%wires,$chr(32)))
  var %cmd $iif($epirate.spam,epirate.notice %player,epirate.public.msg), %time $duration($timer(Epirate.Game.Bomb).secs) left!
  if (!%player) return
  if (!%wire) { epirate.notice %player What wire do ye want to cut? %wires Ye 'ave %time | return }
  elseif (!$findtok(%wires,%wire,44)) { %cmd That not be a wire ye can cut! %time | return }
  elseif ($findtok($hget(epirate.games,bomb.game.alreadycut),%wire,44)) { %cmd $epirate.capitalize(%wire) already be cut! %time | return }
  elseif ($findtok($hget(EPirate.Games,bomb.game.duds),%wire,32)) {
    hadd epirate.games bomb.game.alreadycut $addtok($hget(epirate.games,bomb.game.alreadycut),%wire,44)
    var %odds $rand(1,100)
    if (%odds < 30) {
      set %time $round($calc($timer(Epirate.Game.Bomb).secs / $+(1.,$rand(1,7))),0)
      .timerEpirate.Game.Bomb 1 %time epirate.game.bomb.end timeout
      %cmd $epirate.capitalize(%wire) has increased the countdown! $duration(%time) left!
    }
    else %cmd Cuttin' %wire has no effect! %time
  }
  elseif ($findtok($hget(EPirate.Games,bomb.game.diffuse),%wire,44)) { epirate.game.bomb.end win %wire | return }
  else {
    ;all other wires will blow the bomb
    epirate.game.bomb.end fail %wire
  }
}
alias epirate.game.bomb.end {
  ;/epirate.game.bomb.end <timeout,fail,win> - ends the bomb game. if player did action and bomb timeout then that is same as fail
  .timerEpirate.Game.Bomb off
  var %msg, %player1 $hget(epirate.games,bomb.game.player1), %player2 $hget(epirate.games,bomb.game.player2), %fail 0, %win 0, %reward, %timeout 0
  var %today $hget(epirate.daily,game.bomb.times. $+ %player2)
  if ($1 == win) {
    inc %win
    set %msg $epirate.nick(%player2) %player2 diffuses %player1 $+ 's bomb effortlessly!
    if (%today > $epirate.game.bot.max.today) {
      ;reward is doubloons divided by how many times player has played bomb today
      var %sum $epirate.player.percentage(%player2,$epirate.game.bomb.reward.doubloon.percentage), %max $calc($EPirate.Max.Percentage.Bonus / 3)
      set %sum $calc(%sum / %today)
      if (%sum > $epirate.player.percentage(%player2,%max)) set %sum $v2
      set %reward $epirate.round(%sum) doubloons
      epirate.pay %player2 %sum games
    }
    else {
      var %r $rand(1,3)
      if (%r == 1) {
        ;win duelin' power
        var %power $rand(1,2)
        hinc EPirate.Duels duel.bonus. $+ %player2 %power
        set %reward + $+ %power power
      }
      elseif (%r == 2) {
        ;win stamina
        var %stamina $rand(2,4)
        hdec epirate.stamina %player2 %stamina
        set %reward + $+ %stamina stamina
      }
      else {
        var %sum $epirate.player.percentage(%player2,$epirate.game.bomb.reward.doubloon.percentage), %max $calc($EPirate.Max.Percentage.Bonus / 3)
        if (%sum > $epirate.player.percentage(%player2,%max)) set %sum $v2
        set %reward $epirate.round(%sum) doubloons
        epirate.pay %player2 %sum games
      }
    }
  }
  elseif ($1 == fail) {
    inc %fail
    set %msg $epirate.nick(%player2) %player2 is blown to bits by %player1 $+ 's bomb!
    var %r $rand(1,3)
    if (%r == 1) {
      ;lose duelin' power
      var %power $rand(1,2)
      hdec EPirate.Duels duel.bonus. $+ %player2 %power
      set %reward - $+ %power power
    }
    elseif (%r == 2) {
      ;lose stamina
      var %stamina $rand(2,4)
      hinc epirate.stamina %player2 %stamina
      set %reward - $+ %stamina stamina
    }
    else {
      var %sum $epirate.player.percentage(%player2,$epirate.game.bomb.reward.doubloon.percentage), %max $calc($EPirate.Max.Percentage.Bonus / 3)
      if (%sum > $epirate.player.percentage(%player2,%max)) set %sum $v2
      epirate.pay %player2 - $+ %sum games
      set %reward - $+ $epirate.round(%sum) doubloons
    }

  }
  else {
    ;timeout
    if ($hget(epirate.games,bomb.game.alreadycut)) {
      ;player2 cut wires but ran out of time
      inc %fail
      set %msg $epirate.nick(%player2) %player2 falls asleep n' the bomb from %player1 explodes!
    }
    else {
      ;player2 never played
      if (!%player1) return
      if (%player1 == %player2) epirate.notice %player1 The bomb timed out!
      else {
        if ($epirate.spam) epirate.notice %player1 Ye bomb fer %player2 timed out!
        else set %msg $epirate.nick(%player2) %player2 be too busy to play %player1 $+ 's lame games...
      }
    }

  }
  hdel -w epirate.games bomb.game.*
  hadd -u90 epirate.games bomb.game.cooldown 1

  if (%msg) {
    if (%win) {
      hinc epirate.stats %player2 $+ .Game.Bomb.Win
      var %total $calc($hget(epirate.stats,%player2 $+ .Game.Bomb.Win) + $hget(epirate.stats,%player2 $+ .Game.Bomb.Lose))
      set %msg %msg %player2 be awarded %reward fer $epirate.hisorher(%player2) $ord($hget(epirate.stats,%player2 $+ .Game.Bomb.Win)) bomb diffusal out o' %total $+ !
    }
    elseif (%fail) {
      hinc epirate.stats %player2 $+ .Game.Bomb.Lose
      var %total $calc($hget(epirate.stats,%player2 $+ .Game.Bomb.Win) + $hget(epirate.stats,%player2 $+ .Game.Bomb.Lose))
      set %msg %msg %player2 be awarded %reward n' has blown up $hget(epirate.stats,%player2 $+ .Game.Bomb.Lose) out o' %total bombs!
    }
    epirate.public.msg %msg
  }

  if (%win) || (%fail) {
    hinc epirate.daily game.bomb.times. $+ %player2
    hinc epirate.stats %player2 $+ .Game.Bomb.Times
    hinc EPirate.Stats ship.games
    if ($hget(EPirate.Players.Skills,%player2 $+ .learning) == Luck) .timerEPirate.Skills.Check.Luck. $+ %player2 1 30 EPirate.Skills.Check %player2 Luck
    if ($EPirate.Pirate.Rank(%player2) != 1st) && (!$EPirate.Party) hinc EPirate.Games played. $+ %player2
  }
}

alias epirate.game.bomb.help {
  ;/epirate.game.bomb.help <pirate> - notices the player the help
  var %player $1
  if (%player) {
    epirate.notice %player Give someone the gift o' carin' with !Pirates Bomb <pirate> or yourself wit' !Pirates Bomb Start
    .timer 1 3 epirate.notice %player The pirate will be notified of the colors of wires n' must !Pirates Cut <color> to diffuse the bomb. Careful, some wires will instantly trigger the bomb or decrease the countdown.
    .timer 1 6 epirate.notice %player A player that successfully diffuses a bomb will be rewarded n' a failure will be punished.
  }
}
alias epirate.game.bomb.wires {
  ;$epirate.game.bomb.wires - returns wire colors.
  ;number of colors is $gettok(wires,1,94)
  ;colors in $gettok(wires,2,94) are the choices
  ;colors in $gettok(wires,3,94) are the dud wires (no effect)
  ;color in $gettok(wires,4,94) is diffuse wire

  ;Colors
  var %Bomb.WireColors = 4Red,3Green,2Blue,10Teal,7Orange,8Yellow,5Brown,6Purple,1Black,15White,13Pink,14Gray
  ;Number o' Wires
  var %Bomb.Wires = $r(3,$numtok(%Bomb.WireColors,44))
  ;Wires to choose from.
  var %Bomb.Temp.Inc = 0
  var %Bomb.Temp.Wires = %Bomb.WireColors
  while (%Bomb.Temp.Inc < %Bomb.Wires) {
    var %Bomb.Temp.Tok = $r(1,$numtok(%Bomb.Temp.Wires,44))
    var %Bomb.CutWires = $iif(%Bomb.CutWires,$+(%Bomb.CutWires,$chr(44))) $gettok(%Bomb.Temp.Wires,%Bomb.Temp.Tok,44)
    var %Bomb.Temp.Wires = $deltok(%Bomb.Temp.Wires,%Bomb.Temp.Tok,44)
    inc %Bomb.Temp.Inc
  }
  ;Set the Bombs Diffuse Wire
  var %Bomb.DiffuseWire $remove($strip($gettok(%Bomb.CutWires,$r(1,$numtok(%Bomb.CutWires,32)),32)),$chr(44))
  ;%Bomb.DudWires %Bomb.DiffuseWire %Bomb.CWires
  ;Set The wires that won't trigger the bomb.
  IF ($numtok(%Bomb.CutWires,32) > 2) {
    var %Bomb.DudWires.N = $int($calc($numtok(%Bomb.CutWires,32) * .5))
    var %Bomb.DudWires
    var %Bomb.DudWires.Temp = %Bomb.CutWires
    var %Bomb.DudWires.Temp2 = $remove($strip(%Bomb.CutWires),$chr(44))
    var %Bomb.DudWires.Temp = $deltok(%Bomb.DudWires.Temp2,$findtok(%Bomb.DudWires.Temp2,%Bomb.DiffuseWire,32),32)
    var %Bomb.BlowWire 
    while (%Bomb.DudWires.N > $numtok(%Bomb.DudWires,32)) {
      var %Bomb.DudWires.Temp.Tok = $r(1,$numtok(%Bomb.DudWires.Temp,32))
      %Bomb.DudWires = %Bomb.DudWires $gettok(%Bomb.DudWires.Temp,%Bomb.DudWires.Temp.Tok,32)
      var %Bomb.DudWires.Temp = $deltok(%Bomb.DudWires.Temp,%Bomb.DudWires.Temp.Tok,32)
    }
  }
  ;%Bomb.DudWires
  return $+(%Bomb.Wires,^,%Bomb.CutWires,^,%Bomb.DudWires,^,%Bomb.DiffuseWire)
}
;----------------- end bomb minigame
