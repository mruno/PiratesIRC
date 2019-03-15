;----------------------------------------------------------------
;Text Captcha by mruno
;*Sometimes* uses textcaptcha.com
;uses json script by sreject - http://hawkee.com/snippet/10194/
;----------------------------------------------------------------
;$Captcha.question to get a question
;$Captcha.answer(question»without»spaces,answer) returns $true if answer is correct
;----------------------------------------------------------------

alias -l Number.of.Captcha.Questions return 50
;number of captcha questions to store in database

alias -l File.for.Full.Captchas return C:\ep\Captcha.txt
;all captchas cached location

alias -l Alt.Captcha.File.List return c:\ep\captcha.alt.txt
;backup captcha questions

alias -l Clean.Captcha.Database.Every.XX.Days return 13
;set to 0 to disable clean/refreshing database

alias captcha.email return mruno@protonmail.com
;used by textcaptcha.com
;----------------------------------------------------------------
alias Captcha.question {
  ;$Captcha.question - returns a captcha question

  if (!$hget(captcha)) {
    echo -sat error no captchas in table
    hmake captcha
  }
  var %r $rand(1,$hget(captcha,0).data), %question $hget(captcha,%r).item
  set %question $replace(%question,$chr(187),$chr(32))
  if (%question) return %question
  else {
    var %line $read($Alt.Captcha.File.List)
    set %question $gettok(%line,1,42)
    var %answer $gettok(%line,2,42)
    hadd captcha $replace(%question,$chr(32),$chr(187)) $md5(%answer)
    return %question
  }
}
alias Captcha.answer {
  ;$Captcha.answer(question»without»spaces,answer) - $true if correct, $false if incorrect

  var %question $1, %answer $md5($lower($2-)), %answers $hget(captcha,%question), %i 0
  if (!%answers) return $true
  while ($gettok(%answers,0,44) > %i) {
    inc %i
    if (%answer isin $gettok(%answers,%i,44)) || ($2- == $gettok(%answers,%i,44)) {

      ;remove captcha question since answered correctly
      .timer 1 0 hdel captcha %question

      return $true
    }
  }
  return $false
}

