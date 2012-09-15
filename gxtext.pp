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
              --------------------------------------------
                               G X T E X T
              --------------------------------------------
                                  v1.00
              --------------------------------------------
              VGA-Font
                written and (c) by Michael Knapp
              CHR-Loader:
                based on CHR.PAS (c) Jean-Pierre Planas
                modified by Michael Knapp
              FNT-Loader:
                written and (c) by Michael Knapp
              --------------------------------------------
}

{$I gxglobal.cfg}
UNIT gxtext;

INTERFACE

USES gxtype,gxbase;
{$I gxlocal.cfg}

CONST fts_normal=$0000;
      fts_underline=$0010;
      fts_italic=$0020;

      ftj_left=$0000;
      ftj_center=$0001;
      ftj_right=$0002;

      fto_topleft=$0000;
      fto_baseline=$0001;

TYPE TFontType=(ascii,ansi);

     PFont=^TFont;
     TFont=OBJECT
       fontbufptr:pointer;
       fontbufsize:longint;
       fontsize,fontstyle,fontdir,fontorigin:longint;
       fonttype:TFontType;
       fontloaded:boolean;
       fontname:string;
       oimage:pimage;
       oputpixel:putpixelproc;
       oline:lineproc;
       oputbitmap:putbitmapproc;
       CONSTRUCTOR LoadFont;
       DESTRUCTOR RemoveFont;
       PROCEDURE setimage(image:pimage);
       PROCEDURE setfontdirection(dir:longint);virtual;
       PROCEDURE setfontorigin(origin:longint);virtual;
       PROCEDURE setfontsize(size:longint);virtual;
       PROCEDURE setfontstyle(style:longint);virtual;
       PROCEDURE outtext(x,y:longint;s:string;f:longint);virtual;
       FUNCTION textlength(s:string):longint;virtual;
       FUNCTION textheight(s:string):longint;virtual;
       FUNCTION fontheight:longint;virtual;
       FUNCTION isloaded:boolean;
       FUNCTION getfontname:string;
     END;

{------------ VGA -------------}

TYPE PFontVGA=^TFontVGA;
     TFontVGA=OBJECT(TFont)
       CONSTRUCTOR LoadFont;
       PROCEDURE outtext(x,y:longint;s:string;f:longint);virtual;
       FUNCTION textlength(s:string):longint;virtual;
       FUNCTION textheight(s:string):longint;virtual;
       FUNCTION fontheight:longint;virtual;
       DESTRUCTOR RemoveFont;
     END;

{------------ CHR -------------}
     TCHRHeader = PACKED RECORD        {* Header of a CHR file*}
       id1,ids:longint;
       info:Array[1..$50] of Char; {*Header*}
       b1,b2,b3:byte;
       fontid:array[0..3] of char;
       a1:Array[1..$20] of Char; {*Header*}
       b4:byte;
       Sig         :char;	{* SIGNATURE byte                        *}
       Nchrs       :smallint;	{* number of characters in file          *}
       Mystery     :char;       {* Currently Undefined                   *}
       First	   :byte;    	{* first character in file               *}
       Cdefs	   :smallint;   {* offset to char definitions            *}
       Scan_Flag   :char;	{* True if set is scanable               *}
       Org_To_Cap  :Shortint;	{* Height from origin to top of capitol  *}
       Org_To_Base :Shortint;	{* Height from origin to baseline        *}
       Org_To_Dec  :Shortint;	{* Height from origin to bot of decender *}
       FntName     :Array[0..3] of char;{* Four character name of font   *}
       Unused      :char;       {* Currently undefined                   *}
     End;

     TCHRFont = Record        {*CHR font informations*}
       Org_to_cap   :longint; {* Height from origin to top of capitol      *}
       Org_to_base  :longint; {* Height from origin to baseline            *}
       Org_to_dec   :longint; {* Height from origin to bot of decender     *}
       Num_chrs     :longint;
       First        :Byte;    {* First character in file                   *}
       Char_Width   :Array[0..255] of byte;  {* Character Width Table	   *}
       Offset       :Array[0..255] of word;
     End;

     PFontCHR=^TFontCHR;
     TFontCHR=OBJECT(TFont)
       C_Font       : TCHRFont; { Current Font }                         {þMICþ}
       Chrloaded    : Boolean;                                           {þMICþ}
       charbuf:pointer;
       divider:longint;
       CONSTRUCTOR LoadFont(name:string);
       PROCEDURE outtext(x,y:longint;s:string;f:longint);virtual;
       FUNCTION textlength(s:string):longint;virtual;
       FUNCTION textheight(s:string):longint;virtual;
       FUNCTION fontheight:longint;virtual;
       DESTRUCTOR RemoveFont;
     END;

