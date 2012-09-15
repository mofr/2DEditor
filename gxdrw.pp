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
UNIT gxdrw;

INTERFACE

USES gxtype,gxbase,graphix;
{$I gxlocal.cfg}

PROCEDURE imagesetoutput(img:pimage);
PROCEDURE imagegraphwin(image:pimage;x1,y1,x2,y2:longint);
PROCEDURE imagesubgraphwin(image:pimage;x1,y1,x2,y2:longint);
PROCEDURE imagegetgraphwin(image:pimage;var x1,y1,x2,y2:longint);
PROCEDURE imagemaxgraphwin(image:pimage);
PROCEDURE imageputpixel(image:pimage;x,y,f:longint);
FUNCTION imagegetpixel(image:pimage;x,y:longint):longint;
PROCEDURE imageline(image:pimage;x1,y1,x2,y2,f:longint);
PROCEDURE imagelineXOR(image:pimage;x1,y1,x2,y2,f:longint);
PROCEDURE imagelineH(image:pimage;x1,x2,y,f:longint);
PROCEDURE imagelineV(image:pimage;x,y1,y2,f:longint);
PROCEDURE imagerectangle(image:pimage;x1,y1,x2,y2,f:longint);
PROCEDURE imagebar(image:pimage;x1,y1,x2,y2,f:longint);
PROCEDURE imagebarXOR(image:pimage;x1,y1,x2,y2,f:longint);
PROCEDURE imagemoverect(image:pimage;x1,y1,x2,y2,x,y:longint);
FUNCTION imagecaptureimage(image:pimage;x1,y1,x2,y2:longint;img:pimage):pimage;
FUNCTION imagegetimage(image:pimage;x,y:longint;img:pimage):pimage;
PROCEDURE imageputimage(image:pimage;x,y:longint;img:pimage);
PROCEDURE imageputimageC(image:pimage;x,y:longint;img:pimage);
PROCEDURE imageputimagepart(image:pimage;x,y,xi1,yi1,xi2,yi2:longint;img:pimage);
PROCEDURE imageputimagepartC(image:pimage;x,y,xi1,yi1,xi2,yi2:longint;img:pimage);
PROCEDURE imagezoomimage(image:pimage;x1,y1,x2,y2:longint;img:pimage);
PROCEDURE imagezoomimageC(image:pimage;x1,y1,x2,y2:longint;img:pimage);
PROCEDURE imageputbitmap(image:pimage;x,y,w,h,bpl,col:longint;var bitmap);
PROCEDURE imagelinepattern(image:pimage;x1,y1,x2,y2,f,pat,bits:longint);
PROCEDURE imagelinepatternXOR(image:pimage;x1,y1,x2,y2,f,pat,bits:longint);

VAR iputpixel:putpixelproc;
    igetpixel:getpixelproc;
    iline,ilineXOR:lineproc;
    ilineH:lineHproc;
    ilineV:lineVproc;
    ibar:barproc;
    ibarXOR:barproc;
    imoverect:moverectproc;
    icaptureimage:captureimageproc;
    igetimage:getimageproc;
    iputimage:putimageproc;
    iputimageC:putimageproc;
    iputimagepart:putimagepartproc;
    iputimagepartC:putimagepartproc;
    izoomimage:zoomimageproc;
    izoomimageC:zoomimageproc;
    iputbitmap:putbitmapproc;
    ilinepattern,ilinepatternXOR:linepatternproc;


IMPLEMENTATION

USES gxsup;

VAR ilineH_solid,ilineH_pattern:lineHproc;
    ilineV_solid,ilineV_pattern:lineVproc;
    ibar_solid,ibar_pattern:barproc;
    ibarXOR_solid,ibarXOR_pattern:barproc;

VAR vx1,vy1,vx2,vy2:longint;
    bytperline:longint;
    lfboffs,drawoffset:longint;

{============================= set image ==================================}

PROCEDURE imagesetoutput(img:pimage);
BEGIN
  lfboffs:=longint(img^.pixeldata);
  drawoffset:=0;
  vx1:=img^.vx1;
  vy1:=img^.vy1;
  vx2:=img^.vx2;
  vy2:=img^.vy2;
  bytperline:=img^.bytesperline;
END;

{============================= drawing window =============================}

PROCEDURE imagegraphwin(image:pimage;x1,y1,x2,y2:longint);
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
  IF (x2>image^.width-1) THEN x2:=image^.width-1;
  IF (y1<0) THEN y1:=0;
  IF (y2>image^.height-1) THEN y2:=image^.height-1;
  image^.vx1:=x1;
  image^.vy1:=y1;
  image^.vx2:=x2;
  image^.vy2:=y2;
