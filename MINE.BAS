rem ===raw audio player===

rem Copyright 2017, gombe all right reserved.

rem   This software is free software
rem and there is NO WARRANTY.
rem   No restriction on use. You can
rem use, modify and redistribute it
rem under your responsibility.
rem   Redistribution of source code 
rem must retain the above copyright
rem notice.

rem for BASIC KM-1203 or later.
rem (use SD library.)

rem   without LPF, AMP may be damaged.

rem in>-----+---------->output
rem         |
rem         = C
rem         |
rem         - (Ground)
rem C is 0.01uF or so.

rem ==sound data format==
rem sampling    : 32KHz
rem channel     : 1ch
rem resolution  : 8bit
rem data format : raw
rem size        : 1024*2 Byte

rem ==system specific==
rem DMA         : use ch 1
rem PWM         : use OC4
rem PWMtimebase : use tmr3
rem DMATimeBase : use tmr4
rem clock freq  : 3.58*16

rem ==memo==
rem  If you want to use graphic mode,
rem you must reculculate DMATimeBase.

rem  If you want to make audio data,
rem you should use sox command.
rem $ sox <in> -r32000 -c1 -b8 -u <out>.raw

rem  If you play premade data, you 
rem can use aplay command.
rem $ aplay <in> -r32000


rem ==gloval variables==
 rem c : count playing
 rem s : sound buff(1024*2) 

rem ==functions==
 rem setpwm
  rem initialize pwm for audio
  rem use TMR3,OC4
  rem resolution:8bit
 rem setbst
  rem initialize base timer
  rem use TMR4
  rem interval:1/32KHz
  rem  if you use graphic mode, you
  rem need reculculation of interval.
 rem setdma
  rem initialize DMA
  rem args
   rem ARGS(1):buffer
   rem ARGS(2):buffer size
  rem for detail, ref:body
 rem clrbuf
  rem clear buffer
  rem clear audio buffer with 0x7F
 rem inimus
  rem initialize for music
  rem ARG(1):filename
 rem diptim
  rem display time
 rem mustas
  rem do music task
  rem  this function must be called 
  rem every 1 frame, or overrun.
 rem stpmus
  rem  deinit dma and timers to stop 
  rem music.


rem ===================
rem ====source code====
rem ===================


label bgmain
rem  usegraphic
  cls
  var i,a
  DIM S(512)
rem pwm setup
  gosub setpwm
rem time base setup
  gosub setbst
rem dma setup
  gosub setdma,S,2048

  gosub clrbuf
  gosub init

rem init for music
  gosub inimus,"music.raw"

end

rem clear buffer
label clrbuf
  var i
  for i=0 to 511
    s(i)=0x7F7F7F7F
  next
return

rem dma init
rem args(1):buff pointer
rem args(2):size of buff[byte]

rem DMAMode     : auto
rem trigger     : TMR4IRQ
rem DMAchannel  : ch0
rem source      : buff
rem destination : OC4RS

label setdma
  var A
  A = 0xBF883000
rem dma on
  A(2) = 0x00008000
  A = 0xBF883060
rem enable ch0 (auto mode,pri lv=2)
  A(0) = 0x00000012
rem transfer @irq tmr4(19)
rem (19<<8) OR (1<<4)
  A(4) = 0x1310
rem set source addr
  A(12) = ARGS(1) AND 0x1FFFFFFF
rem set dest addr OC4RS
rem (0x8F803620 AND 0x1FFFFFFF)
  A(16) = 0x1F803620
rem set source size [0(as 65536)-65535]
  A(20) = ARGS(2)
rem set dist size
  A(24) = 1
rem set cell size
  A(36) = 1
  gosub clrflg
rem turn on dma ch0
  A(2) = 0x00000080
return

rem dma abort
label dmaabo
rem force abort
  var A
  A = 0xBF883060
  A(6) =0x40
return

rem dma clear if flags
label clrflg
rem clear if flags(Half and full trans)
  var A
  A = 0xBF883060
  A(9) = 0x00FF00FF
return

rem dma trans half?
label dmishf
  var A
  A = 0xBF883080
return A(0) AND 0x40

rem dma trans finished?
label dmisfi
  var A
  A = 0xBF883080
return A(0) AND 0x80

