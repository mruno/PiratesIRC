;PiratesIRC helper script for debugging, coding, etc
;contains helper aliases to edit hash tables and display messages locally on the bot

alias clear.all.hash.tables {
  if ($1 == yes) {
    var %i 0
    while ($hget(0) > %i) {
      inc %i
      hdel -sw $hget(%i) *
    }
  }
  else iecho Are you sure you want to clear all hash tables? if so /clear.all.hash.tables yes
}
alias iecho echo -sat $1-
alias -l hc return 12 $+ $1- $+ 
alias -l fix2 {
  var %z
  if ($2- != $null) set %z $2-
  set %z %z $+ $str( ,$calc($1 - $len($strip(%z))))
  return %z
}
alias hlist {
  unset %hlist*
  .timerhlist off
  if ($hget($1)) {
    set %hlist $1
    window -slek @hlist "courier new" 12
    clear @hlist
    var %a,%b
    if (* isin $2) {
      set %a 1
      while (%a <= $hfind($1,$2,0,w)) {
        aline -l @hlist $fix2(20,$hfind($1,$2,%a,w)) = $hget($1,$hfind($1,$2,%a,w))
        inc %a
      }
      iline -l @hlist 1 $fix2(20,Found $hfind($1,$2,0,w) Results) dclick to go up, rclick to refresh
      set %hlist.num $hfind($1,$2,0,w)
      .timerhlist -o 0 2 _hlist.update
    }
    else {
      set %a 1
      set %b $1
      while (%a <= $hget(%b,0).item) {
        aline -l @hlist $fix2(20,$hc($hget(%b,%a).item)) $hget(%b,$hget(%b,%a).item)
        inc %a
      }
      iline -l @hlist 1 $fix2(20,Found $hget(%b,0).item Results) dclick to go up, rclick to refresh
      set %hlist.num $hget(%b,0).item
      .timerhlist -o 0 2 _hlist.update
    }
  }
  else {
    window -sleik @hlist  "courier new" 12
    clear @hlist
    var %a = 1
    while ($hget(%a) != $null) {
      aline -l @hlist $fix2(20,$hc($hget(%a))) $chr(160) $hget(%a,0).item $+ / $+ $hget(%a).size
      inc %a
    }
    set %hlist.num $hget(0)
    .timerhlist -o 0 2 _hlist.update
  }
}

on *:INPUT:@hlist:{
  hlist %hlist
}
menu @hlist {
  lbclick {
    var %a = $gettok($strip($sline(@hlist,1)),1,160)
    if (Found * Results* iswm %a) { hlist | return }
    if (%hlist) { 
      var %c = $remove($gettok($strip($sline(@hlist,1)),-1,160),$chr(160))
      editbox -p @hlist /hadd %hlist %a $hget(%hlist,%a)
    }
    ;elseif ($hget(%a)) hlist %a
  }
  dclick {
    var %a = $gettok($strip($sline(@hlist,1)),1,160)
    if (Found * Results* iswm %a) { hlist | return }
    if (%hlist) { 
      var %c = $remove($gettok($strip($sline(@hlist,1)),-1,160),$chr(160))
      .timer 1 0 $chr(123) var % $+ b = $ $+ input(Set [ %a ] to new value:,e,Set new value, %c ) $chr(124) if (% $+ b) $chr(123) hadd %hlist %a % $+ b $chr(124) hlist %hlist  $chr(125) $chr(125)
    }
    elseif ($hget(%a))  hlist %a
  }
  rclick {
    hlist %hlist 
  }
}
alias _hlist.update {
  if (!$window(@hlist)) { .timerhlist off | unset %hlist* | return }
  if (%hlist) {
    if (($hget(%hlist,0).item > %hlist.num) || ($hget(%hlist,0).item < %hlist.num) || (%hlist.num == $null)) {
      set %hlist.num $hget(%hlist,0).item 
      hlist %hlist
    }
  }
  elseif (($hget(0) > %hlist.num) || ($hget(0) < %hlist.num) || (%hlist.num == $null)) { set %hlist.num $hget(0) | hlist }
}
