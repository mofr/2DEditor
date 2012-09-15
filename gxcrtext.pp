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
  FPC-Konversion 25.03.1999 - 16:49 - OK 
} 

{$I gxglobal.cfg}
UNIT gxcrtext;

INTERFACE

{$I gxlocal.cfg}

TYPE PCachedFile=^TCachedFile;
     TCachedFile=RECORD
       f:file;
       cache:pointer;
       size:longint;
       first,last,fp:longint;
     END; 

FUNCTION CheckFile(Dateiname:string):word;
PROCEDURE OpenCachedFile(var cf:TCachedFile;Dateiname:string);
PROCEDURE SeekCachedFile(var cf:TCachedFile;pos:longint);
PROCEDURE SeekRelCachedFile(var cf:TCachedFile;pos:longint);
PROCEDURE ReadCachedFile(var cf:TCachedFile;var buf;bytes:longint);
PROCEDURE CloseCachedFile(var cf:TCachedFile); 

PROCEDURE swap16(var p);
PROCEDURE swap32(var p);
FUNCTION bytswp16(d:word):word;
FUNCTION bytswp32(d:longint):longint;

FUNCTION hexbyte(b:byte):string;
FUNCTION hexword(w:word):string;
FUNCTION hexlong(l:longint):string;
FUNCTION word2str(v:word):string;
FUNCTION long2str(v:longint):string;
FUNCTION longnum2str(v:longint):string;
FUNCTION real2str(r:real;le,ri:longint):string;
FUNCTION double2str(d:double;le,ri:longint):string;
PROCEDURE pchar2str(p:pchar;var s:string);
FUNCTION str2pchar(var s:string):pchar;

FUNCTION roundpower2(w:dword):dword;
FUNCTION logdual(x:dword):dword;

IMPLEMENTATION

CONST CacheSize=128*1024;

FUNCTION CheckFile(Dateiname:string):word;
VAR f:file;
BEGIN
  assign(f,Dateiname);
  reset(f);
  CheckFile:=IOResult;
  close(f);
END;

PROCEDURE OpenCachedFile(var cf:TCachedFile;Dateiname:string);
BEGIN
  WITH cf DO
    BEGIN
      assign(f,Dateiname);
      reset(f,1);
      size:=CacheSize;
      getmem(cache,CacheSize);
      First:=-1;
      Last:=-1;
      fp:=0;
    END;
END;

PROCEDURE SeekCachedFile(var cf:TCachedFile;pos:longint);
BEGIN
  cf.fp:=pos;
END;

PROCEDURE SeekRelCachedFile(var cf:TCachedFile;pos:longint);
BEGIN
  cf.fp:=cf.fp+pos;
END;

PROCEDURE ReadCachedFile(var cf:TCachedFile;var buf;bytes:longint);
VAR cfs,wtc,io:longint;
BEGIN
  WITH cf DO
    BEGIN
      IF (fp<first) OR (fp+bytes>last) THEN
        BEGIN
          cfs:=filesize(f);
          IF (cfs<size) THEN
            BEGIN
              First:=0;
              Last:=cfs-1;
              wtc:=cfs;
            END
          ELSE
            IF (fp+size>cfs) THEN
              BEGIN
                First:=cfs-size;
                Last:=cfs;
                wtc:=size;
              END
            ELSE
              BEGIN
                First:=fp;
                Last:=fp+size;
                wtc:=size;
              END;
          seek(f,first);
          blockread(f,cache^,wtc,io);
        END;
      move((cf.cache+(cf.fp-cf.first))^,buf,bytes);
      inc(cf.fp,bytes);
    END;
{ seek(cf.f,cf.fp);
 blockread(cf.f,buf,bytes,io);
 inc(cf.fp,bytes); }
END;

PROCEDURE CloseCachedFile(var cf:TCachedFile);
BEGIN
  WITH cf DO
    BEGIN
      close(f);
      freemem(cache,CacheSize);
      First:=-1;
      Last:=-1;
    END;
END;