on 1:START:{
  var %table captcha, %file captcha.dat
  if (!$hget(captcha)) hmake captcha
  if ($exists(captcha.dat)) hload captcha captcha.dat
  if (!$hget(captcha.options)) hmake captcha.options
  if ($exists(captcha.options.dat)) hload captcha.options captcha.options.dat
  else echo -st ERROR captcha.options.dat does not exist
  .timerCaptcha.Check.If.More.Needed -o 0 1800 Captcha.Check.If.More.Needed
  if (!$exists($Alt.Captcha.File.List)) echo -sat $Alt.Captcha.File.List does not exist as captcha alternative list. Format: question*answer
  .timer -o 1 $rand(1,120) Captcha.Check.If.More.Needed
  if (%captcha.dbase.date) && ($Clean.Captcha.Database.Every.XX.Days) {
    if ($round($calc($calc($ctime - %captcha.dbase.date) / 86400),0) >= $Clean.Captcha.Database.Every.XX.Days) {
      echo -sat Captcha database is over $v2 days old ( $+ $v1 $+ )... 
      echo -sat Refreshing captcha dbase! Stop with: /timerCaptcha.Refresh.Dbase OFF
      .timerCaptcha.Refresh.Dbase -o 1 20 Captcha.Refresh.Dbase
    }
    else echo -sat Captcha database is $v1 days old. Dbase will be refreshed in $calc($v2 - $v1) days...
  }
  else set %captcha.dbase.date $ctime
}
on 1:EXIT:{
  hsave captcha captcha.dat
  hsave captcha.options captcha.options.dat
}
alias Captcha.Refresh.Dbase {
  if (!$hget(captcha)) hmake captcha
  hdel -w captcha *
  Captcha.Check.If.More.Needed
  set %captcha.dbase.date $ctime
}
alias Captcha.Check.If.More.Needed {
  ;/Captcha.Check.If.More.Needed - checks to see if mininum number of questions are available. if not, gets more
  if (!$hget(captcha)) hmake captcha
  if ($hfind(captcha,*»*,0,w) < $Number.of.Captcha.Questions) {
    var %num $calc($Number.of.Captcha.Questions - $hget(captcha,0).data)
    .timerCaptcha.Get.More %num 10 Captcha.Get
  }
}
alias Captcha.Get {
  ;/Captcha.Get - assigns a captcha question and answer to an nick or id. if no nick or id, item will be ctime
  ;Will either use textcaptcha.com or create its own captcha questions

  if (!$hget(captcha)) hmake captcha
  var %r $rand(1,3)

  ;if email is incorrect, will not use textcaptcha.com
  if (!$ismail($captcha.email)) set %r 3

  if (%r == 1) {
    JSONOpen -u captcha $+(http://api.textcaptcha.com/,$captcha.email,.json)
    .timerCaptcha.Populate -m 0 500 Captcha.Populate $1
  }
  else Captcha.Create
}
alias Captcha.Populate {
  ;/Captcha.Populate this populates the captcha hash table with textcaptcha.com

  var %question $json(captcha,q)
  if (%question) .timerCaptcha.Populate off
  else return
  var %id $iif($1,$1,$ctime)
  var %answers, %answer, %i 0
  while ($json(captcha,a,%i)) {
    set %answer $json(captcha,a,%i)
    if (!%answer) break
    set %answers $addtok(%answers,%answer,44)
    inc %i
  }
  if (%answers) {
    ;add captcha question and answer to table

    set %question $replace(%question,$chr(32),$chr(187))
    if ($len(%answers) < 4000) {
      hadd captcha %question %answers
      write $+(",$File.for.Full.Captchas,") $+(%question,*,%answers)
    }
  }
  jsonclose captcha
}

alias Captcha.Create {
  ;/Captcha.Create - creates a captcha question/answer and records it to the hash table
  var %question, %answer, %r $rand(1,23)
  if (%r == 1) {
    var %1 $rand(1,9999), %2 $rand(1,9999)
    if (%1 == %2) inc %1 10
    if (%1 > %2) set %answer %1
    else set %answer %2
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    var %r $rand(1,3)
    if (%r == 1) set %question Which is more, %1 or %2 ?
    elseif (%r == 2) set %question What has more value, %1 or %2 ?
    else set %question Which is greater, %1 or %2 ?
  }
  elseif (%r == 2) {
    var %1 $rand(1,9999), %2 $rand(1,9999)
    if (%1 == %2) inc %1 10
    if (%1 < %2) set %answer %1
    else set %answer %2
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    var %r $rand(1,3)
    if (%r == 1) set %question Which is less, %1 or %2 ?
    elseif (%r == 2) set %question Which is less, %1 or %2 ?
    else set %question Which has the least value, %1 or %2 ?
  }
  elseif (%r == 3) {
    set %answer $Captcha.Name
    var %r $rand(1,3), %color $captcha.color
    if (%r == 1) set %question What is %answer $+ 's name?
    elseif (%r == 2) set %question %answer likes the color, %color $+ . Who likes %color $+ ?
    else set %question The name is %answer $+ . What is the name?
  }
  elseif (%r == 4) {
    var %s
    if ($rand(1,2) == 1) {
      set %answer uppercase
      set %s $upper($captcha.name)
    }
    else {
      set %answer lowercase
      set %s $lower($captcha.name)
    }
    var %r $rand(1,3)
    if (%r == 1) set %question Is this lowercase or uppercase: %s ?
    elseif (%r == 2) set %question Is this uppercase or lowercase: %s ?
    else set %question Lowercase or uppercase: %s ?
  }
  elseif (%r == 5) {
    var %1 $upper($rand(a,z)), %2 $upper($rand(a,z))
    while (%1 == %2) set %2 $upper($rand(a,z))
    if ($asc(%1) > $asc(%2)) set %answer %2
    else set %answer %1
    var %r $rand(1,3)
    if (%r == 1) set %question Which occurs first in the alphabet, %1 or %2 ?
    elseif (%r == 2) set %question Alphabetically, which is first %1 or %2 ?
    else set %question Which letter comes first, %1 or %2 ?
  }
  elseif (%r == 6) {
    var %l 4,9,16,25,36,49,64,81,100,144,400
    var %n $gettok(%l,$rand(1,$gettok(%l,0,44)),44)
    set %answer $sqrt(%n)
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    if ($Captcha.Convert.Number(%n)) set %n $ifmatch
    if ($rand(1,2) == 1) set %question What is the square root of %n ?
    else set %question The square root of %n is?
  }
  elseif (%r == 7) {
    var %n $rand(1,9)
    set %answer $Captcha.Convert.Number(%n)
    var %r $rand(1,3)
    if (%r == 1) set %question How do you spell %n ?
    elseif (%r == 2) set %question %n spelled is?
    else set %question Name this number in word(s): %n
  }
  elseif (%r == 8) {
    var %n $rand(1,9)
    set %answer %n
    if ($rand(1,2) == 1) set %question Convert this to number format: $Captcha.Convert.Number(%n)
    else set %question Convert to a number: $Captcha.Convert.Number(%n)
  }
  elseif (%r == 9) {
    var %n $rand(1,999)
    if (2 // %n) set %answer even
    else set %answer odd
    if ($Captcha.Convert.Number(%n)) set %n $ifmatch
    var %r $rand(1,4)
    if (%r == 1) set %question Is %n even or odd?
    elseif (%r == 2) set %question Even or odd, %n ?
    elseif (%r == 3) set %question %n is odd or even?
    else set %question Is %n an even or odd number?
  }
  elseif (%r == 10) {
    var %1 $rand(1,9), %2 $rand(1,9)
    set %answer $calc(%1 + %2)
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    if ($rand(1,2) == 1) set %1 $Captcha.Convert.Number(%1)
    if ($rand(1,2) == 1) set %2 $Captcha.Convert.Number(%2)
    var %r $rand(1,5)
    if (%r == 1) set %question What is %1 + %2 equal?
    elseif (%r == 2) set %question %1 + %2 = ?
    elseif (%r == 3) set %question %1 plus %2 = ?
    elseif (%r == 4) set %question The sum of %1 and %2 is?
    else set %question What is the sum of %1 and %2 ?
  }
  elseif (%r == 11) {
    var %1 $rand(10,20), %2 $rand(1,9)
    set %answer $calc(%1 - %2)
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    if ($rand(1,2) == 1) set %1 $Captcha.Convert.Number(%1)
    if ($rand(1,2) == 1) set %2 $Captcha.Convert.Number(%2)
    var %r $rand(1,5)
    if (%r == 1) set %question What is %1 - %2 equal?
    elseif (%r == 2) set %question %1 - %2 = ?
    elseif (%r == 3) set %question %2 subtracted from %1 is?
    elseif (%r == 4) set %question %1 from %2 is?
    else set %question What is %1 minus %2 ?
  }
  elseif (%r == 12) {
    var %1 $rand(1,10), %2 $rand(1,9)
    set %answer $calc(%1 * %2)
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    if ($rand(1,2) == 1) && ($Captcha.Convert.Number(%1)) set %1 $ifmatch
    if ($rand(1,2) == 1) && ($Captcha.Convert.Number(%2)) set %2 $ifmatch
    var %r $rand(1,5)
    if (%r == 1) set %question What is %2 * %1 equal?
    elseif (%r == 2) set %question %2 * %1 = ?
    elseif (%r == 3) set %question %2 times %1 is?
    elseif (%r == 4) set %question %2 multiplied by %1 is?
    else set %question What is the product of %2 * %1 ?
  }
  elseif (%r == 13) {
    var %1 $rand(10,100), %2 $rand(1,9), %i 0
    set %answer $calc(%1 / %2)
    while (. isin %answer) {
      inc %i
      set %1 $rand(10,20)
      set %2 $rand(1,9)
      set %answer $calc(%1 / %2)
      if (%i > 20) return
    }
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    if ($rand(1,2) == 1) && ($Captcha.Convert.Number(%1)) set %1 $ifmatch
    if ($rand(1,2) == 1) && ($Captcha.Convert.Number(%2)) set %2 $ifmatch
    var %r $rand(1,3)
    if (%r == 1) set %question What is %1 / %2 equal?
    elseif (%r == 2) set %question %1 / %2 = ?
    else set %question %1 divided by %2 is?
  }
  elseif (%r == 14) {
    var %r $rand(1,4), %n
    if (%r == 1) set %n $Captcha.Color
    elseif (%r == 2) set %n $Captcha.Name
    elseif (%r == 3) set %n $Captcha.Convert.Number($rand(1,20))
    else set %n $Captcha.Body.Part
    set %answer $len(%n)
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    set %r $rand(1,3)
    if (%r == 1) set %question How many characters are in the following: %n
    elseif (%r == 2) set %question Number of characters: %n
    else set %question How many letters are in: %n
  }
  elseif (%r == 15) {
    var %n $chr($rand(48,122))
    if (%n isnum) set %answer number
    elseif (%n isalpha) set %answer letter
    else set %answer symbol
    var %r $rand(1,4)
    if (%r == 1) set %question Number, letter, or symbol: %n
    elseif (%r == 2) set %question Letter, number or symbol: %n
    elseif (%r == 3) set %question Is the following a symbol, letter, or number: %n
    else set %question Symbol, number, or letter: %n
  }
  elseif (%r == 16) {
    var %n $rand(2,20)
    set %answer $calc(%n - 1)
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)
    set %n $ord(%n)
    var %r $rand(1,3)
    if (%r == 1) set %question If you scored %n $+ $chr(44) how many scored better than you?
    elseif (%r == 2) set %question How many precede %n $+ ?
    else set %question How many come before %n $+ ?
  }
  elseif (%r == 17) {
    var %n $rand(1,10), %i $rand(3,5), %m $iif($rand(1,2) == 1,+,*), %list %n, %a $rand(2,10)
    while (%i > 0) {
      inc %n $calc(%a %m %a)
      set %list $addtok(%list,%n,32)
      dec %i
      if (%i == 0) {
        inc %n $calc(%a %m %a)
        set %answer %n
      }
    }
    if (%list) {
      var %r $rand(1,3)
      if (%r == 1) set %question What comes next: %list ?
      elseif (%r == 2) set %question What is next in the series: %list ?
      else set %question What is next: %list ?
    }
  }
  elseif (%r == 18) {
    var %a $iif($rand(1,2) == 1,inc,dec), %i 0, %n
    if (%a == inc) set %n $rand(65,86)
    else set %n $rand(69,90)
    var %list $chr(%n)
    while (%i < 2) {
      inc %i
      %a %n
      set %list $addtok(%list,$chr(%n),32)
    }
    %a %n 
    set %answer $chr(%n)
    var %r $rand(1,3)
    if (%r == 1) set %question What letter is next: %list ?
    elseif (%r == 2) set %question What is the next letter: %list ?
    else set %question What is next: %list ?
  }
  elseif (%r == 19) {
    var %i 0, %n $rand(65,86), %list $chr(%n)
    while (%i < 4) {
      inc %i
      inc %n
      set %list $addtok(%list,$chr(%n),32)
    }
    set %answer $gettok(%list,$rand(2,4),32)
    set %list $remtok(%list,%answer,32)

    var %r $rand(1,3)
    if (%r == 1) set %question What letter is missing: %list ?
    elseif (%r == 2) set %question What is the missing letter: %list ?
    else set %question What is missing: %list ?
  }
  elseif (%r == 20) {
    var %i 0, %n $rand(65,86), %list %n
    while (%i < 4) {
      inc %i
      inc %n
      set %list $addtok(%list,%n,32)
    }
    set %answer $gettok(%list,$rand(2,4),32)
    set %list $remtok(%list,%answer,32)

    var %r $rand(1,3)
    if (%r == 1) set %question What number is missing: %list ?
    elseif (%r == 2) set %question What is the missing number: %list ?
    else set %question What is missing: %list ?
  }
  elseif (%r == 21) {
    var %n $rand(21,1000)
    if ($right(%n,1) == 0) set %n $rand(21,1000)
    set %n $calc(%n / 10)
    set %answer $round(%n,0)
    if ($Captcha.Convert.Number(%answer)) set %answer $addtok(%answer,$ifmatch,44)

    var %r $rand(1,3)
    if (%r == 1) set %question Round to the nearest whole number: %n
    elseif (%r == 2) set %question Round this number: %n
    else set %question %n rounded to the nearest whole number is?
  }
  elseif (%r == 22) {
    set %answer $captcha.color
    var %n $captcha.body.part

    var %r $rand(1,5)
    if (%r == 1) set %question $captcha.name has a $captcha.color $captcha.body.part and a %answer %n $+ . What color is the %n $+ ?
    elseif (%r == 2) set %question $captcha.name has a %answer %n and a $captcha.color $captcha.body.part $+ . What color is the %n $+ ?
    elseif (%r == 3) set %question $captcha.name has a %answer %n $+ $chr(44) $captcha.color $captcha.body.part $+ $chr(44) and a $captcha.color $captcha.body.part $+ . What color is the %n $+ ?
    elseif (%r == 4) set %question $captcha.name has a $captcha.color $captcha.body.part $+ $chr(44) $captcha.color $captcha.body.part $+ $chr(44) and a %answer %n $+ . What color is the %n $+ ?
    else set %question $captcha.name has a $captcha.color $captcha.body.part $+ $chr(44) %answer %n $+ $chr(44) and a $captcha.color $captcha.body.part $+ . What color is the %n $+ ?
  }
  elseif (%r == 23) {
    var %r $rand(1,3), %chr
    if (%r == 1) {
      set %answer letter
      if ($rand(1,2) == 1) set %chr $rand(a,z)
      else set %chr $rand(A,Z)
    }
    elseif (%r == 2) {
      set %answer number
      set %chr $rand(1,9)
    }
    else {
      set %answer symbol
      var %list !,@,^,&,*,(,),-,=,+,?,<,>,/,\,:,;,",'
      set %chr $gettok(%list,$rand(1,$gettok(%list,0,44)),44)
    }

    var %r $rand(1,3)
    if (%r == 1) set %question Symbol, letter, or number? %chr
    elseif (%r == 2) set %question Is the following a letter, number, or symbol? %chr
    else set %question %chr is a symbol, letter, or number?
  }

  ;which is a vowel
  ;which is a color
  ;how many colors in the list:
  ;$count
  ;how many times is 'string' repeated: $str(ho,3)


  if (%question) && (%answer) {
    set %question $replace(%question,$chr(32),$chr(187))
    hadd captcha %question %answer
    write $+(",$File.for.Full.Captchas,") $+(%question,*,%answer)
  }
}

alias Captcha.Color {
  var %c red,blue,yellow,orange,white,pink,black,brown,green
  return $gettok(%c,$rand(1,$gettok(%c,0,44)),44)
}
alias Captcha.Body.Part {
  var %p ankle,arch,arm,armpit,beard,calf,cheek,chest,chin,ear,earlobe,elbow,eye,eyebrow,eyelash,eyelid,face,finger,forearm,forehead,heel,hip,jaw,knee,knuckle,leg,lip,mouth,mustache,wrist,thumb,foot,shoulder,neck,nose,tongue
  return $gettok(%p,$rand(1,$gettok(%p,0,44)),44)
}
alias Captcha.Name {
  var %n
  if ($rand(1,2) == 1) set %n Jacob,Michael,Matthew,Joshua,Christopher,Nick,Andrew,Joseph,Daniel,Tyler,William,Brandon,Ryan,John,Zachary,David,Anthony,Jamie,Justin,Alexander,Mike,Dan
  else set %n Emily,Hannah,Madison,Ashley,Sarah,Alexa,Samantha,Jessica,Elizabeth,Taylor,Lauren,Alyssa,Kayla,Abigail,Brianna,Olivia,Emma,Megan,Grace,Victoria,Karen,Jennifer
  return $gettok(%n,$rand(1,$gettok(%n,0,44)),44)
}

alias Captcha.Convert.Number {
  if ($1 isnum) {
    if ($1 == 1) return one
    elseif ($1 == 2) return two
    elseif ($1 == 3) return three
    elseif ($1 == 4) return four
    elseif ($1 == 5) return five
    elseif ($1 == 6) return six
    elseif ($1 == 7) return seven
    elseif ($1 == 8) return eight
    elseif ($1 == 9) return nine
    elseif ($1 == 10) return ten
    elseif ($1 == 11) return eleven
    elseif ($1 == 12) return twelve
    elseif ($1 == 13) return thirteen
    elseif ($1 == 14) return fourteen
    elseif ($1 == 15) return fifteen
    elseif ($1 == 16) return sixteen
    elseif ($1 == 17) return seventeen
    elseif ($1 == 18) return eighteen
    elseif ($1 == 19) return nineteen
    elseif ($1 == 20) return twenty
  }
  else {
    if ($1 == one) return 1
    elseif ($1 == two) return 2
    elseif ($1 == three) return 3
    elseif ($1 == four) return 4
    elseif ($1 == five) return 5
    elseif ($1 == six) return 6
    elseif ($1 == seven) return 7
    elseif ($1 == eight) return 8
    elseif ($1 == nine) return 9
    elseif ($1 == ten) return 10
    elseif ($1 == eleven) return 11
    elseif ($1 == twelve) return 12
    elseif ($1 == thirteen) return 13
    elseif ($1 == fourteen) return 14
    elseif ($1 == fifteen) return 15
    elseif ($1 == sixteen) return 16
    elseif ($1 == seventeen) return 17
    elseif ($1 == eighteen) return 18
    elseif ($1 == nineteen) return 19
    elseif ($1 == twenty) return 20
  }
}
alias captcha.size.check {
  var %i 0, %item
  while ($hget(captcha,0).data > %i) {
    inc %i
    set %item $hget(captcha,%i).data
    if ($len($ifmatch) > 4000) echo -sta Too Big: $hget(captcha,%i)
  }
}

;----------------------------------------------------------------
alias -l ismail {
  ;http://forums.mirc.com/ubbthreads.php/topics/224358/
  var %r = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  if ($regex($1,%r)) { return $true }
  return $false
}
;json script by sreject - http://hawkee.com/snippet/10194/
alias JSONVersion {
  if ($isid) {
    return $iif($1 != short,JSONForMirc v,v) $+ 0.2.4
  }
}
alias JSONError {
  if ($isid) {
    return %JSONError 
  }
}
alias -l COMOpenTry {
  if (!$len($com($1))) {
    if ($len($~adiircexe) && $appbits == 64) {
      .comopen $1 ScriptControl
    }
    else {
      .comopen $1 MSScriptControl.ScriptControl
    }
    if ($com($1) && !$comerr) {
      return $true
    }
  }
}
alias JSONOpen {
  if ($isid) return
  unset %JSONError
  debugger -i 0 Calling /JSONOpen $1-
  var %switches = -, %error, %com, %file
  if (-* iswm $1) {
    %switches = $1
    tokenize 32 $2-
  }
  if ($regex(%switches, ([^dbfuw\-]))) {
    %error = Invalid switches specified: $regml(1)
  }
  elseif ($regex(%switches, ([dbfuw]).*?\1)) {
    %error = Duplicate switch specified: $regml(1)
  }
  elseif ($regex(%switches, /([bfu])/g) > 1) {
    %error = Conflicting switches: $regml(1) $+ , $regml(2)
  }
  elseif (u !isin %switches && w isin %switches) {
    %error = -w switch can only be used with -u
  }
  elseif ($0 < 2) {
    %error = Missing Parameters
  }
  elseif (!$regex($1, /^[a-z][a-z\d_.-]+$/i)) {
    %error = Invalid handler name: Must start with a letter and contain only letters numbers _ . and -
  }
  elseif ($com(JSONHandler:: $+ $1)) {
    %error = Name in use
  }
  elseif (b isin %switches && $0 != 2) {
    %error = Invalid parameter: Binary variable names cannot contain spaces
  }
  elseif (b isin %switches && &* !iswm $2) {
    %error = Invalid parameters: Binary variable names start with &
  }
  elseif (b isin %switches && !$bvar($2, 0)) {
    %error = Invalid parameters: Binary variable is empty
  }
  elseif (f isin %switches && !$isfile($2-)) {
    %error = Invalid parameters: File doesn't exist
  }
  elseif (f isin %switches && !$file($2-).size) {
    %error = Invalid parameters: File is empty
  }
  elseif (u isin %switches && $0 != 2) {
    %error = Invalid parameters: URLs cannot contain spaces
  }
  else {
    if (!$COMOpenTry(JSONHandler:: $+ $1)) {
      %error = Unable to create an instance of MSScriptControl.ScriptControl
    }
    else {
      %com = JSONHandler:: $+ $1
      if (!$com(%com, language, 4, bstr, jscript) || $comerr) {
        %error = Unable to set ScriptControl's language to Javascript
      }
      elseif (!$com(%com, timeout, 4, bstr, 60000) || $comerr) {
        %error = Unable to set ScriptControl's timeout to 60seconds
      }
      elseif (!$com(%com, ExecuteStatement, 1, bstr, $JScript) || $comerr) {
        %error = Unable to add required javascript to the ScriptControl instance
      }
      elseif (u isincs %switches) {
        if (1 OK != $jstry(%com, $jscript(urlInit), $escape($2-).quote)) {
          %error = $gettok($v2, 2-, 32)
        }
        elseif (w !isincs %switches && 0 ?* iswm $jsTry(%com, $jscript(urlParse), status="error").withError) {
          %error = $gettok($v2, 2-, 32)
        }
      }
      elseif (f isincs %switches) {
        if (1 OK != $jstry(%com, $jscript(fileParse), $escape($longfn($2-)).quote)) {
          %error = $gettok($v2, 2-, 32)
        }
      }
      elseif (b isincs %switches) {
        %file = $tempfile
        bwrite $qt(%file) -1 -1 $2
        debugger %com Wrote $2 to $qt(%file)
        if (0 ?* iswm $jstry(%com, $jscript(fileParse), $escape(%file).quote)) {
          %error = $gettok($v2, 2-, 32)
        }
      }
      else {
        %file = $tempfile
        write -n $qt(%file) $2-
        debugger %com Wrote $2- to $qt(%file)
        if (0 ?* iswm $jstry(%com, $jscript(fileParse), $escape(%file).quote)) {
          %error = $gettok($v2, 2-, 32)
        }
      }
      if (!%error) {
        if (d isin %switches) {
          $+(.timer, %com) -o 1 0 JSONClose $1
        }
        Debugger -s %com Successfully created
      }
    }
  }
  :error
  %error = $iif($error, $error, %error)
  reseterror
  if (%file && $isfile(%file)) {
    .remove $qt(%file)
    debugger %com Removed $qt(%file)
  }
  if (%error) {
    if (%com && $com(%com)) {
      .comclose %com
    }
    set -eu0 %JSONError %error
    Debugger -e 0 /JSONOpen %switches $1- --RAISED-- %error
  }
}
alias JSONUrlMethod {
  if ($isid) return
  unset %JSONError
  debugger -i 0 Calling /JSONUrlMethod $1-
  var %error, %com
  if ($0 < 2) {
    %error = Missing parameters
  }
  elseif ($0 > 2) {
    %error = Too many parameters specified
  }
  elseif (!$regex($1, /^[a-z][a-z\d_.\-]+$/i)) {
    %error = Invalid handler name: Must start with a letter and contain only letters numbers _ . and -
  }
  elseif (!$com(JSONHandler:: $+ $1)) {
    %error = Invalid handler name: JSON handler does not exist
  }
  elseif (!$regex($2, /^(?:GET|POST|PUT|DEL)$/i)) {
    %error = Invalid request method: Must be GET, POST, PUT, or DEL
  }
  else {
    var %com = JSONHandler:: $+ $1
    if (1 OK != $jsTry(%com, $JScript(UrlMethod), status="error", $qt($upper($2))).withError) {
      %error = $gettok($v2, 2-, 32)
    }
    else {
      Debugger -s $+(%com,>JSONUrlMethod) Method set to $upper($2)
    }
  }
  :error
  %error = $iif($error, $v1, %error)
  reseterror
  if (%error) {
    set -eu0 %JSONError %error
    if (%com) {
      set -eu0 % [ $+ [ %com ] $+ ] ::Error %error
    }
    Debugger -e $iif(%com, $v1, 0) /JSONUrlMethod %switches $1- --RAISED-- %error
  }
}
alias JSONUrlHeader {
  if ($isid) return
  unset %JSONError
  debugger -i 0 Calling /JSONUrlHeader $1-
  var %error, %com
  if ($0 < 3) {
    %error = Missing parameters
  }
  elseif (!$regex($1, /^[a-z][a-z\d_.\-]+$/i)) {
    %error = Invalid handler name: Must start with a letter and contain only letters numbers _ . and -
  }
  elseif (!$com(JSONHandler:: $+ $1)) {
    %error = Invalid handler name: JSON handler does not exist
  }
  elseif (!$regex($2, /^[a-z_-]+:?$/i)) {
    %error = Invalid header name: Header names can only contain letters, _ and -
  }
  else {
    %com = JSONHandler:: $+ $1
    if (1 OK !== $jsTry(%com, $JScript(UrlHeader), status="error", $escape($regsubex($2, :+$, )).quote, $escape($3-).quote).withError) {
      %error = $gettok($v2, 2-, 32)
    }
    else {
      Debugger -s $+(%com,>JSONUrlHeader) Header $+(',$2,') set to $3-
    }
  }
  :error
  %error = $iif($error, $v1, %error)
  reseterror
  if (%error) {
    set -eu0 %JSONError %error
    if (%com) set -eu0 % [ $+ [ %com ] $+ ] ::Error %error
    Debugger -e $iif(%com, $v1, 0) /JSONUrlMethod %switches $1- --RAISED-- %error
  }
}
alias JSONUrlOption {
  if ($isid) return
  unset %JSONError
  Debugger -i 0 /JSONUrlOption is depreciated and will be removed. Please use /JSONUrlMethod and /JSONUrlHeader
  if ($2 == method) {
    JSONUrlMethod $1 $3-
  }
  else {
    JSONUrlHeader $1-
  }
}
alias JSONUrlGet {
  if ($isid) return
  unset %JSONError
  Debugger -i 0 Calling /JSONUrlGet $1-
  var %switches = -, %error, %com, %file
  if (-* iswm $1) {
    %switches = $1
    tokenize 32 $2-
  }
  if (!$0 || (%switches != - && $0 < 2)) {
    %error = Missing parameters
  }
  elseif (!$regex(%switches, ^-[bf]?$)) {
    %error = Invalid switch(es) specified
  }
  elseif (!$regex($1, /^[a-z][a-z\d_.\-]+$/i)) {
    %error = Invalid handler name: Must start with a letter and contain only letters numbers _ . and -
  }
  elseif (!$com(JSONHandler:: $+ $1)) {
    %error = Specified handler does not exist
  }
  elseif (b isincs %switches && &* !iswm $2) {
    %error = Invalid bvar name: bvars start with &
  }
  elseif (b isincs %switches && $0 > 2) {
    %error = Invalid bvar name: Contains spaces: $2-
  }
  elseif (f isincs %switches && !$isfile($2-)) {
    %error = Specified file does not exist: $longfn($2-)
  }
  else {
    %com = JSONHandler:: $+ $1
    if ($0 > 1) {
      if (f isincs %switches) {
        if (0 ?* iswm $jsTry(%com, $JScript(UrlData), status="error", $escape($longfn($2-)).quote).withError) {
          %error = $gettok($v2, 2-, 32)
        }
        else {
          Debugger -s $+(%com,>JSONUrlGet) Stored $longfn($2-) as data to send with HTTP Request
        }
      }
      else {
        %file = $tempfile
        if (b isincs %switches) {
          bwrite $qt(%file) -1 -1 $2
        }
        else {
          write -n $qt(%file) $2-
        }
        Debugger -s $+(%com,>JSONUrlGet) Wrote specified data to %file
        if (0 ?* iswm $jsTry(%com, $JScript(UrlData), status="error", $escape(%file).quote).withError) {
          %error = $gettok($v2, 2-, 32)
        }
        else {
          Debugger -s $+(%Com,>JSONUrlGet) Stored $2- as data to send with HTTP Request
        }
        .remove $qt(%file)
      }
    }
    if (!%error) {
      if (0 ?* iswm $jsTry(%com, $JScript(URLParse), status="error").withError) {
        %error = $gettok($v2, 2-, 32)
      }
      else {
        Debugger -s $+(%com,>JSONUrlGet) Request finished
      }
    }
  }
  :error
  %error = $iif($error, $v1, %error)
  reseterror
  if (%error) {
    set -eu0 %JSONError %error
    if (%com) set -eu0 % [ $+ [ %com ] $+ ] ::Error %error
    Debugger -e $iif(%com, $v1, 0) /JSONUrlGet %switches $1- --RAISED-- %error
  }
}
alias JSONGet {
  if ($isid) return
  unset %JSONError
  debugger -i 0 /JSONGet is depreciated and will be removed. Please use /JSONUrlGet
  JSONUrlGet $1-
}
alias JSONClose {
  if ($isid) return
  unset %JSONError
  Debugger -i 0 /JSONClose $1-
  var %switches = -, %error, %com, %x
  if (-* iswm $1) {
    %switches = $1
    tokenize 32 $2-
  }
  if ($0 < 1) {
    %error = Missing parameters
  }
  elseif ($0 > 1) {
    %error = Too many parameters specified.
  }
  elseif (%switches !== - && %switches != -w) {
    %error = Unknown switches specified
  }
  elseif (%switches == -) {
    %com = JSONHandler:: $+ $1
    if ($com(%com)) { .comclose %com }
    if ($timer(%com)) { $+(.timer,%com) off }
    unset % [ $+ [ %com ] $+ ] ::Error
    Debugger -i %com Closed
  }
  else {
    %com = JSONHandler:: $+ $1
    %x = 1
    while (%x <= $com(0)) {
      if (%com iswm $com(%x)) {
        .comclose $v1
        $+(.timer,$v1) off
        unset % [ $+ [ $v1 ] $+ ] ::*
        Debugger -i %com Closed
      }
      else {
        inc %x
      }
    }
  }
  :error
  %error = $iif($error, $v1, %error)
  reseterror
  if (%error) {
    set -eu0 %JSONError %error
  }
}
alias JSONList {
  if ($isid) return
  Debugger -i 0 Calling /JSONList $1-
  var %x = 1, %i = 0
  while ($com(%x)) {
    if (JSONHandler::* iswm $v1) {
      inc %i
      echo $color(info) -a * # $+ %i : $regsubex($v2, /^JSONHandler::/, )
    }
    inc %x
  }
  if (!%i) {
    echo $color(info) -a * No active JSON handlers
  }
}
alias JSON {
  if (!$isid) {
    return
  }
  var %x, %calling, %i = 0, %com, %get = json, %ref = $false, %error, %file
  if ($JSONDebug) {
    %x = 0
    while (%x < $0) {
      inc %x
      %calling = %calling $+ $iif(%calling,$chr(44)) $($ $+ %x,2)
    }
    debugger -i 0 Calling $!JSON( $+ %calling $+ $chr(41) $+ $iif($prop,. $+ $prop)
  }
  if (!$0) {
    return
  }
  if ($regex($1, ^\d+$)) {
    %x = 1
    while ($com(%x)) {
      if (JSONHandler::* iswm $v1) {
        inc %i
        if (%i == $1) {
          %com = $com(%x)
          break
        }
      }
      inc %x
    }
    if ($0 == 1 && $1 == 0) {
      return %i
    }
  }
  elseif ($regex($1, /^[a-z][a-z\d_.-]+$/i)) {
    %com = JSONHandler:: $+ $1
  }
  elseif ($regex($1, /^(JSONHandler::[a-z][a-z\d_.-]+)::(.+)$/i)) {
    %com = $regml(1)
    %get = json $+ $regml(2)
    %ref = $true
  }
  if (!%com) {
    %error = Invalid name specified
  }
  elseif (!$com(%com)) {
    %error = Handler doesn't exist
  }
  elseif (!$regex($prop, /^(?:Status|IsRef|IsChild|Error|Data|UrlStatus|UrlStatusText|UrlHeader|Fuzzy|FuzzyPath|Type|Length|ToBvar|IsParent)?$/i)) {
    %error = Unknown prop specified
  }
  elseif ($0 == 1) {
    if ($prop == isRef) {
      return %ref
    }
    elseif ($prop == isChild) {
      Debugger -i 0 $!JSON().isChild is depreciated use $!JSON().isRef
      return %ref
    }
    elseif ($prop == status) {
      if ($com(%com, eval, 1, bstr, status) && !$comerr) {
        return $com(%com).result
      }
      else {
        %error = Unable to determine status
      }
    }
    elseif ($prop == error) {
      if ($eval($+(%,%com,::Error),2)) {
        return $v1
      }
      elseif ($com(%com, eval, 1, bstr, error) && !$comerr) {
        return $com(%com).result
      }
      else {
        %error = Unable to determine if there is an error
      }
    }
    elseif ($prop == UrlStatus || $prop == UrlStatusText) {
      if (0 ?* iswm $jsTry(%com, $JScript($prop))) {
        %error = $gettok($v2, 2-, 32)
      }
      else {
        return $v2
      }
    }
    elseif (!$prop) {
      return $regsubex(%com,/^JSONHandler::/,)
    }
  }
  elseif (!$regex($prop, /^(?:fuzzy|fuzzyPath|data|type|length|toBvar|isParent)?$/i)) {
    %error = $+(',$prop,') cannot be used when referencing items
  }
  elseif ($prop == toBvar && $chr(38) !== $left($2, 1) ) {
    %error = Invalid bvar specified: bvar names must start with &
  }
  elseif ($prop == UrlHeader) {
    if ($0 != 2) {
      %error = Missing or excessive header parameter specified
    }
    elseif (0 ?* iswm $jsTry(%com, $JScript(UrlHeader), $escape($2).quote)) {
      %error = $gettok($v2, 2-, 32)
    }
    else {
      return $gettok($v2, 2-, 32)
    }
  }
  elseif (fuzzy* iswm $prop) {
    if ($0 < 2) {
      %error = Missing parameters
    }
    else {
      var %x = 2, %path, %res
      while (%x <= $0) {
        %path = %path $+ $escape($($ $+ %x, 2)).quote $+ $chr(44)
        inc %x
      }
      %res = $jsTry(%com, $JScript(fuzzy), %get, $left(%path, -1))
      if (0 ? iswm %res) {
        %error = $gettok(%res, 2-, 32)
      }
      elseif ($prop == fuzzy) {
        %get = %get $+ $gettok(%res, 2-, 32)
      }
      else {
        return $regsubex(%get, ^json, ) $+ $gettok(%res, 2-, 32)
      }
    }
  }
  if (!%error) {
    if (fuzzy* !iswm $prop) {
      %x = $iif($prop == toBvar, 3, 2)
      while (%x <= $0) {
        %i = $($ $+ %x, 2)
        if ($len(%i)) {
          %get = $+(%get, [", $escape(%i), "])
          inc %x
        }
        else {
          %error = Empty index|item passed.
          break
        }
      }
    }
    if (!%error) {
      if ($prop == type) {
        if (0 ?* iswm $jsTry(%com, $JScript(typeof), %get)) {
          %error = $gettok($v2, 2-, 32)
        }
        else {
          return $gettok($v2, 2-, 32)
        }
      }
      elseif ($prop == length) {
        if (0 ?* iswm $jsTry(%com, $JScript(length), %get)) {
          %error = $gettok($v2, 2-, 32)
        }
        else {
          return $gettok($v2, 2-, 32)
        }
      }
      elseif ($prop == isParent) {
        if (0 ?* iswm $jsTry(%com, $JScript(isparent), %get)) {
          %error = $gettok($v2, 2-, 32)
        }
        else {
          return $iif($gettok($v2, 2-, 32), $true, $false)
        }
      }
      elseif ($prop == toBvar) {
        %file = $tempfile
        if (0 ?* iswm $jsTry(%com, $JScript(tofile), $escape(%file).quote, %get)) {
          %error = $gettok($v2, 2-, 32)
        }
        else {
          bread $qt(%file) 0 $file(%file) $2
        }
        if ($isfile(%file)) { .remove $qt(%file) }
      }
      elseif (0 ?* iswm $jsTry(%com, $JScript(get), %get)) {
        %error = $gettok($v2, 2-, 32)
        if (%error == Object or Array referenced) {
          %error = $null
          Debugger -s $+(%com,>$JSON) Result is an Object or Array; returning reference
          return %com $+ :: $+ $regsubex(%get, /^json/, )
        }
      }
      else {
        var %res = $gettok($v2, 2-, 32)
        Debugger -s $+(%com,>$JSON) %get references %res
        return %res
      }
    }
  }
  :error
  %error = $iif($error, $v1, %error)
  if (%error) {
    set -eu0 %JSONError
    if (%com && $com(%com)) {
      set -eu0 $+(%,%com,::Error) %error
    }
    var %r
    %x = 0
    while (%x < $0) {
      inc %x
      %r = $addtok(%r, $chr(32) $+ $ [ $+ [ %x ] ] , 44)
    }
    debugger -e $iif(%com && $com(%com),%com,0) $!JSON( $+ %r $+ ) $+ $+ $iif($prop,. $+ $prop) --RAISED-- %error
  }
}
alias JSONDebug {
  if ($isid) {
    return $iif($group(#JSONForMircDebug) == on, $true, $false)
  }
  elseif ($0) {
    tokenize 32 $iif($group(#JSONForMircDebug) == on, off, on)
  }
  if ($regex($1-,/^(?:on|enable)$/i)) {
    .enable #JSONForMircDebug
    debugger -i Debugger Now Enabled
  }
  elseif ($regex($1-, /^(?:off|disable)$/i)) {
    .disable #JSONForMircDebug
    if ($window(@JSONForMircDebug)) {
      close -@ @JSONForMircDebug
    }
  }
}
#JSONForMircDebug off
alias -l Debugger {
  if ($isid) return
  if (!$window(@JSONForMircDebug)) {
    window -zk0 @JSONForMircDebug
  }
  var %switches = -, %c
  if (-* iswm $1) {
    %switches = $1
    tokenize 32 $2-
  }
  if (e isincs %switches) {
    %c = 04
  }
  elseif (s isincs %switches) {
    %c = 12
  }
  else {
    %c = 03
  }
  var %n = $iif($1, $1, JSONForMirc)
  %n = $regsubex(%n, /^JSONHandler::, )
  aline -p @JSONForMircDebug $+($chr(3),%c,[,%n,],$chr(15)) $2-
}
#JSONForMircDebug end
alias -l Debugger return
menu @JSONForMircDebug {
  .Clear: clear -@ @JsonForMircDebug
  .Disable and Close: JSONDebug off
}
alias -l tempfile {
  var %n = 1
  while ($isfile($scriptdirJSONTmpFile $+ %n $+ .json)) {
    inc %n
  }
  return $scriptdirJSONTmpFile $+ %n $+ .json
}
alias -l escape {
  var %esc = $replace($1-,\,\\,",\")
  return $iif($prop == quote, $qt(%esc), %esc)
}
alias -l JScript {
  if (!$isid) return
  if (!$0) return (function(){status="init";json=null;url={m:"GET",u:null,h:[],d:null};response=null;var r,x=['MSXML2.SERVERXMLHTTP.6.0','MSXML2.SERVERXMLHTTP.3.0','MSXML2.SERVERXMLHTTP','MSXML2.XMLHTTP.6.0','MSXML2.XMLHTTP.3.0','Microsoft.XMLHTTP'],i;while(x.length){try{r=new ActiveXObject(x.shift());break}catch(e){}}xhr=r?function(){r.open(url.m,url.u,false);for(i=0;i<url.h.length;i+=1)r.setRequestHeader(url.h[i][0],url.h[i][1]);r.send(url.d);return(response=r).responseText}:function(){throw new Error("HTTP Request object not found")};read=function(f){var a=new ActiveXObject("ADODB.stream"),d;a.CharSet="utf-8";a.Open();a.LoadFromFile(f);if(a.EOF){a.close();throw new Error("No content in file")}d=a.ReadText();a.Close();return d;};write=function(f,d){var a=new ActiveXObject("ADODB.stream");a.CharSet="utf-8";a.Open();a.WriteText(d);a.SaveToFile(f,2);a.Close()};parse=function(t){if(/^[\],:{}\s]*$/.test((t=(String(t)).replace(/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,function(a){return'\\u'+('0000'+a.charCodeAt(0).toString(16)).slice(-4)})).replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,'@').replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,']').replace(/(?:^|:|,)(?:\s*\[)+/g,''))){try{return eval('('+t+')');}catch(e){throw new SyntaxError('Unable to Parse: Invalid JSON');}}throw new SyntaxError('Unable to Parse: Invalid JSON')};fuzzy=function(){var a=Array.prototype.slice.call(arguments),b=a.shift(),c="",d=Object.prototype.toString.call(b),e,f,g,h,i;for(e=0;e<a.length;e+=1){f=a[e];if(b.hasOwnProperty(f)){if(typeof b[f]==="function")throw new TypeError("Reference points to a function");b=b[f];c+="[\""+f+"\"]"}else if(d==="[object Object]"){if(typeof f==="number")f=f.toString(10);f=f.toLowerCase();g=-1;i=!1;for(h in b){if(b.hasOwnProperty(h)&&typeof b[h]!=="function"){g+=1;if(h.toLowerCase()===f){b=b[h];c+="[\""+h+"\"]";i=!0;break}else if(g.toString(10)===f){b=b[h];c+="[\""+h+"\"]";i=!0;break}}}if(!i)throw new Error("No matching reference found");}else{throw new Error("Reference does not exist")}d=Object.prototype.toString.call(b)}return c}}());
  if ($1 == FileParse)     return if(status!=="init")throw new Error("Parse Not Pending");json=parse(read(@1@));status="done";
  if ($1 == UrlInit)       return if(status!=="init")throw new Error("JSON handler not ready");url.u=@1@;status="url";
  if ($1 == UrlMethod)     return if(status!=="url")throw new Error("URL Request Not Pending");url.m=@1@;
  if ($1 == UrlHeader)     return if(status!=="url")throw new Error("URL Request Not Pending");url.h.push([@1@,@2@]);
  if ($1 == UrlData)       return if(status!=="url")throw new Error("URL Request Not Pending");url.d=read(@1@);
  if ($1 == UrlParse)      return if(status!=="url")throw new Error("URL Request Not Pending");json=parse(xhr());status="done";
  if ($1 == UrlStatus)     return if(status!=="done")throw new Error("Data not parsed");if(!response)throw new Error("URL request not made");return response.status;
  if ($1 == UrlStatusText) return if(status!=="done")throw new Error("Data not parsed");if(!response)throw new Error("URL request not made");return response.statusText;
  if ($1 == UrlHeader)     return if(status!=="done")throw new Error("Data not parsed");if(!response)throw new Error("URL Request not made");return response.getResponseHeader(@1@);
  if ($1 == fuzzy)         return if(status!=="done")throw new Error("Data not parsed");return "1 "+fuzzy(@1@,@2@);
  if ($1 == typeof)        return if(status!=="done")throw new Error("Data not parsed");var i=@1@;if(i===undefined)throw new TypeError("Reference doesn't exist");if(i===null)return"1 null";var s=Object.prototype.toString.call(i);if(s==="[object Array]")return"1 array";if(s==="[object Object]")return"1 object";return "1 "+typeof(i);
  if ($1 == length)        return if(status!=="done")throw new Error("Data not parsed");var i=@1@;if(i===undefined)throw new TypeError("Reference doesn't exist");if(/^\[object (?:String|Array)\]$/.test(Object.prototype.toString.call(i)))return"1 "+i.length.toString(10);throw new Error("Reference is not a string or array");
  if ($1 == isparent)      return if(status!=="done")throw new Error("Data not parsed");var i=@1@;if(i===undefined)throw new TypeError("Reference doesn't exist");if(/^\[object (?:Object|Array)\]$/.test(Object.prototype.toString.call(i)))return"1 1";return"1 0";
  if ($1 == tofile)        return if(status!=="done")throw new Error("Data not parsed");var i=@2@;if(i===undefined)throw new TypeError("Reference doesn't exist");if(typeof i!=="string")throw new TypeError("Reference must be a string");write(@1@,i);
  if ($1 == get)           return if(status!=="done")throw new Error("Data not parsed");var i=@1@;if(i===undefined)throw new TypeError("Reference doesn't exist");if(i===null)return"1";if(/^\[object (?:Array|Object)\]$/.test(Object.prototype.toString.call(i)))throw new TypeError("Object or Array referenced");if(i.length>4000)throw new Error("Data would exceed mIRC's line length limit");if(typeof i == "boolean")return i?"1 1":"1 0";if(typeof i == "number")return "1 "+i.toString(10);return "1 "+i;
}
alias -l jsTry {
  if ($isid) {
    if ($0 < 2 || $prop == withError && $0 < 3) {
      return 0 Missing parameters
    }
    elseif (!$com($1)) {
      return 0 No such com
    }
    else {
      var %code = $2, %error, %n = 2, %o, %js
      if ($prop == withError) {
        %error = $3
        %n = 3
      }
      %o = %n
      while (%n < $0) {
        inc %n
        set -l $+(%, arg, $calc(%n - %o)) $eval($+($, %n), 2)
      }
      %code = $regsubex($regsubex(%code, /@(\d+)@/g, $var($+(%, arg, \t ),1).value), [\s;]+$, )
      %error = $regsubex($regsubex(%error, /@(\d+)@/g, $var($+(%, arg, \t ),1).value), [\s;]+$, )
      if ($len(%code)) {
        %code = %code $+ $chr(59)
      }
      if ($len(%error)) {
        %error = %error $+ $chr(59)
      }
      %js = (function(){error=null;try{ $+ %code $+ return"1 OK"}catch(e){ $+ %error $+ error=e.message;return"0 "+error}}());
      debugger $1>$jsTry Executing: %js
      if (!$com($1, eval, 1, bstr, %js) || $comerr) {
        return 0 Unable to execute specified javascript
      }
      return $com($1).result
    }
  }
}