{------------ FNT -------------}
     TCharInfo=RECORD
       width:word;
       offset:word;
     END;

     PFNTHeader=^TFNTHeader;
     TFNTHeader=RECORD
       dfVersion:word;
       dfSize:longint;
       dfCopyright:array[1..60] of char;
       dfType:word;
       dfPoints:smallint;
       dfVertRes:smallint;
       dfHorizRes:smallint;
       dfAscent:smallint;
       dfInternalLeading:smallint;
       dfExternalLeading:smallint;
       dfItalic:byte;
       dfUnderline:byte;
       dfStrikeOut:byte;
       dfWeight:smallint;
       dfCharSet:byte;
       dfPixWidth:smallint;
       dfPixHeight:smallint;
       dfPitchAndFamily:byte;
       dfAvgWidth:smallint;
       dfMaxWidth:smallint;
       dfFirstChar:byte;
       dfLastChar:byte;
       dfDefaultChar:byte;
       dfBreakChar:byte;
       dfWidthBytes:smallint;
       dfDevice:byte;
       dfFace:byte;
       dfBitsPointer:smallint;
       dfBitsOffset:smallint;
       dfReserved:smallint;
       dfFlags:smallint;
       dfAspace:byte;
       dfBspace:byte;
       dfCspace:byte;
       dfColorpoints:word;
       dfReserved1:smallint;
       dfCharTable:array[0..255] of TCharInfo;
     END;

     PFontFNT=^TFontFNT;
     TFontFNT=OBJECT(TFont)
       CONSTRUCTOR LoadFont(name:string);
       PROCEDURE outtext(x,y:longint;s:string;f:longint);virtual;
       FUNCTION textlength(s:string):longint;virtual;
       FUNCTION textheight(s:string):longint;virtual;
       FUNCTION fontheight:longint;virtual;
       DESTRUCTOR RemoveFont;
     END;

{------------------------------}

FUNCTION EditText(Font:PFont;x,y,d,fg,bg:longint;var txt:string;max:byte):boolean;

IMPLEMENTATION

USES gxcrt,graphix,gx2d,gxdrw{,go32}{,dbgherc};

{------------------------------}

CONST ASCIItoANSI:array[0..255] of byte=
        ($00,$01,$02,$03,$04,$05,$06,$B7,$08,$09,$0A,$0B,$0C,$0D,$0E,$A4,
         $10,$11,$12,$13,$B6,$A7,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,
         $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,
         $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,
         $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,
         $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F,
         $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F,
         $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$7F,

         $C7,$FC,$E9,$E2,$E4,$E0,$E5,$E7,$EA,$EB,$E8,$EF,$EE,$EC,$C4,$C5,
         $C9,$E6,$C6,$F4,$F6,$F2,$FB,$F9,$FF,$D6,$DC,$A2,$A3,$A5,$20,$20,
         $E1,$ED,$F3,$FA,$F1,$D1,$AA,$BA,$BF,$A9,$AC,$BD,$BC,$A1,$AB,$BB,
         $B0,$B1,$B2,$7C,$2B,$2B,$2B,$2B,$2B,$2B,$7C,$2B,$2B,$2B,$2B,$2B,
         $2B,$2B,$2B,$2B,$2D,$2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B,$2D,$2B,$2B,
         $2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B,$DB,$DC,$DD,$DE,$DF,
         $E0,$DF,$E2,$E3,$E4,$E5,$B5,$E7,$E8,$E9,$EA,$EB,$EC,$F8,$EE,$EF,
         $F0,$B1,$F2,$F3,$F4,$F5,$F6,$F7,$B0,$F9,$FA,$FB,$B3,$B2,$FE,$FF);