PROCEDURE swap16(var p);assembler;
ASM
  MOV EDI,p
  MOV AX,[EDI]
  XCHG AL,AH
  MOV [EDI],AX
END;

PROCEDURE swap32(var p);assembler;
ASM
  MOV EDI,p
  MOV EAX,[EDI]
  XCHG AL,AH
  ROL EAX,16
  XCHG AL,AH
  MOV [EDI],EAX
END;

FUNCTION bytswp16(d:word):word;assembler;
ASM
  MOV AX,d
  XCHG AL,AH
END;

FUNCTION bytswp32(d:longint):longint;assembler;
ASM
  MOV EAX,d
  XCHG AL,AH
  ROL EAX,16
  XCHG AL,AH
END;

FUNCTION hexbyte(b:byte):string;
CONST digits:array[0..15] of char=
        ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
VAR s:string;
BEGIN
  s:='00';
  s[2]:=digits[b AND $0F];
  s[1]:=digits[(b SHR 4) AND $0F];
  hexbyte:=s;
END;

FUNCTION hexword(w:word):string;
CONST digits:array[0..15] of char=
        ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
VAR s:string;
BEGIN
  s:='0000';
  s[4]:=digits[w AND $000F];
  s[3]:=digits[(w SHR 4) AND $000F];
  s[2]:=digits[(w SHR 8) AND $000F];
  s[1]:=digits[(w SHR 12) AND $000F];
  hexword:=s;
END;

FUNCTION hexlong(l:longint):string;
CONST digits:array[0..15] of char=
        ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
VAR s:string;
BEGIN
  s:='00000000';
  s[8]:=digits[l AND $000F];
  s[7]:=digits[(l SHR 4) AND $000F];
  s[6]:=digits[(l SHR 8) AND $000F];
  s[5]:=digits[(l SHR 12) AND $000F];
  s[4]:=digits[(l SHR 16) AND $000F];
  s[3]:=digits[(l SHR 20) AND $000F];
  s[2]:=digits[(l SHR 24) AND $000F];
  s[1]:=digits[(l SHR 28) AND $000F];
  hexlong:=s;
END;

FUNCTION word2str(v:word):string;
VAR s:string;
BEGIN
  s:='';
  str(v,s);
  word2str:=s;
END;

FUNCTION long2str(v:longint):string;
VAR s:string;
BEGIN
  s:='';
  str(v,s);
  long2str:=s;
END;

FUNCTION longnum2str(v:longint):string;
VAR s:string;
    i:longint;
BEGIN
  s:='';
  str(v,s);
  i:=length(s);
  REPEAT
    dec(i,3);
    s:=copy(s,1,i)+'.'+copy(s,i+1,length(s)-i);
  UNTIL (i<=3);
  longnum2str:=s;
END;

FUNCTION real2str(r:real;le,ri:longint):string;
VAR s:string;
BEGIN
  s:='';
  str(r:le:ri,s);
  real2str:=s;
END;

FUNCTION double2str(d:double;le,ri:longint):string;
VAR s:string;
BEGIN
  s:='';
  str(d:le:ri,s);
  double2str:=s;
END;

PROCEDURE pchar2str(p:pchar;var s:string);
VAR count:byte;
BEGIN
  s:='';
  Count:=0;
  WHILE (byte(p^)<>0) DO
    BEGIN
      inc(count);
      inc(p);
    END;
  s[0]:=chr(count);
  move(p^,s[1],count);
END;

FUNCTION str2pchar(var s:string):pchar;
BEGIN
  s:=s+#0;
  str2pchar:=pointer(addr(s)+1);
END;

FUNCTION roundpower2(w:dword):dword;
VAR c:byte;
BEGIN
  c:=0;
  dec(w);
  WHILE (w>0) DO
    BEGIN
      w:=w SHR 1;
      inc(c);
    END;
  roundpower2:=dword(1) SHL c;
END;

FUNCTION logdual(x:dword):dword;
VAR ld:dword;
BEGIN
  ld:=0;
  WHILE (x>0) DO
    BEGIN
      x:=x SHR 1;
      inc(ld);
    END;
  logdual:=ld-1;
END;

END.