END;

PROCEDURE imagesubgraphwin(image:pimage;x1,y1,x2,y2:longint);
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
  IF (x1>image^.vx1) THEN image^.vx1:=x1;
  IF (x2<image^.vx2) THEN image^.vx2:=x2;
  IF (y1>image^.vy1) THEN image^.vy1:=y1;
  IF (y2<image^.vy2) THEN image^.vy2:=y2;
END;

PROCEDURE imagegetgraphwin(image:pimage;var x1,y1,x2,y2:longint);
BEGIN
  x1:=image^.vx1;
  y1:=image^.vy1;
  x2:=image^.vx2;
  y2:=image^.vy2;
END;

PROCEDURE imagemaxgraphwin(image:pimage);
BEGIN
  image^.vx1:=0;
  image^.vy1:=0;
  image^.vx2:=image^.width-1;
  image^.vy2:=image^.height-1;
END;

{============================= drawing ====================================}

{$I GRAPHIXL.PPI}
{$I GRAPHIXM.PPI}

PROCEDURE SetProcs(col:longint);
BEGIN
  CASE col OF
    ig_col8:
      BEGIN
        iputpixel:=@putpixelL8;
        igetpixel:=@getpixelL8;
        iline:=@lineL8;
        ilineXOR:=@lineXORL8;
        ilinepattern:=@linepatternL8;
        ilinepatternXOR:=@linepatternXORL8;
        ilineH:=@lineHL8;
        ilineH_solid:=@lineHL8;
        ilineH_pattern:=@lineH_patternL8;
        ilineV:=@lineVL8;
        ilineV_solid:=@lineVL8;
        ilineV_pattern:=@lineV_patternL8;
        ibar:=@barL8;
        ibar_solid:=@barL8;
        ibar_pattern:=@bar_patternL8;
        ibarXOR:=@barXORL8;
        ibarXOR_solid:=@barXORL8;
        ibarXOR_pattern:=@barXOR_patternL8;
        imoverect:=@moverectL8;
        icaptureimage:=@captureimageL8;
        igetimage:=@getimageL8;
        iputimage:=@putimageL8;
        iputimageC:=@putimageCL8;
        iputimagepart:=@putimagepartL8;
        iputimagepartC:=@putimagepartCL8;
        izoomimage:=@zoomimageL8;
        izoomimageC:=@zoomimageCL8;
        iputbitmap:=@putbitmapL8;
        IF MMXavail THEN
          BEGIN
            ilineH:=@lineHLM8;
            ibar:=@barLM8;
            imoverect:=@moverectLM8;
            igetimage:=@getimageLM8;
            iputimage:=@putimageLM8;
          END;
      END;
    ig_col15:
      BEGIN
        iputpixel:=@putpixelL16;
        igetpixel:=@getpixelL16;
        iline:=@lineL16;
        ilineXOR:=@lineXORL16;
        ilinepattern:=@linepatternL16;
        ilinepatternXOR:=@linepatternXORL16;
        ilineH:=@lineHL16;
        ilineH_solid:=@lineHL16;
        ilineH_pattern:=@lineH_patternL16;
        ilineV:=@lineVL16;
        ilineV_solid:=@lineVL16;
        ilineV_pattern:=@lineV_patternL16;
        ibar:=@barL16;
        ibar_solid:=@barL16;
        ibar_pattern:=@bar_patternL16;
        ibarXOR:=@barXORL16;
        ibarXOR_solid:=@barXORL16;
        ibarXOR_pattern:=@barXOR_patternL16;
        imoverect:=@moverectL16;
        icaptureimage:=@captureimageL16;
        igetimage:=@getimageL16;
        iputimage:=@putimageL16;
        iputimageC:=@putimageCL16;
        iputimagepart:=@putimagepartL16;
        iputimagepartC:=@putimagepartCL16;
        izoomimage:=@zoomimageL16;
        izoomimageC:=@zoomimageCL16;
        iputbitmap:=@putbitmapL16;
        IF MMXavail THEN
          BEGIN
            ilineH:=@lineHLM16;
            ibar:=@barLM16;
            imoverect:=@moverectLM16;
            igetimage:=@getimageLM16;
            iputimage:=@putimageLM16;
          END;
       END;
    ig_col16:
      BEGIN
        iputpixel:=@putpixelL16;
        igetpixel:=@getpixelL16;
        iline:=@lineL16;
        ilineXOR:=@lineXORL16;
        ilinepattern:=@linepatternL16;
        ilinepatternXOR:=@linepatternXORL16;
        ilineH:=@lineHL16;
        ilineH_solid:=@lineHL16;
        ilineH_pattern:=@lineH_patternL16;
        ilineV:=@lineVL16;
        ilineV_solid:=@lineVL16;
        ilineV_pattern:=@lineV_patternL16;
        ibar:=@barL16;
        ibar_solid:=@barL16;
        ibar_pattern:=@bar_patternL16;
        ibarXOR:=@barXORL16;
        ibarXOR_solid:=@barXORL16;
        ibarXOR_pattern:=@barXOR_patternL16;
        imoverect:=@moverectL16;
        icaptureimage:=@captureimageL16;
        igetimage:=@getimageL16;
        iputimage:=@putimageL16;
        iputimageC:=@putimageCL16;
        iputimagepart:=@putimagepartL16;
        iputimagepartC:=@putimagepartCL16;
        izoomimage:=@zoomimageL16;
        izoomimageC:=@zoomimageCL16;
        iputbitmap:=@putbitmapL16;
        IF MMXavail THEN
          BEGIN
            ilineH:=@lineHLM16;
            ibar:=@barLM16;
            imoverect:=@moverectLM16;
            igetimage:=@getimageLM16;
            iputimage:=@putimageLM16;
          END;
      END;
    ig_col24:
      BEGIN
        iputpixel:=@putpixelL24;
        igetpixel:=@getpixelL24;
        iline:=@lineL24;
        ilineXOR:=@lineXORL24;
        ilinepattern:=@linepatternL24;
        ilinepatternXOR:=@linepatternXORL24;
        ilineH:=@lineHL24;
        ilineH_solid:=@lineHL24;
        ilineH_pattern:=@lineH_patternL24;
        ilineV:=@lineVL24;
        ilineV_solid:=@lineVL24;
        ilineV_pattern:=@lineV_patternL24;
        ibar:=@barL24;
        ibar_solid:=@barL24;
        ibar_pattern:=@bar_patternL24;
        ibarXOR:=@barXORL24;
        ibarXOR_solid:=@barXORL24;
        ibarXOR_pattern:=@barXOR_patternL24;
        imoverect:=@moverectL24;
        icaptureimage:=@captureimageL24;
        igetimage:=@getimageL24;
        iputimage:=@putimageL24;
        iputimageC:=@putimageCL24;
        iputimagepart:=@putimagepartL24;
        iputimagepartC:=@putimagepartCL24;
        izoomimage:=@zoomimageL24;
        izoomimageC:=@zoomimageCL24;
        iputbitmap:=@putbitmapL24;
        IF MMXavail THEN
          BEGIN
            ilineH:=@lineHLM24;
            ibar:=@barLM24;
            imoverect:=@moverectLM24;
            igetimage:=@getimageLM24;
            iputimage:=@putimageLM24;
          END;
      END;
    ig_col32:
      BEGIN
        iputpixel:=@putpixelL32;
        igetpixel:=@getpixelL32;
        iline:=@lineL32;
        ilineXOR:=@lineXORL32;
        ilinepattern:=@linepatternL32;
        ilinepatternXOR:=@linepatternXORL32;
        ilineH:=@lineHL32;
        ilineH_solid:=@lineHL32;
        ilineH_pattern:=@lineH_patternL32;
        ilineV:=@lineVL32;
        ilineV_solid:=@lineVL32;
        ilineV_pattern:=@lineV_patternL32;
        ibar:=@barL32;
        ibar_solid:=@barL32;
        ibar_pattern:=@bar_patternL32;
        ibarXOR:=@barXORL32;
        ibarXOR_solid:=@barXORL32;
        ibarXOR_pattern:=@barXOR_patternL32;
        imoverect:=@moverectL32;
        icaptureimage:=@captureimageL32;
        igetimage:=@getimageL32;
        iputimage:=@putimageL32;
        iputimageC:=@putimageCL32;
        iputimagepart:=@putimagepartL32;
        iputimagepartC:=@putimagepartCL32;
        izoomimage:=@zoomimageL32;
        izoomimageC:=@zoomimageCL32;
        iputbitmap:=@putbitmapL32;
        IF MMXavail THEN
          BEGIN
            ilineH:=@lineHLM32;
            ibar:=@barLM32;
            imoverect:=@moverectLM32;
            igetimage:=@getimageLM32;
            iputimage:=@putimageLM32;
          END;
      END;
  END;