{============================================================================}

CONSTRUCTOR TFont.LoadFont;
BEGIN
  fontname:='no font';
  fontloaded:=FALSE;
  oimage:=nil;
  oputpixel:=putpixel;
  oline:=line;
  oputbitmap:=putbitmap;
END;

PROCEDURE Tfont.setimage(image:pimage);
BEGIN
  oimage:=image;
  IF (oimage=nil) THEN
    BEGIN
      oputpixel:=putpixel;
      oline:=line;
      oputbitmap:=putbitmap;
    END
  ELSE
    BEGIN
      imagesetoutput(oimage);
      oputpixel:=iputpixel;
      oline:=iline;
      oputbitmap:=iputbitmap;
    END;
END;

PROCEDURE TFont.setfontdirection(dir:longint);
BEGIN
  fontdir:=dir;
END;

PROCEDURE TFont.setfontorigin(origin:longint);
BEGIN
  fontorigin:=origin;
END;

PROCEDURE TFont.setfontsize(size:longint);
BEGIN
  fontsize:=size;
END;

PROCEDURE TFont.setfontstyle(style:longint);
BEGIN
  fontstyle:=style;
END;

PROCEDURE TFont.outtext(x,y:longint;s:string;f:longint);
BEGIN
END;

FUNCTION TFont.textlength(s:string):longint;
BEGIN
  textlength:=length(s);
END;

FUNCTION TFont.textheight(s:string):longint;
BEGIN
  textheight:=1;
END;

FUNCTION TFont.fontheight:longint;
BEGIN
  fontheight:=1;
END;

FUNCTION TFont.isloaded:boolean;
BEGIN
  isloaded:=fontloaded;
END;

FUNCTION TFont.getfontname:string;
BEGIN
  getfontname:=fontname;
END;

DESTRUCTOR TFont.RemoveFont;
BEGIN
END;

{============================ VGA-Font ======================================}

{$I vgafont.ppi}

CONSTRUCTOR TFontVGA.LoadFont;
BEGIN
  INHERITED LoadFont;
  fontname:='8x16 VGA Fixed Font';
  fontloaded:=TRUE;
  fontbufsize:=16*256;
  fontbufptr:=@vgafont;
  fontstyle:=0;
  fonttype:=ascii;
END;

PROCEDURE TFontVGA.outtext(x,y:longint;s:string;f:longint);
VAR i,u,v,b,k,xp,yp,org:longint;
BEGIN
  CASE fontorigin OF
    fto_topleft:org:=0;
    fto_baseline:org:=-11;
  END;
  IF (fontstyle AND fts_italic=fts_italic) THEN k:=2 ELSE k:=16;
  FOR i:=1 TO length(s) DO
    BEGIN
      yp:=y;
      FOR u:=0 TO 15 DO
        BEGIN
          xp:=x;
          b:=byte((pointer(fontbufptr)+ord(s[i])*16+u)^);
          FOR v:=0 TO 7 DO
            BEGIN
              IF ((b SHL v) AND $80=$80) THEN
                oputpixel(xp+((16-u) SHR k),yp+org,f);
              inc(xp);
            END;
          inc(yp);
        END;
   {   oputbitmap(x,y+org,8,16,1,f,(pointer(fontbufptr)+ord(s[i])*16)^); }
      inc(x,8);
    END;
