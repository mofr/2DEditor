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

UNIT gxsup;

INTERFACE

TYPE PModeEntry=^TModeEntry;
     TModeEntry=RECORD
       mode_nr:word;
       xres,yres:word;
       bytperpix,bytperline,scanline:word;
       hwainit,hwascanline:word;
       Rpos,Rsiz:byte;
       Gpos,Gsiz:byte;
       Bpos,Bsiz:byte;
       flags:longint;
       next:PModeEntry;
     END;

     PModeInfoEntry=^TModeInfoEntry;
     TModeInfoEntry=RECORD
       xres,yres:longint;
       name:string;
       flags:longint;
       next:PModeInfoEntry;
     END;

     gxunitinitproc=procedure;

CONST ig_modemask  =$0000000F;
      ig_bank      =$00000001;
      ig_lfb       =$00000002;
      ig_hwa       =$00000004;
      ig_colmask   =$0000FF00;
      ig_col8      =$00000100;
      ig_col15     =$00000200;
      ig_col16     =$00000400;
      ig_col24     =$00000800;
      ig_col32     =$00001000;

PROCEDURE RegisterGXUnit(proc:gxunitinitproc);
PROCEDURE ExecuteGXUnitInit;

PROCEDURE AddModeToList(var modelist:PModeEntry;mode_nr,xres,yres,bytperpix,bytperline,scanline,hwainit,hwascanline:word;rpos,rsiz,gpos,gsiz,bpos,bsiz:byte;flags:longint);
FUNCTION GetModeFromList(modelist:PModeEntry;xres,yres:word;flags:longint):PModeEntry;
{FUNCTION GetModeFromList(modelist:PModeEntry;xres,yres:word):PModeEntry;}
PROCEDURE DeleteModeList(var modelist:PModeEntry);
FUNCTION CreateModeInfoList:PModeInfoEntry;
FUNCTION GetNextModeInfo(var list:PModeInfoEntry;var modeinfo:TModeInfoEntry):boolean;
PROCEDURE DeleteModeInfoList(var list:PModeInfoEntry);

PROCEDURE PUSHcoords(x1,y1,x2,y2:longint);
PROCEDURE POPcoords(var x1,y1,x2,y2:longint);

IMPLEMENTATION

USES gxbase,gxcrtext;

{---------------------------- automatic init --------------------------------}

TYPE PRegUnitList=^TRegUnitList;
     TRegUnitList=RECORD
       gxunitinit:gxunitinitproc;
       next:PRegUnitList;
     END;

CONST RegUnitList:PRegUnitList=nil;

PROCEDURE RegisterGXUnit(proc:gxunitinitproc);
VAR h:PRegUnitList;
BEGIN
  new(h);
  h^.gxunitinit:=proc;
  h^.next:=RegUnitList;
  RegUnitList:=h;
END;

PROCEDURE ExecuteGXUnitInit;
VAR h:PRegUnitList;
BEGIN
  h:=RegUnitList;
  WHILE (h<>nil) DO
    BEGIN
      h^.gxunitinit;
      h:=h^.next;
    END;
END;

PROCEDURE DeleteGXUnitList;
VAR h:PRegUnitList;
BEGIN
  h:=RegUnitList;
  WHILE (h<>nil) DO
    BEGIN
      RegUnitList:=h;
      h:=h^.next;
      dispose(RegUnitList);
    END;
  RegUnitList:=nil;
END;

{---------------------------- modelist-management -------------------------}

PROCEDURE AddModeToList(var modelist:PModeEntry;mode_nr,xres,yres,bytperpix,bytperline,scanline,hwainit,hwascanline:word;rpos,rsiz,gpos,gsiz,bpos,bsiz:byte;flags:longint);
VAR h:PModeEntry;
BEGIN
  new(h);
  h^.mode_nr:=mode_nr;
  h^.xres:=xres;
  h^.yres:=yres;
  h^.bytperpix:=bytperpix;
  h^.bytperline:=bytperline;
  h^.scanline:=scanline;
  h^.hwainit:=hwainit;
  h^.hwascanline:=hwascanline;
  h^.rpos:=rpos;
  h^.rsiz:=rsiz;
  h^.gpos:=gpos;
  h^.gsiz:=gsiz;
  h^.bpos:=bpos;
  h^.bsiz:=bsiz;
  h^.flags:=flags;
  h^.next:=modelist;
  modelist:=h;
END;

FUNCTION GetModeFromList(modelist:PModeEntry;xres,yres:word;flags:longint):PModeEntry;
VAR h:PModeEntry;
BEGIN
  h:=modelist;
  WHILE (h<>nil) DO
    BEGIN
      IF (h^.xres=xres) AND (h^.yres=yres) AND
         ((h^.flags AND ig_colmask)=(flags AND ig_colmask)) THEN break;
      h:=h^.next;
    END;
  GetModeFromList:=h;
