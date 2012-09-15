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

{DEFINE STARTINFO}  { displays startup message }
{DEFINE GXINFO}     { displays detecting information}
{DEFINE GXMODES}    { displays supported modes}
{DEFINE VBEONLY}    { VBE detection only }

{                      --------------------------
                             G r a p h i X
                             for FreePascal
                       --------------------------
                                 v4.00
                               2001/02/01
                       --------------------------

VERSION HISTORY

#  + 'readscanline' & 'writescanline'
# + Chips&Tech (6555x) direct support with hardware acceleration
# + ATI (mach8, mach32, mach64) direct support with hardware acceleration
# + nVidia Riva128/RivaTNT/RivaTNT2 support

Version 4.00.06 (2000/07/xx)
    = bugfix: getpixel (LFB)
    = bugfix: clearscreen
    = extended GXTTF
    = extended filterimage in GXIMEFF

Version 4.00.04 (2000/03/15)
    = bugfix in MSVC 15bit codec
    = Range checking problems solved
    + dashed lines - opaque and XORed
    = win32-double-buffering problem fixed
    + ANI Player in GXMEDIA

Version 4.00.02 (2000/03/04)
    + text output to images
    + output images now clipped

Version 4.00 (2000/02/xx)
    = Working ATI Support
    = GO32V2 & WIN32 in one library
    = more flexible TImage format
    + WinNT4 SP3+ (DirectX3) support
    + some renamings
    + New Buffer & Surface Management
    + 15, 16 and 32bit support for Windows Bitmaps
    + Linux Support SVGAlib

Version 3.10 rev 7 (2000/09/06)
    + Mouse Unit improved (7)
    = ATI Support works now (6)
    = ImageDrawing Functions (6)

Version 3.10 rev 3 (2000/07/30)
    = Bugfixes
    = ARK Logic support works now
    = Initialisation Routines Clean-Up

Version 3.10 (2000/07/12)
    = Bugfixes
    = $MODE OBJFPC supported
    + Voodoo Banshee/Avenger Support
    + S3 ViRGE 24bit support
    + staturated ADD/SUB in GXIMEFF

Version 3.00# (2000/01/03)
  Version 3.00g4 (2000/02/14)
    = GXIMG
      = JPG - Loader:
        * speed-up & bugfixes
  Version 3.00g3 (2000/02/11)
    = GXIMG
      = JPG - Loader:
        * speed-up & bugfixes
  Version 3.00g2 (2000/02/07)
    = GXIMG
      + JPG - Loader:
        * SOF1-Markers: standard encoded, extended huffmann
        * SOF2-Markers: progressive encoded, huffmann
  Version 3.00g (2000/02/05)
    = GXIMG
      + JPG - Loader:
        * SOF0-Markers: standard encoded, huffmann
      + ProgressMonitor
  Version 3.00f (2000/01/21)
    = Image-format-extension
      + img_origincoords (flags)
      + originX, originY - coorinates of image center
    = GXIMG
      + BMP - bug-fixes, RLE4, RLE8 support
      + GIF - multiple image
      + ICO - bug-fixes, CUR-cursors-support, RLE4, RLE8 support
      + TIF - CMYK color, multiple image
    = GXMAUSD
      + 'CreateMousePointer' extended
  Version 3.00e (2000/01/09)
    - GIF-Animator
    - some GXIMG bugfixes
    - PNG interlaced image support
  Version 3.00d2 (2000/01/05)
    - a lot of GXIMG bugfixes
    - Faster Stream: TMyStream in GXIMG
  Version 3.00d (2000/01/03)
    - GXIMAGE removed
      * Loader & Saver in GXIMG - TStream - based
      * Image-Handling now in GRAPHIX
  Version 3.00c (2000/01/01)
    = compiling problems with ppc386 0.99.13 solved
  Version 3.00b (2000/01/01)
    = some dirty things removed
    = some changes in GXMAUSD
  Version 3.00a (1999/12/31)
    = Initialisation-routines-clean-up and bug-fixes
    + 'putimagepart' - displays a part of an image
    + 'putimagepartC' - displays a part of a transparent image
    + 'LoadImageICO' - loads MS-Windows (tm) icons, with transparency
    = 'LoadImagePCX' supports now 4bit PCX-images
    + 'LoadImagePNG' loader for PNG-Images
    + 'LoadImagePxM' loader for PBM, PGM and PPM-Images - ascii & binary
    + 'InitGX3D','InitGXIMEFF' are not needed anymore
    + new transparency color management
      - new image-header format (64 bytes size)
      - transparency color added to image header
      - 'LoadImageGIF' supports now transparency color
      - 'LoadImageICO' supports transparency color
      - declarations of the transpareny-image-output-routines
        are now the same as the solid-image-output-routines
    = Bugfixes
      - 'SaveImagBMP' - corrected header info
      - Tseng ET4000 direct support

Version 2.10 (08.08.1999)
  + new graphics mode management system
  = 'getimage' --> 'captureimage'
  + new 'getimage'
  = 'putimageHG'/'zoomimageHG' --> 'putimageC'/'zoomimageC'
  + Compiler-Directives 'STARTINFO','GXINFO','VBEONLY'
  = Bugfixes:
    - 'zoomimage','zoomimageC'

Version 2.00 (08.07.1999)
  + 8x8 Pattern Support

Version 1.20 (03.06.1999)
  + more internal changes (intialisation)
  + Trident Hardware-Acceleration (9440+,96xx)

Version 1.11 (30.05.1999)
  + internal changes (initialisation)
  + MMX-'copyfront2back'-bugfix

Version 1.10 (24.05.1999)
  + GXTEXT - Text-Output-Unit
  + MMX for moverect

Version 1.02 (16.05.1999)
  + better memory detection
  + MMX support for bar (not 24bit), putimage

Version 1.01 (12.05.1999)
  + 'getrgbcolor'
  + VESA-wrong-color-problem fixed
  + 32bit TGA support

Version 1.00 (25.03.1999 - 09.05.1999)
  Conversion of
    "GraphiX 7.11 for Borland Pascal"
  to
    "GraphiX 1.00 for FreePascal"

                       --------------------------
}

{$I gxglobal.cfg}
UNIT graphix;

INTERFACE

USES gxtype{$IFDEF GO32V2},gxpci{$ENDIF}
           {$IFDEF WIN32},gxdd{$ENDIF}
           {$IFDEF GO32V2LINUX},gxvidmem{$ENDIF},gxbase,gxsup;
{$I gxlocal.cfg}

CONST vergxname='GraphiX/FP';
      vergxauthor='Michael Knapp';
      vergxmajornum='4';
      vergxminornum='0';
      vergxrev='5';
      vergxdate='2001/07/25';
      vergxcopyright='(c) 1999-2001';
      {$IFDEF GO32V2}vergxtarget='GO32V2';{$ENDIF}
      {$IFDEF WIN32}vergxtarget='Win32';{$ENDIF}
      {$IFDEF LINUX}vergxtarget='Linux';{$ENDIF}
      vergraphix=vergxname+' '+vergxmajornum+'.'+vergxminornum+'.'+vergxrev+' for '+vergxtarget+' ['+vergxdate+'] '+vergxcopyright+' '+vergxauthor;

CONST ig_modemask      =$0000000F;
      ig_bank          =$00000001;
      ig_lfb           =$00000002;
      ig_hwa           =$00000004;
      ig_hwaclip       =$00000014;
      ig_colmask       =$0000FF00;
      ig_col8          =$00000100;
      ig_col15         =$00000200;
      ig_col16         =$00000400;
      ig_col24         =$00000800;
      ig_col32         =$00001000;
      ig_hicol         =$00000600;
      ig_truecol       =$00001800;