END;

FUNCTION TFontVGA.textlength(s:string):longint;
BEGIN
  textlength:=length(s)*8;
END;

FUNCTION TFontVGA.textheight(s:string):longint;
BEGIN
  textheight:=16;
END;

FUNCTION TFontVGA.fontheight:longint;
BEGIN
  fontheight:=16;
END;

DESTRUCTOR TFontVGA.RemoveFont;
BEGIN
{  IF fontloaded THEN freemem(fontbufptr,fontbufsize); }
END;

{============================ CHR-Font ======================================}

CONSTRUCTOR TFontCHR.LoadFont(name:string);
VAR F:File;
    Header:TCHRHeader;
    i:longint;
Begin
  INHERITED LoadFont;
  fontloaded:=FALSE;
  For i:=0 to 255 do
    Begin
      C_Font.Offset[i]:=0;
      C_Font.Char_Width[i]:=0;
    End;
  C_Font.NUM_chrs:=0;
  Assign(F,name);
  Reset(F,1);
  fontbufsize:=0;
  IF (IOResult=0) THEN
    BEGIN
      BlockRead(F,HEADER,Sizeof(HEADER));       {*Lecture du header*}
      C_Font.NUM_chrs:=HEADER.nchrs;
      C_Font.org_to_cap :=Header.org_to_cap ;
      C_Font.org_to_base:=Header.org_to_base;
      C_Font.org_to_dec :=Header.org_to_dec ;
      C_Font.first      :=header.first;
      {*Charge table offset et taille char*}
      BlockRead(F,C_Font.OFFSET[header.first],2*C_Font.NUM_chrs);
      BlockRead(F,C_Font.CHAR_WIDTH[header.first],1*C_Font.NUM_chrs);
      fontbufsize:=filesize(f)-filepos(f);      {*Calcule m‚moire n‚c‚ssaire*}
      getmem(fontbufptr,fontbufsize);
      blockRead(f,fontbufptr^,fontbufsize);
      close(f);
      getmem(charbuf,32768);
      fontloaded:=TRUE;
      divider:=abs(C_Font.org_to_cap)+abs(C_Font.org_to_dec);
      fontname:='CHR Font '+HEADER.fontid;
    END;
  fontsize:=16;
  fontstyle:=0;
  fontdir:=0;
  fonttype:=ascii;
END;

