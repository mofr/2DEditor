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

{$I gxglobal.cfg}
UNIT gxcrt;

INTERFACE

{$I gxlocal.cfg}

FUNCTION readkey:char;
FUNCTION keypressed:boolean;
PROCEDURE delay(ms:word);

IMPLEMENTATION

{$IFDEF GO32V2LINUX}
USES crt;
{$ENDIF}
{$IFDEF WIN32}
USES gxdd;
{$ENDIF}

FUNCTION readkey:char;
BEGIN
{$IFDEF GO32V2LINUX}
  readkey:=crt.readkey;
{$ENDIF}
{$IFDEF WIN32}
  readkey:=DDreadkey;
{$ENDIF}
END;

FUNCTION keypressed:boolean;
BEGIN
{$IFDEF GO32V2LINUX}
  keypressed:=crt.keypressed;
{$ENDIF}
{$IFDEF WIN32}
  keypressed:=DDkeypressed;
{$ENDIF}
END;

PROCEDURE delay(ms:word);
BEGIN
{$IFDEF GO32V2LINUX}
  crt.delay(ms);
{$ENDIF}
{$IFDEF WIN32}
  DDdelay(ms);
{$ENDIF}
END;

END.