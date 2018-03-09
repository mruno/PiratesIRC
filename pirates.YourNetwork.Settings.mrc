;This is network specific items for PiratesIRC
;Your Network Name here and in the filename IF more than one instance (pirate ship) will be used

;
;Topic to be set by the bot. Either use $epirate.standard.topic or set your own. To set no topic, leave as $null
;default: $epirate.standard.topic
alias EPirate.Topic return $epirate.standard.topic
;---------------------------------
;This is for the "master ship". set to 0 to have only one ship (game instance)
alias EPirate.Debug.Ship return 1
alias epirate.ship.debug return 1
;---------------------------------
;this enables this ship to sail on its own and attack other ship/pirates
;default: 0
alias epirate.bot.ship return 1
;---------------------------------
;non-functional. set to 0
alias epirate.allow.non-nickserv.accounts return 0
;---------------------------------
;if players can be kick banned  a channel bot with !kb this will brig the pirate who typed it
;default: 0
alias epirate.trigger.kb return 0
;---------------------------------
;run pirate cleaner - if 1 disabled the deletion of pirates who abandon the ship after XX days as specified in global.settings.mrc
;default: 1
alias epirate.disable.pirate.cleaner return 1
;---------------------------------
;Time game will first start in $ctime. Enter a time to delay the game from starting (first round) giving players a chance to 'get ready' for it to start
;default: 1477090987
;alias EPirate.Start.Game.Time return 1477090987
;---------------------------------
;captain control - 1 if on. tries to keep the captain from getting to far ahead
;default: 1
alias EPirate.Captain.Control return 1
;---------------------------------
;no ops - does not halfop or op player specified. nicknames seperated by spaces
;default: $null
alias EPirate.No.Ops return
;---------------------------------
;clones - keeps players specified from performing certain command such as !p aye and !P mutiny. nicknames seperated by spaces
;default: $null
alias EPirate.Clones return 
;---------------------------------
;banned - players banned from the game. nicknames seperated by spaces
;default: $null
alias EPirate.Banned return 
;---------------------------------
;chan - irc channel game is played on
alias EPirate.Chan return #PiratesGame
;---------------------------------
;network - name of network the game is played on ($network)
alias EPirate.Network return Rizon
;---------------------------------
;ship - name of the ship
alias Epirate.Ship return The Revenge
;---------------------------------
;admin - nickname of the admin. ensure nickname is set as a user: 999:mruno!*@Dont.Tell.My.Wife.I.dot.dot.dot. Admin can perform !P Admin commands
;default: $null
alias EPirate.ADMIN.Nick return mruno
;---------------------------------
;Memoserv - disabled memoserv use on the network if set to 1
;default: 0
alias EPirate.Disable.MemoServ return 0
;---------------------------------
;name of the bot that players can duel. most of the time its $me
;default: $me
alias Epirate.Bot return $me
;---------------------------------
;unbans players after XX seconds if banned by another player within the channel. set to 0 to not unban players
;default: 0
alias Epirate.Unban.Players return 0
;---------------------------------
;Sends a player who bans another player to the brig (in addition to losing doubloons)
;default: 1
alias Epirate.Jail.Pirates.Who.Ban.Players return 1
;---------------------------------
;reduce spam - reduces the length and lines of text from the game. should be 0 when on a channel dedicated solely for this game
;default: 0
alias EPirate.Reduce.SPAM return 0
;---------------------------------
;next round delay - time in hours after someone wins and the next round starts
;default: 8
alias EPirate.Next.Round.Delay return 8
;---------------------------------
;onjoin - 1 enables the onjoin msg to nicknames that join and are not a player
;default: 0
alias EPirate.Onjoin return 0
;---------------------------------
;captcha - performs checks to ensure players are not using timers or a script to play
;default: 0
alias Epirate.Enable.Captcha return 0
;---------------------------------
;Captcha Check level. level 1 is the least frequent. Level: 1 for low, 2 for medium, 3 for strict
;default: 1
alias Epirate.Captcha.Level return 1
;---------------------------------
;enlist captcha - performs checks to ensure players are not bots auto enlisting wit' the crew
;default: 1
alias Epirate.Enable.Enlist.Captcha return 1
;---------------------------------
;censored - removes offensive wording. Game messages will be rated E10+ (Everyone 10+) if set to 1, otherwise rated T (teen)
;default: 0
alias EPirate.Censored return 0
;---------------------------------
;channel bots - names of players that will not identify with nickserv. should only be used on channel bots. nicknames separated by spaces
;default: $null
alias EPirate.ChannelBots return 
;---------------------------------
;passwords - enables the use of passwords as authentication in case nickserv is not used on the network or is down
;default: 0
alias EPirate.Password.Authenication return 0
;---------------------------------
;enable duels with other game instances (networks using dde). 1 to enable
;default: 1
alias Epirate.Network.Duels.Enabled return 1
;---------------------------------
;command to register to play the game
;default: Ye must be registered wit' Nickserv to enlist in the crew! Learn how wit': /msg nickserv HELP REGISTER
alias EPirate.Register.Msg return Ye must be registered wit' Nickserv to enlist in the crew! Learn how wit': /msg nickserv HELP REGISTER
;---------------------------------
;command to msg nickserv
;default: .msg NickServ
alias EPirate.Nickserv.Command return .msg NickServ
;---------------------------------
;command for a players's status with nickserv. most networks have it as STATUS or ACC
;default: STATUS
alias EPirate.Nickserv.Status.Command return STATUS
;---------------------------------
;command to msg memoserv
;default: .msg MemoServ
alias EPirate.MemoServ.Command return .msg MemoServ

;----------------
;Leveling Rates: Y is coarse and X is fine
;----------------
;Landlubber default  y 1.5545 and X 0.66
;Landlubbers are players level 1-9
alias epirate.landlubbers.rate.x return 0.66
alias epirate.landlubbers.rate.y return 1.52
;----
;Apprentice default  Y 1.525 and X 0.63
;Apprentice are players level 1-9
alias epirate.apprentice.rate.x return 0.63
alias epirate.apprentice.rate.y return 1.54
;----
;Master default  Y 1.543 and X 0.64
;Master are players level 1-9
alias epirate.master.rate.x return 0.64
alias epirate.master.rate.y return 1.57
;---- END