{----- new flags -----}
      {general flags}
      gx_ok            =$00000000;
      gx_error         =$FFFFFFFF;
      {surface flags}
      gxsf_videomem    =$80000000;
      gxsf_offscreenmem=$80000001;
      gxsf_sysmem      =$80000002;
      mgxsf_memloction =$80000007;
   {   gxsf_relmem      =$80000008; }
      gxsf_primary     =$80000010;
{---------------------}

      ig_detect=$FFFF;
      ig_chiptype=$00FF;
      ig_chipsubtype=$FF00;
      ig_vga=$F000;
      ig_ark=$0001;
      ig_ati=$0009;
      ig_ati_mach8=$1009;
      ig_ati_mach32=$2009;
      ig_ati_mach64=$3009;
      ig_cirrus=$0002;
    {  ig_chips=$0003;
      ig_chipstech=$1003;
      ig_chips6555x=$2003; }
      ig_matrox=$0004;
      ig_s3=$0005;
      ig_s3vision=$0105;
      ig_s3trio=$0205;
      ig_s3virge=$0305;
   {   ig_sis=$0006; }
      ig_trident=$0007;
      ig_tseng=$0008;
      ig_tseng4000=$0208;
      ig_tseng4000w32=$0408;
      ig_tseng6000=$0608;
      ig_3dfx=$000A;
      ig_vesa=$00FF;
      ig_vesa12=$12FF;
      ig_vesa20=$20FF;
      ig_vesa30=$30FF;
      ig_directdraw=$0080;
      ig_svgalib=$0081;
      ig_gxdriver=$FE00;
      ig_user_defined=$FF00;

      fs_style_mask=$00FF;
   {   fs_rop_mask_=$0F02; }

      fs_solid=$0000;
      fs_pattern=$0001;
   {    fs_rop=$0002;

      fs_rop_black=$0002;
      fs_rop_and=$0102;
      fs_rop_nimp=$0202;
      fs_rop_dst=$0302;
      fs_rop_col=$0502;
      fs_rop_xor=$0602;
      fs_rop_or=$0702;
      fs_rop_nor=$0802;
      fs_rop_equ=$0902;
      fs_rop_ncol=$0A02;
      fs_rop_ndst=$0C02;
      fs_rop_imp=$0D02;
      fs_rop_nand=$0E02;
      fs_rop_white=$0F02;  }

    {  gx_Bank=$0001;
      gx_LFB=$0002;
      gx_HW=$0004; }
      gx_MMIO=$0008;
    {  gx_HWclip=$0014; }
    {  gx_res1=$0020;
      gx_res2=$0040; }
{      gx_COL8=$0080;
      gx_COL15=$0100;
      gx_COL16=$0200;
      gx_COL24=$0400;
      gx_COL32=$0800;
      gx_COLall=$0F80; }
{      gx_HW8=$1004;
      gx_HW16=$2004;
      gx_HW24=$4004;
      gx_HW32=$8004;
      gx_HWall=$F004; }

      img_allflags=$FFFFFFFF;
      img_transparency=$00000010;
      img_origincoords=$00000100;

      graphbufsize=65536*4;

TYPE TPatternLine=array[0..7] of char;

TYPE PSurface=^TSurface;
     TSurface=RECORD
       base:pointer;
       flags:dword;
       width,height,bpl,size:longint;
       vx1,vy1,vx2,vy2:longint;
       ss:TSpecSurface;
     END;

VAR vx1,vy1,vx2,vy2:longint;
 {   bytperline,}{bytperpix}{,hwascanline}{:longint;}

{$IFDEF GO32V2}
    PCIdevice:TPCIdevice;
{$ENDIF}

    curbank,bankgran:word;
    scrnsize:longint;

    pciaddr:longint;

{    oldinit:boolean; }

  {  drawoffset}{,drawoffsetpix,drawoffsety,Zbufofs}{:longint;}
  {  frontdrawoffset,}{frontdrawoffsetpix,}frontdrawoffsety{,frontZbufofs}:longint;
    drawbufsize,drawbufsizepix,drawbufsizey:longint;

    curmode:PModeEntry;
    curinit:longint;
    gxcurres:longint;
    gxcurcol:longint;
    gxcurflags:dword;
    gxcurresname:string;
    gxcurcolname:string;
    graphbuf:pointer;

    curvisualpage:longint;
    curactivepage:longint;

    gxredpos,gxredsize:byte;
    gxgreenpos,gxgreensize:byte;
    gxbluepos,gxbluesize:byte;

    bankswitch:bankswitchproc;
    waitforretrace:retraceproc;
    waitforretracestart:retracestartproc;
    waitforretraceend:retraceendproc;
{    scanline:scanlineproc;
    displaystart:displaystartproc; }
 {   pageflip:pageflipproc; }
{    copy_ram2vram:copy_ram2vramproc;
    copy_vram2ram:copy_vram2ramproc; }

    copy_sram2sram:copy_xram2xramproc;
    copy_sram2vram:copy_xram2xramproc;
    copy_vram2sram:copy_xram2xramproc;
    copy_vram2vram:copy_xram2xramproc;

    pixofs:pixofsproc;
    rgbcolorRGB:rgbcolorproc;
    rgbcolor:rgbcolor32proc;
    getrgbcolor32:getrgbcolor32proc;
    putpixel:putpixelproc;
    getpixel:getpixelproc;
    line,lineXOR:lineproc;
    linepattern,linepatternXOR:linepatternproc;
    lineH,lineH_solid,lineH_pattern:lineHproc;
    lineV,lineV_solid,lineV_pattern:lineVproc;
    bar,bar_solid,bar_pattern:barproc;
    barrop,barrop_solid,barrop_pattern:barproc;
    barXOR,barXOR_solid,barXOR_pattern:barproc;
    moverect:moverectproc;
    captureimage:captureimageproc;
    getimage:getimageproc;
    putimage:putimageproc;
    putimageC:putimageproc;
    putimagepart:putimagepartproc;
    putimagepartC:putimagepartproc;
    putbitmap:putbitmapproc;
    zoomimage:zoomimageproc;
    zoomimageC:zoomimageproc;
    graphwinHW:graphwinHWproc;
    setpatternHW:setpatternHWproc;

VAR VGAphys,VGAsize,VGAlinear:dword;
    LFBphys,LFBsize,LFBlinear:dword;
    MMIOphys,MMIOsize,MMIOlinear:dword;
    LFBenabled,HWAenabled,MMIOenabled,GraphiXActive:boolean;
    HWAused,HWAclip,MFBused:boolean;
    defaultbackbuf:pointer;
    crtcsave:array[0..127] of byte;

PROCEDURE moveto(x,y:longint);
PROCEDURE lineto(x,y,f:longint);
PROCEDURE rectangle(x1,y1,x2,y2,f:longint);
PROCEDURE clearscreen(color:dword);

{FUNCTION GetNumPages:word;
PROCEDURE EnableDoubleBuffering;
PROCEDURE DisableDoubleBuffering;
PROCEDURE SetActivePage(nr:longint);
PROCEDURE SetVisualPage(nr:longint);
PROCEDURE SetFrontBuffer;
PROCEDURE SetBackBuffer(buf:pointer);
PROCEDURE CreateBackBuffer(var buf:pointer);
PROCEDURE DestroyBackBuffer(var buf:pointer);
PROCEDURE CopyFront2Front(srcpage,dstpage:longint);
PROCEDURE CopyBack2Front(buf:pointer;page:longint);
PROCEDURE CopyFront2Back(page:longint;buf:pointer);
PROCEDURE CopyBack2Back(srcbuf,dstbuf:pointer); }

FUNCTION CreateSurface(var sf:PSurface;flags:dword):dword;
FUNCTION DestroySurface(var sf:PSurface):dword;
FUNCTION SetActiveSurface(sf:PSurface;changeclip:boolean):dword;
{FUNCTION SetVisibleSurface(sf:PSurface):dword;}
FUNCTION EnableSurfaceFlipping(var sf:PSurface;flags:dword):dword;
FUNCTION DisableSurfaceFlipping(sf:PSurface):dword;
FUNCTION CopySurface(dsf,ssf:PSurface):dword;
FUNCTION FlipSurface(waitforverticalretrace:boolean):dword;

PROCEDURE GetGraphix(init:longint);
FUNCTION InitGraphiX(init,memmode:longint):boolean;
FUNCTION IsModeAvailable(xres,yres,col:longint):boolean;
FUNCTION SetModeGraphiX(xres,yres,col:longint):boolean;
PROCEDURE DoneGraphix;

PROCEDURE setfillstyle(fillstyle:dword);
PROCEDURE setfillpattern(fillstyle:dword;pattern:ppattern);
FUNCTION createpattern(pc:char;b0,b1,b2,b3,b4,b5,b6,b7:tpatternline):PPattern;
PROCEDURE destroypattern(p:PPattern);

