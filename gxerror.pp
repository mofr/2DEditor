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
UNIT gxerror;

INTERFACE

{$I gxlocal.cfg}

CONST err_ok=0;
      err_outofmem=203;

VAR gxerrno:longint;

PROCEDURE gxerr(errno:longint);
PROCEDURE graphixerror(errvar:longint;errmsg:string);

IMPLEMENTATION

USES graphix;

PROCEDURE gxerr(errno:longint);
BEGIN
  CASE errno OF
  gx_error:
    BEGIN
      InitText;
      halt;
    END;
  END;
END;

FUNCTION getgxerrmsg(errvar:longint):string;
CONST prefix='GraphiX-Error: ';
BEGIN
  CASE errvar OF
  err_ok:      getgxerrmsg:=prefix+'no error';
  err_outofmem:getgxerrmsg:=prefix+'out of memory';
  ELSE         getgxerrmsg:=prefix+'unknown error';
  END;
END;

PROCEDURE graphixerror(errvar:longint;errmsg:string);
BEGIN
  IF (errvar<>err_ok) THEN
    BEGIN
      DoneGraphiX;
      InitText;
      writeln(getgxerrmsg(errvar),' (',errmsg,')');
      halt;
    END;
END;

BEGIN
  gxerrno:=err_ok;
END.