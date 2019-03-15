;------------------------
;PiratesIRC by mruno
;------------------------
;
;Test code goes here until it is done. 
;This code is loaded on all game instances
;
;
;-------------------------


alias epirate.port.sizes.populate {
  epirate.global.command yes timerepirate.port.size.populate* off
  epirate.global.command yes hdel -w epirate.port.sizes *
  var %total $hget(epirate.ports,0).item
  var %size
  var %i 0
  while (%total > %i) {
    inc %i
    set %port $hget(epirate.ports,%i).item
    if (Independent. !isin %port) epirate.global.command slow .timerepirate.port.size.populate. $+ %i 1 %i hadd epirate.port.sizes %port $rand(1,10)
  }
}


alias epirate.verify.treasure.map.cells {
  var %f $epirate.dir(treasure.ini)
  var %cell
  var %i 0
  while ($ini(%f,cells,0) > %i ) {
    inc %i 
    set %cell $ini(%f,cells,%i)
    if (!$readini(%f,%cell,1)) echo -s Missing %cell
  }
}


alias epirate.playerdata.clean.invalid.players {
  ;removes players from playerdata that do not have a start time, faction, or age
  var %f $epirate.player.data, %p, %total 0, %t $ini(%f,0)
  var %i 0
  while (%i < %t) {
    inc %i
    set %p $ini(%f,%i)
    if (!$readini(%f,%p,start)) && (!$readini(%f,%p,age)) && (!$readini(%f,%p,faction)) {
      echo -s remini %f %p
      inc %total
    }
  }
  echo -s Removed %total invalid entries in %f
}
alias epirate.wtf.test {
  if ($epirate.debug.ship) return
  ;adds msgtype to auto if $null in player options
  var %player, %total 0, %i 0
  while ($hget(EPirate.Players.All,0).item > %i) {
    inc %i
    set %player $hget(EPirate.Players.All,%i).item
    if (!$hget(Epirate.Players.Options,msgtype. $+ %player)) {
      .timer 1 0 hadd Epirate.Players.Options msgtype. $+ %player Auto
      inc %total
    }
  }
  IECHO Added %total players to auto msgtype!
}

alias epirate.transfer.player.options {
  ;/epirate.transfer.player.options <option> - transfers player options to new hash table
  if ($1 == automarketsell) epirate.transfer.player.automarketsell.options
  else {
    var %p $1, %player, %item, %data, %total 0, %i 0
    while ($hfind(EPirate.Options,%p $+ .*,0,w) > %i) {
      inc %i
      set %item $hfind(EPirate.Options,%p $+ .*,%i,w)
      if (%item) {
        set %data $hget(EPirate.Options,%item)
        set %player $gettok(%item,2,46)
        hadd EPirate.Players.Options $+(%p,.,%player) %data
        .timer 1 0 hdel epirate.options %item
        inc %total
      }

    }
    IECHO Transferred %total  %p options
  }
}
alias epirate.transfer.player.automarketsell.options {
  ;/epirate.transfer.player.automarketsell.options - transfers player automarketsell options to new hash table
  var %p AutoMarketSell, %player, %item, %data, %total 0, %i 0
  while ($hfind(EPirate.Options,*. $+ %p,0,w) > %i) {
    inc %i
    set %item $hfind(EPirate.Options,*. $+ %p,%i,w)
    if (%item) {
      set %player $gettok(%item,1,46)
      hadd EPirate.Players.Options $+(%p,.,%player) 1
      .timer 1 0 hdel epirate.options %item
      inc %total
    }

  }
  IECHO Transferred %total  %p options
}



alias epirate.remove.invalid.player.tasks {
  ;removes hash table items from players with no tasks: PLAYER.$NULL
  var %table EPirate.Tasks, %item, %total 0, %i 0
  while ($hget(%table,0).item > %i) {
    inc %i
    set %item $hget(%table,%i).item
    if (!$gettok(%item,2,46)) {
      .timer 1 0 hdel %table %item
      inc %total
    }
  }
  if (%total) EPirate.INFO.ECHO Removed %total invalid player tasks!
}

alias epirate.write.all.playerdata {
  ;/epirate.write.all.playerdata - on the fly code that fixes problems in playerdata file

  var %file $epirate.player.data, %player, %total 0, %i 0
  while ($ini(%file,0) > %i) {
    inc %i
    if (%i > $epirate.max.loops) break
    set %player $ini(%file,%i)
    ;set %last $readini(%file,%player,last)
    set %last $hget(Epirate.Last.CMDs,%player $+ .SEEN)
    if (%player == $me) { remini %file %player | inc %total }
    elseif (!%last) { writeini %file %player last $ctime | inc %total }
  }
  iecho Done! Fixed %total
}