PROCEDURE InitText;

PROCEDURE graphwin(x1,y1,x2,y2:longint);
PROCEDURE subgraphwin(x1,y1,x2,y2:longint);
PROCEDURE maxgraphwin;
PROCEDURE pushgraphwin;
PROCEDURE popgraphwin;
PROCEDURE getgraphwin(var x1,y1,x2,y2:longint);

FUNCTION getmaxX:longint;
FUNCTION getmaxY:longint;

PROCEDURE getrgbcolorRGB(f:longint;var r,g,b:byte);
PROCEDURE getrgbcolor(f:longint;var c:longint);

FUNCTION testMMX:word;

FUNCTION createimageWH(width,height:longint):pimage;
FUNCTION createimage(x1,y1,x2,y2:longint):pimage;
FUNCTION copyimage(dst,src:pimage):pimage;
FUNCTION cloneimage(img:pimage):pimage;
FUNCTION getimagewidth(img:pimage):longint;
FUNCTION getimageheight(img:pimage):longint;
PROCEDURE setimageflags(img:pimage;flags:dword);
PROCEDURE clearimageflags(img:pimage;flags:dword);
FUNCTION getimageflags(img:pimage;flags:dword):longint;
PROCEDURE setimagetransparencycolor(img:pimage;color:longint);
FUNCTION getimagetransparencycolor(img:pimage):longint;
PROCEDURE destroyimage(var img:pimage);

IMPLEMENTATION

{$IFDEF GO32V2}
USES crt,gxcrtext,go32,gxvga,gxvbe,gxerror,gxmem,
     gxhw_mga,gxhw_tsg,gxhw_vdo,gxhw_s3,gxhw_ark,gxhw_cir,gxhw_trd,gxhw_ati;
{$I GRAPHIXB.PPI}
{$ENDIF}

{$IFDEF WIN32}
USES {gxdd,}gxcrtext,windows,strings,sysutils,gxerror;
{$ENDIF}

{$IFDEF LINUX}
USES crt,gxcrtext,gxerror,gxvgalib;
{$I GRAPHIXB.PPI}
{$ENDIF}

{$I GRAPHIXL.PPI}
{$I GRAPHIXM.PPI}

{============================= TestMMX ====================================}

FUNCTION TestMMX:word;assembler;
ASM
{--- test for CPUID}
  PUSHFD
  POP EAX
  MOV EBX,EAX
  XOR EAX,00200000h
  PUSH EAX
  POPFD
  PUSHFD
  POP EAX
  CMP EAX,EBX
  JNE @cpuid_detected
  PUSH EBX
  POPFD
  XOR AX,AX
  JMP @ende
@cpuid_detected:
  PUSH EBX
  POPFD
{--- CPUID}
  XOR EAX,EAX
  CPUID
  CMP AL,01
  JAE @cpuid_inval1
  XOR AX,AX
  JMP @ende
{;--- read feature-info}
@cpuid_inval1:
  XOR EAX,EAX
  MOV AL,01h
  CPUID
  TEST EDX,00800000h
  JNZ @ende
  XOR AX,AX
@ende:
END;

{=============================== Misc =====================================}

FUNCTION IsModeAvailable(xres,yres,col:longint):boolean;
BEGIN
  IsModeAvailable:=(GetModeFromList(CurGraphiX.modelist,xres,yres,col)<>nil);
END;

PROCEDURE InitText;assembler;
ASM
{$IFDEF GO32V2}
  MOV AX,0003h
  XOR BX,BX
  XOR CX,CX
  XOR DX,DX
  INT 10h
{$ENDIF}
END;

PROCEDURE set_gxcurres(x,y:longint);
BEGIN
  gxcurres:=longint((x DIV 1000) MOD 10) SHL 28+
            longint((x DIV 100) MOD 10) SHL 24+
            longint((x DIV 10) MOD 10) SHL 20+
            longint((x DIV 1) MOD 10) SHL 16+
            longint((y DIV 1000) MOD 10) SHL 12+
            longint((y DIV 100) MOD 10) SHL 8+
            longint((y DIV 10) MOD 10) SHL 4+
            longint((y DIV 1) MOD 10) SHL 0;
{DBG(x);
DBG(y);
DBG(hexlong(gxcurres));}
  gxcurresname:=word2str(x)+'x'+word2str(y);
END;

PROCEDURE set_gxcurcol(col:longint);
BEGIN
  CASE (col AND ig_colmask) OF
  ig_col8:gxcurcolname:='8bit';
  ig_col15:gxcurcolname:='15bit';
  ig_col16:gxcurcolname:='16bit';
  ig_col24:gxcurcolname:='24bit';
  ig_col32:gxcurcolname:='32bit';
  END;
END;

{============================= drawing window =============================}

PROCEDURE graphwin(x1,y1,x2,y2:longint);
BEGIN
  IF (x1>x2) THEN
    ASM
      MOV EAX,x1
      XCHG EAX,x2
      MOV x1,EAX
    END;
  IF (y1>y2) THEN
    ASM
      MOV EAX,y1
      XCHG EAX,y2
      MOV y1,EAX
    END;
  IF (x1<0) THEN x1:=0;
  IF (x2>maxX) THEN x2:=maxX;
  IF (y1<0) THEN y1:=0;
  IF (y2>maxY) THEN y2:=maxY;
  IF HWAclip THEN graphwinHW(x1,y1,x2,y2);
  vx1:=x1;
  vy1:=y1;
  vx2:=x2;
  vy2:=y2;
END;

PROCEDURE subgraphwin(x1,y1,x2,y2:longint);
BEGIN
 IF (x1>x2) THEN
    ASM
      MOV EAX,x1
      XCHG EAX,x2
      MOV x1,EAX
    END;
  IF (y1>y2) THEN
    ASM
      MOV EAX,y1
      XCHG EAX,y2
      MOV y1,EAX
    END;
  IF (x1>vx1) THEN vx1:=x1;
  IF (x2<vx2) THEN vx2:=x2;
  IF (y1>vy1) THEN vy1:=y1;
  IF (y2<vy2) THEN vy2:=y2;
  IF HWAclip THEN graphwinHW(vx1,vy1,vx2,vy2);
END;

PROCEDURE pushgraphwin;
BEGIN
  PUSHcoords(vx1,vy1,vx2,vy2);
END;

PROCEDURE popgraphwin;
BEGIN
  POPcoords(vx1,vy1,vx2,vy2);
  IF HWAclip THEN graphwinHW(vx1,vy1,vx2,vy2);
END;

PROCEDURE getgraphwin(var x1,y1,x2,y2:longint);
BEGIN
  x1:=vx1;
  y1:=vy1;
  x2:=vx2;
  y2:=vy2;
END;

PROCEDURE maxgraphwin;
BEGIN
  vx1:=0;
  vy1:=0;
  vx2:=getmaxX;
  vy2:=getmaxY;
  IF HWAclip THEN graphwinHW(vx1,vy1,vx2,vy2);
END;

{============================= rgbcolor =====================================}

FUNCTION rgbcolor8(r,g,b:byte):longint;assembler;
ASM
  XOR EAX,EAX
  MOV AH,r
  AND AH,0E0h
  MOV AL,g
  SHR AL,3
  AND AL,1Ch
  OR AH,AL
  MOV AL,b
  SHR AL,6
  AND AL,03h
  OR AL,AH
  MOVZX EAX,AL
END;

FUNCTION rgbcolor15(r,g,b:byte):longint;assembler;
ASM
  XOR EAX,EAX
  MOV AL,b
  SHR AL,3

  MOV AH,r
  SHR AH,1
  AND AX,7C1Fh

  MOVZX BX,g
  SHL BX,2
  AND BX,03E0h
  OR AX,BX
END;

FUNCTION rgbcolor16(r,g,b:byte):longint;assembler;
ASM
  XOR EAX,EAX
  MOV AL,b
  SHR AL,3
  MOV AH,r
  AND AX,0F81Fh

  MOVZX BX,g
  SHL BX,3
  AND BX,07E0h
  OR AX,BX
END;

FUNCTION rgbcolor24(r,g,b:byte):longint;assembler;
ASM
  XOR EAX,EAX
  MOV AH,r
  SHL EAX,8
  MOV AL,b
  MOV AH,g