PROCEDURE TFontCHR.outtext(x,y:longint;s:string;f:longint);
VAR sinus,cosinus:longint;

  PROCEDURE Decode(w:word;var action:byte;var x,y:longint);assembler;
  asm
    MOV BL,0
    MOV AX,w
    SHL AL,1
    ADC BL,0
    SHL BL,1
    SHL AH,1
    ADC BL,0
    MOV EDI,action
    MOV [EDI],BL

    MOV BL,AH
    CBW
    SAR AX,1
    CWDE
    MOV EDI,x
    MOV [EDI],EAX

    MOV AL,BL
    CBW
    SAR AX,1
    CWDE
    MOV EDI,y
    MOV [EDI],EAX
  END;

  Procedure Draw_char(x,y:longint;i:Byte);
  Var p_w     :^Word;
      Action  :byte;
      xd,yd   :longint;
      Centrage:longint;
      sizebuf,polybuf:^longint;
      polynr:word;

    PROCEDURE lt(x,y:longint);
    BEGIN
      inc(sizebuf^);
      polybuf^:=x;
      inc(polybuf);
      polybuf^:=y;
      inc(polybuf);
    END;

    PROCEDURE mt(x,y:longint);
    BEGIN
      inc(polynr);
      sizebuf:=polybuf;
      sizebuf^:=1;
      inc(polybuf);

      polybuf^:=x;
      inc(polybuf);
      polybuf^:=y;
      inc(polybuf);
    END;

    PROCEDURE Poly(var p;z:word;f:longint);
    VAR q:^longint;
        x,y,a,b,c,ox,oy:longint;
    BEGIN
      q:=addr(p);
      FOR a:=1 TO z DO
        BEGIN
          b:=q^;
          inc(q);

          x:=q^;
          inc(q);
          y:=q^;
          inc(q);
          ox:=x;
          oy:=y;
          FOR c:=2 TO b DO
            BEGIN
              x:=q^;
              inc(q);
              y:=q^;
              inc(q);
              oline(ox,oy,x,y,f);
              ox:=x;
              oy:=y;
            END;
        END;
    END;

  Begin
    polybuf:=charbuf;
    polynr:=0;
    If C_Font.First+C_Font.Num_chrs<i Then Exit;
    If (C_Font.OFFSET[i]<>0) or (i=C_Font.First) Then
      Begin
        CASE fontorigin OF
          fto_topleft:Centrage:=C_Font.org_to_cap;
          fto_baseline:Centrage:=0;
        END;
  {      mt(x+trunc(Centrage*(sinus)),
           y+trunc(Centrage*(cosinus))); }

     {   line(x-10,y+centrage SHR 16,x-10,y-Trunc(((C_Font.org_to_cap)*fontsize)/10)+centrage SHR 16,$00FFFFFF);
        line(x-10+1,y+centrage SHR 16,x-10+1,y-Trunc(((C_Font.org_to_base)*fontsize)/10)+centrage SHR 16,$00FFFFFF);
        line(x-10+2,y+centrage SHR 16,x-10+2,y-Trunc(((C_Font.org_to_dec)*fontsize)/10)+centrage SHR 16,$00FFFFFF); }

        mt(x,y);
        p_w:=fontbufptr;
        inc(p_w,C_Font.OFFSET[i] div 2);
        Decode(p_w^,Action,xd,yd);
        IF (fontstyle AND fts_italic=fts_italic) THEN inc(xd,yd DIV 4);
        yd:=yd-centrage;
        While (Action<>0) do
          Begin
            Case Action of
              2:Mt(x+((xd*cosinus+yd*sinus) DIV 65536){-trunc(Centrage*(sinus))},
                   y+((xd*sinus-yd*cosinus) DIV 65536){+trunc(Centrage*(cosinus))});
              3:LT(x+((xd*cosinus+yd*sinus) DIV 65536){-trunc(Centrage*(sinus))},
                   y+((xd*sinus-yd*cosinus) DIV 65536){+trunc(Centrage*(cosinus))});
            End;{Case}
            inc(p_w);
            Decode(p_w^,Action,Xd,Yd);
            IF (fontstyle AND fts_italic=fts_italic) THEN inc(xd,yd DIV 4);
            yd:=yd-centrage;
          {  IF (fontstyle AND ft_italic=ft_italic) THEN inc(xd,yd DIV 4); }
          End;
      End;
{    IF (fontstyle AND fts_fill=fts_fill) THEN
      multipolygon(charbuf^,polynr,f) ELSE}
    poly(charbuf^,polynr,f);
  End;

VAR i,akku:longint;
BEGIN
  sinus:=trunc(((sin((fontdir*2*pi)/65536)*fontsize)/divider)*65536);
  cosinus:=trunc(((cos((fontdir*2*pi)/65536)*fontsize)/divider)*65536);
  akku:=0;
  For i:=1 to Length(s) do
    Begin
      Draw_Char(x+((akku*cosinus) SHR 16),y+((akku*sinus) SHR 16),ord(s[i]));
      inc(akku,C_Font.Char_Width[ord(s[i])]);
    End;
End;

FUNCTION TFontCHR.textlength(s:string):longint;
Var i:Byte;
    total:Word;
Begin
  Total:=0;
  For i:=1 to Length(S) do
    inc(Total,C_Font.Char_Width[ord(s[i])]);
  textlength:=(Total*fontsize) DIV divider;
