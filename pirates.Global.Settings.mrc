;------------------------
;PiratesIRC by mruno
;------------------------
;Network Specific stuff in C:\EP\Pirates.<NETWORK>.mrc
;Global settings in this file
;------------------------

;----Global SETTINGS --------------------------------------------------
alias EPirate.Dir return $+(",$scriptdir,data\,$1-,")
alias Epirate.Data.Dir return $+(",$scriptdir,data\,$1-,")
alias EPirate.Save.Dir return $+(",$scriptdir,saves\,$EPirate.Network,\,$1-,")
alias EPirate.Log.Dir return $+(",$scriptdir,logs\,$1-,")
alias Epirate.PlayerData return $epirate.save.dir(playerdata.dat)
alias Epirate.Player.Data return $Epirate.PlayerData
alias Epirate.Web.Dir return $+(",$scriptdir,web\,$1-,")

;set EPirate.Auto.Restart.mIRC.Every.Days to 0 to disable
alias EPirate.Auto.Restart.mIRC.Every.Days return 13


alias epirate.standard.topic {
  if ($EPirate.Start.Game.Time) && ($ctime < $EPirate.Start.Game.Time) return ? Pirates be coming soon $paren($gettok($duration($calc($EPirate.Start.Game.Time - $ctime)),1-2,32)) - 12http://tiny.cc/PiratesIRC ?
  var %topic, %winner $hget(epirate.options,End.Game.Winner), %msg $1-
  if ($hget(epirate.options,Next.Round.Loop)) && (%winner) {
    var %round $hget(epirate.options,round)
    if ($hget(epirate.players.all,0).item < $Epirate.Mininum.Players) set %topic %winner has won round %round o' Pirates! $v2 pirates needed to get underway! 8!Pirates 11http://tiny.cc/PiratesIRC
    else set %topic %winner has won round %round o' Pirates! Next round starts 'bout $hget(epirate.options,Next.Round.Loop) hours! 8!Pirates 11http://tiny.cc/PiratesIRC
  }
  else {
    if ($hget(epirate.players.all,0).item < $Epirate.Mininum.Players) && ($calc($ctime - $hget(EPirate.Options,start)) > 2592000) set %topic $Epirate.Mininum.Players pirates needed to get underway next round!
    ;else set %topic !Pirates Round $hget(EPirate.options,round) $+ ) 9Plunder divided @ level $EPirate.End.Game.Level $iif($gettok($EPirate.Holiday.Bonus,1,44),8Happy $ifmatch) 15Rate: $+ $EPirate.Doubloon.Rate 11http://tiny.cc/PiratesIRC
    else set %topic !Pirates Game! - Round $hget(EPirate.options,round) $+ ) $iif($gettok($EPirate.Holiday.Bonus,1,44),8Happy $ifmatch) 15Rate: $+ $EPirate.Doubloon.Rate 11http://tiny.cc/PiratesIRC
  }
  return $EPirate.Random.Topic.Colors($iif(%msg,%msg -) %topic)
}