END;

FUNCTION rgbcolorall(r,g,b:byte):longint;assembler;
ASM
  PUSH ECX
  XOR EAX,EAX

  MOVZX EDX,r
  MOV CL,8
  SUB CL,gxredsize
  SHR DL,CL
  MOV CL,gxredpos
  SHL EDX,CL
  OR EAX,EDX

  MOVZX EDX,g
  MOV CL,8
  SUB CL,gxgreensize
  SHR DL,CL
  MOV CL,gxgreenpos
  SHL EDX,CL
  OR EAX,EDX

  MOVZX EDX,b
  MOV CL,8
  SUB CL,gxbluesize
  SHR DL,CL
  MOV CL,gxbluepos
  SHL EDX,CL
  OR EAX,EDX

  POP ECX
END;

{============================= rgb32color ===================================}

FUNCTION rgbcolor328(f:longint):longint;assembler;
ASM
  MOV EAX,f
  AND EAX,00E0E0C0h
  SHR AH,3
  SHR AL,6
  OR AH,AL
  SHR EAX,8
  OR AL,AH
  MOVZX EAX,AL
END;

FUNCTION rgbcolor3215(f:longint):longint;assembler;
ASM
  MOV EAX,f
  MOVZX BX,AH
  MOV AH,AL
  SHR EAX,8

  SHR AL,3

  SHR AH,1
  AND AX,7C1Fh

  SHL BX,2
  AND BX,03E0h
  OR AX,BX
END;

FUNCTION rgbcolor3216(f:longint):longint;assembler;
ASM
  MOV EAX,f
  MOVZX BX,AH
  MOV AH,AL
  SHR EAX,8

  SHR AL,3
  AND AX,0F81Fh

  SHL BX,3
  AND BX,07E0h
  OR AX,BX
  AND EAX,0000FFFFh
END;

FUNCTION rgbcolor3224(f:longint):longint;assembler;
ASM
  MOV EAX,f
  AND EAX,00FFFFFFh
END;

FUNCTION rgbcolor32all(f:longint):longint;assembler;
ASM
  PUSH ECX

  XOR EAX,EAX
  MOV EBX,f

  MOVZX EDX,BL
  MOV CL,8
  SUB CL,gxbluesize
  SHR DL,CL
  MOV CL,gxbluepos
  SHL EDX,CL
  OR EAX,EDX

  SHR EBX,8

  MOVZX EDX,BL
  MOV CL,8
  SUB CL,gxgreensize
  SHR DL,CL
  MOV CL,gxgreenpos
  SHL EDX,CL
  OR EAX,EDX

  SHR EBX,8

  MOVZX EDX,BL
  MOV CL,8
  SUB CL,gxredsize
  SHR DL,CL
  MOV CL,gxredpos
  SHL EDX,CL
  OR EAX,EDX

  POP ECX
END;

{============================= getrgbcolor =================================}

FUNCTION getrgbcolor328(f:longint):longint;assembler;
ASM
  MOV EAX,f
  SHL EAX,11
  SHR AX,5
  SHR AL,5
  SHL EAX,5
  AND EAX,00E0E0C0h
END;

FUNCTION getrgbcolor3215(f:longint):longint;assembler;
ASM
  MOV EAX,f
  SHL EAX,6
  SHR AX,3
  SHR AL,3
  SHL EAX,3
  AND EAX,00F8F8F8h
END;

FUNCTION getrgbcolor3216(f:longint):longint;assembler;
ASM
  MOV EAX,f
  SHL EAX,5
  SHR AX,2
  SHR AL,2
  SHR AX,1
  SHL EAX,3
  AND EAX,00F8FCF8h
END;

FUNCTION getrgbcolor3224(f:longint):longint;assembler;
ASM
  MOV EAX,f
  AND EAX,00FFFFFFh
END;

FUNCTION getrgbcolor32all(f:longint):longint;assembler;
ASM
  PUSH ECX

  XOR EAX,EAX
  MOV EBX,f

  MOV EDX,EBX
  MOV CL,gxredpos
  SHR EDX,CL
  MOV CL,gxredsize
  MOV CH,1
  SHL CH,CL
  DEC CH
  AND DL,CH
  XCHG CL,CH
  MOV CL,8
  SUB CL,CH
  SHL DL,CL
  MOV AL,DL

  SHL EAX,8

  MOV EDX,EBX
  MOV CL,gxgreenpos
  SHR EDX,CL
  MOV CL,gxgreensize
  MOV CH,1
  SHL CH,CL
  DEC CH
  AND DL,CH
  XCHG CL,CH
  MOV CL,8
  SUB CL,CH
  SHL DL,CL
  MOV AL,DL

  SHL EAX,8

  MOV EDX,EBX
  MOV CL,gxbluepos
  SHR EDX,CL
  MOV CL,gxbluesize
  MOV CH,1
  SHL CH,CL
  DEC CH
  AND DL,CH
  XCHG CL,CH
  MOV CL,8
  SUB CL,CH
  SHL DL,CL
  MOV AL,DL

  POP ECX
END;

PROCEDURE getrgbcolorRGB(f:longint;var r,g,b:byte);assembler;
ASM
  PUSH f
  CALL getrgbcolor32
  MOV EDI,b
  MOV [EDI],AL
  SHL EAX,8
  MOV EDI,g
  MOV [EDI],AL
  SHL EAX,8
  MOV EDI,r
  MOV [EDI],AL
END;

PROCEDURE getrgbcolor(f:longint;var c:longint);
BEGIN
  c:=getrgbcolor32(f);
END;

{======================== Palette =========================================}

PROCEDURE CreateRGBpalette;
VAR r,g,b:longint;
BEGIN
  FOR r:=0 TO 7 DO
    FOR g:=0 TO 7 DO
      FOR b:=0 TO 3 DO
        CurGraphiX.setrgbcolor(r SHL 5+g SHL 2+b,r SHL 5,g SHL 5,b SHL 6);
END;

{======================== GraphiX Initialisation ==========================}