End;

FUNCTION TFontCHR.textheight(s:string):longint;
BEGIN
  textheight:=((C_Font.org_to_cap-C_Font.org_to_dec)*fontsize) DIV divider;
END;

FUNCTION TFontCHR.fontheight:longint;
BEGIN
  fontheight:=((C_Font.org_to_cap-C_Font.org_to_dec)*fontsize) DIV divider;
END;

DESTRUCTOR TFontCHR.RemoveFont;
BEGIN
  IF fontloaded THEN
    BEGIN
      freemem(charbuf,32768);
      freemem(fontbufptr,fontbufsize);
    END;
END;

{============================ FNT-Font ======================================}

CONSTRUCTOR TFontFNT.LoadFont(name:string);
VAR f:file;
BEGIN
  INHERITED LoadFont;
  fontloaded:=FALSE;
  fontbufsize:=0;
  assign(f,name);
  reset(f,1);
  IF (IOResult=0) THEN
    BEGIN
      fontbufsize:=filesize(f);
      getmem(fontbufptr,fontbufsize);
      blockread(f,fontbufptr^,fontbufsize);
      close(f);
      CASE PFNTHeader(fontbufptr)^.dfcharset OF
        $00:fonttype:=ansi;
        $FF:fonttype:=ascii;
      END;
      fontloaded:=TRUE;
      fontname:='FNT Font';
    END;
END;

PROCEDURE TFontFNT.outtext(x,y:longint;s:string;f:longint);
VAR i,ch:byte;
    xx,xd,yd:longint;
    xp,xs:longint;
    xdb:longint;
    charofs:pointer;
    mask:dword;
    origin:longint;
    opp:putpixelproc;
BEGIN
  opp:=oputpixel;
  CASE fontorigin OF
    fto_topleft:origin:=0;
    fto_baseline:origin:=-(PFNTHeader(fontbufptr)^.dfAscent-1);
  END;
  inc(y,origin);
  IF (fontstyle AND fts_italic=fts_italic) THEN mask:=$FFFFFFFF ELSE mask:=0;
  WITH PFNTHeader(fontbufptr)^ DO
    BEGIN
      yd:=dfPixHeight;
      xp:=x;
      FOR i:=1 TO length(s) DO
        BEGIN
          CASE fonttype OF
            ascii:ch:=ord(s[i]);
            ansi:ch:=ASCIItoANSI[ord(s[i])];
          END;
          IF (ch>=dfFirstChar) AND (ch<=dfLastChar) THEN
            dec(ch,dfFirstChar) ELSE ch:=dfDefaultChar;
          charofs:=fontbufptr+dfCharTable[ch].offset;
          xd:=dfCharTable[ch].width;
          xdb:=(xd-1) SHR 3;
          ASM
            MOV ECX,xdb
            INC ECX
            MOV EDX,f
            MOV EDI,xp
            MOV ESI,charofs
          @loop1:
            PUSH ECX
            MOV ECX,yd
            MOV EBX,y
            @loop2:
            PUSH ECX
            LODSB
            PUSH EDI
            AND ECX,mask
            SHR ECX,2
            ADD EDI,ECX
            MOV ECX,8
          @loop3:
            SHL AL,1
            JNC @keinpunkt
            PUSHAD
            PUSH EDX
            PUSH EBX
            PUSH EDI
            CALL opp
            POPAD
          @keinpunkt:
            INC EDI
            LOOP @loop3
            POP EDI
            POP ECX
            INC EBX
            LOOP @loop2
            POP ECX
            ADD EDI,8
            LOOP @loop1
          END;
          inc(xp,xd);

     {     xdb:=xd SHR 3;
          xp:=x;
          FOR xx:=0 TO xdb-1 DO
            BEGIN
              oputbitmap(xp,y,8,yd,1,f,charofs^);
              inc(charofs,yd);
              inc(xp,8);
            END;
          IF (xd AND 7<>0) THEN
            oputbitmap(xp,y,(xd AND 7),yd,1,f,charofs^);
          inc(x,xd); }
        END;
    END;