alias Epirate.FindPath {
  ;$Epirate.FindPath(start,destination) - returns the path to the destination

  var %table EPirate.PathFind, %destination $2, %start $1, %file $epirate.dir(map.ini)
  var %start.x $left(%start,1), %start.y $right(%start,-1)
  var %dest.x $left(%destination,1), %dest.y $right(%destination,-1), %current.x %start.x, %current.y %start.y

  ;if (!$readini(%file,land,%pot.x $+ %path.y)) && (!$readini(%file,inaccessible,%pot.x $+ %path.y)) set %path.x %pot.x


  if ($alph(%dest.x) > 19) || (%dest.y > 16) { EPirate.WARNING.ECHO Destination x or y is too large: %dest.x %dest.y | return }
  ;if ($readini(%file,inaccessible,%dest.x $+ %dest.y)) { EPirate.WARNING.ECHO Destination x or y is inaccessible: %dest.x %dest.y | return }

  ;set %pro.y $alph($calc($alph(%current.y) + 1))

  if (!$hget(%table)) hmake %table
  else hdel -w %table *

  ;initialize the open list - $hget(%table,open)
  ;initialize the closed list - $hget(%table,closed

  ;------------------------
  ;G is cost to get to goal
  ;H is estimate it will take to get goal
  ;F = G + H
  ;Q is the path to goal with lowest F
  ;-----------------------


  ;put the starting node on the open list (you can leave its f at zero)
  hadd %table open %start

  var %g, %h $Epirate.FindPath.Estimate(%start,%destination,1), %f, %q, %path

  ;check to see if estimated path is clear if so return the path
  var %i 0, %check, %bad 0
  while ($gettok($hget(%table,q),0,44) > %i) {
    inc %i
    set %check $gettok($hget(%table,q),%i,44)
    if ($EPirate.Cell.Restricted(%check)) { inc %bad | break }
  }
  if (!%bad) { set %path $hget(%table,q) | goto end }


  var %i 0, %open, %current, %x , %y
  ;while ($hget(%table,open)) {
  while (%i < 15) {
    inc %i
    set %open $hget(%table,open)
    set %current $gettok(%open,1,44)
    hadd %table closed $addtok($hget(%table,closed),%current,44)
    if (%current == %destination) { iecho path found! | break }
    hadd %table open $remtok(%open,%current,44)

    set %x $left(%current,1)
    set %y $right(%current,-1)
    var %check.x, %check.y, %check

    var %URDL 0
    while (%URDL < 4) {
      inc %URDL
      if (%URDL == 1) {
        ;Check the cell above
        set %check.x %x
        set %check.y $calc(%y - 1)
        set %check %check.x $+ %check.y
        iecho above %check
      }
      elseif (%URDL == 2) {
        ;Check the cell right
        set %check.x $alph($calc($alph($left(%x,1)) + 1))
        set %check.y %y
        set %check %check.x $+ %check.y
        iecho right %check
      }
      elseif (%URDL == 3) {
        ;Check the cell below
        set %check.x %x
        set %check.y $calc(%y + 1)
        set %check %check.x $+ %check.y
        iecho below %check
      }
      elseif (%URDL == 4) {
        ;Check the cell left
        set %check.x $alph($calc($alph($left(%x,1)) - 1))
        set %check.y %y
        set %check %check.x $+ %check.y
        iecho left %check
      }
      else { iecho end of URDL | break }

      iecho checking %check

      if ($EPirate.Cell.Restricted(%check)) hadd %table closed $addtok($hget(%table,closed),%check,44)
      else {
        if (!$findtok($hget(%table,closed),%check,44)) {
          iecho %check cell is not on closed list or restricted
          if (!$findtok($hget(%table,open),%check,44)) {
            iecho %check ;cell is not on open list, so add it and calc F G H
            hadd %table open $addtok($hget(%table,open),%check,44)
            var %g $Epirate.FindPath.Estimate(%start,%check), %h $Epirate.FindPath.Estimate(%check,%destination)
            hadd %table %check $+ .G %g
            hadd %table %check $+ .H %h
            hadd %table %check $+ .F $calc(%g + %h)
          }
          else {
            iecho %check ;cell already on open list, so check to see if this path to that square is better, using G cost as the measure
            hadd %table CostFromStart. $+ %check $Epirate.FindPath.Estimate(%start,%check)
          }
        }
      }
    }

    if (%i > 30) { iecho too many loops: $v2 | break }
  }
  :end
  ;perform cleanup

  return %path
}



;------------------------------------------------------ LOCAL ALIASES 
alias -l percent $iif(($isid) && ($1) && ($2),return $calc($1 / $2 * 100) $+ $iif($prop == suf,%))
alias -l debug {
  if ($1) {
    if (!$window(@Pirates)) window -n1e3 @Pirates
    aline -p @Pirates $time $+ : $1-
    ECHO -st $1-
    write $epirate.log.dir($+(Pirates.Log.,$EPirate.Network,.,$time(mmm),.,$time(yyyy),.log)) $date $time - $strip($1-)
  }
}
alias -l short.dur {
  var %a $duration($1)
  var %r 
  if (hour isin %a) return $remove(%a,$wildtok(%a,*sec*,1,32),$wildtok(%a,*min*,1,32))
  else return $remove(%a,$wildtok(%a,*sec*,1,32))
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
alias -l percent $iif(($isid) && ($1) && ($2),return $calc($1 / $2 * 100) $+ $iif($prop == suf,%))
'----------------------------- end local aliases

alias alph {
  var %i $lower($1)
  if (%i < 1) return
  elseif (%i isalpha) return $calc($asc(%i) - 96)
  elseif ($1 isnum) return $chr($calc($1 + 96))
  else return
}
alias EPirate.Debug2 {
  if (!$window(@EP.debug)) window -n1e3 @EP.debug
  aline -p @EP.debug $time $+ : $1-
}
