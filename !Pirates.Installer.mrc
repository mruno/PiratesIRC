;This is the installer script for Pirates
;Load this file in mIRC /load -rs DIR\!Pirates.install.mrc

on *:load: {
  if (!$network) {
    echo -sa  Edit remote.ini aliases: your_nick,your_password, your_network, working.server
    echo -sa  Join network and register with nickserv and register hostname with hostserv
    echo -sa 7 Load this file again after completion: /load -rs $script
    unload -rs $script
    return
  }
  var %file $+($scriptdir,Pirates.,$network,.mrc)
  if ($exists(%file)) {
    epirate.check.files
    epirate.check.new.install
if ($Epirate.Ship) {
    echo -sa !Pirates installation complete! $epirate.ship is ready to sail at $asctime($EPirate.Start.Game.Time)
.timerEPirate.New.Day 1 10 EPirate.New.Day
}
else {
    echo -sa 4 ERROR: Ship name not set in %file $+ ! Epirate.ship - $epirate.ship
    echo -sa 7 Load this file again after completing settings /load -rs $script
}
    .timerUNLOAD.Pirates.Installer 1 3 unload -rs $script
  }
  else {
    echo -sa 4 ERROR: %file does not exist! Create and tailor $nopath(%file) based on this network!
    echo -sa 7 Load this file again after completion: /load -rs $script
    unload -rs $script
  }
}


alias epirate.script.files return elitepirates.Global.Settings.mrc elitepirates.events.mrc elitepirates.mrc elitepirates2.mrc elitepirates3.mrc elitepirates4.mrc elitepirates5.mrc elitepirates.games.mrc elitepirates.html.mrc EPadmin.mrc captcha.mrc ElitePirates.Roulette.mrc Epirates.amsv2.mrc elitepirates.trialcode.mrc
alias epirate.check.files {
  ;/epirate.check.files - verifies all pirate files are loaded. if not it will load them
  var %dir $scriptdir
  var %files $epirate.script.files
  var %file, %n 3, %i 0
  while ($gettok(%files,0,32) > %i) {
    inc %i
    set %file $gettok(%files,%i,32)
    if (!$script(%file)) {
      load -rs $+ %n " $+ %dir $+ %file $+ "
      inc %n
    }
  }
}
alias epirate.check.new.install {
  var %dir $+(",$scriptdir,saves\,$EPirate.Network,\,$1-,")
  var %new $1
  if (!$exists(%dir)) {
    mkdir %dir
    inc %new
  }
  if (!$exists($epirate.player.data)) {
    write -c $epirate.player.data
    inc %new
  }
  if (%new) {
.timer 1 5 .EPirate.Load.Table
.timer 1 10 EPirate.Refresh.DDE
}
}