END;

{FUNCTION GetModeFromList(modelist:PModeEntry;xres,yres:word):PModeEntry;
VAR h:PModeEntry;
BEGIN
  h:=modelist;
  WHILE (h<>nil) DO
    BEGIN
      IF (h^.xres=xres) AND (h^.yres=yres) THEN break;
      h:=h^.next;
    END;
  GetModeFromList:=h;
END;}

PROCEDURE DeleteModeList(var modelist:PModeEntry);
VAR h:PModeEntry;
BEGIN
  h:=modelist;
  WHILE (h<>nil) DO
    BEGIN
      modelist:=h;
      h:=h^.next;
      dispose(modelist);
    END;
  modelist:=nil;
END;

FUNCTION CreateModeInfoList:PModeInfoEntry;
VAR h1:PModeEntry;
    pre,h2a,h2b,h2c:PModeInfoEntry;
    s:string;
BEGIN
  h1:=CurGraphiX.modelist;
  h2b:=nil;
  h2c:=nil;
  WHILE (h1<>nil) DO
    BEGIN
      s:=word2str(h1^.xres)+'x'+word2str(h1^.yres);
      CASE (h1^.flags AND ig_colmask) OF
        ig_col8 :s:=s+'x8';
        ig_col15:s:=s+'x15';
        ig_col16:s:=s+'x16';
        ig_col24:s:=s+'x24';
        ig_col32:s:=s+'x32';
      END;
      new(h2a);
      h2a^.xres:=h1^.xres;
      h2a^.yres:=h1^.yres;
      h2a^.name:=s;
      h2a^.flags:=h1^.flags;
      h2a^.next:=nil;

      IF (h2b=nil) THEN
        BEGIN
          h2b:=h2a;
        END
      ELSE
        BEGIN
          h2c:=h2b;
          WHILE (h2c<>nil) DO
            IF ((longint(h2a^.xres) SHL 18+longint(h2a^.yres) SHL 4+(h2a^.flags AND ig_colmask) SHR 8)>=
                (longint(h2c^.xres) SHL 18+longint(h2c^.yres) SHL 4+(h2c^.flags AND ig_colmask) SHR 8)) THEN
              BEGIN pre:=h2c;h2c:=h2c^.next; END ELSE break;
          IF (h2c=h2b) THEN
            BEGIN
              h2a^.next:=h2c;
              h2b:=h2a;
            END
          ELSE
            BEGIN
              h2a^.next:=h2c;
              pre^.next:=h2a;
            END;
        END;
      h1:=h1^.next;
    END;
  CreateModeInfoList:=h2b;
END;

FUNCTION GetNextModeInfo(var list:PModeInfoEntry;var modeinfo:TModeInfoEntry):boolean;
VAR h:PModeInfoEntry;
BEGIN
  h:=list;
  GetNextModeInfo:=(h<>nil);
  IF (h<>nil) THEN
    BEGIN
      move(h^,modeinfo,sizeof(TModeInfoEntry));
      list:=list^.next;
      dispose(h);
    END;
END;

PROCEDURE DeleteModeInfoList(var list:PModeInfoEntry);
VAR h:PModeInfoEntry;
BEGIN
  WHILE (list<>nil) DO
    BEGIN
      h:=list;
      list:=list^.next;
      dispose(h);
    END;
END;

{--------------------------------------------------------------------------}

TYPE Pcoord=^Tcoord;
     Tcoord=RECORD
       x1,y1,x2,y2:longint;
       next:Pcoord;
     END;

VAR coordstack:Pcoord;

PROCEDURE PUSHcoords(x1,y1,x2,y2:longint);
VAR h:Pcoord;
BEGIN
  new(h);
  h^.x1:=x1;
  h^.y1:=y1;
  h^.x2:=x2;
  h^.y2:=y2;
  h^.next:=coordstack;
  coordstack:=h;
END;

PROCEDURE POPcoords(var x1,y1,x2,y2:longint);
VAR h:Pcoord;
BEGIN
  h:=coordstack;
  IF (h<>nil) THEN
    BEGIN
      x1:=h^.x1;
      y1:=h^.y1;
      x2:=h^.x2;
      y2:=h^.y2;
      coordstack:=h^.next;
      dispose(h);
    END;
END;

PROCEDURE ClearCoordStack;
VAR h:Pcoord;
BEGIN
  h:=coordstack;
  WHILE (h<>nil) DO
    BEGIN
      coordstack:=h;
      h:=h^.next;
      dispose(coordstack);
    END
END;

{==========================================================================}

VAR OldExitProc:pointer;

PROCEDURE NewExitProc;
BEGIN
  ExitProc:=OldExitProc;
  ClearCoordStack;
  DeleteGXUnitList;
END;

BEGIN
  OldExitProc:=ExitProc;
  ExitProc:=@NewExitProc;
  CoordStack:=nil;
END.