alias EPirate.Level.1.Requirement return 10001
alias EPirate.Bonus.NewPlayer return 9000
alias EPirate.spam return $EPirate.Reduce.SPAM
alias Epirate.Mininum.Players return 10
alias EPirate.Duel.Timeout return $rand(2700,5400)
alias EPirate.Max.Percentage.Bonus return 15
alias EPirate.Max.Percentage.Daily.Games return 13
alias EPirate.No.Capn.Onboard return 3
alias EPirate.Level.Multiplier return 0.3
alias EPirate.Triggers.Until.RandomEvent return 35
alias EPirate.Captain.Commands.Player.Min.Level return 5
alias EPirate.Max.Lockpick.Per.Day return $iif(%EPirate.End,999,10)
alias EPirate.Max.Lockpicked.Per.Day return $iif(%EPirate.End,999,4)
alias EPirate.Max.DaveyJones.Per.Day return $iif(%EPirate.End,999,4)
alias EPirate.Max.Rape.Per.Day return $iif(%EPirate.End,999,4)
alias EPirate.Max.Rob.Per.Day return $iif(%EPirate.End,999,6)
alias EPirate.Max.Fish.Per.Day return $iif(%EPirate.End,999,12)
alias EPirate.Max.Dive.Per.Day return $iif(%EPirate.End,999,12)
alias EPirate.Max.Dig.Per.Day return $iif(%EPirate.End,999,12)
alias EPirate.Weapon.Uses return 20
alias EPirate.Max.Duels.Per.Player return $iif(%EPirate.End,999,4)
alias EPirate.Max.Captain.Duels.Per.Player return $iif(%EPirate.End,999,8)
alias EPirate.Max.Duels.Per.Day return $iif(%EPirate.End,999,8)
alias EPirate.Max.Captain.Duels.Per.Day return $iif(%EPirate.End,1,10)
alias EPirate.Top.Limit return 5
alias EPirate.doubloon.HOT return 100
alias EPirate.doubloon.MISHAP return - $+ $rand(10,75)
alias EPirate.doubloon.GOODFORTUNE return $rand(50,150)
alias EPirate.doubloon.KICK return 0.07
alias EPirate.doubloon.LOVE return 0.06
alias EPirate.doubloon.FISH return 0.45
alias EPirate.doubloon.Crab return 0.75
alias EPirate.doubloon.DIG return 0.75
alias EPirate.doubloon.ROB return $rand(2,4)
alias EPirate.Price.sell.weapon return 1
alias EPirate.Captain.Max.Trigger return $iif($EPirate.Captain.Control,6,20)
alias EPirate.Captain.Command.Delay return $iif($EPirate.Captain.Control,$rand(1800,3600),$rand(1200,1800))
alias EPirate.Captain.Brig.Time return 30
alias EPirate.Normal.Stamina return $iif($asctime(ddd) == Mon,4,6)
alias EPirate.doubloon.Level.CMDS return 0.15
alias EPirate.Max.Duel.Bonus return $iif(%EPirate.End,999,5)
alias EPirate.Flood.Warn return 5
alias EPirate.Flood.Punish return 12
alias EPirate.Flood.Brig.Time return 5
alias EPirate.Flood.Ignore.Time return 180
alias EPirate.Flood.Doubloons return 0.025
alias EPirate.Bounty.Min return 0.1
alias EPirate.Bounty.Max return 5
alias EPirate.Player.Quest.Payout return 2.5
alias EPirate.Player.Quest.Wait.Multi return 2.5
alias EPirate.Player.Quest.Steps.Multi return 7
alias EPirate.Player.Quest.Per.Day return 1
alias EPirate.Player.Quest.Level.Requirement return 10
alias EPirate.Personal.Quest.Work return 15
alias EPirate.Doubloon.Rate.Weekend return 1.1
alias EPirate.Captain.Ship.Encounter.Doubloon.Rate return 2
alias EPirate.Captain.Overpowered return $iif($EPirate.Captain.Control,50,99999)
alias EPirate.Captain.Max.Commands return $iif($EPirate.Captain.Control,12,24)
alias EPirate.Captain.Max.Trigger.Command return $iif($EPirate.Captain.Control,10,18)
alias EPirate.Max.Rests return $iif(%EPirate.End,999,6)
alias EPirate.Mutiny.Player.Level return 10
alias EPirate.Max.Percentage.Wager return $iif(%EPirate.End,5,2.5)
alias EPirate.Max.Mutinies return 4
alias EPirate.Max.Mass.Random.Events return $iif(%EPirate.End,999,4)
alias EPirate.Faction.Increase.Rep.Cost return 5
alias EPirate.Storm.Percent return 2
alias EPirate.Weapon.Upkeep return 1.5
alias EPirate.Weapon.Upkeep.Captain return 2
alias EPirate.Skill.Cost return 2.5
alias EPirate.Top.Pirates.Determine.OverP.Captain return 3
alias EPirate.Price.Wench return 0.5
alias EPirate.TimeZone return EST
alias EPirate.doubloon.Idle return 0.02
alias Epirate.Player.Offline.Bonus return 0.04
alias EPirate.Poorest.Bonus return 4
alias EPirate.doubloon.TRIGGER return 0.03
alias EPirate.doubloon.WORD return 0.0075
alias EPirate.Daily.Bonus return 9.5
alias EPirate.Idle.Bonus return 4.5
alias EPirate.Referral.Bonus return 3
alias EPirate.Poll return 
alias EPirate.Low.Level.Commands return 0
alias Epirate.Low.Level.Cmds.Per.Day return 50
alias epirate.Low.Level.CMDs.Cooldown return $rand(30,60)
alias epirate.party.level return 5
alias epirate.max.start.parties return 3
alias epirate.Max.Upkeep return 22
alias Epirate.Games.Before.Bribe.Needed return $iif(%EPirate.End,999,5)
alias EPirate.End.Game.Level return 30
alias EPirate.Group.Quests.Min.Player.Level return 15
alias EPirate.Skills.Min.Player.Level return 12
alias Epirate.Sharpen.Power return 3
alias Epirate.BlackPowder.Power return 3
alias EPirate.Noob.Player.Min.Level.Before.Sponsored return 3
alias EPirate.Noob.Player.Min.Hours.Before.Sponsored return 48
alias EPirate.Noob.Player.Days.Between.Sponsored return 2
alias EPirate.Noob.Player.Sponsor.Max.Level return 3
alias EPirate.Noob.Player.Sponsor.Level.Difference return 3
alias Epirate.Days.Between.Sponsoring.Noobs return 3
alias EPirate.Max.Trolled.Per.Day return $iif(%EPirate.End,999,2)
alias EPirate.Max.Trolls.Per.Day return $iif(%EPirate.End,999,4)
alias EPirate.Time.Before.Player.Leaves.Onboard return 300
alias EPirate.Group.Quest.Hours.Before.Fail return 3
alias EPirate.Min.Players.For.Lottery return 3
alias EPirate.Min.Cost.For.Lottery.Ticket return 100
alias EPirate.Max.Lottery.Tickets.Per.Player return 10
alias EPirate.Lottery.Multiple.Payout return 0.2
alias EPirate.Lottery.Payout.Percentage return 24
alias EPirate.Max.Blackjack.Games.Per.Day return $iif(%EPirate.End,999,10)
alias EPirate.Max.Games.Per.Day return $iif(%EPirate.End,999,99)
alias EPirate.Cleaner.Days.Before.Warn return 32
alias EPirate.Cleaner.Days.Before.Delete return 64
alias EPirate.Max.Min.Stamina return -10
alias EPirate.Max.Gamble.Per.Day return $iif(%EPirate.End,999,10)
alias EPirate.Max.ScuttleButt.Per.Day return $iif(%EPirate.End,999,8)
alias EPirate.Mins.Between.Voyages return 15
alias EPirate.Troll.Min.Level return 13
alias EPirate.Troll.Max.Level return 28
alias EPirate.Chest.Small.Size return 6
alias EPirate.Chest.Medium.Size return 12
alias EPirate.Chest.Large.Size return 20
alias EPirate.Player.Level.Market return 11
alias EPirate.Chest.Lock.Tin.Effectiveness return 35
alias EPirate.Chest.Lock.Iron.Effectiveness return 42
alias EPirate.Chest.Lock.Copper.Effectiveness return 49
alias EPirate.Chest.Lock.Brass.Effectiveness return 56
alias EPirate.Chest.Lock.Steel.Effectiveness return 65
alias epirate.market.refresh.hours return 2
alias Epirate.Lockpick.Player.Level return 15
alias EPirate.Detect.Chest.Trap.Odds return 35
alias EPirate.Chance.Lock.Break return 15
alias EPirate.Chest.Trap.Curse.Effectiveness return 20
alias EPirate.Chest.Trap.Arrow.Effectiveness return 20
alias EPirate.Chest.Trap.Acid.Effectiveness return 28
alias EPirate.Chest.Trap.Poison.Effectiveness return 36
alias EPirate.Chest.Trap.Spike.Effectiveness return 44
alias EPirate.Chest.Trap.Bomb.Effectiveness return 52
alias EPirate.Cheat.Max.Level return 25
alias EPirate.Lockpick.Set.Chance.to.Break return 10
alias EPirate.Market.Medium.Chest.Player.Level return 13
alias EPirate.Market.Large.Chest.Player.Level return 20
alias EPirate.Market.Chest.Lock.Iron.Player.Level return 17
alias EPirate.Market.Chest.Lock.Copper.Player.Level return 19
alias EPirate.Market.Chest.Lock.Brass.Player.Level return 22
alias EPirate.Market.Chest.Lock.Steel.Player.Level return 25
alias Epirate.Coin.Denier.Use return grants a parlay
alias Epirate.Coin.Farthing.Use return grants favor wit' the English
alias Epirate.Coin.Cob.Use return throws a pirate o' ye choosin' in the brig
alias Epirate.Coin.Ducatoon.Use return gives ye a 30% discount on 1 item in the ship's store
alias Epirate.Market.Standard.Price.Food return 0.5
alias Epirate.Market.Standard.Price.Materials return 1
alias Epirate.Market.Standard.Price.Sugar return 1.5
alias Epirate.Market.Standard.Price.Spice return 2
alias Epirate.Market.Standard.Price.Luxuries return 2.5
alias Epirate.Market.Weapon.Upgrade.Price return 10
alias Epirate.Market.Goods.Player.Level return 20
alias Epirate.Market.Goods.Increase.Per.Hour return 0.05
alias Epirate.Market.Goods.Increase.Cap return 2
alias EPirate.Market.Sell.Limit return 4
alias EPirate.Market.Faction.Sell.Limit return 6
alias EPirate.Bounty.Bounties.Expiration.Days return 7
alias EPirate.Max.Bounties return 3
alias EPirate.Captain.Favor.Expires.in.Days return 2
alias EPirate.Captain.Base.Favor return 51
alias EPirate.Sail.Time.Increments.Standard return 6
alias EPirate.Ships.Work.Player.Level return 10
alias EPirate.Work.doubloon.Payout return 0.1
alias EPirate.Max.Work.Per.Day return $iif(%EPirate.End,999,16)
alias EPirate.Work.Tasks.Multiplier return 0.65
alias EPirate.Network.Ship.Attack.Wait return 120
alias EPirate.Ship.HitPoints return 10
alias EPirate.Captain.Request.Delay return 14400
alias EPirate.Captain.Request.Favor.Amount return 3
alias Epirate.Network.Duels.Enabled return 1
alias EPirate.Max.Network.Duels.Per.Day return $iif(%EPirate.End,999,10)
alias EPirate.Max.Network.rapes.Per.Day return $iif(%EPirate.End,999,10)
alias EPirate.Max.Rumors.Per.Day return $iif(%EPirate.End,999,4)
alias EPirate.Max.Skills return $iif(%EPirate.End,999,2)
alias EPirate.Mercy.Duration return 43200
alias EPirate.Max.Mercy.Per.Round return 3
alias EPirate.Crew.Sails.Per.Day return 3
alias EPirate.Sabotage.Per.Day return $iif(%EPirate.End,10,5)
alias EPirate.Captain.Port.Duel.Bet return 3
alias EPirate.Factions.Min.Ports return 9
alias EPirate.Command.Age.For.Bonus return 172800
alias Epirate.Old.Cmd.Bonus return 0.5
alias Epirate.Port.Bounty.Chance return 15
alias Epirate.Port.Jail.Chance return 10
alias EPirate.Disease.Player.Level return 22
alias EPirate.Disease.Sick.Level return 10
alias Epirate.Daily.Active.Player.Bonus return 0.5
alias Epirate.Targets.Before.Revenge return 5
alias EPirate.Max.Jails.Per.Day return 3
alias EPirate.First.of.the.Day.Bonus return 0.25
alias epirate.ship.base.max.maps return 10
alias EPirate.Rusty.Days return 2
alias Epirate.Ship.Treasure.Map.Hint.Help return 129600
alias $Epirate.Ship.Treasure.Map.Expire return 259200
alias Epirate.Max.Network.Robbed return 2
alias Epirate.Max.Network.Rob return 4
alias Epirate.Long.Voyage return 60
alias Epirate.Really.Long.Voyage return 120
alias Epirate.Rep.Max.Per.Day return 3
alias EPirate.Min.Level.LoveorHate return 5
alias Epirate.Market.Auto.Sell.Max.Items return 3
;Port Investments
alias epirate.port.investments.list return brothel,tavern,market
alias epirate.min.level.investments return 13
alias epirate.investment.min.collection.time.in.days return 1
alias epirate.investment.max.collection.time.in.days return 7
alias epirate.max.port.investments return 1
alias epirate.max.global.investments return 4
alias epirate.Brothel.investment.cost return 6
alias epirate.Brothel.Investment.Return return 0.25
alias epirate.Tavern.investment.cost return 12
alias epirate.Tavern.Investment.Return return 0.5
alias epirate.Market.investment.cost return 18
alias epirate.Market.Investment.Return return 0.75
alias epirate.unnecessary.purchase.limit return 8
alias epirate.Max.Independent.Ports return 3
alias epirate.max.loops return $calc($calc($hget(epirate.players.all,0).item * 2) + 3)

;moderator settings

alias epirate.mod.max.bans return 2
alias epirate.mod.max.ban.mins return 240
alias epirate.mod.max.brigs return 3
alias epirate.mod.max.brig.mins return 60
alias epirate.mod.max.captchas return 5

;Captcha Settings
alias EPirate.Captcha.Correct.Answer.Reward return 0.01
alias EPirate.Auto.Captcha.Triggers {
  if ($Epirate.Captcha.Level == 3) return 100
  elseif ($Epirate.Captcha.Level == 2) return 250
  else return 400
}
alias EPirate.Max.Captcha {
  if ($Epirate.Captcha.Level == 3) return 8
  elseif ($Epirate.Captcha.Level == 2) return 4
  else return 2
}
alias EPirate.Max.Captcha.Crew.Command {
  if ($Epirate.Captcha.Level == 3) return 3
  elseif ($Epirate.Captcha.Level == 2) return 2
  else return 1
}
alias epirate.captcha.time.in.between {
  if ($Epirate.Captcha.Level == 3) return 600
  elseif ($Epirate.Captcha.Level == 2) return 1800
  else return 3600
}
;end
