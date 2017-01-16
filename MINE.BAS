rem ==MINE SWEEPER GAME==

rem ===Variables===
rem f: Field
rem c: Cursor (Vector)
rem s: Field Size
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


 dim s(2)
 s(0)=20
 s(1)=25

 dim c(2)
 dim f(s(0),s(1))
 dim t(s(0)*s(1)*3,2)
 gosub main
end

rem game clear judge
label ISGCLR
 var x,y,j,v
 for x=0 to s(0)-1
  for y=0 to s(1)-1
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
 for x=0 to s(0)-1
  for y=0 to s(1)-1
   if f(x,y)=18 then j=1:break
  next
  if j then break
 next
return j

rem on gameover
label GMOVR
 var x,y
 for x=0 to s(0)-1
  for y=0 to s(1)-1
   if f(x,y)=8 then f(x,y)=18
  next
 next
return


rem on gameclear
label GMCLR
 var x,y
 for x=0 to s(0)-1
  for y=0 to s(1)-1
   if f(x,y)=8 then f(x,y)=28
  next
 next
return


rem clear field
label clrfld
 for x=0 to (s(0)-1)
  for y=0 to (s(1)-1)
   f(x,y)=0
  next
 next
return

rem make field
label MKFLD
 var x,y,n,i,j,r

 i=0
 n = ARGS(1)

 for x=0 to (s(0)-1)
  for y=0 to (s(1)-1)
   REM (x,y) is around cursor?
   if ((x>=c(0)-1)AND(x<=c(0)+1)) then
    if ((y>=c(1)-1)AND(y<=c(1)+1)) then
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
 

label main
 var b,n,k,p,i
while 1
 print " 1: ¶ÝÀÝ   ,8 *8 ,10ºÉ ¼Þ×²"
 print " 2: ÌÂ³    ,12*12,25ºÉ ¼Þ×²"
 print " 3: ´·½Êß°Ä,19*19,60ºÉ ¼Þ×²"
 print " 4: ¶½ÀÑ   ,n *m ,k ºÉ ¼Þ×²"

 print " ÅÝ²ÄÞ Ê?[1-4]:";
 k=val(input$())

 if k=1 then
  s(0)=8
  s(1)=8
  n=10
 elseif k=2 then
  s(0)=12
  s(1)=12
  n=25
 elseif k=3 then
  s(0)=19
  s(1)=19
  n=60
 else
  print "ÖºÊÊÞ[1-19]:";
  s(0)=val(input$())
  print "ÀÃ[1-19]:";
  s(1)=val(input$())
  print "¼Þ×²É ¶½Þ[1-300?]:";
  n=val(input$())
 endif

 cls
 gosub clrfld
 gosub PRMAP

 p=0
 b=0
 while 1
  k=keys()
  if p!=k OR (k!=0 AND i>15)then
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
 wend
 print "Enter to continue"
 z$=input$()
 cls
wend
return

label keytas
 if keys(4) then
  c(0)=c(0)-1
  if c(0)<0 then c(0)=s(0)-1
 endif
 if keys(8) then
  c(0)=c(0)+1
  if c(0)>=s(0) then c(0)=0
 endif
 if keys(1) then
  c(1)=c(1)-1
  if c(1)<0 then c(1)=s(1)-1
 endif
 if keys(2) then
  c(1)=c(1)+1
  if c(1)>=s(1) then c(1)=0
 endif
 if keys(32) then
  cursor 0,s(1)
  if ARGS(1)=0 then gosub mkfld,ARGS(2)
  gosub dig,c(0),c(1)
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
 if ((x<0)OR(x>=s(0))) then return 0
 if ((y<0)OR(y>=s(1))) then return 0
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
 if f(c(0),c(1)) < 10 then
  f(c(0),c(1))=f(c(0),c(1))+20
 elseif f(c(0),c(1)) >= 20 then
  f(c(0),c(1))=f(c(0),c(1))-20
 endif
return

LABEL PRMAP
var x,y
for y=0 to (s(1)-1)
 for x=0 to (s(0)-1)
  cursor x*2,y
  if (x=c(0))AND(y=c(1)) then
   color 7:print "["
  elseif ((x-1)=c(0))AND(y=c(1)) then
   color 7:print "]"
  else
   color 7:print "|"
  endif

  cursor x*2+1,y
  if (x=c(0))AND(y=c(1)) then
   gosub PRSELE ,f(x,y)
  else
   gosub PRELE ,f(x,y)
  endif
 next
 cursor s(0)*2,y
 if (s(0)-1=c(0))AND(y=c(1)) then
  color 7:print "]"
 else
  color 7:print "|"
 endif
next
return

rem not selected elements
label PRELE
e = ARGS(1)

if e=0 then
 color 7:print "#"
elseif e<=9 then
 color 7:print "#"
elseif e=10 then
 print " "
elseif e<=16 then
 color 7:print (e-10)
elseif e=18 then
 color 2:print "*"
elseif e<30 then
 COLOR 4:PRINT "F"
else
 color 6:print "E"
endif

return

rem not selected elements
label PRSELE
e = ARGS(1)

if e<=9 then
 color 7:print chr$(0xE0+10)
elseif e=10 then
 print chr$(0x87)
elseif e<=16 then
 color 7:print chr$(0xE0+e-10)
elseif e=18 then
 color 2:print chr$(0xE0+11)
elseif e<30 then
 COLOR 4:print chr$(0xE0+12)
else
 color 6:print "E"
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