PROCEDURE SetProcs(col:longint;lfb,mmx,hwa:boolean);
BEGIN
  mmx:=mmx AND lfb;
  HWAused:=hwa;

  rgbcolorRGB:=@rgbcolorall;
  rgbcolor:=@rgbcolor32all;
  getrgbcolor32:=@getrgbcolor32all;
  IF (gxredpos=5) AND (gxredsize=3) AND (gxgreenpos=2) AND (gxgreensize=3) AND (gxbluepos=0) AND (gxbluesize=2) THEN
    BEGIN
      col:=ig_col8;
      rgbcolorRGB:=@rgbcolor8;
      rgbcolor:=@rgbcolor328;
      getrgbcolor32:=@getrgbcolor328;
    END;
  IF (gxredpos=10) AND (gxredsize=5) AND (gxgreenpos=5) AND (gxgreensize=5) AND (gxbluepos=0) AND (gxbluesize=5) THEN
    BEGIN
      col:=ig_col15;
      rgbcolorRGB:=@rgbcolor15;
      rgbcolor:=@rgbcolor3215;
      getrgbcolor32:=@getrgbcolor3215;
    END;
  IF (gxredpos=11) AND (gxredsize=5) AND (gxgreenpos=5) AND (gxgreensize=6) AND (gxbluepos=0) AND (gxbluesize=5) THEN
    BEGIN
      col:=ig_col16;
      rgbcolorRGB:=@rgbcolor16;
      rgbcolor:=@rgbcolor3216;
      getrgbcolor32:=@getrgbcolor3216;
    END;
  IF (gxredpos=16) AND (gxredsize=8) AND (gxgreenpos=8) AND (gxgreensize=8) AND (gxbluepos=0) AND (gxbluesize=8) THEN
    BEGIN
      rgbcolorRGB:=@rgbcolor24;
      rgbcolor:=@rgbcolor3224;
      getrgbcolor32:=@getrgbcolor3224;
    END;

  CASE col OF
{=== 8bit ================================================================}
    ig_col8:
      BEGIN
        IF lfb THEN
          BEGIN
            putpixel:=@putpixelL8;
            getpixel:=@getpixelL8;
            line:=@lineL8;
            lineXOR:=@lineXORL8;
            linepattern:=@linepatternL8;
            linepatternXOR:=@linepatternXORL8;
            lineH:=@lineHL8;
            lineH_solid:=@lineHL8;
            lineH_pattern:=@lineH_patternL8;
            lineV:=@lineVL8;
            lineV_solid:=@lineVL8;
            lineV_pattern:=@lineV_patternL8;
            bar:=@barL8;
            bar_solid:=@barL8;
            bar_pattern:=@bar_patternL8;
            barXOR:=@barXORL8;
            barXOR_solid:=@barXORL8;
            barXOR_pattern:=@barXOR_patternL8;
            moverect:=@moverectL8;
            captureimage:=@captureimageL8;
            getimage:=@getimageL8;
            putimage:=@putimageL8;
            putimageC:=@putimageCL8;
            putimagepart:=@putimagepartL8;
            putimagepartC:=@putimagepartCL8;
            putbitmap:=@putbitmapL8;
            zoomimage:=@zoomimageL8;
            zoomimageC:=@zoomimageCL8;
            IF mmx THEN
              BEGIN
                lineH:=@lineHLM8;
                bar:=@barLM8;
                moverect:=@moverectLM8;
                getimage:=@getimageLM8;
                putimage:=@putimageLM8;
              END;
          END
        ELSE
          BEGIN
{$IFDEF GO32V2LINUX}
            putpixel:=@putpixelB8;
            getpixel:=@getpixelB8;
            line:=@lineB8;
            lineXOR:=@lineXORB8;
            linepattern:=@linepatternB8;
            linepatternXOR:=@linepatternXORB8;
            lineH:=@lineHB8;
            lineH_solid:=@lineHB8;
            lineH_pattern:=@lineH_patternB8;
            lineV:=@lineVB8;
            lineV_solid:=@lineVB8;
            lineV_pattern:=@lineV_patternB8;
            bar:=@barB8;
            bar_solid:=@barB8;
            bar_pattern:=@bar_patternB8;
            barXOR:=@barXORB8;
            barXOR_solid:=@barXORB8;
            barXOR_pattern:=@barXOR_patternB8;
            moverect:=@moverectB8;
            captureimage:=@captureimageB8;
            getimage:=@getimageB8;
            putimage:=@putimageB8;
            putimageC:=@putimageCB8;
            putimagepart:=@putimagepartB8;
            putimagepartC:=@putimagepartCB8;
            putbitmap:=@putbitmapB8;
            zoomimage:=@zoomimageB8;
            zoomimageC:=@zoomimageCB8;
{$ENDIF}
          END;
      END;
{=== 15bit ================================================================}
    ig_col15:
      BEGIN
        IF lfb THEN
          BEGIN
            putpixel:=@putpixelL16;
            getpixel:=@getpixelL16;
            line:=@lineL16;
            lineXOR:=@lineXORL16;
            linepattern:=@linepatternL16;
            linepatternXOR:=@linepatternXORL16;
            lineH:=@lineHL16;
            lineH_solid:=@lineHL16;
            lineH_pattern:=@lineH_patternL16;
            lineV:=@lineVL16;
            lineV_solid:=@lineVL16;
            lineV_pattern:=@lineV_patternL16;
            bar:=@barL16;
            bar_solid:=@barL16;
            bar_pattern:=@bar_patternL16;
            barXOR:=@barXORL16;
            barXOR_solid:=@barXORL16;
            barXOR_pattern:=@barXOR_patternL16;
            moverect:=@moverectL16;
            captureimage:=@captureimageL16;
            getimage:=@getimageL16;
            putimage:=@putimageL16;
            putimageC:=@putimageCL16;
            putimagepart:=@putimagepartL16;
            putimagepartC:=@putimagepartCL16;
            putbitmap:=@putbitmapL16;
            zoomimage:=@zoomimageL16;
            zoomimageC:=@zoomimageCL16;
            IF mmx THEN
              BEGIN
                lineH:=@lineHLM16;
                bar:=@barLM16;
                moverect:=@moverectLM16;
                getimage:=@getimageLM16;
                putimage:=@putimageLM16;
              END;
          END
        ELSE
          BEGIN
{$IFDEF GO32V2LINUX}
            putpixel:=@putpixelB16;
            getpixel:=@getpixelB16;
            line:=@lineB16;
            lineXOR:=@lineXORB16;
            linepattern:=@linepatternB16;
            linepatternXOR:=@linepatternXORB16;
            lineH:=@lineHB16;
            lineH_solid:=@lineHB16;
            lineH_pattern:=@lineH_patternB16;
            lineV:=@lineVB16;
            lineV_solid:=@lineVB16;
            lineV_pattern:=@lineV_patternB16;
            bar:=@barB16;
            bar_solid:=@barB16;
            bar_pattern:=@bar_patternB16;
            barXOR:=@barXORB16;
            barXOR_solid:=@barXORB16;
            barXOR_pattern:=@barXOR_patternB16;
            moverect:=@moverectB16;
            captureimage:=@captureimageB16;
            getimage:=@getimageB16;
            putimage:=@putimageB16;
            putimageC:=@putimageCB16;
            putimagepart:=@putimagepartB16;
            putimagepartC:=@putimagepartCB16;
            putbitmap:=@putbitmapB16;
            zoomimage:=@zoomimageB16;
            zoomimageC:=@zoomimageCB16;
{$ENDIF}
          END;
      END;
{=== 16bit ================================================================}
    ig_col16:
      BEGIN
        IF lfb THEN
          BEGIN
            putpixel:=@putpixelL16;
            getpixel:=@getpixelL16;
            line:=@lineL16;
            lineXOR:=@lineXORL16;
            linepattern:=@linepatternL16;
            linepatternXOR:=@linepatternXORL16;
            lineH:=@lineHL16;
            lineH_solid:=@lineHL16;
            lineH_pattern:=@lineH_patternL16;
            lineV:=@lineVL16;
            lineV_solid:=@lineVL16;
            lineV_pattern:=@lineV_patternL16;
            bar:=@barL16;
            bar_solid:=@barL16;
            bar_pattern:=@bar_patternL16;
            barXOR:=@barXORL16;
            barXOR_solid:=@barXORL16;
            barXOR_pattern:=@barXOR_patternL16;
            putbitmap:=@putbitmapL16;
            moverect:=@moverectL16;
            captureimage:=@captureimageL16;
            getimage:=@getimageL16;
            putimage:=@putimageL16;
            putimageC:=@putimageCL16;
            putimagepart:=@putimagepartL16;
            putimagepartC:=@putimagepartCL16;
            zoomimage:=@zoomimageL16;
            zoomimageC:=@zoomimageCL16;
            IF mmx THEN
              BEGIN
                lineH:=@lineHLM16;
                bar:=@barLM16;
                moverect:=@moverectLM16;
                getimage:=@getimageLM16;
                putimage:=@putimageLM16;
              END;
          END
        ELSE
          BEGIN
{$IFDEF GO32V2LINUX}
            putpixel:=@putpixelB16;
            getpixel:=@getpixelB16;
            line:=@lineB16;
            lineXOR:=@lineXORB16;
            linepattern:=@linepatternB16;
            linepatternXOR:=@linepatternXORB16;
            lineH:=@lineHB16;
            lineH_solid:=@lineHB16;
            lineH_pattern:=@lineH_patternB16;
            lineV:=@lineVB16;
            lineV_solid:=@lineVB16;
            lineV_pattern:=@lineV_patternB16;
            bar:=@barB16;
            bar_solid:=@barB16;
            bar_pattern:=@bar_patternB16;
            barXOR:=@barXORB16;
            barXOR_solid:=@barXORB16;
            barXOR_pattern:=@barXOR_patternB16;
            moverect:=@moverectB16;
            captureimage:=@captureimageB16;
            getimage:=@getimageB16;
            putimage:=@putimageB16;
            putimageC:=@putimageCB16;
            putimagepart:=@putimagepartB16;
            putimagepartC:=@putimagepartCB16;
            putbitmap:=@putbitmapB16;
            zoomimage:=@zoomimageB16;
            zoomimageC:=@zoomimageCB16;
{$ENDIF}
          END;
      END;
{=== 24bit ================================================================}
    ig_col24:
      BEGIN
        IF lfb THEN
          BEGIN
            putpixel:=@putpixelL24;
            getpixel:=@getpixelL24;
            line:=@lineL24;
            lineXOR:=@lineXORL24;
            linepattern:=@linepatternL24;
            linepatternXOR:=@linepatternXORL24;
            lineH:=@lineHL24;
            lineH_solid:=@lineHL24;
            lineH_pattern:=@lineH_patternL24;
            lineV:=@lineVL24;
            lineV_solid:=@lineVL24;
            lineV_pattern:=@lineV_patternL24;
            bar:=@barL24;
            bar_solid:=@barL24;
            bar_pattern:=@bar_patternL24;
            barXOR:=@barXORL24;
            barXOR_solid:=@barXORL24;
            barXOR_pattern:=@barXOR_patternL24;
            moverect:=@moverectL24;
            captureimage:=@captureimageL24;
            getimage:=@getimageL24;
            putimage:=@putimageL24;
            putimageC:=@putimageCL24;
            putimagepart:=@putimagepartL24;
            putimagepartC:=@putimagepartCL24;
            putbitmap:=@putbitmapL24;
            zoomimage:=@zoomimageL24;
            zoomimageC:=@zoomimageCL24;
            IF mmx THEN
              BEGIN
                lineH:=@lineHLM24;
                bar:=@barLM24;
                moverect:=@moverectLM24;
                getimage:=@getimageLM24;
                putimage:=@putimageLM24;
              END;
          END
        ELSE
          BEGIN
{$IFDEF GO32V2LINUX}
            putpixel:=@putpixelB24;
            getpixel:=@getpixelB24;
            line:=@lineB24;
            lineXOR:=@lineXORB24;
            linepattern:=@linepatternB24;
            linepatternXOR:=@linepatternXORB24;
            lineH:=@lineHB24;
            lineH_solid:=@lineHB24;
            lineH_pattern:=@lineH_patternB24;
            lineV:=@lineVB24;
            lineV_solid:=@lineVB24;
            lineV_pattern:=@lineV_patternB24;
            bar:=@barB24;
            bar_solid:=@barB24;
            bar_pattern:=@bar_patternB24;
            barXOR:=@barXORB24;
            barXOR_solid:=@barXORB24;
            barXOR_pattern:=@barXOR_patternB24;
            moverect:=@moverectB24;
            captureimage:=@captureimageB24;
            getimage:=@getimageB24;
            putimage:=@putimageB24;
            putimageC:=@putimageCB24;
            putimagepart:=@putimagepartB24;
            putimagepartC:=@putimagepartCB24;
            putbitmap:=@putbitmapB24;
            zoomimage:=@zoomimageB24;
            zoomimageC:=@zoomimageCB24;
{$ENDIF}
          END;
      END;
{=== 32bit ================================================================}
    ig_col32:
      BEGIN
        IF lfb THEN
          BEGIN
            putpixel:=@putpixelL32;
            getpixel:=@getpixelL32;
            line:=@lineL32;
            lineXOR:=@lineXORL32;
            linepattern:=@linepatternL32;
            linepatternXOR:=@linepatternXORL32;
            lineH:=@lineHL32;
            lineH_solid:=@lineHL32;
            lineH_pattern:=@lineH_patternL32;
            lineV:=@lineVL32;
            lineV_solid:=@lineVL32;
            lineV_pattern:=@lineV_patternL32;
            bar:=@barL32;
            bar_solid:=@barL32;
            bar_pattern:=@bar_patternL32;
         {   barrop_solid:=@barropL32; }
            barXOR:=@barXORL32;
            barXOR_solid:=@barXORL32;
            barXOR_pattern:=@barXOR_patternL32;
            moverect:=@moverectL32;
            captureimage:=@captureimageL32;
            getimage:=@getimageL32;
            putimage:=@putimageL32;
            putimageC:=@putimageCL32;
            putimagepart:=@putimagepartL32;
            putimagepartC:=@putimagepartCL32;
            putbitmap:=@putbitmapL32;
            zoomimage:=@zoomimageL32;
            zoomimageC:=@zoomimageCL32;
            IF mmx THEN
              BEGIN
                lineH:=@lineHLM32;
                bar:=@barLM32;
                moverect:=@moverectLM32;
                getimage:=@getimageLM32;
                putimage:=@putimageLM32;
              END;
          END
        ELSE
          BEGIN
{$IFDEF GO32V2LINUX}
            putpixel:=@putpixelB32;
            getpixel:=@getpixelB32;
            line:=@lineB32;
            lineXOR:=@lineXORB32;
            linepattern:=@linepatternB32;
            linepatternXOR:=@linepatternXORB32;
            lineH:=@lineHB32;
            lineH_solid:=@lineHB32;
            lineH_pattern:=@lineH_patternB32;
            lineV:=@lineVB32;
            lineV_solid:=@lineVB32;
            lineV_pattern:=@lineV_patternB32;
            bar:=@barB32;
            bar_solid:=@barB32;
            bar_pattern:=@bar_patternB32;
            barXOR:=@barXORB32;
            barXOR_solid:=@barXORB32;
            barXOR_pattern:=@barXOR_patternB32;
            moverect:=@moverectB32;
            captureimage:=@captureimageB32;
            getimage:=@getimageB32;
            putimage:=@putimageB32;
            putimageC:=@putimageCB32;
            putimagepart:=@putimagepartB32;
            putimagepartC:=@putimagepartCB32;
            putbitmap:=@putbitmapB32;
            zoomimage:=@zoomimageB32;
            zoomimageC:=@zoomimageCB32;
{$ENDIF}
          END;
      END;
  END;
