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
UNIT gxbase;

INTERFACE

USES gxtype,gxsup;
{$I gxlocal.cfg}

TYPE sethwaprocsproc=procedure(col:longint);
     adjustaddressesproc=procedure(old_ds_base,new_ds_base:dword);
     initmodeproc=procedure(mode:word);
     enableregsproc=procedure;
     disableregsproc=procedure;
     setcolormodeproc=procedure(col:longint);
     setrgbcolorproc=procedure(i,r,g,b:byte);
     bankswitchproc=procedure;
     scanlineproc=procedure(linewidth:word);
     displaystartproc=procedure(offs:dword);
     enableLFBproc=procedure(physaddr:dword);
     disableLFBproc=procedure;
     getLFBnMMIOproc=procedure;
     enableMMIOproc=procedure(physaddr:dword);
     disableMMIOproc=procedure;
     enableHWAproc=procedure(col,init,bpl,bpp,pix:longint);
     disableHWAproc=procedure;
     errorhandlerproc=procedure;
     retraceproc=procedure;
     retracestartproc=procedure;
     retraceendproc=procedure;

     copy_ram2vramproc=procedure(src,dst:pointer);
     copy_vram2ramproc=procedure(src,dst:pointer);

     copy_xram2xramproc=procedure(src,dst,size:dword);
     pageflipproc=procedure;
     pixofsproc=function(x,y:longint):word;
     rgbcolorproc=function(r,g,b:byte):longint;
     rgbcolor32proc=function(f:longint):longint;
     getrgbcolor32proc=function(f:longint):longint;
     putpixelproc=procedure(x,y,f:longint);
     getpixelproc=function(x,y:longint):longint;
     lineproc=procedure(x1,y1,x2,y2,f:longint);
     linepatternproc=procedure(x1,y1,x2,y2,f,pat,bits:longint);
     lineHproc=procedure(x1,x2,y,f:longint);
     lineVproc=procedure(x,y1,y2,f:longint);
     barproc=procedure(x1,y1,x2,y2,f:longint);
     polygonproc=procedure(var p;nr:word;f:longint);
     moverectproc=procedure(x1,y1,x2,y2,x,y:longint);
     captureimageproc=function(x1,y1,x2,y2:longint;img:pimage):pimage;
     getimageproc=function(x,y:longint;img:pimage):pimage;
     putimageproc=procedure(x,y:longint;img:pimage);
     putimagepartproc=procedure(x,y,xi1,yi1,xi2,yi2:longint;img:pimage);
     putbitmapproc=procedure(x,y,w,h,bpl,col:longint;var bitmap);

     zoomimageproc=procedure(x1,y1,x2,y2:longint;img:pimage);
     graphwinHWproc=procedure(x1,y1,x2,y2:longint);
     setpatternHWproc=procedure(pattern:PPattern);

TYPE TGraphiX=RECORD
       detected,pcidev,vbeinit,vgacomp,oldinit,checkmem:boolean;
       name,vendorname:string;
       memory:word;
       init:word;
       memmode:word;
       flags:word; {gx_xxx - Konstanten}
       numpages:word;
       bankshift:word;
  {     MMRaddr,MMRsize:longint; }
       LFBaddr,LFBsize:dword;
       MMIOaddr,MMIOsize:dword;
       adjustaddresses:adjustaddressesproc;
       sethwaprocs:sethwaprocsproc;
       initmode:initmodeproc;
       enableregs:enableregsproc;
       disableregs:disableregsproc;
       setcolormode:setcolormodeproc;
       setrgbcolor:setrgbcolorproc;
       bankswitch:bankswitchproc;
       retrace:retraceproc;
       retracestart:retracestartproc;
       retraceend:retraceendproc;
       scanline:scanlineproc;
       displaystart:displaystartproc;
       enableLFB:enableLFBproc;
       disableLFB:disableLFBproc;
       enableMMIO:enableMMIOproc;
       disableMMIO:disableMMIOproc;
       getLFBnMMIO:getLFBnMMIOproc;
       enableHWA:enableHWAproc;
       disableHWA:disableHWAproc;
       errorhandler:errorhandlerproc;
       ModeList:PModeEntry;
     END;

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


VAR CurGraphiX:TGraphiX;

    bytperpix,bytperline:dword;
    hwascanline:dword;

    frontdrawoffset:dword;
    frontdrawoffsetpix:dword;

    curpattern:PPattern;
{    currop:array[0..3] of dword; }

    drawoffset:dword;

    maxX,maxY,curX,curY:longint;

    VGAbase,LFBbase:dword;

 {   VGAoffs:longint; }
    LFBoffs,MMIOoffs:dword;

  {  drawoffs,}drawmemsize:dword;
  {  zbufoffs,zbufmemsize:longint; }
    offscreenmemoffs,offscreenmemsize:dword;
    cursormemoffs,cursormemsize:dword;
    imagememoffs,imagememsize:dword;
    patternmemoffs,patternmemsize:dword;
    videomemsize:dword;

    Zbufoffs:pointer;
    Zbufsize:longint;
    Zbufbytperline:longint;

    MMXavail:boolean;

IMPLEMENTATION

END.

