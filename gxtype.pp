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
UNIT gxtype;

INTERFACE

{$I gxlocal.cfg}

TYPE PPattern=^TPattern;
     TPattern=array[0..7] of byte;

TYPE PImage=^TImage;
     TImage=RECORD
       width:longint;
       height:longint;
       bytesperline:dword;
       bytesperpixel:dword;
       size:dword;
       pixeldata:pointer;
       flags:dword;
       transparencycolor:dword;
       originX,originY:longint;
       vx1,vy1,vx2,vy2:longint;
     END;

CONST gxsf_videomem    =$80000000;
      gxsf_offscreenmem=$80000001;
      gxsf_sysmem      =$80000002;
      mgxsf_memloction =$80000007;
{      gxsf_relmem      =$80000008; }
      gxsf_primary     =$80000010;

IMPLEMENTATION

END.