END;

{======================== Surface Management ==============================}

PROCEDURE SetDrawOffset(offset:dword);
BEGIN
  drawoffset:=offset;
  frontdrawoffset:=drawoffset;
  frontdrawoffsetpix:=drawoffset DIV bytperpix;
  frontdrawoffsety:=drawoffset DIV bytperline;
END;

CONST PrimarySurface:PSurface=nil;
      ActiveSurface:PSurface=nil;
      VisibleSurface:PSurface=nil;
      BackSurface:PSurface=nil;

PROCEDURE CreatePrimarySurface;
VAR ok:boolean;
    sf:PSurface;
BEGIN
  new(sf);
  sf^.width:=getmaxX+1;
  sf^.height:=getmaxY+1;
  sf^.bpl:=bytperline;
  sf^.flags:=gxsf_videomem;
  sf^.size:=sf^.height*sf^.bpl;
{$IFDEF GO32V2LINUX}
  WITH sf^ DO ok:=CreateSpecSurface(width,height,bpl,flags,base,ss);
{$ENDIF}
{$IFDEF WIN32}
  DDGetPrimarySurface(sf^.ss.DDS);
{$ENDIF}
  sf^.vx1:=0;
  sf^.vy1:=0;
  sf^.vx2:=maxX;
  sf^.vy2:=maxY;
  sf^.flags:=sf^.flags OR gxsf_primary;
  PrimarySurface:=sf;
END;

FUNCTION CreateSurface(var sf:PSurface;flags:dword):dword;
VAR ok:boolean;
BEGIN
  CreateSurface:=gx_ok;
  ok:=FALSE;
  IF (flags AND gxsf_primary=gxsf_primary) THEN
    BEGIN
      sf:=PrimarySurface;
      exit;
    END;
  new(sf);
  sf^.width:=getmaxX+1;
  sf^.height:=getmaxY+1;
  sf^.bpl:=bytperline;
  sf^.flags:=flags;
  sf^.size:=sf^.height*sf^.bpl;
  WITH sf^ DO ok:=CreateSpecSurface(width,height,bpl,flags,base,ss);
  IF NOT ok THEN WITH sf^ DO
    BEGIN
      ok:=CreateSpecSurface(width,height,bpl,gxsf_sysmem,base,ss);
      flags:=gxsf_sysmem;
    END;
  IF ok THEN
    BEGIN
      sf^.vx1:=0;
      sf^.vy1:=0;
      sf^.vx2:=maxX;
      sf^.vy2:=maxY;
    END
  ELSE
    BEGIN
      CreateSurface:=gx_error;
    END;
END;