rem set base timer(timer4)
rem to generate interval (sampling rate 32kHz)
label setbst
  var A
  A = 0xBF800C00
  A(0) = 0x00000000
rem TMR4 reset
  A(4) = 0x0000
rem PR4 set (3.58*16)MHz/32kHz = 1790
rem  if you use graphic mode, set this
rem value to
rem (3.58*15)MHz/32KHz = 1678
  A(8) = 1790
rem disable interrupt
  A = 0xBF881060
  A(1) = 0x00080000
rem tmr start
  A = 0xBF800C00
  A(2) = 0x00008000
return

label setpwm
  var A
rem **Pin setting**
  A = 0xBF80FB60
  A(0) = 5
rem **TIMR3 settings**
  A = 0xBF800A00
rem clear TMR3
  A(4) = 0x0000
rem clear PR3
  A(8) = 0x0100
rem start TMR3
  A(0) = 0x8000
rem **OC4 setting**
  A = 0xBF803600
  A(0) = 0x000e
  A(2) = 0x8000
return

rem stop sound
label stopsn
  var A
rem stop TMR3
  A = 0xBF800A00
  A(1) = 0x8000
rem stop TMR4
  A = 0xBF800C00
  A(1) = 0x8000  
return

rem init for music
label inimus
  fopen ARGS$(1),"r"
return

rem music task
rem call every 1F
label mustas
  var b
  b=0
rem done until half?
  if gosub(dmishf) then
    b=s
  elseif gosub(dmisfi) then
rem finished?
    b=s+1024
    c=c+1
  endif
rem any buff is empty?
  if b then
rem turn off flags
    gosub clrflg
rem is end of music?
    if fget(b,1024)=0 then
      gosub clrbuf
      fseek 0
    endif
  endif
return

rem deinit for music.
label stpmus
  gosub stopsn
  gosub dmaabo
end


rem ==MINE SWEEPER GAME==

rem ===Variables===
rem f: Field
rem l: Cursor (Vector)
rem e: Field Size
rem t: temp array(to make field)

label INIT
 var x,y
 width 40
 gosub SETPCG
 print "    ==MINE SWEEPER=="
 print ""
 print " Fire : ÎÙ"
 print " Start: ÊÀ¦ µ¸"
 print " Ô¼ÞÙ¼: ¶°¿Ù¦ ²ÄÞ³"
 print ""
 print " **·¦Â¹Ã**"
 print " ¼­³ÍÝ¦ ÊÀ¦ ÓÄÆ¼Ã ¼ÞÄÞ³ÃÞ ÎØÏ½"
 print ""

 print "  made by Gombe"
 print ""

 fclose
 gosub clrbuf
 gosub inimus,"select.raw"

 while inkey()=0
  gosub mustas
 wend

 dim e(2)
 e(0)=20
 e(1)=25

 dim l(2)
 dim f(e(0),e(1))
 dim t(e(0)*e(1)*3,2)
 gosub main
end

rem game clear judge
label ISGCLR
 var x,y,j,v
 for x=0 to e(0)-1
  for y=0 to e(1)-1
   v = f(x,y)
   if (v>=20ANDv=27)OR(v>=0ANDv<=7) then
    j=1
    break
   endif
  next
  if j then break
 next
return j=0


rem gameover judge
label ISGOVR
 var x,y,j
 for x=0 to e(0)-1
  for y=0 to e(1)-1
   if f(x,y)=18 then j=1:break
  next
  if j then break
 next
return j

rem on gameover
label GMOVR
 var x,y
 for x=0 to e(0)-1
  for y=0 to e(1)-1
   if f(x,y)=8 then f(x,y)=18
  next
 next
return


rem on gameclear
label GMCLR
 var x,y
 for x=0 to e(0)-1
  for y=0 to e(1)-1
   if f(x,y)=8 then f(x,y)=28
  next
 next
return


rem clear field
label clrfld
 for x=0 to (e(0)-1)
  for y=0 to (e(1)-1)
   f(x,y)=0
  next
 next
return