END;

PROCEDURE imageputpixel(image:pimage;x,y,f:longint);
BEGIN
  imagesetoutput(image);
  iputpixel(x,y,f);
END;

FUNCTION imagegetpixel(image:pimage;x,y:longint):longint;
BEGIN
  imagesetoutput(image);
  imagegetpixel:=igetpixel(x,y);
END;

PROCEDURE imageline(image:pimage;x1,y1,x2,y2,f:longint);
BEGIN
  imagesetoutput(image);
  iline(x1,y1,x2,y2,f);
END;

PROCEDURE imagelineXOR(image:pimage;x1,y1,x2,y2,f:longint);
BEGIN
  imagesetoutput(image);
  ilineXOR(x1,y1,x2,y2,f);
END;

PROCEDURE imagelineH(image:pimage;x1,x2,y,f:longint);
BEGIN
  imagesetoutput(image);
  ilineH(x1,x2,y,f);
END;

PROCEDURE imagelineV(image:pimage;x,y1,y2,f:longint);
BEGIN
  imagesetoutput(image);
  ilineV(x,y1,y2,f);
END;

PROCEDURE imagerectangle(image:pimage;x1,y1,x2,y2,f:longint);
BEGIN
  imagesetoutput(image);
  ilinev(x1,y1,y2,f);
  ilinev(x2,y1,y2,f);
  ilineh(x1,x2,y1,f);
  ilineh(x1,x2,y2,f);