FUNCTION DestroySurface(var sf:PSurface):dword;
BEGIN
  DestroySurface:=gx_ok;
  IF (sf^.flags AND gxsf_primary=gxsf_primary) THEN exit;
  DestroySpecSurface(sf^.ss);
  dispose(sf);
  sf:=nil;
END;

FUNCTION SetActiveSurface(sf:PSurface;changeclip:boolean):dword;
BEGIN
  SetActiveSurface:=gx_error;
  IF (sf<>nil) THEN
    BEGIN
      SetActiveSurface:=gx_ok;
      IF (ActiveSurface<>nil) THEN
        BEGIN
          ActiveSurface^.vx1:=vx1;
          ActiveSurface^.vy1:=vy1;
          ActiveSurface^.vx2:=vx2;
          ActiveSurface^.vy2:=vy2;
        END;
      ActiveSurface:=sf;
      IF changeclip THEN
        BEGIN
          vx1:=ActiveSurface^.vx1;
          vy1:=ActiveSurface^.vy1;
          vx2:=ActiveSurface^.vx2;
          vy2:=ActiveSurface^.vy2;
        END;
      CASE (ActiveSurface^.flags AND mgxsf_memloction) OF
        gxsf_videomem,gxsf_offscreenmem:
          BEGIN
{$IFDEF GO32V2LINUX}
            lfboffs:=lfbbase;
            SetDrawOffset(dword(ActiveSurface^.base));
{$ENDIF}
{$IFDEF WIN32}
            ActiveSurface^.base:=DDGetSurfacePointer(ActiveSurface^.ss);
            lfbbase:=dword(ActiveSurface^.base);
            lfboffs:=dword(ActiveSurface^.base);
            SetDrawOffset(0);
{$ENDIF}
            SetProcs(gxcurcol,LFBenabled,MMXavail,HWAenabled);
            IF HWAenabled THEN CurGraphiX.sethwaprocs(gxcurcol);
            IF HWAclip THEN graphwinhw(vx1,vy1,vx2,vy2);
            ExecuteGXUnitInit;
            MFBused:=FALSE;
          END;
        gxsf_sysmem:
          BEGIN
            lfboffs:=dword(ActiveSurface^.base);
            SetDrawOffset(0);
            SetProcs(gxcurcol,TRUE,MMXavail,FALSE);
            ExecuteGXUnitInit;
            MFBused:=TRUE;
          END;
      END;
    END;
END;

FUNCTION SetVisibleSurface(sf:PSurface):dword;
BEGIN
  SetVisibleSurface:=gx_error;
  IF (sf<>nil) THEN
    IF (sf^.flags AND mgxsf_memloction=gxsf_videomem) THEN
      BEGIN
        VisibleSurface:=sf;
{$IFDEF GO32V2LINUX}
        CurGraphiX.displaystart(dword(VisibleSurface^.base));
{$ENDIF}
        SetVisibleSurface:=gx_ok;
      END;
END;

FUNCTION EnableSurfaceFlipping(var sf:PSurface;flags:dword):dword;
BEGIN
  IF (flags<>0) THEN CreateSurface(BackSurface,flags) ELSE BackSurface:=sf;
  EnableSurfaceFlipping:=SetActiveSurface(BackSurface,TRUE);
  SetVisibleSurface(PrimarySurface);
  sf:=BackSurface;
{$IFDEF WIN32}
  DDEnableSurfaceFlipping(BackSurface^.ss);
{$ENDIF}
END;

FUNCTION DisableSurfaceFlipping(sf:PSurface):dword;
BEGIN
  DisableSurfaceFlipping:=gx_error;
  IF (sf<>nil) AND (sf<>BackSurface) THEN exit;
{$IFDEF WIN32}
  DDDisableSurfaceFlipping(BackSurface^.ss);
{$ENDIF}
  IF (sf<>nil) THEN DestroySurface(BackSurface);
  SetVisibleSurface(PrimarySurface);
  DisableSurfaceFlipping:=SetActiveSurface(PrimarySurface,TRUE);
  BackSurface:=nil;
END;

FUNCTION CopySurface(dsf,ssf:PSurface):dword;
BEGIN
  CopySurface:=gx_error;
  IF (dsf<>nil) AND (ssf<>nil) THEN
    BEGIN
      CopySurface:=gx_ok;
      IF (ssf=dsf) THEN exit;
      CASE (dsf^.flags AND mgxsf_memloction) OF
        gxsf_videomem,gxsf_offscreenmem:
          CASE (ssf^.flags AND mgxsf_memloction) OF
            gxsf_videomem,gxsf_offscreenmem:
              copy_vram2vram(dword(ssf^.base),dword(dsf^.base),ssf^.size);
            gxsf_sysmem:
              copy_sram2vram(dword(ssf^.base),dword(dsf^.base),ssf^.size);
          END;
        gxsf_sysmem:
          CASE (ssf^.flags AND mgxsf_memloction) OF
            gxsf_videomem,gxsf_offscreenmem:
              copy_vram2sram(dword(ssf^.base),dword(dsf^.base),ssf^.size);
            gxsf_sysmem:
              copy_sram2sram(dword(ssf^.base),dword(dsf^.base),ssf^.size);
          END;
      END;
   END;
END;

FUNCTION FlipSurface(waitforverticalretrace:boolean):dword;
VAR ts:PSurface;
BEGIN
  FlipSurface:=gx_error;
  IF (BackSurface<>nil) THEN
    BEGIN
      FlipSurface:=gx_ok;
      CASE (BackSurface^.flags AND mgxsf_memloction) OF
        gxsf_videomem:
          BEGIN
{$IFDEF GO32V2LINUX}
            ts:=ActiveSurface;
            SetActiveSurface(VisibleSurface,FALSE);
            IF waitforverticalretrace THEN waitforretracestart;
            SetVisibleSurface(ts);
            IF waitforverticalretrace THEN waitforretraceend;
            SetDrawOffset(dword(ActiveSurface^.base));
            IF HWAclip THEN graphwinhw(vx1,vy1,vx2,vy2);
{$ENDIF}
{$IFDEF WIN32}
            DDFlipSurface(waitforverticalretrace);
            lfbbase:=dword(DDGetSurfacePointer(ActiveSurface^.ss));
            lfboffs:=lfbbase;
            SetDrawOffset(0);
{$ENDIF}
          END;
        gxsf_offscreenmem,gxsf_sysmem:
          BEGIN
            IF waitforverticalretrace THEN waitforretrace;
            CopySurface(PrimarySurface,BackSurface);
          END;
      END;
   END;
END;

{======================== Page/Backbuffer Management ======================}

PROCEDURE SetCopyProcs;
BEGIN
  IF LFBenabled THEN
    BEGIN
      IF MMXavail THEN
        BEGIN
          copy_sram2sram:=@copy_sram2sramM;
          copy_vram2sram:=@copy_vram2sramM;
          copy_sram2vram:=@copy_sram2vramM;
          copy_vram2vram:=@copy_vram2vramM;
        END
      ELSE
        BEGIN
          copy_sram2sram:=@copy_sram2sramL;
          copy_vram2sram:=@copy_vram2sramL;
          copy_sram2vram:=@copy_sram2vramL;
          copy_vram2vram:=@copy_vram2vramL;
        END;
    END
  ELSE
    BEGIN
{$IFDEF GO32V2LINUX}
      copy_sram2sram:=@copy_sram2sramB;
      copy_vram2sram:=@copy_vram2sramB;
      copy_sram2vram:=@copy_sram2vramB;
      copy_vram2vram:=@copy_vram2vramB;
{$ENDIF}
    END;
END;

{=============================== nops =======================================}

PROCEDURE sethwaprocs_nop(col:longint);
BEGIN
END;

PROCEDURE enableregs_nop;
BEGIN
END;

PROCEDURE disableregs_nop;
BEGIN
END;

PROCEDURE setcolormode_nop(col:longint);assembler;
ASM
END;

PROCEDURE bankswitch_nop;
BEGIN
END;

PROCEDURE enableLFB_nop(physaddr:dword);
BEGIN
END;

PROCEDURE disableLFB_nop;
BEGIN
END;

PROCEDURE enableMMIO_nop(physaddr:dword);
BEGIN
END;

PROCEDURE disableMMIO_nop;
BEGIN
END;

{============================== include =====================================}

