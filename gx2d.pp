{
    This file is a part of the graphics library GraphiX
    Copyright (C) 2001 Michael Knapp

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{
                  ------------------------------------
                       GX2D - G r a p h i X    2 D
                  ------------------------------------
                                v1.00
                  ------------------------------------

VERSION HISTORY

Version 1.00 (13.02.1999)
  * Grundstruktur der Unit - Erweiterte 2D Funktionen
    - Kreis leer
    - Kreis gefllt
    - Ellipse gefllt
    - Polygon gefllt

                       --------------------------
}

{$I gxglobal.cfg}
UNIT gx2d;

INTERFACE

{$I gxlocal.cfg}

TYPE TPoint2D=RECORD
       x,y:longint;
     END;

FUNCTION squareroot(z:longint):longint;
PROCEDURE circle(x,y,r,f:longint);
PROCEDURE circlefill(x,y,r,f:longint);
PROCEDURE ellipsefill(x,y,rx,ry,f:longint);
PROCEDURE polygon(var p;z,f:longint);
PROCEDURE multipolygon(var p;z,f:longint);

IMPLEMENTATION

USES graphix;

FUNCTION squareroot(z:longint):longint;assembler;
ASM
  MOV ECX,z
  CMP ECX,64517
  JAE @sr_weiter

  MOV BX,1
@sr16_loop1:
  MOV AX,BX
  MUL BX
  CMP AX,CX
  JAE @sr16_weiter1
  ADD BX,11
  JMP @sr16_loop1
@sr16_weiter1:
@sr16_loop2:
  MOV AX,BX
  MUL BX
  CMP AX,CX
  JBE @sr16_weiter2
  DEC BX
  JMP @sr16_loop2
@sr16_weiter2:
  MOVZX EAX,BX
  JMP @ende

@sr_weiter:
  MOV EBX,1
@sr32_loop1:
  MOV EAX,EBX
  MUL EBX
  CMP EAX,ECX
  JGE @sr32_weiter1
  ADD EBX,24
  JMP @sr32_loop1
@sr32_weiter1:
@sr32_loop2:
  MOV EAX,EBX
  MUL EBX
  CMP EAX,ECX
  JLE @sr32_weiter2
  DEC EBX
  JMP @sr32_loop2
@sr32_weiter2:
  MOV EAX,EBX
@ende:
END;

PROCEDURE circle(x,y,r,f:longint);
VAR i,rr,ny:longint;
BEGIN
  IF (x+r>vx1) AND (x-r<vx2) AND
     (y+r>vy1) AND (y-r<vy2) THEN
    IF (r>0) THEN
      BEGIN
        rr:=r;
        rr:=rr*rr;
        FOR i:=0 TO trunc(r/1.414) DO
          BEGIN
            ny:=squareroot(rr-i*i);
            putpixel(x+i,y+ny,f);
            putpixel(x-i,y+ny,f);
            putpixel(x+i,y-ny,f);
            putpixel(x-i,y-ny,f);
            putpixel(x+ny,y+i,f);
            putpixel(x-ny,y+i,f);
            putpixel(x+ny,y-i,f);
            putpixel(x-ny,y-i,f);
          END;
      END
    ELSE
      putpixel(x,y,f);
END;

PROCEDURE circlefill(x,y,r,f:longint);assembler;
VAR nx,x1,x2,i,rr:longint;
ASM
  MOV EAX,x
  MOV EBX,y
  MOV ECX,EAX
  MOV EDX,EBX
  ADD EAX,r
  ADD EBX,r
  SUB ECX,r
  SUB EDX,r
  CMP EAX,vx1
  JLE @cf_ende
  CMP EBX,vy1
  JLE @cf_ende
  CMP ECX,vx2
  JGE @cf_ende
  CMP EDX,vy2
  JGE @cf_ende
  CMP r,0
  JLE @cf_punkt

  MOV ECX,r
  MOV EAX,ECX
  MUL EAX
  MOV rr,EAX
  SHL ECX,1
  INC ECX
  NEG r
@cf_loop:
  PUSH ECX
  MOV EAX,r
  IMUL EAX
  NEG EAX
  ADD EAX,rr

  PUSH EAX
  CALL squareroot

  PUSH f

  MOV EBX,r
  ADD EBX,y
  PUSH EBX

  MOV EBX,x
  ADD EBX,EAX
  PUSH EBX

  MOV EBX,x
  SUB EBX,EAX
  PUSH EBX

  CALL lineH

  POP ECX
  INC r
  DEC ECX
  JNZ @cf_loop
  JMP @cf_ende
@cf_punkt:
  PUSH f
  PUSH y
  PUSH x
  CALL putpixel
@cf_ende:
END;

PROCEDURE ellipsefill(x,y,rx,ry,f:longint);assembler;
VAR x1,x2,i,rrx,rry:longint;
ASM
  MOV EAX,x
  MOV EBX,y
  MOV ECX,EAX
  MOV EDX,EBX
  ADD EAX,rx
  ADD EBX,ry
  SUB ECX,rx
  SUB EDX,ry

  CMP EAX,vx1
  JLE @ef_ende
  CMP EBX,vy1
  JLE @ef_ende
  CMP ECX,vx2
  JGE @ef_ende
  CMP EDX,vy2
  JGE @ef_ende
  CMP rx,0
  JLE @ef_punkt
  CMP ry,0
  JLE @ef_punkt

  MOV EAX,rx
  IMUL EAX
  MOV rrx,EAX
  MOV EAX,ry
  IMUL EAX
  MOV rry,EAX

  MOV EBX,ry
  NEG EBX
  MOV i,EBX

  MOV ECX,ry
  SHL ECX,1
  INC ECX

@ef_loop:
  PUSH ECX
  MOV EAX,i
  IMUL EAX
  NEG EAX
  ADD EAX,rry
  IMUL rrx
  IDIV rry
  PUSH EAX
  CALL squareroot

  PUSH f

  MOV EBX,y
  ADD EBX,i
  PUSH EBX

  MOV EBX,x
  ADD EBX,EAX
  PUSH EBX

  MOV EBX,x
  SUB EBX,EAX
  PUSH EBX

  CALL lineH
  POP ECX
  INC i
  DEC ECX
  JNZ @ef_loop
  JMP @ef_ende
@ef_punkt:
  PUSH f
  PUSH y
  PUSH x
  CALL putpixel
@ef_ende:
END;

PROCEDURE polygon(var p;z,f:longint);assembler;
CONST linesize=12;
VAR ofss,ofsd,px,py,px1,py1,px2,py2,pxd,pyd,lx1,ly1,lx2,ly2,lxd,lyd:longint;
ASM
  MOV ESI,p
  MOV ofss,ESI
  MOV EDI,graphbuf
  MOV ofsd,EDI

  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h

  MOV ECX,z
@py_loop11:
  LODSD
  CMP EAX,px1
  JGE @py_w1
  MOV px1,EAX
@py_w1:
  CMP EAX,px2
  JLE @py_w2
  MOV px2,EAX
@py_w2:
  LODSD
  CMP EAX,py1
  JGE @py_w3
  MOV py1,EAX
@py_w3:
  CMP EAX,py2
  JLE @py_w4
  MOV py2,EAX
@py_w4:
  DEC ECX
  JNZ @py_loop11
{----------}
  MOV EAX,px1
  CMP EAX,vx2
  JG @py_weiter66

  MOV EAX,py1
  CMP EAX,vy2
  JG @py_weiter66

  MOV EAX,px2
  CMP EAX,vx1
  JL @py_weiter66

  MOV EAX,py2
  CMP EAX,vy1
  JL @py_weiter66
{----------}
  MOV EAX,vy1
  CMP EAX,py1
  JLE @py_w5
  MOV py1,EAX
@py_w5:

  MOV EAX,vy2
  CMP EAX,py2
  JGE @py_w6
  MOV py2,EAX
@py_w6:

  MOV EAX,px2
  SUB EAX,px1
  MOV pxd,EAX

  MOV EAX,py2
  SUB EAX,py1
  MOV pyd,EAX
{----------}
  MOV ECX,pyd
  INC ECX
  XOR EAX,EAX
  MOV EDI,ofsd
@py_loop22:
  MOV [EDI],EAX
  ADD EDI,linesize*4
  DEC ECX
  JNZ @py_loop22

{----------}
  MOV ESI,ofss

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX

{----------}

  MOV ECX,z
  DEC ECX
@py_loop33:
  PUSH ECX

  MOV EAX,lx2
  MOV lx1,EAX
  MOV EAX,ly2
  MOV ly1,EAX

  OR ECX,ECX
  JNZ @py_weiter11
  MOV ESI,ofss
@py_weiter11:

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX

  MOV EAX,lx1
  MOV EBX,ly1
  MOV ECX,lx2
  MOV EDX,ly2

  CMP EBX,EDX
  JZ @py_weiter44
  JL @py_weiter22
  XCHG EAX,ECX
  XCHG EBX,EDX
@py_weiter22:
  MOV px,EAX
  MOV py,EBX
  SUB ECX,EAX
  SUB EDX,EBX
  MOV lxd,ECX
  MOV lyd,EDX

  MOV ECX,EDX
  ADD EDX,py

  MOV EBX,linesize*4
  IMUL EBX,EDX

  MOV EDI,ofsd
  ADD EDI,EBX

  OR ECX,ECX
  JLE @py_weiter33

@py_loop44:
  MOV EAX,py
  ADD EAX,ECX
  JL @py_weiter33
  CMP EAX,pyd
  JG @py_weiter33

  MOV EBX,[EDI]
  CMP EBX,linesize-1
  JAE @py_weiter33
  INC EBX
  MOV [EDI],EBX
  SHL EBX,2
  ADD EBX,EDI

  MOV EAX,ECX
  IMUL lxd
  IDIV lyd
  ADD EAX,px
  MOV [EBX],EAX
@py_weiter33:
  SUB EDI,linesize*4
  DEC ECX
  JNZ @py_loop44
@py_weiter44:

  POP ECX
  DEC ECX
  JNS @py_loop33

{--- Sortieren und Zeichnen der X-Werte ---}
  MOV ESI,ofsd

  MOV EBX,py1
  MOV ECX,pyd
  OR ECX,ECX
  JLE @py_weiter66

@py_loop55:
  PUSH ECX
  PUSH ESI
{--- Bubble-Sort ---}
  MOV ECX,[ESI]
  JECXZ @py_weiter55
  PUSH ECX
  ADD ESI,ECX
  ADD ESI,ECX
  ADD ESI,ECX
  ADD ESI,ECX
@py_loop66:
  PUSH ECX
  MOV EAX,[ESI]
  MOV EDI,ESI
@py_loop77:
  MOV EDX,[EDI]
  CMP EAX,EDX
  JLE @py_weiter
  XCHG EAX,EDX
  MOV [ESI],EAX
  MOV [EDI],EDX
@py_weiter:
  SUB EDI,4
  DEC ECX
  JNZ @py_loop77
  SUB ESI,4
  POP ECX
  DEC ECX
  JNZ @py_loop66
  POP ECX
{---}
  ADD ESI,4
  SHR ECX,1
@py_loop88:

  PUSH EBX
  PUSH ECX

  PUSH f
  PUSH EBX
  LODSD
  PUSH EAX
  LODSD
  PUSH EAX
  CALL lineh

  POP ECX
  POP EBX

  DEC ECX
  JNZ @py_loop88
@py_weiter55:

  POP ESI
  POP ECX
  INC EBX
  ADD ESI,linesize*4
  DEC ECX
  JNZ @py_loop55
@py_weiter66:
END;

PROCEDURE multipolygon(var p;z,f:longint);assembler;
CONST linesize=12;
VAR ofss,ofsd,px,py,px1,py1,px2,py2,pxd,pyd,lx1,ly1,lx2,ly2,lxd,lyd:longint;
ASM
  MOV ESI,p
  MOV ofss,ESI
  MOV EDI,graphbuf
  MOV ofsd,EDI

  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h

  MOV ECX,z
@mpy_loop111:
  PUSH ECX
  LODSD
  MOV ECX,EAX
@mpy_loop11:
  LODSD
  CMP EAX,px1
  JGE @mpy_w1
  MOV px1,EAX
@mpy_w1:
  CMP EAX,px2
  JLE @mpy_w2
  MOV px2,EAX
@mpy_w2:
  LODSD
  CMP EAX,py1
  JGE @mpy_w3
  MOV py1,EAX
@mpy_w3:
  CMP EAX,py2
  JLE @mpy_w4
  MOV py2,EAX
@mpy_w4:
  DEC ECX
  JNZ @mpy_loop11
  POP ECX
  DEC ECX
  JNZ @mpy_loop111
{----------}
  MOV EAX,px1
  CMP EAX,vx2
  JG @mpy_weiter66

  MOV EAX,py1
  CMP EAX,vy2
  JG @mpy_weiter66

  MOV EAX,px2
  CMP EAX,vx1
  JL @mpy_weiter66

  MOV EAX,py2
  CMP EAX,vy1
  JL @mpy_weiter66
{----------}
  MOV EAX,vy1
  CMP EAX,py1
  JLE @mpy_w5
  MOV py1,EAX
@mpy_w5:

  MOV EAX,vy2
  CMP EAX,py2
  JGE @mpy_w6
  MOV py2,EAX
@mpy_w6:

  MOV EAX,px2
  SUB EAX,px1
  MOV pxd,EAX

  MOV EAX,py2
  SUB EAX,py1
  MOV pyd,EAX
{----------}
  MOV ECX,pyd
  INC ECX
  XOR EAX,EAX
  MOV EDI,ofsd
@mpy_loop22:
  MOV [EDI],EAX
  ADD EDI,linesize*4
  DEC ECX
  JNZ @mpy_loop22

{----------}
  MOV ESI,ofss
  MOV ECX,z
@mpy_loop333:
  PUSH ECX
  LODSD
  MOV ECX,EAX
  MOV ofss,ESI

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX

  DEC ECX
@mpy_loop33:
  PUSH ECX

  MOV EAX,lx2
  MOV lx1,EAX
  MOV EAX,ly2
  MOV ly1,EAX

  OR ECX,ECX
  JNZ @mpy_weiter11
  PUSH ESI
  MOV ESI,ofss
  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  POP ESI
  JMP @mpy_weiter111
@mpy_weiter11:

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
@mpy_weiter111:

  MOV EAX,lx1
  MOV EBX,ly1
  MOV ECX,lx2
  MOV EDX,ly2

  CMP EBX,EDX
  JZ @mpy_weiter44
  JL @mpy_weiter22
  XCHG EAX,ECX
  XCHG EBX,EDX
@mpy_weiter22:
  MOV px,EAX
  MOV py,EBX
  SUB ECX,EAX
  SUB EDX,EBX
  MOV lxd,ECX
  MOV lyd,EDX

  MOV ECX,EDX
  ADD EDX,py

  MOV EBX,linesize*4
  IMUL EBX,EDX

  MOV EDI,ofsd
  ADD EDI,EBX

  OR ECX,ECX
  JLE @mpy_weiter33

@mpy_loop44:
  MOV EAX,py
  ADD EAX,ECX
  JL @mpy_weiter33
  CMP EAX,pyd
  JG @mpy_weiter33

  MOV EBX,[EDI]
  CMP EBX,linesize-1
  JAE @mpy_weiter33
  INC EBX
  MOV [EDI],EBX
  SHL EBX,2
  ADD EBX,EDI

  MOV EAX,ECX
  IMUL lxd
  IDIV lyd
  ADD EAX,px
  MOV [EBX],EAX
@mpy_weiter33:
  SUB EDI,linesize*4
  DEC ECX
  JNZ @mpy_loop44
@mpy_weiter44:

  POP ECX
  DEC ECX
  JNS @mpy_loop33
  POP ECX
  DEC ECX
  JNZ @mpy_loop333

{--- Sortieren und Zeichnen der X-Werte ---}
  MOV ESI,ofsd

  MOV EBX,py1
  MOV ECX,pyd
  OR ECX,ECX
  JLE @mpy_weiter66

@mpy_loop55:
  PUSH ECX
  PUSH ESI
{--- Bubble-Sort ---}
  MOV ECX,[ESI]
  JECXZ @mpy_weiter55
  PUSH ECX
  ADD ESI,ECX
  ADD ESI,ECX
  ADD ESI,ECX
  ADD ESI,ECX
@mpy_loop66:
  PUSH ECX
  MOV EAX,[ESI]
  MOV EDI,ESI
@mpy_loop77:
  MOV EDX,[EDI]
  CMP EAX,EDX
  JLE @mpy_weiter
  XCHG EAX,EDX
  MOV [ESI],EAX
  MOV [EDI],EDX
@mpy_weiter:
  SUB EDI,4
  DEC ECX
  JNZ @mpy_loop77
  SUB ESI,4
  POP ECX
  DEC ECX
  JNZ @mpy_loop66
  POP ECX
{---}
  ADD ESI,4
  SHR ECX,1
@mpy_loop88:

  PUSH EBX
  PUSH ECX

  PUSH f
  PUSH EBX
  LODSD
  PUSH EAX
  LODSD
  PUSH EAX
  CALL lineh

  POP ECX
  POP EBX

  DEC ECX
  JNZ @mpy_loop88
@mpy_weiter55:

  POP ESI
  POP ECX
  INC EBX
  ADD ESI,linesize*4
  DEC ECX
  JNZ @mpy_loop55
@mpy_weiter66:
END;

END.

