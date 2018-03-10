;PiratesIRC minigame
;
; [AMS] :: Anchor Map Sword (AMSsm) -AKA- Rock Paper Scissors shark mruno
; Sat Feb 25 18:38:13 2017 EST

on :load: { ams-reset }
on :start: { ams-reset }
on :exit: { unset %ams-* }

alias ams-reset {
  unset %ams-*
  set %ams-status idle
  .timerams.* off
}
alias amsl { return $lower($1-) }
alias amsm { epirate.public.msg $1- }
alias amsb { return  $+ $1- $+  }
alias ams-logo { return $amsb([AMSSM]) $+  }

alias EPirate.AMS.Installed return $true

;This ON TEXT is located in the PIRATES EVENTS FILE
;on *:text:!p*:#: {
;  if ($chr(37) isin $1-) || ($chr(36) isin $1-) || ($chan != %EPirate.Chan) || ($EPirate.network !isin $network) return
;  if ($1 == !p) || ($1 == !pirate) || ($1 == !pirates) {
;    if $2 == ams epirate.ams $nick $2-
;  }
;}

on *:text:!p*:?: {
  ;privmsg protection
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) || ($EPirate.network !isin $network) return

  if ($1 == !p) || ($1 == !pirate) || ($1 == !pirates) {
    if $2 == ams || $2 == amssm {

      if ($EPirate.Jail($nick)) { epirate.notice $nick Thar be no fun allowed in the brig! | return }

      var %chan $EPirate.Chan
      ;if (!%ams-status) ams-reset

      if $3 {
        var %start 0
        ;%start is used to determine if game progress to finish
        if %ams-status == inprogress {
          .timer 1 0 set -u90 %ams-status pending
          inc %start
        }
        elseif (%ams-status == pending) {
          if ($nick == %ams-p1) {
            ;lets player1 choose selection before player2 accepts
            inc %start
          }
          elseif ($nick == %ams-p2) {
            ;deducts wagers from players
            if (%ams-p2 != $epirate.bot) epirate.pay %ams-p2 - $+ %ams-wager games
            epirate.pay %ams-p1 - $+ %ams-wager games

            ;lets player2 skip the "!P AMS Accept" trigger
            inc %start
          }
        }
        else { .timerepirate.ams. $+ $nick 1 3 epirate.personal.msg $nick Thar not be a game bein' played! Start one by typing !Pirates AMSSM in %chan | return }
        if (%start) {
          if %ams-p1 ison %chan && %ams-p1 ison %chan {
            if $nick == %ams-p1 {
              if $amsl($3) == $amsl(Anchor) || $amsl($3) == $amsl(Map) || $amsl($3) == $amsl(Sword) || $amsl($3) == $amsl(Shark) || $amsl($3) == $amsl(Mruno) {
                set %ams-p1-answer $remove($amsl($3),<,>)
                hinc EPirate.stats $+(%ams-p1,.AMS.Plays)
                hinc EPirate.stats $+(%ams-p1,.AMS.Selection.,%ams-p1-answer)
                if (!$epirate.reduce.spam) epirate.public.msg $ams-logo $amsb(%ams-p1) has given $epirate.hisorher($nick) answer...
                if %ams-p2-answer {
                  if %ams-p1-answer == anchor {
                    if %ams-p2-answer == anchor { set %ams-winner Cat }
                    if %ams-p2-answer == map { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == sword { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == shark { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == mruno { set %ams-winner %ams-p2 }
                    ams-announcewinner
                    halt
                  }
                  if %ams-p1-answer == map {
                    if %ams-p2-answer == anchor { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == map { set %ams-winner Cat }
                    if %ams-p2-answer == sword { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == shark { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == mruno { set %ams-winner %ams-p1 }
                    ams-announcewinner
                    halt
                  }
                  if %ams-p1-answer == shark {
                    if %ams-p2-answer == anchor { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == map { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == sword { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == shark { set %ams-winner Cat }
                    if %ams-p2-answer == mruno { set %ams-winner %ams-p1 }
                    ams-announcewinner
                    halt
                  }
                  if %ams-p1-answer == sword {
                    if %ams-p2-answer == anchor { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == map { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == sword { set %ams-winner Cat }
                    if %ams-p2-answer == shark { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == mruno { set %ams-winner %ams-p2 }
                    ams-announcewinner
                    return
                  }
                  if %ams-p1-answer == mruno {
                    if %ams-p2-answer == anchor { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == map { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == sword { set %ams-winner %ams-p1 }
                    if %ams-p2-answer == shark { set %ams-winner %ams-p2 }
                    if %ams-p2-answer == mruno { set %ams-winner Cat }
                    ams-announcewinner
                    halt
                  }
                }
                elseif !%ams-p2-answer { epirate.notice %ams-p1 $ams-logo Waitin' fer $+($amsb(%ams-p2),'s) answer... }
              }
              else epirate.personal.msg $nick $ams-logo Choose one: Anchor, Map, Sword, Shark or Mruno. Use: /msg $me !Pirates AMSSM <selection> - Ex: /msg $me !Pirates AMSSM Sword
            }
            if $nick == %ams-p2 {
              if $amsl($3) == $amsl(Anchor) || $amsl($3) == $amsl(Map) || $amsl($3) == $amsl(Sword) || $amsl($3) == $amsl(Shark) || $amsl($3) == $amsl(Mruno) {
                set %ams-p2-answer $amsl($3)
                if (!$epirate.reduce.spam) epirate.public.msg $ams-logo $amsb(%ams-p2) has given $epirate.hisorher($nick) answer...
                if %ams-p1-answer {
                  if %ams-p2-answer == anchor {
                    if %ams-p1-answer == anchor { set %ams-winner Cat }
                    if %ams-p1-answer == map { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == sword { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == shark { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == mruno { set %ams-winner %ams-p1 }
                    ams-announcewinner
                    halt
                  }
                  if %ams-p2-answer == map {
                    if %ams-p1-answer == anchor { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == map { set %ams-winner Cat }
                    if %ams-p1-answer == sword { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == shark { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == mruno { set %ams-winner %ams-p2 }
                    ams-announcewinner
                    halt
                  }
                  if %ams-p2-answer == sword {
                    if %ams-p1-answer == anchor { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == map { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == sword { set %ams-winner Cat }
                    if %ams-p1-answer == shark { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == mruno { set %ams-winner %ams-p1 }
                    ams-announcewinner
                    halt
                  }
                  if %ams-p2-answer == shark {
                    if %ams-p1-answer == anchor { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == map { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == sword { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == shark { set %ams-winner Cat }
                    if %ams-p1-answer == mruno { set %ams-winner %ams-p2 }
                    ams-announcewinner
                    halt
                  }
                  if %ams-p2-answer == mruno {
                    if %ams-p1-answer == anchor { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == map { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == sword { set %ams-winner %ams-p2 }
                    if %ams-p1-answer == shark { set %ams-winner %ams-p1 }
                    if %ams-p1-answer == mruno { set %ams-winner Cat }
                    ams-announcewinner
                    halt
                  }
                }
                elseif !%ams-p1-answer {
                  epirate.notice %ams-p2 Waitin' fer $+($amsb(%ams-p1),'s) answer...
                  epirate.notice %ams-p1 It be yer turn! Anchor, Map, Sword, Shark, or Mruno. Use: /msg $me !Pirates AMSSM <selection> - Ex: /msg $me !Pirates AMSSM Map
                }
              }
              else epirate.personal.msg $nick $ams-logo Choose one: Anchor, Map, Sword, Shark or Mruno. Use: /msg $me !Pirates AMSSM <selection> - Ex: /msg $me !Pirates AMSSM Map
            }
          }
        }
      }
    }
  }
}
alias EPirate.Bot.Game.AMS.Start {
  ;/EPirate.Bot.Game.AMS.Start <player> - bot start a game of AMS with the player
  if (!$epirate.bot) || ($EPirate.Special.Event) || ($timer(EPirate.BlackJack.Start1)) return
  if (%ams-status) && (%ams-status != idle) return
  var %player $1
  if ($epirate.isuser(%player)) {
    var %wager $epirate.player.percentage(%player,$calc($rand(5,50) / 100))
    if (%wager isnum) EPirate.AMS.Start $epirate.bot AMS %player %wager
  }
}
alias epirate.ams.start {
  ;/epirate.ams.start <player1> AMS <player2> <wager> - starts up a game of AMS
  ;flood checks
  if ($timer(EPirate.Flood).secs) { EPirate.Flood.Check $1 | return }
  else .timerEPirate.Flood -m 1 1000 noop
  var %dll $EPirate.dir(dicelib.dll)

  ;player flood check
  EPirate.Flood.Check $1

  var %chan $EPirate.Chan

  if ($3 == stats) {
    var %player $iif($4,$4,$1)
    var %games $hget(EPirate.stats,$+(%player,.AMS.Plays)), %notice 
    if (%games) {
      if ($1 != $epirate.bot) epirate.notice $1 %player has played AMSSM %games times n' has the followin' tendencies: Anchor $epirate.percentage($hget(EPirate.stats,$+(%player,.AMS.Selection.Anchor)),%games) $+ $chr(37) Map $epirate.percentage($hget(EPirate.stats,$+(%player,.AMS.Selection.Map)),%games) $+ $chr(37) Sword $epirate.percentage($hget(EPirate.stats,$+(%player,.AMS.Selection.Sword)),%games) $+ $chr(37) Shark $epirate.percentage($hget(EPirate.stats,$+(%player,.AMS.Selection.Shark)),%games) $+ $chr(37) Mruno $epirate.percentage($hget(EPirate.stats,$+(%player,.AMS.Selection.Mruno)),%games) $+ $chr(37) 
    }
    else epirate.notice $1 %player has never played AMS!
    return
  }

  if (!%ams-status) ams-reset

  ;checks if player is specified and onboard
  if (!$3) ams-help $1
  if $3 {
    ;ams cooldown
    if ($timer(EPirate.AMS.Cooldown)) { epirate.notice $1 Too soon! | return }

    ;too many games played today check
    ;if ($hget(epirate.daily,Games.Played. $+ $1) >= $EPirate.Max.Games.Per.Day) { epirate.notice $1 Ye played enough games today! New day starts in $EPirate.Time.Until.New.Day | return }
    if ($hget(EPirate.Expenses.Today,$1 $+ .games) > $epirate.player.percentage($1,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice $1 Ye 'ave earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }

    if $3 !ison %chan && $3 != accept && $3 != decline && $3 != help && $3 != stats { epirate.notice $1 $ams-logo The format be !Pirates AMSSM <pirate> <wager>  - Use !Pirates AMSSM help fer Commands. | return }

    if (!%ams-status) || (%ams-status == idle) {
      if ($1 == $3) { epirate.notice $1 Stop tryin' to play wit' yeself n' play wit' others! | return }
      if ($3 ison %chan) && ($EPirate.Onboard($3)) || ($3 == $epirate.bot) {

        ;too many games played today check
        ;if ($hget(epirate.daily,Games.Played. $+ $3) >= $EPirate.Max.Games.Per.Day) { epirate.notice $1 $3 played enough games today! New day starts in $EPirate.Time.Until.New.Day | return }

        set %ams-p1 $1
        ;$2 is AMS
        set %ams-p2 $3
        if (%ams-status) || (%ams-status == idle) {

          if (%ams-p1 == $epirate.bot) {
            var %r $dll(%dll,roll,d5)
            if (%r == 1) set %ams-p1-answer $amsl(Anchor)
            elseif (%r == 2) set %ams-p1-answer $amsl(Map)
            elseif (%r == 3) set %ams-p1-answer $amsl(Shark)
            elseif (%r == 4) set %ams-p1-answer $amsl(Mruno)
            elseif (%r == 5) set %ams-p1-answer $amsl(Sword)
            hinc EPirate.stats $+(%ams-p1,.AMS.Plays)
            hinc EPirate.stats $+(%ams-p1,.AMS.Selection.,%ams-p1-answer)
          }

          ;player needs to buy a bribe to play more games
          if ($hget(EPirate.Games,played. $+ %ams-p1) >= $Epirate.Games.Before.Bribe.Needed) {
            EPirate.Notice %ams-p1 Th' Cap'n will catch ye if ye keep playin' those games 'n nah scrubbin' th' poop deck. Play later, ye blaggard!
            EPirate.Notice %ams-p1 I may be able t' help ye play some more games. Type !Pirates Store Bribe
            return
          }

          ;wager checks
          var %wager 0
          ;if ($4 == max) set %wager $epirate.player.percentage(%ams-p1,$EPirate.Max.Percentage.Wager)
          if ($4 == max) set %wager $epirate.determine.max.wager(%ams-p1,%ams-p2)
          else set %wager $EPirate.Convert.Wager($4)
          if ($4) && (%wager isnum) && (%wager >= 1) set %ams-wager %wager
          else { epirate.notice $1 How much do ye want to wager? !Pirates AMSSM <pirate> <wager> | return }
          if (%ams-p1 != $epirate.bot) && (%wager > $epirate.player.percentage(%ams-p1,$EPirate.Max.Percentage.Wager)) { EPirate.Notice $1 The buy-in be too rich fer ye blood n' ye won't have drinkin' money if ye lose! Try $EPirate.Round($v2) doubloons or less | return }

          ;bot playing game
          if (%ams-p2 == $epirate.bot) {
            var %r $dll(%dll,roll,d5)
            if (%r == 1) set %ams-p2-answer $amsl(Anchor)
            elseif (%r == 2) set %ams-p2-answer $amsl(Map)
            elseif (%r == 3) set %ams-p2-answer $amsl(Shark)
            elseif (%r == 4) set %ams-p2-answer $amsl(Mruno)
            elseif (%r == 5) set %ams-p2-answer $amsl(Sword)
            hinc EPirate.stats $+(%ams-p2,.AMS.Plays)
            hinc EPirate.stats $+(%ams-p2,.AMS.Selection.,%ams-p2-answer)
            set -u90 %ams-status inprogress
            epirate.pay %ams-p1 - $+ %ams-wager games
          }

          ;additional wager checks
          if (%ams-p2 != $epirate.bot) && (%wager > $epirate.player.percentage(%ams-p2,$EPirate.Max.Percentage.Wager)) { EPirate.Notice $1 The wager be too much fer %ams-p2 $+ ! Try $EPirate.Round($v2) doubloons or less | return }
          if (%ams-p2 != $epirate.bot) && (%wager > $hget(epirate.players.all,%ams-p2)) { EPirate.notice $1 Ye too poor to play tis game! | return }
          if ($hget(EPirate.Expenses.Today,%ams-p2 $+ .games) > $epirate.player.percentage(%ams-p2,$EPirate.Max.Percentage.Daily.Games)) { epirate.notice $1 %ams-p2 has earned too much from games today! New day starts in $EPirate.Time.Until.New.Day | return }


          if (%wager < $epirate.player.percentage(%ams-p1,0.1)) EPirate.Achievement %ams-p1 Game.Low.Wager

          .timer 1 0 set -u90 %ams-status pending
          if ($epirate.spam) && (%ams-p2 == $epirate.bot) noop
          else epirate.public.msg $epirate.nick($1) $amsb($1) has challenged $amsb($3) to a game of $ams-logo $+ . -AKA- Rock, Paper, Scissors, Lizard, Spock.

          var %games $hget(EPirate.stats,$+(%ams-p1,.AMS.Plays)), %notice 
          if (%games) {
            set %notice %ams-p1 has played AMSSM %games times n' has the followin' tendencies: Anchor $epirate.percentage($hget(EPirate.stats,$+(%ams-p1,.AMS.Selection.Anchor)),%games) $+ $chr(37) Map $epirate.percentage($hget(EPirate.stats,$+(%ams-p1,.AMS.Selection.Map)),%games) $+ $chr(37) Sword $epirate.percentage($hget(EPirate.stats,$+(%ams-p1,.AMS.Selection.Sword)),%games) $+ $chr(37) Shark $epirate.percentage($hget(EPirate.stats,$+(%ams-p1,.AMS.Selection.Shark)),%games) $+ $chr(37) Mruno $epirate.percentage($hget(EPirate.stats,$+(%ams-p1,.AMS.Selection.Mruno)),%games) $+ $chr(37)
          }
          else set %notice This be %ams-p2 $+ 's first time playin' AMSSM.

          if (%ams-p2 != $epirate.bot) {
            epirate.notice %ams-p2 %ams-p1 has challenged ye to AMSSM wit' a wager o' $epirate.round(%ams-wager) doubloons! Ye can accept this challenge wit' $amsb(!Pirates AMSSM Accept)
            ;epirate.notice %ams-p2 %notice
          }

          var %games $hget(EPirate.stats,$+(%ams-p2,.AMS.Plays)) 
          if (%games) {
            if (%ams-p1 != $epirate.bot) epirate.notice %ams-p1 %ams-p2 has played AMSSM %games times n' has the followin' tendencies: Anchor $epirate.percentage($hget(EPirate.stats,$+(%ams-p2,.AMS.Selection.Anchor)),%games) $+ $chr(37) Map $epirate.percentage($hget(EPirate.stats,$+(%ams-p2,.AMS.Selection.Map)),%games) $+ $chr(37) Sword $epirate.percentage($hget(EPirate.stats,$+(%ams-p2,.AMS.Selection.Sword)),%games) $+ $chr(37) Shark $epirate.percentage($hget(EPirate.stats,$+(%ams-p2,.AMS.Selection.Shark)),%games) $+ $chr(37) Mruno $epirate.percentage($hget(EPirate.stats,$+(%ams-p2,.AMS.Selection.Mruno)),%games) $+ $chr(37)
          }
          else epirate.notice %ams-p1 This be %ams-p2 $+ 's first time playin' AMSSM.

          ;check if anything in pot from previous draw
          if ($hget(epirate.games,AMSSM.pot)) set %ams-pot $ifmatch

          .timerams.cancel 1 90 ams-cancel
          if (%ams-p2 == $epirate.bot) .timer 1 3 epirate.notice $1 $epirate.bot has made a selection... make yers! Anchor, Map, Sword, Shark or Mruno. Use: /msg $me !Pirates AMSSM <selection> - Ex: /msg $me !Pirates AMSSM Anchor
          else epirate.notice $1 Waitin' $duration($timer(ams.cancel).secs) fer %ams-p2 to respond...
          return
        }
        else { epirate.notice $1 A game already be in progress! | return }
      }
      else {
        if ($3 == accept) || ($3 == decline) epirate.notice $1 Thar not be a game bein' played! Start one wit' !Pirates AMSSM
        elseif ($3 == help) ams-help $1
        else epirate.notice $1 $amsb($3) not be onboard!
        return
      }
    }
  }
  if %ams-status == pending {
    if ($hget(EPirate.Games,played. $+ %ams-p2) >= $Epirate.Games.Before.Bribe.Needed) {
      ;player needs to buy a bribe to play more games
      EPirate.Notice %ams-p1 Th' Cap'n caught %ams-p2 playin' games 'n be now scrubbin' th' poop deck. Try again later.
      EPirate.Notice %ams-p2 I may be able t' help ye play some more games. Type !Pirates Store Bribe
      return
    }

    if $3 == accept {
      .timerams.* off
      set -u90 %ams-status inprogress
      epirate.notice %ams-p1 %ams-p2 accepted ye challenge!
      .timerams.noanswer 1 60 ams-cancel noanswer
      if (!%ams-p1-answer) epirate.notice %ams-p1 Ye 'ave $duration($timer(ams.noanswer).secs) to tell me what ye playin' wit'! Anchor, Map, Sword, Shark or Mruno. Use: /msg $me !Pirates AMSSM <selection> - Ex: /msg $me !Pirates AMSSM Map
      if (!%ams-p2-answer) epirate.notice %ams-p2 Ye 'ave $duration($timer(ams.noanswer).secs) to tell me what ye playin' wit'! Anchor, Map, Sword, Shark or Mruno. Use: /msg $me !Pirates AMSSM <selection> - Ex: /msg $me !Pirates AMSSM Anchor

      ;if no answer, wager still deducted
      epirate.pay %ams-p2 - $+ %ams-wager games
      if (%ams-p1 != $epirate.bot) epirate.pay %ams-p1 - $+ %ams-wager games
      return
    }
    elseif $3 == decline {
      ;if ($epirate.reduce.spam) epirate.notice %ams-p1 %ams-p2 declined ye challenge request!
      ;else epirate.public.msg $epirate.nick(%ams-p2) %ams-p2 declined the challenge from %ams-p1 to play $ams-logo $+ .
      ams-cancel decline
      return
    }
    else {
      if (%ams-p1 == $1) { epirate.notice $1 Waitin' on %ams-p2 to accept ye challenge! | return }
      if (%ams-p2 == $1) { epirate.notice $1 Waitin' on ye to accept the challenge from %ams-p1 $+ !  !Pirates AMSSM Accept | return }
      ;epirate.notice $1 $ams-logo game not in progress.
    }
  }
  if $3 == help {
    ams-help $1
    return
  }
  else epirate.notice $1 AMSSM be %ams-status
}
alias ams-help {
  if ($1) {
    epirate.notice $1 $ams-Logo $asmb(Anchor, Map, Sword, Shark, Mruno) - Just like Rock Paper Scissors Lizard Spock. The Same Rules apply:
    epirate.notice $1 $ams-logo Sword cuts Map, Map covers Anchor, Anchor crushes Shark, Shark eats Mruno, Mruno breaks Sword, Sword impales Shark, Shark rips through Map, Map confuses Mruno, Mruno is harder than an Anchor, n' Anchor breaks Sword.
    epirate.notice $1 $ams-logo - $amsb(!p amssm Challenge Nick) to Challenge Nick to a game of $ams-logo
    epirate.notice $1 $ams-logo - $amsb(!p amssm accept or decline) to accept or decline a Challenge.
    epirate.notice $1 $ams-logo Once a game has been accepted, players must /msg $me !Pirates AMSSM Answer - Answers being: $amsb(Anchor, Map, Sword, Shark, Mruno.)
    ;epirate.notice $1 $ams-logo Once a game has been accepted, players must /msg $me !Pirates AMSSM Answer - Answers being: $amsb(Anchor, Map, Sword, Shark, Mruno.) (Like Rock, Paper, Scissors, Lizard, Spock.)
    ;epirate.notice $1 Ex: /msg $me !Pirates AMSSM Anchor OR /msg $me !Pirates AMSSM Map OR /msg $me !Pirates AMSSM Sword  OR /msg $me !Pirates AMSSM Shark  OR /msg $me !Pirates AMSSM Mruno
  }
}
alias beats {
  var %a anchor.map.sword.shark.mruno
  var %b Cuts.Covers.Crushes.Eats.Breaks.Impales.Tears.Confuses.Shatters
  if ($2) {
    if ($+(*,$1,*) iswm %a) && ($+(*,$2,*) iswm %a) {
      if (($1 == anchor) && ($2 == map)) || (($1 == map) && ($2 == anchor)) { return $gettok(%b,2,46) }
      if (($1 == anchor) && ($2 == sword)) || (($1 == sword) && ($2 == anchor)) { return $gettok(%b,5,46) }
      if (($1 == anchor) && ($2 == shark)) || (($1 == shark) && ($2 == anchor)) { return $gettok(%b,3,46) }
      if (($1 == anchor) && ($2 == mruno)) || (($1 == mruno) && ($2 == anchor)) { return $gettok(%b,9,46) }
      if (($1 == map) && ($2 == sword)) || (($1 == sword) && ($2 == map)) { return $gettok(%b,1,46) }
      if (($1 == map) && ($2 == shark)) || (($1 == shark) && ($2 == map)) { return $gettok(%b,7,46) }
      if (($1 == map) && ($2 == mruno)) || (($1 == mruno) && ($2 == map)) { return $gettok(%b,8,46) }
      if (($1 == sword) && ($2 == shark)) || (($1 == shark) && ($2 == sword)) { return $gettok(%b,6,46) }
      if (($1 == sword) && ($2 == mruno)) || (($1 == mruno) && ($2 == sword)) { return $gettok(%b,5,46) }
      if (($1 == shark) && ($2 == mruno)) || (($1 == mruno) && ($2 == shark)) { return $gettok(%b,4,46) }
    }
  }
}
alias ams-announcewinner {
  var %winner, %loser, %winner-answer, %tax 0, %msg, %loser-answer, %sum $calc(%ams-wager * 2)
  if %ams-winner == Cat {
    ;no winners add to pot
    hinc epirate.games AMSSM.pot %sum
    set %msg Both %ams-p1 n' %ams-p2 chose %ams-p1-answer $+ ! $epirate.round($hget(epirate.games,AMSSM.pot)) doubloons be added to the pot for the next game!
  }
  elseif %ams-winner == %ams-p1 {
    set %winner %ams-p1
    set %winner-answer %ams-p1-answer
    set %loser %ams-p2
    set %loser-answer %ams-p2-answer
  }
  elseif %ams-winner == %ams-p2 {
    set %winner %ams-p2
    set %winner-answer %ams-p2-answer
    set %loser %ams-p1
    set %loser-answer %ams-p1-answer
  }

  if (%winner) {
    if (%ams-pot) inc %sum %ams-pot

    ;reduces amount if too much being paid to winner because of previous pot
    if (%winner != $epirate.bot) && (%sum > $epirate.player.percentage(%winner,$EPirate.Max.Percentage.Bonus)) {
      inc %tax
      set %sum $epirate.player.percentage(%winner,$EPirate.Max.Percentage.Bonus)
      .timer 1 3 epirate.notice %winner Ye payout be reduced due to taxes from the Cap'n!
    }

    set %msg $upper(%winner-answer) $beats($amsl(%winner-answer),$amsl(%loser-answer)) $upper(%loser-answer) - $epirate.nick(%winner) $amsb(%winner) wins $epirate.round(%sum) doubloons $+ $iif(%tax,$chr(32) after taxes!,!)
    hdel epirate.games AMSSM.pot

    ;pays winner if not bot. pay is doubled since wager was deducted ealier
    if (%winner != $epirate.bot) epirate.pay %winner %sum games
  }

  ;after game commands
  epirate.public.msg $ams-logo %msg
  hinc EPirate.Stats ship.games

  if (%ams-p1 != $epirate.bot) {
    hinc epirate.daily Games.Played. $+ %ams-p1
    EPirate.Achievement %ams-p1 game
    EPirate.Skills.Check %ams-p1 Luck
    EPirate.Command.Age.Check %ams-p1 AMS
    if (!$timer(EPirate.Party)) hinc EPirate.Games played. $+ %ams-p1
    EPirate.Task.Check %ams-p1 play.game
  }

  if (%ams-p2 != $epirate.bot) {
    ;skips bot from the below commands
    hinc epirate.daily Games.Played. $+ %ams-p2
    EPirate.Achievement %ams-p2 game
    EPirate.Skills.Check %ams-p2 Luck
    EPirate.Command.Age.Check %ams-p2 AMS
    if (!$timer(EPirate.Party)) hinc EPirate.Games played. $+ %ams-p2
    EPirate.Task.Check %ams-p2 play.game
  }

  .timerEPirate.AMS.Cooldown 1 $rand(45,90) noop
  ams-reset
}
alias ams-cancel {
  if (!$1) {
    if (!$epirate.reduce.spam) epirate.public.msg $ams-logo $epirate.nick(%ams-p2) %ams-p2 did not accept the challenge from %ams-p1 in time!
    if (%ams-p1) .timerepirate.ams.cancel. $+ %ams-p1 1 1 epirate.notice %ams-p1 $amsb(%ams-p2) did not accept ye challenge in AMS!
    if (%ams-p2) .timerepirate.ams.cancel. $+ %ams-p2 1 1 epirate.notice %ams-p2 The AMSSM challenge from %ams-p1 timed out!
    ams-reset
  }
  if $1 == decline {
    if (!$epirate.reduce.spam) epirate.public.msg $ams-logo $amsb(%ams-p2) declined the game with %ams-p1
    if (%ams-p1) .timerepirate.ams.cancel. $+ %ams-p1 1 1 epirate.notice %ams-p1 %ams-p2 did not accept ye challenge in AMS!
    ams-reset
  }
  elseif $1 == noanswer {
    if (!$epirate.reduce.spam) epirate.public.msg $ams-logo %ams-p1 n' %ams-p2 did not reply with their answer in time. $ams-logo Game Cancelled.
    if (%ams-p1) epirate.notice %ams-p1 The game o' AMSSM has timed out!
    if (%ams-p2) epirate.notice %ams-p2 The game o' AMSSM has timed out!
    ams-reset
  }
}



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