{$IFDEF GO32V2}
{$I gxgo32v2.ppi}
{$ENDIF}

{$IFDEF WIN32}
{$I gxwin32.ppi}
{$ENDIF}

{$IFDEF LINUX}
{$I gxlinux.ppi}
{$ENDIF}

{============================== pattern ====================================}

PROCEDURE setfillstyle(fillstyle:dword);
BEGIN
  CASE (fillstyle AND fs_style_mask) OF
    fs_solid:
      BEGIN
        lineH:=lineH_solid;
        lineV:=lineV_solid;
        bar:=bar_solid;
        barXOR:=barXOR_solid
      END;
    fs_pattern:
      BEGIN
        lineH:=lineH_pattern;
        lineV:=lineV_pattern;
        bar:=bar_pattern;
        barXOR:=barXOR_pattern;
      END;
 {   fs_solid+fs_rop:
      BEGIN
        CASE bytperpix OF
        1:FOR i:=0 TO 3 DO currop[i]:=((fillstyle SHR (11-i)) AND 1) SHL 7;
        2:FOR i:=0 TO 3 DO currop[i]:=((fillstyle SHR (11-i)) AND 1) SHL 15;
        3:FOR i:=0 TO 3 DO currop[i]:=((fillstyle SHR (11-i)) AND 1) SHL 23;
        4:FOR i:=0 TO 3 DO currop[i]:=((fillstyle SHR (11-i)) AND 1) SHL 23;
        END;
        bar:=barrop_solid;
      END;  }
  END;
END;

PROCEDURE setfillpattern(fillstyle:dword;pattern:ppattern);
BEGIN
  CASE (fillstyle AND fs_style_mask) OF
    fs_solid:
      BEGIN
        lineH:=lineH_solid;
        lineV:=lineV_solid;
        bar:=bar_solid;
        barXOR:=barXOR_solid
      END;
    fs_pattern:
      BEGIN
        move(pattern^,curpattern^,8);
{$IF GO32V2}
        IF HWAenabled THEN setpatternHW(curpattern);
{$ENDIF}
        lineH:=lineH_pattern;
        lineV:=lineV_pattern;
        bar:=bar_pattern;
        barXOR:=barXOR_pattern;
      END;
{    fs_solid+fs_rop:
      BEGIN
        FOR i:=0 TO 3 DO currop[i]:=(fillstyle SHL (20+i)) AND $80000000;
        bar:=barrop_solid;
      END; }
  END;
END;

FUNCTION createpattern(pc:char;b0,b1,b2,b3,b4,b5,b6,b7:tpatternline):PPattern;
VAR h:PPattern;

  FUNCTION createbyte(bs:tpatternline):byte;
  VAR i,b:byte;
  BEGIN
    b:=0;
    FOR i:=0 TO 7 DO
      BEGIN
        b:=b SHR 1;
        IF (bs[i]=pc) THEN b:=b OR $80;
      END;
    createbyte:=b;
  END;

BEGIN
  new(h);
  h^[0]:=createbyte(b0);
  h^[1]:=createbyte(b1);
  h^[2]:=createbyte(b2);
  h^[3]:=createbyte(b3);
  h^[4]:=createbyte(b4);
  h^[5]:=createbyte(b5);
  h^[6]:=createbyte(b6);
  h^[7]:=createbyte(b7);
  createpattern:=h;
END;

PROCEDURE destroypattern(p:PPattern);
BEGIN
  dispose(p);
END;

{============================== misc =======================================}

PROCEDURE moveto(x,y:longint);
BEGIN
  curx:=x;
  cury:=y;
END;

PROCEDURE lineto(x,y,f:longint);
BEGIN
  line(curX,curY,x,y,f);
  curx:=x;
  cury:=y;
END;

FUNCTION getmaxX:longint;
BEGIN
  getmaxX:=maxX;
END;

FUNCTION getmaxY:longint;
BEGIN
  getmaxY:=maxY;
END;

{============================== rectangle =================================}

PROCEDURE rectangle(x1,y1,x2,y2,f:longint);
BEGIN
  linev(x1,y1,y2,f);
  linev(x2,y1,y2,f);
  lineh(x1,x2,y1,f);
  lineh(x1,x2,y2,f);
END;

PROCEDURE clearscreen(color:dword);
BEGIN
  bar_solid(0,0,maxX,maxY,color);
END;

{========================== image management =============================}

FUNCTION createimageWH(width,height:longint):pimage;
VAR mxd,size:dword;
    img:pimage;
BEGIN
  mxd:=(dword(width)*bytperpix+7) AND $FFFFFFF8;
  size:=mxd*dword(height);
  new(img);
  IF (img<>nil) THEN
    BEGIN
      fillchar(img^,sizeof(timage),0);
      img^.width:=width;
      img^.height:=height;
      img^.bytesperline:=mxd;
      img^.bytesperpixel:=bytperpix;
      img^.size:=size;
      getmem(img^.pixeldata,size);
      img^.flags:=0; { flags }
      img^.transparencycolor:=0; { transparency color }
      img^.vx1:=0;
      img^.vy1:=0;
      img^.vx2:=width-1;
      img^.vy2:=height-1;
    END
  ELSE
    BEGIN
      gxerrno:=err_outofmem;
      graphixerror(gxerrno,'getmem/createimagewh');
    END;
  createimageWH:=img;
END;

FUNCTION createimage(x1,y1,x2,y2:longint):pimage;
BEGIN
  createimage:=createimageWH(abs(x2-x1)+1,abs(y2-y1)+1);
END;

FUNCTION copyimage(dst,src:pimage):pimage;
BEGIN
  copyimage:=nil;
  IF (dst^.size=src^.size) THEN
    BEGIN
      dst^.width:=src^.width;
      dst^.height:=src^.height;
      dst^.bytesperline:=src^.bytesperline;
      dst^.bytesperpixel:=src^.bytesperpixel;
      dst^.size:=src^.size;
      move(src^.pixeldata^,dst^.pixeldata^,src^.size);
      dst^.flags:=src^.flags;
      dst^.transparencycolor:=src^.transparencycolor;
      copyimage:=dst;
    END;
END;

FUNCTION cloneimage(img:pimage):pimage;
VAR nimg:pimage;
BEGIN
  new(nimg);
  IF (nimg<>nil) THEN
    BEGIN
      nimg^:=img^;
      getmem(nimg^.pixeldata,img^.size);
      move(img^.pixeldata^,nimg^.pixeldata^,nimg^.size);
    END
  ELSE
    BEGIN
      gxerrno:=err_outofmem;
      graphixerror(gxerrno,'getmem/cloneimage');
    END;
  cloneimage:=nimg;
END;

FUNCTION getimagewidth(img:pimage):longint;
BEGIN
  getimagewidth:=img^.width;
END;

FUNCTION getimageheight(img:pimage):longint;
BEGIN
  getimageheight:=img^.height;
END;

PROCEDURE setimageflags(img:pimage;flags:dword);
BEGIN
  img^.flags:=img^.flags OR flags;
END;

PROCEDURE clearimageflags(img:pimage;flags:dword);
BEGIN
  img^.flags:=img^.flags AND NOT flags;
END;

FUNCTION getimageflags(img:pimage;flags:dword):longint;
BEGIN
  getimageflags:=img^.flags AND flags;
END;

PROCEDURE setimagetransparencycolor(img:pimage;color:longint);
BEGIN
  img^.transparencycolor:=color;
END;

FUNCTION getimagetransparencycolor(img:pimage):longint;
BEGIN
  getimagetransparencycolor:=img^.transparencycolor;
END;

PROCEDURE destroyimage(var img:pimage);
BEGIN
  IF (img<>nil) THEN
    BEGIN
      freemem(img^.pixeldata,img^.size);
      dispose(img);
    END;
  img:=nil;
END;

{=========================================================================}

BEGIN
{  OldExitProc:=ExitProc;
  ExitProc:=@DoneGraphiX; }
  GraphiXActive:=FALSE;
  LFBenabled:=FALSE;
  HWAenabled:=FALSE;
  HWAclip:=FALSE;
  MMIOenabled:=FALSE;
  CurGraphiX.detected:=FALSE;
{$IFDEF GO32V2}
  adjustaddresses:=@adjustalladdresses;
{$ENDIF}
END.