END;

PROCEDURE imagebar(image:pimage;x1,y1,x2,y2,f:longint);
BEGIN
  imagesetoutput(image);
  ibar(x1,y1,x2,y2,f);
END;

PROCEDURE imagebarXOR(image:pimage;x1,y1,x2,y2,f:longint);
BEGIN
  imagesetoutput(image);
  ibarXOR(x1,y1,x2,y2,f);
END;

PROCEDURE imagemoverect(image:pimage;x1,y1,x2,y2,x,y:longint);
BEGIN
  imagesetoutput(image);
  imoverect(x1,y1,x2,y2,x,y);
END;

FUNCTION imagecaptureimage(image:pimage;x1,y1,x2,y2:longint;img:pimage):pimage;
BEGIN
  imagesetoutput(image);
  imagecaptureimage:=icaptureimage(x1,y1,x2,y2,img);
END;

FUNCTION imagegetimage(image:pimage;x,y:longint;img:pimage):pimage;
BEGIN
  imagesetoutput(image);
  imagegetimage:=igetimage(x,y,img);
END;

PROCEDURE imageputimage(image:pimage;x,y:longint;img:pimage);
BEGIN
  imagesetoutput(image);
  iputimage(x,y,img);
END;

PROCEDURE imageputimageC(image:pimage;x,y:longint;img:pimage);
BEGIN
  imagesetoutput(image);
  iputimageC(x,y,img);
END;

PROCEDURE imageputimagepart(image:pimage;x,y,xi1,yi1,xi2,yi2:longint;img:pimage);
BEGIN
  imagesetoutput(image);
  iputimagepart(x,y,xi1,yi1,xi2,yi2,img);
END;

PROCEDURE imageputimagepartC(image:pimage;x,y,xi1,yi1,xi2,yi2:longint;img:pimage);
BEGIN
  imagesetoutput(image);
  iputimagepartC(x,y,xi1,yi1,xi2,yi2,img);
END;

PROCEDURE imagezoomimage(image:pimage;x1,y1,x2,y2:longint;img:pimage);
BEGIN
  imagesetoutput(image);
  izoomimage(x1,y1,x2,y2,img);
END;

PROCEDURE imagezoomimageC(image:pimage;x1,y1,x2,y2:longint;img:pimage);
BEGIN
  imagesetoutput(image);
  izoomimageC(x1,y1,x2,y2,img);
END;

PROCEDURE imageputbitmap(image:pimage;x,y,w,h,bpl,col:longint;var bitmap);
BEGIN
  imagesetoutput(image);
  iputbitmap(x,y,w,h,bpl,col,bitmap);
END;

PROCEDURE imagelinepattern(image:pimage;x1,y1,x2,y2,f,pat,bits:longint);
BEGIN
  imagesetoutput(image);
  ilinepattern(x1,y1,x2,y2,f,pat,bits);
END;

PROCEDURE imagelinepatternXOR(image:pimage;x1,y1,x2,y2,f,pat,bits:longint);
BEGIN
  imagesetoutput(image);
  ilinepatternXOR(x1,y1,x2,y2,f,pat,bits);
END;

PROCEDURE InitGXIMGDRW;
BEGIN
  SetProcs(gxcurcol);
END;

BEGIN
  RegisterGXUnit(@InitGXIMGDRW);
END.