rem make field
label MKFLD
 var x,y,n,i,j,r

 i=0
 n = ARGS(1)

 for x=0 to (e(0)-1)
  for y=0 to (e(1)-1)
   REM (x,y) is around cursor?
   if ((x>=l(0)-1)AND(x<=l(0)+1)) then
    if ((y>=l(1)-1)AND(y<=l(1)+1)) then
     continue
    endif
   endif
   t(i,0)=x
   t(i,1)=y
   i=i+1
  next
 next

 rem no region?
 if i<n then return 1

 rem random sort
 for j=0 to i-1
  r=rnd()%i
  x=t(j,0)
  y=t(j,1)
  t(j,0)=t(r,0)
  t(j,1)=t(r,1)
  t(r,0)=x
  t(r,1)=y
 next

 for i=0 to n-1
  f(t(i,0),t(i,1))=8
  for x=t(i,0)-1 to t(i,0)+1
   for y=t(i,1)-1 to t(i,1)+1
    j=gosub(isinfi,x,y)
    if j=0 then continue
    if f(x,y)=8 then continue
    f(x,y)=f(x,y)+1
   next
  next
 next
return

label dsptim
 var t
 cursor 0,22
 t=c*2048/32000
 print t/60;":";t%60/10;t%10
return 

label main
 var b,n,k,p,i
while 1
 gosub clrbuf

 print " 1: ¶ÝÀÝ   ,8 *8 ,10ºÉ ¼Þ×²"
 print " 2: ÌÂ³    ,12*12,25ºÉ ¼Þ×²"
 print " 3: ´·½Êß°Ä,19*19,60ºÉ ¼Þ×²"
 print " 4: ¶½ÀÑ   ,n *m ,k ºÉ ¼Þ×²"
 print " 5: ¹Þ°Ñ ¦ ¼­³Ø®³"

 print " ÅÝ²ÄÞ Ê?[1-4]:";

 k=0
 while inkey():gosub mustas:wend
 while k=0
  k = inkey()
  gosub mustas
 wend

 k = k - 0x30
 if k=1 then
  e(0)=8
  e(1)=8
  n=10
 elseif k=2 then
  e(0)=12
  e(1)=12
  n=25
 elseif k=3 then
  e(0)=19
  e(1)=19
  n=60
 elseif k=4 then
  print "ÖºÊÊÞ[1-19]:";
  e(0)=val(input$())
  print "ÀÃ[1-19]:";
  e(1)=val(input$())
  print "¼Þ×²É ¶½Þ[1-300?]:";
  n=val(input$())
 else
  gosub stpmus
  end
 endif

 cls
 gosub clrfld
 gosub PRMAP

 fclose
 gosub clrbuf
 gosub inimus,"bgmhigh.raw"

 p=0
 b=0
 while 1
  k=keys()
  gosub dsptim
  if b=0 then c=0
  if p!=k OR (i>15 AND i%3=1)then
   b=gosub(keytas,b,n)
   if gosub(isgovr) then
    print "Game Over"
    gosub GMOVR
    gosub PRMAP
    break
   elseif gosub(ISGCLR) then
    print "Game Clear"
    gosub GMCLR
    gosub PRMAP
    break
   endif
   gosub PRMAP
  elseif k=0 then
   i=0
  endif
  p=k
  i=i+1
  wait 1
  gosub mustas
 wend
 fclose
 gosub clrbuf
 gosub inimus,"recall.raw"
 print ""
 print "Hit any key to continue"
 while inkey()=0
  gosub mustas
 wend
 fclose
 gosub clrbuf
 gosub inimus,"select.raw"
 cls
 c=0
wend
return

label keytas
 if keys(4) then
  l(0)=l(0)-1
  if l(0)<0 then l(0)=e(0)-1
 endif
 if keys(8) then
  l(0)=l(0)+1
  if l(0)>=e(0) then l(0)=0
 endif
 if keys(1) then
  l(1)=l(1)-1
  if l(1)<0 then l(1)=e(1)-1
 endif
 if keys(2) then
  l(1)=l(1)+1
  if l(1)>=e(1) then l(1)=0
 endif
 if keys(32) then
  cursor 0,e(1)
  if ARGS(1)=0 then gosub mkfld,ARGS(2)
  gosub dig,l(0),l(1)
  return 1
 endif
 if (keys()=16)AND(ARGS(1)=1) then
  gosub putflg
 endif

return ARGS(1)


rem is in field?
LABEL isinfi
 var x,y
 x=ARGS(1)
 y=ARGS(2)
 if ((x<0)OR(x>=e(0))) then return 0
 if ((y<0)OR(y>=e(1))) then return 0