END;

FUNCTION TFontFNT.textlength(s:string):longint;
VAR i,ch:byte;
    xd:longint;
BEGIN
  xd:=0;
  WITH PFNTHeader(fontbufptr)^ DO
    BEGIN
      FOR i:=1 TO length(s) DO
        BEGIN
          CASE fonttype OF
          ascii:ch:=ord(s[i]);
          ansi:ch:=ASCIItoANSI[ord(s[i])];
          END;
          IF (ch>=dfFirstChar) AND (ch<=dfLastChar) THEN
            dec(ch,dfFirstChar) ELSE ch:=dfDefaultChar;
          inc(xd,dfCharTable[ch].width);
       END;
    END;
  textlength:=xd;
END;

FUNCTION TFontFNT.textheight(s:string):longint;
BEGIN
  textheight:=PFNTHeader(fontbufptr)^.dfPixHeight;
END;

FUNCTION TFontFNT.fontheight:longint;
BEGIN
  fontheight:=PFNTHeader(fontbufptr)^.dfPixHeight;
END;

DESTRUCTOR TFontFNT.RemoveFont;
BEGIN
  IF fontloaded THEN freemem(fontbufptr,fontbufsize);
END;

{============================================================================}

FUNCTION EditText(Font:PFont;x,y,d,fg,bg:longint;var txt:string;max:byte):boolean;
VAR sx,sy:longint;
    ch:char;
    ap,sl:byte;
    l:longint;
    ex,change:boolean;
    s:string;

  PROCEDURE Cursor;
  BEGIN
    barXOR(sx+l+1,sy+2,sx+l+2,sy+Font^.fontheight-2,$00FFFFFF);
  END;

BEGIN
  bar(x,y,x+d,y+Font^.fontheight,bg);
  s:=txt;
  sx:=x;
  sy:=y;

  sl:=length(s);
  ap:=sl;
  l:=Font^.textlength(s);
  Cursor;
  ex:=FALSE;
  change:=FALSE;
  Font^.outtext(sx+2,sy,s,fg);
  REPEAT
    IF keypressed THEN
      BEGIN
        ch:=readkey;
        Cursor;
        CASE ch OF
        #0:BEGIN
             ch:=readkey;
             CASE ch OF
             'G':ap:=0;
             'K':IF (ap>0) THEN dec(ap);
             'M':IF (ap<sl) THEN inc(ap);
             'O':ap:=sl;
             'S':IF (ap<sl) THEN
                   BEGIN
                     Font^.outtext(sx+2,sy,s,bg);
                     delete(s,ap+1,1);
                     sl:=length(s);
                     Font^.outtext(sx+2,sy,s,fg);
                   END;
             END;
           END;
        #8:IF (ap>0) THEN
             BEGIN
               Font^.outtext(sx+2,sy,s,bg);
               delete(s,ap,1);
               sl:=length(s);
               dec(ap);
               Font^.outtext(sx+2,sy,s,fg);
             END;
        #13:BEGIN
              change:=TRUE;
              ex:=TRUE;
            END;
        #27:BEGIN
              change:=FALSE;
              ex:=TRUE;
            END;
        #32..#255:
           IF (sl<max) AND (x+Font^.textlength(s)<x+d) THEN
             BEGIN
               Font^.outtext(sx+2,sy,s,bg);
               insert(ch,s,ap+1);
               sl:=length(s);
               inc(ap);
               Font^.outtext(sx+2,sy,s,fg);
             END;
        END;
        l:=Font^.textlength(copy(s,1,ap));
        Cursor;
      END;
  UNTIL (ex=TRUE);
  Cursor;
  IF change THEN txt:=s;
  EditText:=change;
END;

{============================================================================}

END.