return 1

rem count around flags.
rem ARGs1:x
rem ARGs2:y
LABEL CFLAGS
 var i,x,y

 i=0
 for x=ARGS(1)-1 to ARGS(1)+1
  for y=ARGS(2)-1 to ARGS(2)+1
   if gosub(isinfi,x,y) then
    if f(x,y)>=20 then
     i=i+1
    endif
   endif
  next
 next
return i


rem Dig around.
rem ARGs1:x
rem ARGs2:y

rem use stack
rem recursive call cause exception
rem (because of deep nest)
LABEL DIG
 var x,y,i,a,b,z

 x=ARGS(1)
 y=ARGS(2)
 i=0

 t(i,0)=x
 t(i,1)=y

 do
  x = t(i,0)
  y = t(i,1)
  if f(x,y)<10 then
   f(x,y)=f(x,y)+10
  else
   i=i-1
   if i<0 then i=0
  endif

  a = t(i,0)
  b = t(i,1)

  gosub mustas

  if f(a,b)-10=(gosub(cflags,a,b)) then
   for x=a-1 to a+1
    for y=b-1 to b+1
     if gosub(isinfi,x,y) then
      if f(x,y)<10 then
       i = i+1
       t(i,0) = x
       t(i,1) = y
      endif
     endif
    next
   next
  endif
 loop while i
return


rem put a flag
LABEL PUTFLG
 if f(l(0),l(1)) < 10 then
  f(l(0),l(1))=f(l(0),l(1))+20
 elseif f(l(0),l(1)) >= 20 then
  f(l(0),l(1))=f(l(0),l(1))-20
 endif
return

LABEL PRMAP
var x,y
for y=0 to (e(1)-1)
 gosub mustas
 cursor 0,y
 for x=0 to (e(0)-1)
  if (x=l(0))AND(y=l(1)) then
   color 7:print "[";
  elseif ((x-1)=l(0))AND(y=l(1)) then
   color 7:print "]";
  else
   color 7:print "|";
  endif

  cursor x*2+1,y
  if (x=l(0))AND(y=l(1)) then
   gosub PRSELE ,f(x,y)
  else
   gosub PRELE ,f(x,y)
  endif
 next
 if (e(0)-1=l(0))AND(y=l(1)) then
  color 7:print "]"
 else
  color 7:print "|"
 endif
next
return

rem not selected elements
label PRELE
var e
e = ARGS(1)

if e=0 then
 color 7:print "#";
elseif e<=9 then
 color 7:print "#";
elseif e=10 then
 print " ";
elseif e<=16 then
 color 7:print (e-10);
elseif e=18 then
 color 2:print "*";
elseif e<30 then
 COLOR 4:PRINT "F";
else
 color 6:print "E";
endif

return

rem not selected elements
label PRSELE
var e
e = ARGS(1)

if e<=9 then
 color 7:print chr$(0xE0+10);
elseif e=10 then
 print chr$(0x87)
elseif e<=16 then
 color 7:print chr$(0xE0+e-10);
elseif e=18 then
 color 2:print chr$(0xE0+11);
elseif e<30 then
 COLOR 4:print chr$(0xE0+12);
else
 color 6:print "E";
endif

return


rem set reversed charactor
LABEL SETPCG
 var i,j,d,k,m
 
 USEPCG
rem register characters
 z$ = "0123456789#*F"
 d = SYSTEM(104)
rem asc
rem asc(z$(i))
 for i=0 to len(z$)-1
  m=asc(z$(i))
  j=0
  j=j OR D(m*2) >> 24
  j=j OR ((D(m*2) AND 0xFF0000) >> 8)
  j=j OR ((D(m*2) AND 0xFF00) << 8)
  j=j OR ((D(m*2) AND 0xFF) << 24)
  j=j XOR 0xFFFFFFFF
  k=0
  k=k OR D(m*2+1) >> 24
  k=k OR ((D(m*2+1) AND 0xFF0000) >> 8)
  k=k OR ((D(m*2+1) AND 0xFF00) << 8)
  k=k OR ((D(m*2+1) AND 0xFF) << 24)
  k=k XOR 0xFFFFFFFF
  PCG 0xE0+i,j ,k
 next
return