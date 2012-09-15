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
                                GXIMG
                  ------------------------------------
                                v2.20
                  ------------------------------------

VERSION HISTORY

Version 2.20
  + 'LoadImageJPG' iDCT speed-up: 3.5 times faster now

Version 2.10
  + 'LoadImageJPG'

Version 2.00
  = NEW UNIT: GXIMG
  + TStream for LoadImage
  + 'LoadImagePNG'
  + 'LoadImageTIF'

Version 1.30
  + 'LoadImageICO'
  + 'LoadImagePxM'

Version 1.20
  + 'CreateImageWH'
  + 'saveimageBMP'
  + 'saveimageTGA'

Version 1.10
  + 'CloneImage' creates an identical copy of an image
  + 'imageheight' retrives image width
  + 'imageheight' retrives image height
  = some bug-fixes

Version 1.00
  + Loader for BMP, GIF, PCX, TGA
  + Image-Management Functions: 'CreateImage', 'RemoveImage'

                       --------------------------
}

{$I gxglobal.cfg}
UNIT gximg;

INTERFACE

USES gxtype,graphix,objects{,dbgherc};
{$I gxlocal.cfg}

TYPE TImageType=(itunknown,itdetect,itBMP,itGIF,itCUR,itICO,itJPG,itPCX,itPNG,itPxM,itTGA,itTIF);
     TProgressMonitorProc=procedure(curline,maxline:longint);

FUNCTION WhatIsImageStream(stream:pstream):TImagetype;
FUNCTION WhatIsImageFile(filename:string):TImagetype;
FUNCTION LoadImageStream(imagetype:TImagetype;stream:pstream;var img:pimage;nr:longint):longint;
FUNCTION LoadImageFile(imagetype:TImagetype;filename:string;var img:pimage;nr:longint):longint;
FUNCTION SaveImageBMP(filename:string;img:pimage):boolean;
FUNCTION SaveImagePPM(filename:string;img:pimage):boolean;
FUNCTION SaveImageTGA(filename:string;img:pimage):boolean;

PROCEDURE SetProgressMonitor(pm:Tprogressmonitorproc);
PROCEDURE ClearProgressMonitor;

IMPLEMENTATION

USES gxcrtext,gxbase,gxerror;

VAR ProgressMonitor:Tprogressmonitorproc;

PROCEDURE ProgressMonitorDummy(curline,maxline:longint);
BEGIN
END;

PROCEDURE SetProgressMonitor(pm:Tprogressmonitorproc);
BEGIN
  ProgressMonitor:=pm;
END;

PROCEDURE ClearProgressMonitor;
BEGIN
  ProgressMonitor:=@ProgressMonitorDummy;
END;

{========================== LoadImageBMP ==================================}

FUNCTION LoadImageBMP(stream:pstream;var img:pimage;nr:longint):longint;
TYPE TBMPfileheader=RECORD
       bfType:word;
       bfSize:longint;
       bfReserved1:word;
       bfReserved2:word;
       bfOffBits:longint;
     END;

     TBMPinfoheader=RECORD
       biSize:longint;
       biWidth:longint;
       biHeight:longint;
       biPlanes:word;
       biBitCount:word;
       biCompression:longint;
       biSizeImage:longint;
       biXPelsPerMeter:longint;
       biYPelsPerMeter:longint;
       biClrUsed:longint;
       biClrImportant:longint;
     END;

     TBMPinfoheaderOS2ext=RECORD
       usUnits:word;
       usReserved:word;
       usRecording:word;
       usRendering:word;
       cSize1:dword;
       cSize2:dword;
       ulColorEncoding:dword;
       ulIdentifier:dword;
     END;

  CONST BI_RGB=0;
        BI_RLE8=1;
        BI_RLE4=2;
        BI_BITFIELDS=3;

  PROCEDURE decode_RLE4(buf:pointer;count:longint);
  VAR b1,b2:byte;
      tmp:longint;
      wpos:byte;

    PROCEDURE fill4bits(num,bits:byte);
    VAR i,rpos:byte;
    BEGIN
      rpos:=4;
      FOR i:=1 TO num DO
        BEGIN
          byte(buf^):=(byte(buf^) AND NOT($0F SHL wpos)) OR (((bits SHR rpos) AND $0F) SHL wpos);
          IF (wpos=0) THEN inc(buf);
          wpos:=(wpos-4) AND 7;
          rpos:=(rpos-4) AND 7;
        END;
    END;

    PROCEDURE copy4bits(num:byte);
    VAR i,rpos:byte;
        bits:byte;
    BEGIN
      rpos:=4;
      FOR i:=1 TO num DO
        BEGIN
          IF (rpos=4) THEN stream^.read(bits,1);
          byte(buf^):=(byte(buf^) AND NOT($0F SHL wpos)) OR (((bits SHR rpos) AND $0F) SHL wpos);
          IF (wpos=0) THEN inc(buf);
          wpos:=(wpos-4) AND 7;
          rpos:=(rpos-4) AND 7;
        END;
    END;

  BEGIN
    wpos:=4;
    REPEAT
      stream^.read(b1,1);
      stream^.read(b2,1);
      IF (b1=0) THEN
        BEGIN
          CASE b2 OF
          0:;
          1:;
          2:BEGIN
              stream^.read(tmp,2);
            END;
          ELSE
            BEGIN
              copy4bits(b2);
              stream^.read(tmp,((b2+1) SHR 1) AND 1);
              dec(count,b2);
            END;
          END;
        END
      ELSE
        BEGIN
          fill4bits(b1,b2);
          dec(count,b1);
        END;
    UNTIL ((b1=0) AND ((b2=0) OR (b2=1))) OR (count<0);
  END;

  PROCEDURE decode_RLE8(buf:pointer;count:longint);
  VAR b1,b2:byte;
      tmp:longint;
  BEGIN
    REPEAT
      stream^.read(b1,1);
      stream^.read(b2,1);
      IF (b1=0) THEN
        BEGIN
          CASE b2 OF
          0:;
          1:;
          2:BEGIN
              stream^.read(tmp,2);
            END;
          ELSE
            BEGIN
              stream^.read(buf^,b2);
              stream^.read(tmp,b2 AND 1);
              inc(buf,b2);
              dec(count,b2);
            END;
          END;
        END
      ELSE
        BEGIN
          fillchar(buf^,b1,b2);
          inc(buf,b1);
          dec(count,b1);
        END;
    UNTIL ((b1=0) AND ((b2=0) OR (b2=1))) OR (count<0);
  END;

VAR BMPfh:TBMPfileheader;
    BMPih:TBMPinfoheader;
    BMPbf:packed array[0..2] of dword;
    startpos:longint;
    palette:array[0..255] of longint;
    linebuf:pointer;
    linesize:longint;
    imgypos:pointer;
    color:longint;
    i,x,y,z:longint;
    xd,yd:longint;
    rgbformat:dword;
BEGIN
  LoadImageBMP:=-1;
  IF (nr<>1) THEN exit;
  startpos:=stream^.getpos;
  stream^.Read(BMPfh,sizeof(TBMPfileheader));
  stream^.Read(BMPih,sizeof(TBMPinfoheader));
  IF (BMPfh.bfType=$4D42) THEN
    BEGIN
      xd:=BMPih.biWidth;
      yd:=BMPih.BiHeight;

      IF (BMPih.biCompression=BI_BITFIELDS) THEN
        BEGIN
          stream^.Read(BMPbf,sizeof(BMPbf));
          IF (BMPbf[2]=$001F) AND (BMPbf[1]=$03E0) AND (BMPbf[0]=$7C00) THEN rgbformat:=$555;
          IF (BMPbf[2]=$001F) AND (BMPbf[1]=$07E0) AND (BMPbf[0]=$F800) THEN rgbformat:=$565;
{DBG(hexlong(rgbformat)); }
        END;

{DBG('b1');
DBG(xd);
DBG(yd);}
      img:=CreateImageWH(xd,yd);
{DBG('b1a');}
      imgypos:=img^.pixeldata+img^.bytesperline*yd;
      linesize:=((xd*BMPih.biBitCount+7) DIV 8+3) AND $FFFC;
      getmem(linebuf,linesize+4);
{DBG(BMPih.biBitCount);}
      IF (BMPih.biBitCount>0) AND (BMPih.biBitCount<=8) THEN
        BEGIN
          IF (BMPih.biClrUsed=0) THEN
            BEGIN
              FOR i:=0 TO (1 SHL BMPih.biBitCount)-1 DO
                BEGIN
                  stream^.read(color,4);
                  palette[i]:=rgbcolor(color);
                END;
            END
          ELSE
            BEGIN
              FOR i:=0 TO BMPih.biClrUsed-1 DO
                BEGIN
                  stream^.read(color,4);
                  palette[i]:=rgbcolor(color);
                END;
            END;
        END;

      stream^.seek(startpos+BMPfh.bfOffBits);
      FOR y:=0 TO yd-1 DO
        BEGIN
          ProgressMonitor(y,yd-1);
          dec(imgypos,img^.bytesperline);
          CASE BMPih.biCompression OF
            BI_RGB:stream^.read(linebuf^,linesize);
            BI_RLE8:decode_RLE8(linebuf,xd);
            BI_RLE4:decode_RLE4(linebuf,xd);
            BI_BITFIELDS:stream^.read(linebuf^,linesize);
          END;
          CASE BMPih.biBitCount OF
            1:ASM
                MOV EDX,bytperpix
                MOV ESI,linebuf
                MOV EDI,imgypos
                MOV ECX,xd
              @loop1:
                LODSB
                SHL EAX,24
                OR EAX,1
                MOV EBX,EAX
              @loop2:
                ROL EBX,1
                MOV EAX,EBX
                AND EAX,1
                MOV EAX,[palette+EAX*4]
                PUSH EDX
              @loop3:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop3
                POP EDX
                DEC ECX
                JZ @eol
                TEST EBX,00000100h
                JZ @loop2
                JMP @loop1
              @eol:
              END;
            4:ASM
                MOV EDX,bytperpix
                MOV ESI,linebuf
                MOV EDI,imgypos
                MOV ECX,xd
              @loop1:
                LODSB
                SHL EAX,24
                OR EAX,1
                MOV EBX,EAX
              @loop2:
                ROL EBX,4
                MOV EAX,EBX
                AND EAX,15
                MOV EAX,[palette+EAX*4]
                PUSH EDX
              @loop3:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop3
                POP EDX
                DEC ECX
                JZ @eol
                TEST EBX,00000100h
                JZ @loop2
                JMP @loop1
              @eol:
              END;
            8:ASM
                MOV EDX,bytperpix
                MOV ESI,linebuf
                MOV EDI,imgypos
                MOV ECX,xd
              @loop1:
                LODSB
                SHL EAX,2
                AND EAX,3FCh
                MOV EAX,[palette+EAX]
                PUSH EDX
             @loop3:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop3
                POP EDX
                DEC ECX
                JNZ @loop1
              END;
           16:CASE rgbformat OF
              $555:ASM
                     MOV ECX,xd
                     MOV ESI,linebuf
                     MOV EDI,imgypos
                   @loop2:
                     LODSW

                     SHL EAX,6
                     SHR AX,3
                     SHR AL,3
                     SHL EAX,3
                     AND EAX,00F8F8F8h

                     PUSH EAX
                     CALL rgbcolor
                     MOV EDX,bytperpix
                   @loop1:
                     STOSB
                     SHR EAX,8
                     DEC EDX
                     JNZ @loop1
                     LOOP @loop2
                   END;
              $565:ASM
                     MOV ECX,xd
                     MOV ESI,linebuf
                     MOV EDI,imgypos
                   @loop2:
                     LODSW

                     SHL EAX,5
                     SHR AX,2
                     SHR AL,2
                     SHR AX,1
                     SHL EAX,3
                     AND EAX,00F8FCF8h

                     PUSH EAX
                     CALL rgbcolor
                     MOV EDX,bytperpix
                   @loop1:
                     STOSB
                     SHR EAX,8
                     DEC EDX
                     JNZ @loop1
                     LOOP @loop2
                   END;
              END;
           24:ASM
                MOV ECX,xd
                MOV ESI,linebuf
                MOV EDI,imgypos
              @loop2:
                LODSD
                DEC ESI
                PUSH EAX
                CALL rgbcolor
                MOV EDX,bytperpix
              @loop1:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop1
                LOOP @loop2
              END;
           32:ASM
                MOV ECX,xd
                MOV ESI,linebuf
                MOV EDI,imgypos
              @loop2:
                LODSD
                PUSH EAX
                CALL rgbcolor
                MOV EDX,bytperpix
              @loop1:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop1
                LOOP @loop2
              END;
{ELSE
  BEGIN

    freemem(linebuf,linesize+4);
    LoadImageBMP:=1234;
    exit;
  END; }

          END;

{DBGns;
DBG(y);}
{IF keypressed THEN IF readkey='d' THEN putimage(0,0,img);}
        END;
      freemem(linebuf,linesize+4);
      LoadImageBMP:=0;
    END;
  stream^.seek(startpos);
END;

{========================== LoadImageGIF ==================================}

FUNCTION LoadImageGIF(stream:pstream;var img:pimage;nr:longint):longint;
TYPE ppal=^tpal;
     tpal=array[0..255] of longint;

CONST ilstart:array[1..4] of longint=(0,4,2,1);
      ilstep:array[1..4] of longint=(8,8,4,2);

  PROCEDURE DumpData;
  VAR count:byte;
  BEGIN
    REPEAT
      stream^.read(count,1);
{DBGns;
DBG('dump '+long2str(count)); }
      stream^.seek(stream^.getpos+count);
    UNTIL (count=0) OR (stream^.getpos>=stream^.getsize);
{DBG('');}
  END;

  PROCEDURE decodeGIFLZW(image:pimage;pal:ppal;interlaced:boolean);
  VAR xd,yd:longint;
  CONST tablen=4095;
  TYPE Pstr=^Tstr;
       Tstr=RECORD
         prefix:Pstr;
         suffix:longint;
       END;
       Pstrtab=^Tstrtab;
       Tstrtab=array[0..tablen] of Tstr;

  VAR strtab:Pstrtab;
      oldcode,curcode,clearcode,endcode:longint;
      codesize,codelen,codemask:longint;
      stridx:longint;
      bitbuf,bitsinbuf:longint;
      bytbuf:array[0..255] of byte;
      bytinbuf,bytbufidx:byte;
      endofsrc:boolean;
      xcnt,ycnt,pcnt,ystep,pass:longint;
      imageypos:pointer;

    PROCEDURE InitStringTable;
    VAR i:longint;
    BEGIN
      new(strtab);
      clearcode:=1 SHL codesize;
      endcode:=clearcode+1;
      stridx:=endcode+1;
      codelen:=codesize+1;
      codemask:=(1 SHL codelen)-1;
      FOR i:=0 TO clearcode-1 DO
        BEGIN
          strtab^[i].prefix:=nil;
          strtab^[i].suffix:=i;
        END;
      FOR i:=clearcode TO tablen DO
        BEGIN
          strtab^[i].prefix:=nil;
          strtab^[i].suffix:=0;
        END;
    END;

    PROCEDURE ClearStringTable;
    VAR i:longint;
    BEGIN
      clearcode:=1 SHL codesize;
      endcode:=clearcode+1;
      stridx:=endcode+1;
      codelen:=codesize+1;
      codemask:=(1 SHL codelen)-1;
      FOR i:=clearcode TO tablen DO
        BEGIN
          strtab^[i].prefix:=nil;
          strtab^[i].suffix:=0;
        END;
    END;

    PROCEDURE DoneStringTable;
    BEGIN
      dispose(strtab);
    END;

    FUNCTION GetNextCode:longint;
    BEGIN
      WHILE (bitsinbuf<codelen) DO
        BEGIN
          IF (bytinbuf=0) THEN
            BEGIN
              stream^.read(bytinbuf,1);
              IF (bytinbuf=0) THEN endofsrc:=TRUE;
              stream^.read(bytbuf,bytinbuf);
              bytbufidx:=0;
            END;
          bitbuf:=bitbuf OR (longint(byte(bytbuf[bytbufidx])) SHL bitsinbuf);
          inc(bytbufidx);
          dec(bytinbuf);
          inc(bitsinbuf,8);
        END;
      getnextcode:=bitbuf AND codemask;
{DBG(bitbuf AND codemask);}
      bitbuf:=bitbuf SHR codelen;
      dec(bitsinbuf,codelen);
    END;

    PROCEDURE AddStr2Tab(prefix:Pstr;suffix:longint);
    BEGIN
      strtab^[stridx].prefix:=prefix;
      strtab^[stridx].suffix:=suffix;
      inc(stridx);
      CASE stridx OF
      0..1:codelen:=1;
      2..3:codelen:=2;
      4..7:codelen:=3;
      8..15:codelen:=4;
      16..31:codelen:=5;
      32..63:codelen:=6;
      64..127:codelen:=7;
      128..255:codelen:=8;
      256..511:codelen:=9;
      512..1023:codelen:=10;
      1024..2047:codelen:=11;
      2048..4096:codelen:=12;
      END;
      codemask:=(1 SHL codelen)-1;
    END;

    FUNCTION Code2Str(code:longint):Pstr;
    BEGIN
      Code2Str:=addr(strtab^[code]);
    END;

    PROCEDURE WriteStr(s:Pstr);
    BEGIN
      IF (s^.prefix<>nil) THEN WriteStr(s^.prefix);
      IF (ycnt>=yd) THEN
        BEGIN
          IF interlaced THEN
            BEGIN
              WHILE (ycnt>=yd) AND (pass<5) DO
                BEGIN
                  inc(pass);
                  ycnt:=ilstart[pass];
                  ystep:=ilstep[pass];
                  imageypos:=img^.pixeldata+ycnt*image^.bytesperline;
                END;
{            END
          ELSE
            BEGIN
DBG('#########################');
              inc(pass); }
            END;
{          xcnt:=0; }
        END;
{       IF NOT finished THEN}
     {   BEGIN }
      move(pal^[s^.suffix],(imageypos+xcnt*bytperpix)^,bytperpix);
{putimage(0,0,image);}

{dbg(pal^[s^.suffix]);}
      inc(xcnt);
      IF (xcnt>=xd) THEN
        BEGIN
          ProgressMonitor(pcnt,yd-1);
          inc(pcnt);
          xcnt:=0;
          inc(ycnt,ystep);
{DBGns;
DBG('line '+long2str(ycnt)+'/'+long2str(yd));}
          inc(imageypos,ystep*image^.bytesperline);
          IF NOT interlaced THEN
            IF (ycnt>=yd) THEN
              BEGIN
                inc(pass);
{putimage(0,0,image);
DBG('%%%%%%%%%%%%%%%%%%%%%%%%%');}
              END;

{putimage(0,0,image);}
        END;
   {     END; }
    END;

    FUNCTION firstchar(s:Pstr):byte;
    BEGIN
      WHILE (s^.prefix<>nil) DO s:=s^.prefix;
      firstchar:=s^.suffix;
    END;

  BEGIN
{DBG('lzw start');}
    endofsrc:=FALSE;
    xd:=image^.width;
    yd:=image^.height;
    xcnt:=0;
    pcnt:=0;
    IF interlaced THEN
      BEGIN
        pass:=1;
        ycnt:=ilstart[pass];
        ystep:=ilstep[pass];
      END
    ELSE
      BEGIN
        pass:=4;
        ycnt:=0;
        ystep:=1;
      END;
    imageypos:=img^.pixeldata+ycnt*image^.bytesperline;
    oldcode:=0;
    bitbuf:=0;
    bitsinbuf:=0;
    bytinbuf:=0;
    bytbufidx:=0;
    codesize:=0;
    stream^.read(codesize,1);
{DBG(codesize);}
    InitStringTable;
    curcode:=getnextcode;
{DBG(curcode);}
    WHILE (curcode<>endcode) AND (pass<5) AND NOT endofsrc{ AND NOT finished} DO
      BEGIN
{DBG('-----');
DBG(curcode);
DBGw(stridx);}
        IF (curcode=clearcode) THEN
          BEGIN
            ClearStringTable;
            REPEAT
              curcode:=getnextcode;
{DBG('lzw clear');}
            UNTIL (curcode<>clearcode);
            IF (curcode=endcode) THEN break;
            WriteStr(code2str(curcode));
            oldcode:=curcode;
          END
        ELSE
          BEGIN
            IF (curcode<stridx) THEN
              BEGIN
                WriteStr(Code2Str(curcode));
                AddStr2Tab(Code2Str(oldcode),firstchar(Code2Str(curcode)));
                oldcode:=curcode;
              END
            ELSE
              BEGIN
                IF (curcode>stridx) THEN break;
                AddStr2Tab(Code2Str(oldcode),firstchar(Code2Str(oldcode)));
                WriteStr(Code2Str(stridx-1));
                oldcode:=curcode;
              END;
          END;
        curcode:=getnextcode;
      END;
    DoneStringTable;
{putimage(0,0,image);}
{DBG('lzw end');
DBG(bytinbuf);}
    IF NOT endofsrc THEN DumpData;
{DBG('lzw finished');}
  END;

TYPE TGIFSignature=array[1..6] of char;

     TGIFScreenDescriptor=RECORD
       width,height:word;
       flags,background,map:byte;
     END;

     TGIFImageDescriptor=RECORD
       x,y,xd,yd:word;
       flags:byte;
     END;

     TGIFExtensionBlock=RECORD
       functioncode:byte;
     END;

     TGIFGraphicControlExtension=RECORD
       flags:byte;
       delaytime:word;
       transcolor:byte;
     END;

     TRGB=RECORD
       r,g,b:byte;
     END;

VAR GIFSignature:TGIFSignature;
    GIFScreenDescriptor:TGIFScreenDescriptor;
    GIFBlockID:char;
    GIFImageDescriptor:TGIFImageDescriptor;
    GIFExtensionBlock:TGIFExtensionBlock;
    GIFGraphicControlExtension:TGIFGraphicControlExtension;
    xd,yd:longint;
    count:byte;
    transcolor:longint;
    transparency,imageloaded:boolean;

VAR i:longint;
    globalpal,localpal:tpal;
    pal:ppal;
    startpos:longint;
    rgb:trgb;

BEGIN
{DBG('GIF start');}
  LoadImageGIF:=-1;
  IF (nr<1) THEN exit;
  startpos:=stream^.getpos;
  transcolor:=0;
  transparency:=FALSE;
  imageloaded:=FALSE;
  stream^.Read(GIFSignature,sizeof(GIFSignature));
  IF (GIFSignature[1]='G') AND (GIFSignature[2]='I') AND (GIFSignature[3]='F') THEN
    BEGIN
{DBG('GIF ok');}
      stream^.read(GIFScreenDescriptor,sizeof(GIFScreenDescriptor));
      IF (GIFScreenDescriptor.flags AND $80=$80) THEN
        BEGIN
          pal:=@globalpal;
          FOR i:=0 TO (1 SHL (GIFScreenDescriptor.flags AND $07+1))-1 DO
             BEGIN
               stream^.read(rgb,3);
               globalpal[i]:=rgbcolorRGB(rgb.r,rgb.g,rgb.b);
             END;
        END;
      REPEAT
        stream^.read(GIFBlockID,sizeof(GIFBlockID));
{DBG(GIFBlockID);}
        CASE GIFBlockID OF
        ';':;
        ',':BEGIN  { Image separator }
              dec(nr);
              IF NOT imageloaded THEN
                BEGIN
                  pal:=@globalpal;
                  stream^.read(GIFImageDescriptor,sizeof(GIFImageDescriptor));
                  IF (GIFImageDescriptor.flags AND $80=$80) THEN
                    BEGIN
                      pal:=@localpal;
{DBG('#LP');
DBG((2 SHL (GIFImageDescriptor.flags AND $07)));}
                      FOR i:=0 TO (2 SHL (GIFImageDescriptor.flags AND $07))-1 DO
                        BEGIN
                          stream^.read(rgb,3);
                          localpal[i]:=rgbcolorRGB(rgb.r,rgb.g,rgb.b);
                        END;
                      END;
                  xd:=GIFImageDescriptor.xd;
                  yd:=GIFImageDescriptor.yd;
{IF yd>768 then exit;}
{DBG(xd);
DBG(yd);}
                  IF (nr<=0) THEN
                    BEGIN
{DBG('a');}
                      img:=createimagewh(xd,yd);
{DBG('b');}
                      DecodeGIFLZW(img,pal,(GIFImageDescriptor.flags AND $40=$40));
                      imageloaded:=TRUE;
                      LoadImageGIF:=0;
                    END
                  ELSE
                    BEGIN
                      stream^.read(count,1);
                      DumpData;
                    END;
                END
              ELSE
                BEGIN
                  GIFBlockID:=';';
                END;
            END;
        '!':BEGIN
              stream^.read(GIFExtensionBlock,sizeof(GIFExtensionBlock));
{DBG(GIFExtensionBlock.functioncode);}
              CASE GIFExtensionBlock.functioncode OF
              $F9:BEGIN
                    stream^.read(count,1);
                    stream^.read(GIFGraphicControlExtension,count);
                 {   REPEAT
                      stream^.read(count,1);
                    UNTIL (count=0); }
                    transcolor:=pal^[GIFGraphicControlExtension.transcolor];
                    transparency:=TRUE;
                    DumpData;
                  END;
              ELSE
                BEGIN
                  DumpData;
                END;
              END;
            END;
        ELSE exit;
        END;
      UNTIL (GIFBlockID=';') OR (stream^.getpos>=stream^.getsize);
      IF transparency THEN
        IF (img<>nil) THEN
          BEGIN
            img^.flags:=img_transparency;
            img^.transparencycolor:=transcolor;
          END;
    END;
{DBG('GIF end');}
  stream^.seek(startpos);
END;

{========================== LoadImageICO ==================================}

FUNCTION LoadImageICO(stream:pstream;var img:pimage;nr:longint):longint;
TYPE Ticondir=RECORD
       idReserved:word;
       idType:word;
       idCount:word;
     END;

     Ticondirentry=RECORD
       bWidth:byte;
       bHeight:byte;
       bColorCount:byte;
       bReserved:byte;
       wPlanes:word;
       wBitCount:word;
       dwBytesInRes:longint;
       dwImageOffset:longint;
     END;

     TBMPinfoheader=RECORD
       biSize:longint;
       biWidth:longint;
       biHeight:longint;
       biPlanes:word;
       biBitCount:word;
       biCompression:longint;
       biSizeImage:longint;
       biXPelsPerMeter:longint;
       biYPelsPerMeter:longint;
       biClrUsed:longint;
       biClrImportant:longint;
     END;

  PROCEDURE decode_RLE4(buf:pointer;count:longint);
  VAR b1,b2:byte;
      tmp:longint;
      wpos:byte;

    PROCEDURE fill4bits(num,bits:byte);
    VAR i,rpos:byte;
    BEGIN
      rpos:=4;
      FOR i:=1 TO num DO
        BEGIN
          byte(buf^):=(byte(buf^) AND NOT($0F SHL wpos)) OR (((bits SHR rpos) AND $0F) SHL wpos);
          IF (wpos=0) THEN inc(buf);
          wpos:=(wpos-4) AND 7;
          rpos:=(rpos-4) AND 7;
        END;
    END;

    PROCEDURE copy4bits(num:byte);
    VAR i,rpos:byte;
        bits:byte;
    BEGIN
      rpos:=4;
      FOR i:=1 TO num DO
        BEGIN
          IF (rpos=4) THEN stream^.read(bits,1);
          byte(buf^):=(byte(buf^) AND NOT($0F SHL wpos)) OR (((bits SHR rpos) AND $0F) SHL wpos);
          IF (wpos=0) THEN inc(buf);
          wpos:=(wpos-4) AND 7;
          rpos:=(rpos-4) AND 7;
        END;
    END;

  BEGIN
    wpos:=4;
    REPEAT
      stream^.read(b1,1);
      stream^.read(b2,1);
      IF (b1=0) THEN
        BEGIN
          CASE b2 OF
          0:;
          1:;
          2:BEGIN
              stream^.read(tmp,2);
            END;
          ELSE
            BEGIN
              copy4bits(b2);
              stream^.read(tmp,((b2+1) SHR 1) AND 1);
              dec(count,b2);
            END;
          END;
        END
      ELSE
        BEGIN
          fill4bits(b1,b2);
          dec(count,b1);
        END;
    UNTIL ((b1=0) AND ((b2=0) OR (b2=1))) OR (count<0);
  END;

  PROCEDURE decode_RLE8(buf:pointer;count:longint);
  VAR b1,b2:byte;
      tmp:longint;
  BEGIN
    REPEAT
      stream^.read(b1,1);
      stream^.read(b2,1);
      IF (b1=0) THEN
        BEGIN
          CASE b2 OF
          0:;
          1:;
          2:BEGIN
              stream^.read(tmp,2);
            END;
          ELSE
            BEGIN
              stream^.read(buf^,b2);
              stream^.read(tmp,b2 AND 1);
              inc(buf,b2);
              dec(count,b2);
            END;
          END;
        END
      ELSE
        BEGIN
          fillchar(buf^,b1,b2);
          inc(buf,b1);
          dec(count,b1);
        END;
    UNTIL ((b1=0) AND ((b2=0) OR (b2=1))) OR (count<0);
  END;

VAR ICOdir:Ticondir;
    ICOdirentry:Ticondirentry;
 {   CURdirentry:Tcursordirentry absolute ICOdirentry; }
    ICOBMPinfo:TBMPinfoheader;
    x,y,xd,yd,numicons:longint;
    transcolor,imgsize,colfound:longint;
    palette:array[0..255] of longint;
    linebuf,imgypos:pointer;
    linesize:longint;
    startpos:longint;
    i,color:longint;
BEGIN
  LoadImageICO:=-1;
  IF (nr<1) THEN exit;
  startpos:=stream^.getpos;
  stream^.read(ICOdir,sizeof(Ticondir));
  IF (ICOdir.idType=1) OR (ICOdir.idType=2) THEN
    BEGIN
      IF (nr>ICOdir.idcount) THEN exit;
      FOR numicons:=1 TO nr DO
        stream^.read(ICOdirentry,sizeof(Ticondirentry));
      stream^.seek(startpos+ICOdirentry.dwImageOffset);
      stream^.read(ICOBMPinfo,sizeof(ICOBMPinfo));

      xd:=ICOdirentry.bwidth;
      yd:=ICOdirentry.bheight;
      IF (ICOBMPinfo.biBitCount=0) THEN ICOBMPinfo.biBitCount:=24;
{IF (ICOdir.idType=2) THEN
DBG(xd);
IF (ICOdir.idType=2) THEN
DBGw(yd);}
{IF (ICOdir.idType=2) THEN
  DBGw(ICOBMPinfo.biBitCount);}
{DBG('x',xd);
DBG('y',yd);}
      img:=CreateImageWH(xd,yd);
{LoadImageICO:=ICOdir.idcount-nr;
exit;}
      imgypos:=img^.pixeldata+img^.bytesperline*yd;
      linesize:=((xd*ICOBMPinfo.biBitCount+7) DIV 8+3) AND $FFFFFFFC;
{DBGw(linesize);}
      getmem(linebuf,linesize+4);
      IF (ICOBMPinfo.biBitCount>0) AND (ICOBMPinfo.biBitCount<=8) THEN
        BEGIN
          IF (ICOBMPinfo.biClrUsed=0) THEN
            BEGIN
              FOR i:=0 TO (1 SHL ICOBMPinfo.biBitCount)-1 DO
                BEGIN
                  stream^.read(color,4);
                  palette[i]:=rgbcolor(color);
                END;
            END
          ELSE
            BEGIN
              FOR i:=0 TO ICOBMPinfo.biClrUsed-1 DO
                BEGIN
                  stream^.read(color,4);
                  palette[i]:=rgbcolor(color);
                END;
            END;
        END;
      FOR y:=0 TO yd-1 DO
        BEGIN
          ProgressMonitor(y,yd-1);
          dec(imgypos,img^.bytesperline);
          CASE ICOBMPinfo.biCompression OF
          0:stream^.read(linebuf^,linesize);
          1:decode_RLE8(linebuf,xd);
          2:decode_RLE4(linebuf,xd);
          END;
          CASE ICOBMPinfo.biBitCount OF
            1:ASM
                MOV EDX,bytperpix
                MOV ESI,linebuf
                MOV EDI,imgypos
                MOV ECX,xd
              @loop1:
                LODSB
                SHL EAX,24
                OR EAX,1
                MOV EBX,EAX
              @loop2:
                ROL EBX,1
                MOV EAX,EBX
                AND EAX,1
                MOV EAX,[palette+EAX*4]
                PUSH EDX
              @loop3:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop3
                POP EDX
                DEC ECX
                JZ @eol
                TEST EBX,00000100h
                JZ @loop2
                JMP @loop1
              @eol:
              END;
            4:ASM
                MOV EDX,bytperpix
                MOV ESI,linebuf
                MOV EDI,imgypos
                MOV ECX,xd
              @loop1:
                LODSB
                SHL EAX,24
                OR EAX,1
                MOV EBX,EAX
              @loop2:
                ROL EBX,4
                MOV EAX,EBX
                AND EAX,15
                MOV EAX,[palette+EAX*4]
                PUSH EDX
              @loop3:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop3
                POP EDX
                DEC ECX
                JZ @eol
                TEST EBX,00000100h
                JZ @loop2
                JMP @loop1
              @eol:
              END;
            8:ASM
                MOV EDX,bytperpix
                MOV ESI,linebuf
                MOV EDI,imgypos
                MOV ECX,xd
              @loop1:
                LODSB
                SHL EAX,2
                AND EAX,3FCh
                MOV EAX,[palette+EAX]
                PUSH EDX
             @loop3:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop3
                POP EDX
                DEC ECX
                JNZ @loop1
              END;
           24:ASM
                MOV ECX,xd
                MOV ESI,linebuf
                MOV EDI,imgypos
              @loop2:
                LODSD
                DEC ESI
                PUSH EAX
                CALL rgbcolor
                MOV EDX,bytperpix
              @loop1:
                STOSB
                SHR EAX,8
                DEC EDX
                JNZ @loop1
                LOOP @loop2
              END;
          END;
        END;
      freemem(linebuf,linesize+4);
      { search for not used color }
      imgypos:=img^.pixeldata;
      REPEAT
        transcolor:=rgbcolor(random($00FFFFFF));
        ASM
          MOV EDI,bytperpix
          MOV ESI,imgypos
          MOV EBX,yd
        @loopy:
          MOV EDX,xd
        @loopx:
          MOV ECX,EDI
        @loopz:
          LODSB
          ROR EAX,8
          DEC ECX
          JNZ @loopz
          MOV ECX,EDI
          SHL ECX,3
          ROL EAX,CL
          AND EAX,00FFFFFFh
          CMP EAX,transcolor
          JE @colorfound
          DEC EDX
          JNZ @loopx
          ADD ESI,7
          AND ESI,0FFFFFFF8h
          DEC EBX
          JNZ @loopy
        @colorfound:
          OR EDX,EBX
          MOV colfound,EDX
        END;
      UNTIL (colfound=0);
      img^.transparencycolor:=transcolor;
      { read the AND-mask and set the transparency color }
      imgypos:=img^.pixeldata+img^.bytesperline*yd;
      linesize:=((xd+7) DIV 8+3) AND $FFFFFFFC;
      getmem(linebuf,linesize+4);
      FOR y:=0 TO yd-1 DO
        BEGIN
          dec(imgypos,img^.bytesperline);
          stream^.Read(linebuf^,linesize);
          ASM
            MOV EDX,bytperpix
            MOV ESI,linebuf
            MOV EDI,imgypos
            MOV ECX,xd
            ADD ECX,7
            SHR ECX,3
          @loop1:
            PUSH ECX
            LODSB
            MOV BL,AL
            MOV ECX,8
          @loop2:
            PUSH ECX
            SHL BL,1
            JNC @weiter
            MOV ECX,EDX
            MOV EAX,transcolor
          @loop3:
            STOSB
            SHR EAX,8
            LOOP @loop3
            POP ECX
            LOOP @loop2
            JMP @loop2end
          @weiter:
            ADD EDI,EDX
            POP ECX
            LOOP @loop2
          @loop2end:
            POP ECX
            LOOP @loop1
          END;
        END;
      freemem(linebuf,linesize+4);

      IF (ICOdir.idType=2) THEN
        BEGIN
          setimageflags(img,img_origincoords);
        {  img^.originX:=CURdirentry.centerX;
          img^.originY:=CURdirentry.centerY; }
          img^.originX:=ICOdirentry.wPlanes;
          img^.originY:=ICOdirentry.wBitCount;
        END;

      LoadImageICO:=ICOdir.idcount-nr;
    END;
  stream^.seek(startpos);
END;

{========================== LoadImageJPG ==================================}

FUNCTION LoadImageJPG(stream:pstream;var img:pimage;nr:longint):longint;

  FUNCTION hi4(b:byte):byte;
  BEGIN
    hi4:=(b SHR 4) AND $0F;
  END;

  FUNCTION lo4(b:byte):byte;
  BEGIN
    lo4:=b AND $0F;
  END;

{=== Annex A === Annex A === Annex A === Annex A === Annex A ===}

  CONST maxcomp=3;

  TYPE float=single;

  TYPE {Tcoeff=array[0..8*8-1] of smallint;}
       {Tblockfloat=array[0..7,0..7] of float;}
       {Tvectfloat=array[0..63] of float;}
       Tblocklongint=array[0..7,0..7] of longint;
       Tvectlongint=array[0..63] of longint;

       Pcoeffbuf=^Tcoeffbuf;
       Tcoeffbuf=array[0..0,0..63] of smallint;

  VAR Qk:array[0..3] of tvectlongint;
      idctfix:array[0..1,0..1,1..3] of tblocklongint;
      pred:array[1..maxcomp] of longint;
   {   pix_h,pix_v:array[1..maxcomp,0..3] of byte; }
      coeffbuf:array[1..maxcomp] of Pcoeffbuf;
      coeffbufW,coeffbufH,coeffbufidx,coeffeobrun,coeffX,coeffY,coeffbufXd,coeffbufYd:array[1..maxcomp] of longint;

  CONST zigzag:array[0..7,0..7] of byte=
        (( 0, 1, 5, 6,14,15,27,28),
         ( 2, 4, 7,13,16,26,29,42),
         ( 3, 8,12,17,25,30,41,43),
         ( 9,11,18,24,31,40,44,53),
         (10,19,23,32,39,45,52,54),
         (20,22,33,38,46,51,55,60),
         (21,34,37,47,50,56,59,61),
         (35,36,48,49,57,58,62,63));

  CONST zigizagi:array[0..63] of byte=
        (0, 8, 1, 2, 9, 16,24,17,
         10,3, 4, 11,18,25,32,40,
         33,26,19,12,5, 6, 13,20,
         27,34,41,48,56,49,42,35,
         28,21,14,7, 15,22,29,36,
         43,50,57,58,51,44,37,30,
         23,31,38,45,52,59,60,53,
         46,39,47,54,61,62,55,63);

  CONST pi=3.141592654;
        cuv=0.707106781;
        cx:array[0..7] of float=(cuv,1.0,1.0,1.0,1.0,1.0,1.0,1.0);
        fixpt=16;
        fixptmul=1 SHL fixpt;

  VAR costab:Tblocklongint;

  PROCEDURE invDCTfix(var dst,src:Tblocklongint);assembler;
  VAR rows:TBlockLongint;
  ASM
    {--- 1D-iDCT on rows ---}
    LEA EDI,rows
    MOV EDX,src
    MOV ECX,8
  @loop1a:
    PUSH ECX

    MOV EAX,[EBP+08h]
    LEA ESI,[EAX+OFFSET costab]

    MOV ECX,4
  @loop2a:
    PUSH ECX

    LODSD {0}
    IMUL EAX,DWORD PTR [EDX+000h]
    MOV EBX,EAX
    LODSD {1}
    IMUL EAX,DWORD PTR [EDX+004h]
    MOV ECX,EAX
    {----------}
    LODSD {2}
    IMUL EAX,DWORD PTR [EDX+008h]
    ADD EBX,EAX
    LODSD {3}
    IMUL EAX,DWORD PTR [EDX+00Ch]
    ADD ECX,EAX
    {----------}
    LODSD {4}
    IMUL EAX,DWORD PTR [EDX+010h]
    ADD EBX,EAX
    LODSD {5}
    IMUL EAX,DWORD PTR [EDX+014h]
    ADD ECX,EAX
    {----------}
    LODSD {6}
    IMUL EAX,DWORD PTR [EDX+018h]
    ADD EBX,EAX
    LODSD {7}
    IMUL EAX,DWORD PTR [EDX+01Ch]
    ADD ECX,EAX

    MOV EAX,EBX
    SUB EBX,ECX
    ADD EAX,ECX

    POP ECX

    MOV [EDI+ECX*8-4],EBX
    STOSD

    DEC ECX
    JNZ @loop2a

    POP ECX
    ADD EDI,16
    ADD EDX,020h
    DEC ECX
    JNZ @loop1a

    {--- 1D-iDCT on columns ---}
    MOV EDI,dst

    MOV EAX,[EBP+08h]
    LEA ESI,[EAX+OFFSET costab]

    MOV ECX,4
  @loop1b:
    PUSH ECX

    MOV EAX,ECX
    SHL EAX,6
    SUB EAX,36

    MOV ECX,8

    LEA EDX,rows

  @loop2b:
    PUSH ESI
    PUSH EAX
    PUSH ECX

    LODSD {0}
    IMUL EAX,DWORD PTR [EDX]
    MOV EBX,EAX
    LODSD {1}
    IMUL EAX,DWORD PTR [EDX+020h]
    MOV ECX,EAX
    {----------}
    LODSD {2}
    IMUL EAX,DWORD PTR [EDX+040h]
    ADD EBX,EAX
    LODSD {3}
    IMUL EAX,DWORD PTR [EDX+060h]
    ADD ECX,EAX
    {----------}
    LODSD {4}
    IMUL EAX,DWORD PTR [EDX+080h]
    ADD EBX,EAX
    LODSD {5}
    IMUL EAX,DWORD PTR [EDX+0A0h]
    ADD ECX,EAX
    {----------}
    LODSD {6}
    IMUL EAX,DWORD PTR [EDX+0C0h]
    ADD EBX,EAX
    LODSD {7}
    IMUL EAX,DWORD PTR [EDX+0E0h]
    ADD ECX,EAX

    MOV EAX,EBX
    SUB EBX,ECX
    ADD EAX,ECX

    POP ECX

    STOSD
    POP EAX

    MOV [EDI+EAX],EBX

    POP ESI
    ADD EDX,4
    DEC ECX
    JNZ @loop2b

    POP ECX
    ADD ESI,32
    DEC ECX
    JNZ @loop1b
  END;

{=== Annex C === Annex C === Annex C === Annex C === Annex C ===}

  TYPE phuff=^thuff;
       thuff=RECORD
         mincode,maxcode:array[1..16] of dword;
         valptr,bits:array[1..16] of longint;
         huffsize:array[0..256] of longint;
         huffval:array[0..256] of longint;
         huffcode:array[0..256] of dword;
         lastk:longint;
       END;
       phufftable=^thufftable;
       thufftable=array[0..1,0..3] of thuff;
  
  VAR hufftable:phufftable;

  TYPE
       DHT_t=RECORD
         Tc_Th:byte;
         Li:array[1..16] of byte;
         Vij:array[0..256] of byte;
       END;

       DQT_p=^DQT_t;
       DQT_t=RECORD
         Pq_Tq:byte;
         Qk:array[0..8*8-1] of smallint;
       END;

       SOF_t=RECORD
         P:byte;
         Y:word;
         X:word;
         Nf:byte;
         Ci:array[0..255] of byte;
         Hi_Vi:array[0..255] of byte;
         Tqi:array[0..255] of byte;
       END;

       SOS_t=RECORD
         Ns:byte;
         Csj:array[1..4] of byte;
         Tdj_Taj:array[1..10] of byte;
         Ss:byte;
         Se:byte;
         Ah_Al:byte;
       END;

  VAR
      DHT:DHT_t;
      DQT:DQT_t;
      SOF:SOF_t;
      SOS:SOS_t;
      SOFtype:word;

  PROCEDURE generate_size_table(tc,th:longint);
  VAR i,j,k:longint;
  BEGIN
    WITH hufftable^[tc,th] DO
      BEGIN
        k:=0;
        FOR i:=1 TO 16 DO
          BEGIN
            FOR j:=1 TO bits[i] DO
              BEGIN
                huffsize[k]:=i;
                inc(k);
              END;
          END;
        huffsize[k]:=0;
        lastk:=k;
      END;
  END;

  PROCEDURE generate_code_table(tc,th:longint);
  VAR k,si:longint;
      code:dword;
  BEGIN
    WITH hufftable^[tc,th] DO
      BEGIN
        k:=0;
        code:=0;
        si:=huffsize[0];
        REPEAT
          REPEAT
            huffcode[k]:=code;
{DBGw(hexlong(huffcode[k]));}
            code:=code+1;
            k:=k+1;
          UNTIL NOT (huffsize[k]=si);
          IF NOT (huffsize[k]=0) THEN
            BEGIN
              REPEAT
                code:=code SHL 1;
                si:=si+1;
              UNTIL (huffsize[k]=si);
            END;
        UNTIL (huffsize[k]=0);
      END;
  END;

  PROCEDURE Decoder_Tables(tc,th:longint);
  VAR i,j:longint;
  BEGIN
    WITH hufftable^[tc,th] DO
      BEGIN
        j:=0;
        FOR i:=1 TO 16 DO
          BEGIN
            IF (bits[i]=0) THEN
              BEGIN
                maxcode[i]:=$FFFFFFFF;
              END
            ELSE
              BEGIN
                valptr[i]:=j;
                mincode[i]:=huffcode[j];
                j:=j+bits[i]-1;
                maxcode[i]:=huffcode[j];
                j:=j+1;
              END;
          END;
      END;
  END;

{=== Annex F === Annex F === Annex F === Annex F === Annex F ===}

  VAR cnt_nb:longint;
      b_nb:byte;
      end_of_scan,end_of_image:boolean;
      restart_interval:longint;

  FUNCTION NEXTBYTE:byte;
  VAR b,c:byte;
  BEGIN
    stream^.read(b,1);
    IF (stream^.getpos>=stream^.getsize) THEN
      BEGIN
        end_of_scan:=TRUE;
        end_of_image:=TRUE;
      END
    ELSE
      BEGIN
        IF (b=$FF) THEN
          BEGIN
            stream^.read(c,1);
            IF (c<>0) THEN
              BEGIN
                stream^.seek(stream^.getpos-2);
                end_of_scan:=TRUE;
              END;
          END;
      END;
    NEXTBYTE:=b;
  END;

  FUNCTION NEXTBIT:longint;
  VAR bit:longint;
  BEGIN
    IF (cnt_nb=0) THEN
      BEGIN
        b_nb:=NEXTBYTE;
        cnt_nb:=8;
      END;
    bit:=b_nb SHR 7;
    cnt_nb:=cnt_nb-1;
    b_nb:=byte(b_nb SHL 1);
    NEXTBIT:=bit AND 1;
  END;

  FUNCTION RECEIVE(n:longint):longint;
  VAR bits:longint;
  BEGIN
    IF end_of_scan THEN exit;
    bits:=0;
    IF (n>=cnt_nb) THEN
      BEGIN
        bits:=b_nb SHR (8-cnt_nb);
        dec(n,cnt_nb);
        b_nb:=NEXTBYTE;
        cnt_nb:=8;
      END;
    WHILE (n>=8) DO
      BEGIN
        bits:=(bits SHL 8) OR b_nb;
        b_nb:=NEXTBYTE;
        dec(n,8);
      END;
    WHILE (n>0) DO
      BEGIN
        IF (cnt_nb=0) THEN
          BEGIN
            b_nb:=NEXTBYTE;
            cnt_nb:=8;
          END;
        bits:=(bits SHL 1) OR (b_nb SHR 7) AND 1;
        dec(cnt_nb);
        b_nb:=byte(b_nb SHL 1);
        dec(n);
      END;
    RECEIVE:=bits;
  END;

  FUNCTION EXTEND(v,t:longint):longint;assembler;
  ASM
    MOV ECX,t
    MOV EBX,1
    SHL EBX,CL
    SHR EBX,1
    MOV EAX,v
    CMP EAX,EBX
    JGE @nosign
    MOV EBX,-1
    SHL EBX,CL
    INC EBX
    ADD EAX,EBX
  @nosign:
  END;

{  FUNCTION RECEIVE(ssss:longint):longint;
  BEGIN
    RECEIVE:=NEXTBITS(ssss);
  END; }

  FUNCTION DECODE(tc,th:longint):longint;
  VAR i,j,value,code:dword;
  BEGIN
    WITH hufftable^[tc,th] DO
      BEGIN
        i:=1;
        code:=NEXTBIT;
        WHILE ((code>maxcode[i]) OR (bits[i]=0)) AND NOT(end_of_scan OR end_of_image) DO
          BEGIN
            i:=i+1;
            code:=(code SHL 1)+NEXTBIT;
          END;
        IF end_of_scan THEN exit;
        j:=valptr[i];
        j:=j+code-mincode[i];
        value:=huffval[j];
      END;
    DECODE:=value;
  END;

  PROCEDURE decode_coefficients_SOF0(sosidx,comp,v,h:longint);
  VAR i,k,rs,ssss,rrrr,t,hdc,hac:longint;
      coeff:array[0..63] of longint;
  {    dequ:Tblocklongint; }
      Q:^Tvectlongint;
  BEGIN
    IF end_of_scan THEN exit;
    hdc:=hi4(SOS.Tdj_Taj[sosidx]);
    hac:=lo4(SOS.Tdj_Taj[sosidx]);
    Q:=@Qk[SOF.Tqi[comp]];
    t:=DECODE(0,hdc);
    IF end_of_scan THEN exit;
    pred[comp]:=pred[comp]+EXTEND(RECEIVE(t),t);
    coeff[zigizagi[0]]:=pred[comp]*Q^[0];
    FOR i:=1 TO 63 DO coeff[i]:=0;
    k:=1;
    REPEAT
      rs:=DECODE(1,hac);
      ssss:=RS AND 15;
      rrrr:=(RS SHR 4) AND 15;
      k:=k+rrrr;
      IF (ssss<>0) THEN
        BEGIN
          IF (k<=63) THEN coeff[zigizagi[k]]:=EXTEND(RECEIVE(ssss),ssss)*Q^[k];
        END
      ELSE
        BEGIN
          IF (rrrr<>15) THEN break;
        END;
      inc(k);
    UNTIL (k>63) OR end_of_scan OR end_of_image;
   { _fixfastinvDCT(idctfix[v,h,comp],tblocklongint(coeff)); }
    invDCTfix(idctfix[v,h,comp],tblocklongint(coeff));
  END;

  PROCEDURE decode_coefficients_SOF2(sosidx,comp:longint);
  VAR k,rs,ssss,rrrr,t,hdc,hac,cb,eobrun,Al,Ah:longint;
      p1,m1:smallint;
      coeff:^smallint;
  BEGIN
    IF end_of_scan THEN exit;
    cb:=coeffbufidx[comp];
    eobrun:=coeffeobrun[comp];
    IF (cb>=coeffbufW[comp]*coeffbufH[comp]) THEN
      BEGIN
        WHILE NOT end_of_scan DO NEXTBIT;
        exit;
      END;
    Ah:=hi4(SOS.Ah_Al);
    Al:=lo4(SOS.Ah_Al);
    hdc:=hi4(SOS.Tdj_Taj[sosidx]);
    hac:=lo4(SOS.Tdj_Taj[sosidx]);
    IF (SOS.Ss=0) THEN
      BEGIN
        IF (Ah=0) THEN
          BEGIN
            t:=DECODE(0,hdc);
            pred[comp]:=pred[comp]+EXTEND(RECEIVE(t),t);
            IF end_of_scan THEN exit;
            coeffbuf[comp]^[cb,0]:=pred[comp] SHL Al;
          END
        ELSE
          BEGIN
            coeffbuf[comp]^[cb,0]:=coeffbuf[comp]^[cb,0] OR (receive(1) SHL Al);
          END;
      END
    ELSE
      BEGIN
        IF (Ah=0) THEN
          BEGIN
            {progessive}
            IF (eobrun>0) THEN
              BEGIN
                dec(eobrun);
              END
            ELSE
              BEGIN
                k:=SOS.Ss;
                WHILE (k<=SOS.Se) DO
                  BEGIN
                    rs:=DECODE(1,hac);
                    IF end_of_scan THEN exit;
                    ssss:=rs AND 15;
                    rrrr:=(rs SHR 4) AND 15;
                    IF (ssss<>0) THEN
                      BEGIN
                        inc(k,rrrr);
                        coeffbuf[comp]^[cb,k]:=EXTEND(RECEIVE(ssss),ssss) SHL Al;
                        IF end_of_scan THEN exit;
                      END
                    ELSE
                      BEGIN
                        IF (rrrr=15) THEN
                          BEGIN
                            inc(k,15);
                          END
                        ELSE
                          BEGIN
                            eobrun:=longint(1) SHL rrrr;
                            IF (rrrr<>0) THEN
                              BEGIN
                                rrrr:=RECEIVE(rrrr);
                                IF end_of_scan THEN exit;
                                inc(eobrun,rrrr);
                              END;
                            dec(eobrun);
                            break;
                          END;
                      END;
                    inc(k);
                  END;
              END;
          END
        ELSE
          BEGIN
            {successive}
            p1:=smallint(1) SHL Al;
            m1:=smallint(-1) SHL Al;
            k:=SOS.Ss;
            IF (eobrun=0) THEN
              BEGIN
                WHILE (k<=SOS.Se) DO
                  BEGIN
                    rs:=DECODE(1,hac);
                    IF end_of_scan THEN exit;
                    ssss:=rs AND 15;
                    rrrr:=(rs SHR 4) AND 15;
                    IF (ssss<>0) THEN
                      BEGIN
                        IF (RECEIVE(1)<>0) THEN ssss:=p1 ELSE ssss:=m1;
                        IF end_of_scan THEN exit;
                      END
                    ELSE
                      BEGIN
                        IF (rrrr<>15) THEN
                          BEGIN
                            eobrun:=longint(1) SHL rrrr;
                            IF (rrrr<>0) THEN
                              BEGIN
                                rrrr:=RECEIVE(rrrr);
                                IF end_of_scan THEN exit;
                                inc(eobrun,rrrr);
                              END;
                            break;
                          END;
                      END;
                    REPEAT
                      coeff:=@(coeffbuf[comp]^[cb,k]);
                      IF (coeff^<>0) THEN
                        BEGIN
                          IF (RECEIVE(1)<>0) THEN
                            IF (coeff^ AND p1=0) THEN
                              IF (coeff^>=0) THEN inc(coeff^,p1) ELSE inc(coeff^,m1);
                          IF end_of_scan THEN exit;
                        END
                      ELSE
                        BEGIN
                          dec(rrrr);
                          IF (rrrr<0) THEN break;
                        END;
                      inc(k);
                    UNTIL (k>SOS.Se);
                    IF (ssss<>0) THEN
                      BEGIN
                        coeffbuf[comp]^[cb,k]:=ssss;
                      END;
                    inc(k);
                  END;
              END;
            IF (eobrun>0) THEN
              BEGIN
                WHILE (k<=SOS.Se) DO
                  BEGIN
                    coeff:=@(coeffbuf[comp]^[cb,k]);
                    IF (coeff^<>0) THEN
                      BEGIN
                        IF (RECEIVE(1)<>0) THEN
                          IF (coeff^ AND p1=0) THEN
                            IF (coeff^>=0) THEN inc(coeff^,p1) ELSE inc(coeff^,m1);
                        IF end_of_scan THEN exit;
                      END;
                    inc(k);
                  END;
                dec(eobrun);
              END;
          END;
      END; { IF (SOS.Ss=0) THEN }
    coeffeobrun[comp]:=eobrun;
  END;

  FUNCTION ycbcr2rgbfix(y,cb,cr:longint):longint;assembler;
  CONST Rcr=trunc((1 SHL (32-fixpt))*1.40200);
        Gcb=trunc((1 SHL (32-fixpt))*0.34414);
        Gcr=trunc((1 SHL (32-fixpt))*0.71414);
        Bcb=trunc((1 SHL (32-fixpt))*1.77200);
  ASM
    MOV EBX,y
    SAR EBX,fixpt
    ADD EBX,128

    MOV EAX,Bcb
    IMUL cb
    ADD EDX,EBX
    TEST EDX,0FFFFFF00h
    SETZ AL
    SETS CL
    DEC AL
    OR DL,AL
    ADD DL,CL
    SHRD EDI,EDX,8

    MOV ECX,EBX
    MOV EAX,Gcr
    IMUL cr
    SUB ECX,EDX
    MOV EAX,Gcb
    IMUL cb
    SUB ECX,EDX
    TEST ECX,0FFFFFF00h
    SETZ AL
    SETS DL
    DEC AL
    OR CL,AL
    ADD CL,DL
    SHRD EDI,ECX,8

    MOV EAX,Rcr
    IMUL cr
    ADD EDX,EBX
    TEST EDX,0FFFFFF00h
    SETZ AL
    SETS CL
    DEC AL
    OR DL,AL
    ADD DL,CL
    SHRD EDI,EDX,8

    SHR EDI,8
    PUSH EDI
    CALL rgbcolor
  END;

  PROCEDURE draw;
  VAR x,y,c,v,h,v1,h1,v2,h2,v3,h3,hx,vy,xx,yy:longint;
  {    hi,vi:longint; }
      hh1,hh2,hh3:longint;
      vv1,vv2,vv3:longint;
      ih1,ih2,ih3:longint;
      iv1,iv2,iv3:longint;
      hx1,hx2,hx3:longint;
      vy1,vy2,vy3:longint;
  BEGIN
    xx:=coeffX[1];
    yy:=coeffY[1];
    v1:=lo4(SOF.Hi_Vi[1]);
    h1:=hi4(SOF.Hi_Vi[1]);
    v2:=lo4(SOF.Hi_Vi[2]);
    h2:=hi4(SOF.Hi_Vi[2]);
    v3:=lo4(SOF.Hi_Vi[3]);
    h3:=hi4(SOF.Hi_Vi[3]);
    IF (v1=0) THEN v1:=1;
    IF (h1=0) THEN h1:=1;
    IF (v2=0) THEN v2:=1;
    IF (h2=0) THEN h2:=1;
    IF (v3=0) THEN v3:=1;
    IF (h3=0) THEN h3:=1;
    ih1:=(h1 SHL 4) DIV h1;
    ih2:=(h2 SHL 4) DIV h1;
    ih3:=(h3 SHL 4) DIV h1;
    iv1:=(v1 SHL 4) DIV v1;
    iv2:=(v2 SHL 4) DIV v1;
    iv3:=(v3 SHL 4) DIV v1;
    FOR v:=0 TO v1-1 DO
      FOR h:=0 TO h1-1 DO
        BEGIN
          vv1:=v MOD v1;
          hh1:=h MOD h1;
          vv2:=v MOD v2;
          hh2:=h MOD h2;
          vv3:=v MOD v3;
          hh3:=h MOD h3;
          vy1:=(v*iv1) SHL 3;
          vy2:=(v*iv2) SHL 3;
          vy3:=(v*iv3) SHL 3;
          FOR y:=0 TO 7 DO
            BEGIN
              hx1:=(h*ih1) SHL 3;
              hx2:=(h*ih2) SHL 3;
              hx3:=(h*ih3) SHL 3;
              FOR x:=0 TO 7 DO
                BEGIN
                  CASE SOF.Nf OF
                  1:c:=ycbcr2rgbfix(idctfix[vv1,hh1,1][x,y],0,0);
                  3:c:=ycbcr2rgbfix(idctfix[vv1,hh1,1][(hx1 SHR 4) AND 7,(vy1 SHR 4) AND 7],
                                    idctfix[vv2,hh2,2][(hx2 SHR 4) AND 7,(vy2 SHR 4) AND 7],
                                    idctfix[vv3,hh3,3][(hx3 SHR 4) AND 7,(vy3 SHR 4) AND 7]);
                  END;
                  hx:=xx+(h SHL 3+x);
                  vy:=yy+(v SHL 3+y);
                  IF (hx<SOF.X) AND (vy<SOF.Y) THEN
                    move(c,(img^.pixeldata+vy*img^.bytesperline+hx*bytperpix)^,bytperpix);
                  inc(hx1,ih1);
                  inc(hx2,ih2);
                  inc(hx3,ih3);
                END;
              inc(vy1,iv1);
              inc(vy2,iv2);
              inc(vy3,iv3);
            END;
        END;
    IF (xx=0) THEN ProgressMonitor(yy,(SOF.Y-1) AND NOT((v1*8)-1));
    inc(xx,(h1*8));
    IF (xx>=SOF.X) THEN
      BEGIN
        xx:=0;
        inc(yy,(v1*8));
        IF (yy>=SOF.Y) THEN
          BEGIN
            REPEAT
              NEXTBIT;
            UNTIL end_of_scan;
          END;
      END;
    coeffX[1]:=xx;
    coeffY[1]:=yy;
  END;

  PROCEDURE drawcoeffbuf;
  VAR xx,yy,x,y,c,v,h,v1,h1,v2,h2,v3,h3,hx,vy,hh,vv,i,j,k,l,qq:longint;
      dequ:tblocklongint;
   {   idct:array[0..1,0..1,1..maxcomp] of tblockfloat; }
      cbi,cbX,cbY:array[1..maxcomp] of longint;
      hh1,hh2,hh3:longint;
      vv1,vv2,vv3:longint;
      ih1,ih2,ih3:longint;
      iv1,iv2,iv3:longint;
      hx1,hx2,hx3:longint;
      vy1,vy2,vy3:longint;
  BEGIN
    v1:=lo4(SOF.Hi_Vi[1]);
    h1:=hi4(SOF.Hi_Vi[1]);
    v2:=lo4(SOF.Hi_Vi[2]);
    h2:=hi4(SOF.Hi_Vi[2]);
    v3:=lo4(SOF.Hi_Vi[3]);
    h3:=hi4(SOF.Hi_Vi[3]);
    IF (v1=0) THEN v1:=1;
    IF (h1=0) THEN h1:=1;
    IF (v2=0) THEN v2:=1;
    IF (h2=0) THEN h2:=1;
    IF (v3=0) THEN v3:=1;
    IF (h3=0) THEN h3:=1;
    ih1:=(h1 SHL 4) DIV h1;
    ih2:=(h2 SHL 4) DIV h1;
    ih3:=(h3 SHL 4) DIV h1;
    iv1:=(v1 SHL 4) DIV v1;
    iv2:=(v2 SHL 4) DIV v1;
    iv3:=(v3 SHL 4) DIV v1;
    xx:=0;
    yy:=0;
    FOR c:=1 TO SOF.Nf DO
      BEGIN
{DBG(cbi[c]); }
        cbi[c]:=0;
        cbX[c]:=0;
        cbY[c]:=0;
      END;
    REPEAT
      FOR c:=1 TO SOF.Nf DO
        BEGIN
          vv:=lo4(SOF.Hi_Vi[c]);
          hh:=hi4(SOF.Hi_Vi[c]);
          qq:=SOF.Tqi[c];
          FOR v:=0 TO vv-1 DO
            FOR h:=0 TO hh-1 DO
              BEGIN
                cbi[c]:=(cbY[c]+v)*coeffbufW[c]+(cbX[c]+h);
                l:=cbi[c];
                FOR i:=0 TO 7 DO
                  FOR j:=0 TO 7 DO
                    BEGIN
                      k:=zigzag[j,i];
                      dequ[i,j]:=coeffbuf[c]^[l][k]*Qk[qq][k];
                    END;
              {  _fixfastinvDCT(idctfix[v,h,c],dequ); }
                invDCTfix(idctfix[v,h,c],dequ);
                inc(cbi[c]);
              END;
          inc(cbX[c],hh);
          IF (cbX[c]>=coeffbufXd[c]) THEN
            BEGIN
              cbX[c]:=0;
              inc(cbY[c],vv);
            END;
        END;
      FOR v:=0 TO v1-1 DO
        FOR h:=0 TO h1-1 DO
          BEGIN
            vv1:=v MOD v1;
            hh1:=h MOD h1;
            vv2:=v MOD v2;
            hh2:=h MOD h2;
            vv3:=v MOD v3;
            hh3:=h MOD h3;
            vy1:=(v*iv1) SHL 3;
            vy2:=(v*iv2) SHL 3;
            vy3:=(v*iv3) SHL 3;
            FOR y:=0 TO 7 DO
              BEGIN
                hx1:=(h*ih1) SHL 3;
                hx2:=(h*ih2) SHL 3;
                hx3:=(h*ih3) SHL 3;
                FOR x:=0 TO 7 DO
                  BEGIN
                    CASE SOF.Nf OF
                    1:c:=ycbcr2rgbfix(idctfix[vv1,hh1,1][x,y],0,0);
                    3:c:=ycbcr2rgbfix(idctfix[vv1,hh1,1][(hx1 SHR 4) AND 7,(vy1 SHR 4) AND 7],
                                      idctfix[vv2,hh2,2][(hx2 SHR 4) AND 7,(vy2 SHR 4) AND 7],
                                      idctfix[vv3,hh3,3][(hx3 SHR 4) AND 7,(vy3 SHR 4) AND 7]);
                    END;
                    hx:=xx+(h SHL 3+x);
                    vy:=yy+(v SHL 3+y);
                    IF (hx<SOF.X) AND (vy<SOF.Y) THEN
                      move(c,(img^.pixeldata+vy*img^.bytesperline+hx*bytperpix)^,bytperpix);
                    inc(hx1,ih1);
                    inc(hx2,ih2);
                    inc(hx3,ih3);
                  END;
                inc(vy1,iv1);
                inc(vy2,iv2);
                inc(vy3,iv3);
              END;
          END;
  {    IF (xx=0) THEN ProgressMonitor(yy,SOF.Y); }
      IF (xx=0) THEN ProgressMonitor(yy,(SOF.Y-1) AND NOT((v1*8)-1));
      inc(xx,(h1*8));
      IF (xx>=SOF.X) THEN
        BEGIN
          xx:=0;
          inc(yy,(v1*8));
        END;
{putimage(0,0,img);
IF keypressed THEN IF readkey=#27 THEN halt; }
    UNTIL (yy>=SOF.Y);
{putimage(0,0,img);}
  END;

{=== Annex E === Annex E === Annex E === Annex E === Annex E ===}

{CONST mname:array[$FFC0..$FFFE] of string[5]=
      ('SOF0' ,'SOF1' ,'SOF2' ,'SOF3' ,'DHT'  ,'SOF5' ,'SOF6' ,'SOF7' ,
       'SOF8' ,'SOF9' ,'SOF10','SOF11','DAC'  ,'SOF13','SOF14','SOF15',
       'RST0' ,'RST1' ,'RST2' ,'RST3' ,'RST4' ,'RST5' ,'RST6' ,'RST7' ,
       'SOI'  ,'EOI'  , 'SOS' ,'DQT'  ,'DNL'  ,'DRI'  ,'DHP'  ,'EXP'  ,
       'APP0' ,'APP1' ,'APP2' ,'APP3' ,'APP4' ,'APP5' ,'APP6' ,'APP7' ,
       'APP8' ,'APP9' ,'APP10','APP11','APP12','APP13','APP14','APP15',
       'JPG0' ,'JPG1' ,'JPG2' ,'JPG3' ,'JPG4' ,'JPG5' ,'JPG6' ,'JPG7' ,
       'JPG8' ,'JPG9' ,'JPG10','JPG11','JPG12','JPG13','COM');
}
CONST
      mSOF0=$FFC0;
      mSOF1=$FFC1;
      mSOF2=$FFC2;
      mSOF3=$FFC3;
      mDHT=$FFC4;
      mSOF5=$FFC5;
      mSOF6=$FFC6;
      mSOF7=$FFC7;
      mSOF8=$FFC8;
      mSOF9=$FFC9;
      mSOF10=$FFCA;
      mSOF11=$FFCB;
      mDAC=$FFCC;
      mSOF13=$FFCD;
      mSOF14=$FFCE;
      mSOF15=$FFCF;
      mRST0=$FFD0;
      mRST1=$FFD1;
      mRST2=$FFD2;
      mRST3=$FFD3;
      mRST4=$FFD4;
      mRST5=$FFD5;
      mRST6=$FFD6;
      mRST7=$FFD7;
      mSOI=$FFD8;
      mEOI=$FFD9;
      mSOS=$FFDA;
      mDQT=$FFDB;
      mDNL=$FFDC;
      mDRI=$FFDD;
      mDHP=$FFDE;
      mEXP=$FFDF;
      mAPP0=$FFE0;
      mAPP1=$FFE1;
      mAPP2=$FFE2;
      mAPP3=$FFE3;
      mAPP4=$FFE4;
      mAPP5=$FFE5;
      mAPP6=$FFE6;
      mAPP7=$FFE7;
      mAPP8=$FFE8;
      mAPP9=$FFE9;
      mAPP10=$FFEA;
      mAPP11=$FFEB;
      mAPP12=$FFEC;
      mAPP13=$FFED;
      mAPP14=$FFEE;
      mAPP15=$FFEF;
      mJPG0=$FFF0;
      mJPG1=$FFF1;
      mJPG2=$FFF2;
      mJPG3=$FFF3;
      mJPG4=$FFF4;
      mJPG5=$FFF5;
      mJPG6=$FFF6;
      mJPG7=$FFF7;
      mJPG8=$FFF8;
      mJPG9=$FFF9;
      mJPG10=$FFFA;
      mJPG11=$FFFB;
      mJPG12=$FFFC;
      mJPG13=$FFFD;
      mCOM=$FFFE;

  FUNCTION readstream(n:longint):longint;
  VAR l:longint;
  BEGIN
    l:=0;
    stream^.read(l,n);
    readstream:=l;
  END;

  FUNCTION interpret_markers(marker:word):word;
  VAR segmarker,seglength:word;
      i,j,k,tc,th:longint;
  BEGIN
    interpret_markers:=0;
    IF end_of_image THEN exit;
    stream^.read(segmarker,2);
    swap16(segmarker);
    WHILE NOT((segmarker>=$FFC0) AND (segmarker<=$FFFE)) AND (stream^.getpos<stream^.getsize) DO
      BEGIN
        stream^.seek(stream^.getpos-1);
        stream^.read(segmarker,2);
        swap16(segmarker);
      END;
    interpret_markers:=segmarker;
    IF (stream^.getpos>=stream^.getsize) THEN
      BEGIN
        end_of_scan:=TRUE;
        end_of_image:=TRUE;
        exit;
      END;
{IF ((segmarker>=$FFC0) AND (segmarker<=$FFFE)) THEN
DBG('#'+mname[segmarker]) ELSE DBGw(hexword(segmarker)); }
    IF (marker<>0) THEN IF (segmarker<>marker) THEN exit;

    CASE segmarker OF
    mSOF0..mSOF3,mSOF5..mSOF11,mSOF13..mSOF15:
      BEGIN
{DBG(mname[segmarker]);}
        stream^.read(seglength,2);
        swap16(seglength);
        dec(seglength,2);
        stream^.read(SOF.P,1);
        stream^.read(SOF.Y,2);
        stream^.read(SOF.X,2);
        stream^.read(SOF.Nf,1);
        dec(seglength,6);
        FOR i:=1 TO SOF.Nf DO
          BEGIN
            stream^.read(SOF.Ci[i],1);
            stream^.read(SOF.Hi_Vi[i],1);
            stream^.read(SOF.Tqi[i],1);
            dec(seglength,3)
          END;
{DBG(seglength);}
        stream^.seek(stream^.getpos+seglength);
        swap16(SOF.Y);
        swap16(SOF.X);
        IF (segmarker>=mSOF0) AND (segmarker<=mSOF2) THEN
          BEGIN
            img:=createimagewh(SOF.X,SOF.Y);
            LoadImageJPG:=0;
            SOFtype:=segmarker;
          END
        ELSE
          BEGIN
            end_of_scan:=TRUE;
            end_of_image:=TRUE;
          END;
{DBG('  Nf',SOF.Nf);
FOR i:=1 TO SOF.Nf DO
  BEGIN
    DBG('  #idx',i);
    DBG('  Ci',SOF.Ci[i]);
    DBG('  Hi',hi4(SOF.Hi_Vi[i]));
    DBG('  Vi',lo4(SOF.Hi_Vi[i]));
  END;
DBG('  Y',SOF.y);
DBG('  X',SOF.x); }
      END;
    mDHT: {FFC4}
      BEGIN
        stream^.read(seglength,2);
        swap16(seglength);
        dec(seglength,2);
        WHILE (seglength>0) DO
          BEGIN
            stream^.read(DHT.Tc_Th,1);
            stream^.read(DHT.Li,16);
            dec(seglength,17);
            tc:=hi4(DHT.Tc_Th);
            th:=lo4(DHT.Tc_Th);
{DBG(tc);
DBG(th);}
            k:=0;
            FOR i:=1 TO 16 DO
              BEGIN
                hufftable^[tc,th].bits[i]:=DHT.Li[i];
                FOR j:=1 TO DHT.Li[i] DO
                  BEGIN
                    hufftable^[tc,th].huffval[k]:=readstream(1);
                    dec(seglength);
                    inc(k);
                  END;
              END;
{DBG(k);}
            generate_size_table(tc,th);
            generate_code_table(tc,th);
            decoder_tables(tc,th);
          END;
        stream^.seek(stream^.getpos+seglength);
      END;
    mSOI: {FFD8}
      BEGIN
      END;
    mEOI: {FFD9}
      BEGIN
        end_of_scan:=TRUE;
        end_of_image:=TRUE;
      END;
    mSOS: {FFDA}
      BEGIN
        stream^.read(seglength,2);
        swap16(seglength);
        dec(seglength,2);
        stream^.read(SOS.Ns,1);
        dec(seglength);
        FOR i:=1 TO SOS.Ns DO
          BEGIN
            stream^.read(SOS.Csj[i],1);
            stream^.read(SOS.Tdj_Taj[i],1);
{DBG('['+long2str(i)+']',SOS.Tdj_Taj[i]);
DBG(SOS.Csj[i]);}
            dec(seglength,2);
            IF (SOS.Csj[i]>SOF.Nf) THEN SOS.Csj[i]:=1;
          END;
        stream^.read(SOS.Ss,1);
        stream^.read(SOS.Se,1);
        stream^.read(SOS.Ah_Al,1);
        dec(seglength,3);
        stream^.seek(stream^.getpos+seglength);
{DBG('  Ns',SOS.Ns);
DBG('  Ss',SOS.Ss);
DBG('  Se',SOS.Se);
DBG('  Al',lo4(SOS.Ah_Al));
DBG('  Ah',hi4(SOS.Ah_Al));
DBG('============'); }
      END;
    mDQT: {FFDB}
      BEGIN
        stream^.read(seglength,2);
        swap16(seglength);
        dec(seglength,2);
        WHILE (seglength>0) DO
          BEGIN
            stream^.read(DQT.Pq_Tq,1);
{DBG(DQT.Pq_Tq);}
            dec(seglength);
            FOR i:=0 TO 63 DO
              BEGIN
                DQT.Qk[i]:=0;
                CASE (hi4(DQT.Pq_Tq)) OF
                  0:BEGIN
                      stream^.read(DQT.Qk[i],1);
                      dec(seglength,1);
                    END;
                  1:BEGIN
                      stream^.read(DQT.Qk[i],2);
                      dec(seglength,2);
                    END;
                END;
                Qk[lo4(DQT.Pq_Tq)][i]:=DQT.Qk[i];
              END;
          END;
        stream^.seek(stream^.getpos+seglength);
      END;
    mDRI: {FFDD}
      BEGIN
        stream^.read(seglength,2);
        swap16(seglength);
        dec(seglength,2);
        restart_interval:=0;
        stream^.read(restart_interval,2);
        swap16(restart_interval);
        dec(seglength,2);
        stream^.seek(stream^.getpos+seglength);
      END;
    mAPP0..mAPP15: {FFE0..FFEF}
      BEGIN
        stream^.read(seglength,2);
        swap16(seglength);
        dec(seglength,2);
        stream^.seek(stream^.getpos+seglength);
      END;
    mCOM: {FFFE}
      BEGIN
        stream^.read(seglength,2);
        swap16(seglength);
        dec(seglength,2);
        stream^.seek(stream^.getpos+seglength);
      END;
    END;
  END;

  FUNCTION getcompidx(comp:longint):longint;
  VAR n:longint;
  BEGIN
    n:=0;
    REPEAT
      inc(n);
    UNTIL (n>SOF.Nf) OR (SOF.Ci[n]=comp);
    IF (n>SOF.Nf) THEN n:=1;
    getcompidx:=n;
  END;

  PROCEDURE decode_MCU_SOF0;
  VAR i,j,v,h,vi,hi:longint;
  BEGIN
    FOR i:=1 TO SOS.Ns DO
      BEGIN
        j:=getcompidx(SOS.Csj[i]);
        vi:=lo4(SOF.Hi_Vi[j]);
        hi:=hi4(SOF.Hi_Vi[j]);
        FOR v:=0 TO vi-1 DO
          BEGIN
            FOR h:=0 TO hi-1 DO
              BEGIN
                decode_coefficients_SOF0(i,j,v,h);
                IF end_of_scan THEN break;
              END;
            IF end_of_scan THEN break;
          END;
        IF end_of_scan THEN break;
      END;
    draw;
  END;

  PROCEDURE decode_MCU_SOF2;
  VAR i,j,v,h,vi,hi:longint;
  BEGIN
    FOR i:=1 TO SOS.Ns DO
      BEGIN
        j:=getcompidx(SOS.Csj[i]);
        vi:=lo4(SOF.Hi_Vi[j]);
        hi:=hi4(SOF.Hi_Vi[j]);
        IF (SOS.Ss=0) THEN
          BEGIN
            FOR v:=0 TO vi-1 DO
              BEGIN
                FOR h:=0 TO hi-1 DO
                  BEGIN
                    coeffbufidx[j]:=(coeffY[j]+v)*coeffbufW[j]+coeffX[j]+h;
                    decode_coefficients_SOF2(i,j);
                    IF end_of_scan THEN break;
                  END;
                IF end_of_scan THEN break;
              END;
{drawcoeffbuf;}
            inc(coeffX[j],hi);
            IF (coeffX[j]>=coeffbufXd[j]) THEN
              BEGIN
                coeffX[j]:=0;
                inc(coeffY[j],vi);
                IF (coeffY[j]>=coeffbufYd[j]) THEN end_of_scan:=TRUE;
              END;
            IF end_of_scan THEN break;
          END
        ELSE
          BEGIN
            coeffbufidx[j]:=coeffY[j]*coeffbufW[j]+coeffX[j];
            decode_coefficients_SOF2(i,j);
            inc(coeffX[j]);
            IF (coeffX[j]>=coeffbufXd[j]) THEN
              BEGIN
                coeffX[j]:=0;
                inc(coeffY[j]);
                IF (coeffY[j]>=coeffbufYd[j]) THEN end_of_scan:=TRUE;
              END;
          END;
      END;
  END;

  PROCEDURE decode_restart_interval;
  VAR marker:word;
      c:longint;
  BEGIN
    cnt_nb:=0;
    FOR c:=1 TO maxcomp DO pred[c]:=0;
    end_of_scan:=FALSE;
    REPEAT
      IF (restart_interval=0) THEN
        BEGIN
          CASE SOFtype OF
            mSOF0:decode_MCU_SOF0;
            mSOF1:decode_MCU_SOF0;
            mSOF2:decode_MCU_SOF2;
          END;
        END
      ELSE
        BEGIN
          FOR c:=1 TO restart_interval DO
            BEGIN
        {      decode_MCU; }
              CASE SOFtype OF
                mSOF0:decode_MCU_SOF0;
                mSOF1:decode_MCU_SOF0;
                mSOF2:decode_MCU_SOF2;
              END;
              IF end_of_scan THEN break;
            END;
          end_of_scan:=TRUE;
        END;
    UNTIL end_of_scan;
{drawcoeffbuf;
putimage(0,0,img);
readkey;}
    marker:=interpret_markers(mDNL);
    IF (marker<>mDNL) THEN stream^.seek(stream^.getpos-2);
  END;

  PROCEDURE decode_scan;
  VAR marker:word;
      c:longint;
  BEGIN
    end_of_scan:=FALSE;
    FOR c:=1 TO maxcomp DO
      BEGIN
        coeffbufidx[c]:=0;
        coeffeobrun[c]:=0;
        coeffX[c]:=0;
        coeffY[c]:=0;
      END;
    REPEAT
      decode_restart_interval;
{DBG('***eos');}
{      savepos:=stream^.getpos; }
      marker:=interpret_markers($FFFF);
      IF (marker>=mRST0) AND (marker<=mRST7) THEN
        BEGIN
          end_of_scan:=FALSE;
{DBG('restart'); }
        END
      ELSE
        BEGIN
          stream^.seek(stream^.getpos-2);
        END;
    UNTIL end_of_scan OR end_of_image;
{    drawcoeffbuf; }
  END;

  PROCEDURE decode_frame;
  VAR marker:word;
      c,h,v,v1,h1:longint;
  BEGIN
    IF (SOFtype=mSOF2) THEN
      BEGIN
        v1:=lo4(SOF.Hi_Vi[1]);
        h1:=hi4(SOF.Hi_Vi[1]);
        FOR c:=1 TO SOF.Nf DO
          BEGIN
            v:=lo4(SOF.Hi_Vi[c]);
            h:=hi4(SOF.Hi_Vi[c]);
            coeffbufW[c]:=((SOF.X+15) AND $FFFF) DIV 8;
            coeffbufH[c]:=((SOF.Y+15) AND $FFFF) DIV 8;
            coeffbufXd[c]:=(SOF.X+(h1 DIV h)*8-1) DIV (8*(h1 DIV h));
            coeffbufYd[c]:=(SOF.Y+(v1 DIV v)*8-1) DIV (8*(v1 DIV v));
{DBG(coeffbufW[c]);
DBG(coeffbufH[c]);
DBG(SOF.X);
DBGw(SOF.Y);}
            getmem(coeffbuf[c],coeffbufW[c]*coeffbufH[c]*sizeof(Tcoeffbuf));
            fillchar(coeffbuf[c]^,coeffbufW[c]*coeffbufH[c]*sizeof(Tcoeffbuf),0);
{DBG(coeffbufW[c]*coeffbufH[c]*sizeof(Tcoeffbuf));}
          END;
      END;
    REPEAT
      REPEAT
        marker:=interpret_markers(0);
      UNTIL (marker=mSOS) OR end_of_image;
      decode_scan;
      marker:=interpret_markers(mEOI);
      IF (marker<>mEOI) THEN stream^.seek(stream^.getpos-2);
    UNTIL (marker=mEOI) OR end_of_image;
    IF (SOFtype=mSOF2) THEN
      BEGIN
        drawcoeffbuf;
        FOR c:=1 TO SOF.Nf DO
          BEGIN
            freemem(coeffbuf[c],coeffbufW[c]*coeffbufH[c]*sizeof(Tcoeffbuf));
          END;
      END;
{DBG('%EXIT decode_frame');}
  END;

  PROCEDURE decode_image;
  VAR marker:word;
      u,v,x,y:longint;
  BEGIN
    new(hufftable);
    FOR v:=0 TO 7 DO
      FOR u:=0 TO 7 DO
        costab[v,u]:=trunc(cos((2*v+1)*u*pi/16)*cx[u]*0.5*256{fixptmul});
    end_of_image:=FALSE;
    restart_interval:=0;
    SOFtype:=0;

    stream^.read(marker,2);
    swap16(marker);
    IF (marker=mSOI) THEN
      BEGIN
        REPEAT
          marker:=interpret_markers(0);
        UNTIL (SOFtype<>0) OR end_of_image;
        IF (SOFtype<>0) THEN decode_frame;
    {    IF (SOFtype=mSOF2) THEN decode_frame; }
      END;
{DBG('%EXIT decode_image');}
    dispose(hufftable);
  END;

{===============================================================}

VAR startpos:longint;

BEGIN
{  DBG('%MEMAVAIL',memavail); }
  LoadImageJPG:=-1;
  IF (nr<>1) THEN exit;
  startpos:=stream^.getpos;
  decode_image;
  stream^.seek(startpos);
{  DBG('%MEMAVAIL',memavail); }
END;

{========================== LoadImagePCX ==================================}

FUNCTION LoadImagePCX(stream:pstream;var img:pimage;nr:longint):longint;
TYPE TRGB=RECORD
       r,g,b:byte;
     END;
     TPCXheader=RECORD
       Manufacturer:byte;
       Version:byte;
       Encoding:byte;
       BitsPerPixel:byte;
       Window:array[1..4] of smallint;
       HDpi:smallint;
       VDpi:smallint;
       Colormap:array[0..15] of TRGB;
       Reserved:byte;
       NPlanes:byte;
       BytesPerLine:smallint;
       PaletteInfo:smallint;
       HscreenSize:smallint;
       VscreenSize:smallint;
       Filler:array[1..54] of byte;
     END;

VAR PCXhd:TPCXheader;
    linesize:longint;
    xd,yd,count:longint;
    linebuf,imgypos:pointer;
    dst:^byte;
    x,y,z1,z2:longint;
    b1,b2,colordepth:byte;
    palette:array[0..255] of longint;
    curpos,startpos:longint;
    rgb:trgb;
    i:longint;
BEGIN
  LoadImagePCX:=-1;
  IF (nr<>1) THEN exit;
  startpos:=stream^.getpos;
  stream^.Read(PCXhd,sizeof(PCXhd));
  xd:=PCXhd.Window[3]-PCXhd.Window[1]+1;
  yd:=PCXhd.Window[4]-PCXhd.Window[2]+1;
  linesize:=PCXhd.NPlanes*PCXhd.BytesPerLine;
{IF yd>768 then exit;
DBG(xd);
DBG(yd);
DBG(PCXhd.NPlanes);
DBG(PCXhd.BytesPerLine);
DBG(PCXhd.PaletteInfo);}
  colordepth:=PCXhd.BitsPerPixel*PCXhd.NPlanes;
  CASE PCXhd.PaletteInfo OF
  0,1:CASE colordepth OF
        4:BEGIN
            FOR i:=0 TO 15 DO
              WITH PCXhd.colormap[i] DO
                palette[i]:=rgbcolorRGB(r,g,b);
          END;
        8:BEGIN
            curpos:=stream^.getpos;
            stream^.seek(stream^.getsize-769);
            i:=0;
            stream^.read(i,1);
{DBG(i);}
            IF (i=12) THEN
            FOR i:=0 TO 255 DO
              BEGIN
                stream^.read(rgb,3);
                WITH rgb DO
                  palette[i]:=rgbcolorRGB(r,g,b);
              END;
            stream^.seek(curpos);
          END;
      END;
    2:BEGIN
        FOR i:=0 TO 255 DO
          palette[i]:=rgbcolorRGB(i,i,i);
      END;
  END;
  IF (PCXhd.Encoding=1) THEN
    BEGIN
      img:=CreateImageWH(xd,yd);
      imgypos:=img^.pixeldata;
      getmem(linebuf,linesize+4);

      FOR y:=0 TO yd-1 DO
        BEGIN
          ProgressMonitor(y,yd-1);
          dst:=linebuf;
          count:=0;
          REPEAT
            stream^.read(b1,1);
            IF (b1 AND $C0=$C0) THEN
              BEGIN
                b1:=b1 AND $3F;
                stream^.read(b2,1);
                fillchar(dst^,b1,b2);
                inc(dst,b1);
                inc(count,b1);
              END
            ELSE
              BEGIN
                dst^:=b1;
                inc(dst);
                inc(count);
              END;
          UNTIL (count>=linesize);
          CASE colordepth OF
            1:BEGIN
                ASM
                  MOV EDX,bytperpix
                  MOV ESI,linebuf
                  MOV EDI,imgypos
                  MOV ECX,xd
                @loop1:
                  LODSB
                  SHL EAX,24
                {  OR EAX,1 }
                  XOR EAX,0FF000001h
                  MOV EBX,EAX
                @loop2:
                  ROL EBX,1
                  MOV EAX,EBX
                  AND EAX,1
                {  MOV EAX,[palette+EAX*4] }
                  DEC EAX
                  PUSH EDX
                @loop3:
                  STOSB
                  SHR EAX,8
                  DEC EDX
                  JNZ @loop3
                  POP EDX
                  DEC ECX
                  JZ @eol
                  TEST EBX,00000100h
                  JZ @loop2
                  JMP @loop1
                @eol:
                END;
              END;
            4:BEGIN
                FOR x:=0 TO xd-1 DO
                  BEGIN
                    b1:=0;
                    FOR z2:=0 TO 3 DO
                      b1:=b1 OR (((byte((linebuf+z2*PCXhd.BytesperLine+(x SHR 3))^) SHR (NOT x AND 7)) AND 1) SHL z2);
                    move(palette[b1],(imgypos+x*bytperpix)^,bytperpix);
                  END;
              END;
            8:BEGIN
                ASM
                  MOV EDX,bytperpix
                  MOV ESI,linebuf
                  MOV EDI,imgypos
                  MOV ECX,xd
                @loop1:
                  LODSB
                  SHL EAX,2
                  AND EAX,3FCh
                  MOV EAX,[palette+EAX]
                  PUSH EDX
               @loop3:
                  STOSB
                  SHR EAX,8
                  DEC EDX
                  JNZ @loop3
                  POP EDX

                  DEC ECX
                  JNZ @loop1
                END;
              END;
           24:BEGIN
                ASM
                  MOV ESI,linebuf
                  MOV EDI,imgypos
                  MOV ECX,xd
                @loop:
                  MOV EBX,xd
                  MOV AL,[ESI]
                  SHL EAX,8
                  MOV AL,[ESI+EBX]
                  SHL EAX,8
                  MOV AL,[ESI+EBX*2]
                  PUSH EAX
                  CALL rgbcolor
                  MOV EBX,bytperpix
                @loop2:
                  STOSB
                  SHR EAX,8
                  DEC EBX
                  JNZ @loop2
                  INC ESI
                  DEC ECX
                  JNZ @loop
                END;
              END;
          END;
          inc(imgypos,img^.bytesperline);
        END;
      freemem(linebuf,linesize+4);
      LoadImagePCX:=0;
    END;
  stream^.seek(startpos);
END;

{========================== LoadImagePNG ==================================}

FUNCTION LoadImagePNG(stream:pstream;var img:pimage;nr:longint):longint;

{-------------------------- INFLATE.C -------------------------------------}

{
  inflate.c -- Not copyrighted 1992 by Mark Adler
               version c10p1, 10 January 1993
  Adapted for booting Linux by Hannu Savolainen 1993
  based on gzip-1.0.3

  Freepascal-Conversion and Adaption for PNG-Loader
  by Michael Knapp, Dec 21st, 1999

}

TYPE
  int=longint;
  uch=byte;
  ulg=dword;
  unsigned=dword;
  ush=word;

  pint=^int;
  puch=^uch;
  puld=^ulg;
  punsigned=^unsigned;
  push=^ush;

  plongint=^longint;

  pphuft=^phuft;
  phuft=^huft;
  huft=RECORD
    e:uch;           { number of extra bits or operation }
    b:uch;           { number of bits in this code or subcode }
    v:RECORD
        CASE smallint OF
        0:(n:ush);   { literal, length base, or distance base }
        1:(t:phuft)  { pointer to next level of table }
        END;
  END;

TYPE pbyte=^byte;

     tfourcc=array[0..3] of char;
     TPNGsig=array[0..7] of byte;

     TPNGchunk=RECORD
       size:longint;
       name:tfourcc;
     END;

     IHDR_t=RECORD
       width:longint;
       height:longint;
       bitdepth:byte;
       colortype:byte;
       compressiontype:byte;
       filtertype:byte;
       interlacetype:byte;
     END;

     PLTE_t=array[0..255,0..2] of byte;

CONST
  WSIZE=$8000;

TYPE
  Window=array[0..WSIZE-1] of byte;
  pWindow=^Window;

CONST
  border:array[0..18] of unsigned= { Order of the bit length code lengths }
    (16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15);
  cplens:array[0..30] of ush=      { Copy lengths for literal codes 257..285 }
    (3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
     35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0);
  cplext:array[0..30] of ush=      { Extra bits for literal codes 257..285 }
    (0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
     3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 99, 99);
  cpdist:array[0..29] of ush=      { Copy offsets for distance codes 0..29 }
    (1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193,
     257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145,
     8193, 12289, 16385, 24577);
  cpdext:array[0..29] of ush=      { Extra bits for distance codes }
    (0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6,
     7, 7, 8, 8, 9, 9, 10, 10, 11, 11,
     12, 12, 13, 13);

  mask_bits:array[0..16] of ush=
      ($0000,
       $0001, $0003, $0007, $000f, $001f, $003f, $007f, $00ff,
       $01ff, $03ff, $07ff, $0fff, $1fff, $3fff, $7fff, $ffff);


  lbits:int=9; { bits in base literal/length lookup table }
  dbits:int=6; { bits in base distance lookup table }

  { If BMAX needs to be larger than 16, then h and x[] should be ulg. }
  BMAX=16;     { maximum bit length of any code (16 for explode) }
  N_MAX=288;   { maximum number of codes in any set }


  FUNCTION cmp(f1,f2:tfourcc):boolean;
  BEGIN
    cmp:=((f1[0]=f2[0]) AND (f1[1]=f2[1]) AND (f1[2]=f2[2]) AND (f1[3]=f2[3]));
  END;

VAR
  hufts:unsigned; { track memory usage }

  FUNCTION huft_build(b:punsigned; { code lengths in bits (all assumed <= BMAX) }
                      n:unsigned;  { number of codes (assumed <= N_MAX) }
                      s:unsigned;  { number of simple-valued codes (0..s-1) }
                      d:push;      { list of base values for non-simple codes }
                      e:push;      { list of extra bits for non-simple codes }
                      t:pphuft;    { result: starting table }
                      m:pint       { maximum lookup bits, returns actual }
                     ):int;
  { Given a list of code lengths and a maximum table size, make a set of
    tables to decode that set of codes.  Return zero on success, one if
    the given code set is incomplete (the tables are still built in this
    case), two if the input is invalid (all zero length codes or an
    oversubscribed set of lengths), and three if not enough memory. }
  VAR
    a:unsigned;                      { counter for codes of length k }
    c:array[0..BMAX] of unsigned;    { bit length count table }
    f:unsigned;                      { i repeats in table every f entries }
    g:int;                           { maximum code length }
    h:int;                           { table level }
    i:unsigned;                      { counter, current code }
    j:unsigned;                      { counter }
    k:int;                           { number of bits in current code }
    l:int;                           { bits per table (returned in m) }
    p:punsigned;                     { pointer into c[], b[], or v[] }
    q:phuft;                         { points to current table }
    r:huft;                          { table entry for structure assignment }
    u:array[0..BMAX-1] of phuft;     { table stack }
    v:array[0..N_MAX-1] of unsigned; { values in order of bit length }
    w:int;                           { bits before this table == (l * h) }
    x:array[0..BMAX] of unsigned;    { bit offsets, then code stack }
    xp:punsigned;                    { pointer into x }
    y:int;                           { number of dummy codes added }
    z:unsigned;                      { number of entries in current table }
  BEGIN
    { Generate counts for each bit length }
    fillchar(c,sizeof(c),0);
    p:=b;
    i:=n;
    REPEAT
      inc(c[p^]);
      inc(p);
      dec(i);  { assume all entries <= BMAX }
    UNTIL (i=0);
    IF (c[0]=n) THEN { null input--all zero length codes }
      BEGIN
        t^:=nil;
        m^:=0;
        huft_build:=0;
        exit;
      END;
    { Find minimum and maximum length, bound *m by those }
    l:=m^;
    FOR j:=1 TO BMAX DO
      IF (c[j]<>0) THEN break;
    k:=j; { minimum code length }
    IF (unsigned(l)<j) THEN l:=j;
    FOR i:=BMAX DOWNTO 1 DO
      IF (c[i]<>0) THEN break;
    g:=i; { maximum code length }
    IF (unsigned(l)>i) THEN l:=i;
    m^:=l;
    { Adjust last length count to fill out codes, if needed }
    y:=1 SHL j;
    WHILE (j<i) DO
      BEGIN
        dec(y,c[j]);
        IF (y<0) THEN
          BEGIN
            huft_build:=2; { bad input: more codes than bits }
            exit;
          END;
        inc(j);
        y:=y SHL 1;
      END;
    dec(y,int(c[i]));
    IF (y<0) THEN
      BEGIN
        huft_build:=2; { bad input: more codes than bits }
        exit;
      END;
    inc(c[i],y);
    { Generate starting offsets into the value table for each length }
    x[1]:=0;
    j:=0;
    p:=c;inc(p);
    xp:=x;inc(xp,2);
    dec(i);
    WHILE (i<>0) DO { note that i == g from above }
      BEGIN
        inc(j,p^);
        inc(p);
        xp^:=j;
        inc(xp);
        dec(i);
      END;
    { Make a table of values in order of bit lengths }
    p:=b;
    i:=0;
    REPEAT
      j:=p^;
      inc(p);
      IF (j<>0) THEN
        BEGIN
         v[x[j]]:=i;
         inc(x[j]);
        END;
      inc(i);
    UNTIL (i>=n);
    { Generate the Huffman codes and for each, make the table entries }
    x[0]:=0;    { first Huffman code is zero }
    i:=0;
    p:=v;       { grab values in bit order }
    h:=-1;      { no tables yet--level -1 }
    w:=-l;      { bits decoded == (l * h) }
    u[0]:=nil;  { just to keep compilers happy }
    q:=nil;     { ditto }
    z:=0;       { ditto }
    { go through the bit lengths (k already is bits in shortest code) }
    WHILE (k<=g) DO
      BEGIN
        a:=c[k];
        WHILE (a<>0) DO
          BEGIN
            dec(a);
            { here i is the Huffman code of length k bits for value *p }
            { make tables up to required level }
            WHILE (k>w+l) DO
              BEGIN
                inc(h);
                inc(w,l); { previous table always l bits }
                { compute minimum size table less than or equal to l bits }
                z:=g-w;
                IF (z>unsigned(l)) THEN z:=l; { upper limit on table size }
                j:=k-w; { try a k-w bit table }
                f:=1 SHL j;
                IF (f>a+1) THEN
                  BEGIN
                    dec(f,a+1); { deduct codes from patterns left }
                    xp:=c;inc(xp,k);
                    inc(j);
                    WHILE (j<z) DO { try smaller tables up to z bits }
                      BEGIN
                        f:=f SHL 1;
                        inc(xp);
                        IF (f<=xp^) THEN break; { enough codes to use up j bits }
                        dec(f,xp^); { else deduct codes from patterns }
                        inc(j);
                      END;
                  END;
                z:=1 SHL j; { table entries for j-bit table }
                { allocate and link in new table }
                getmem(q,4+(z+1)*sizeof(huft));
                plongint(q)^:=4+(z+1)*sizeof(huft);
{DBG(plongint(p)^);}
                inc(pointer(q),4);
                inc(hufts,z+1); { track memory usage }
                t^:=q;inc(t^);  { link to list for huft_free() }
                t:=addr(q^.v.t);
                t^:=nil;
                inc(q);
                u[h]:=q; { table starts after link }
                { connect to last table, if there is one }
                IF (h<>0) THEN
                  BEGIN
                    x[h]:=i;             { save pattern for backing up }
                    r.b:=uch(l);         { bits to dump before this table }
                    r.e:=uch(16+j);      { bits in this table }
                    r.v.t:=q;            { pointer to this table }
                    j:=i SHR (w-l);      { (get around Turbo C bug) }
                    u[h-1][j]:=r;        { connect to last table }
                  END;
              END;
            { set up table entry in r }
            r.b:=uch(k-w);
            IF (dword(p)>=dword(@(v[n]))) THEN
              BEGIN
                r.e:=99; { out of values--invalid code }
              END
            ELSE IF (p^<s) THEN
              BEGIN
                IF (p^<256) THEN r.e:=16 ELSE r.e:=15; { 256 is end-of-block code }
                r.v.n:=p^; { simple code is just the value }
                inc(p);
              END
            ELSE
              BEGIN
                r.e:=uch(e[p^-s]); { non-simple--look up in lists }
                r.v.n:=d[p^-s];
                inc(p);
              END;
            { fill code-like entries with r }
            f:=1 SHL (k-w);
            j:=i SHR w;
            WHILE (j<z) DO
              BEGIN
                q[j]:=r;
                inc(j,f);
              END;
            { backwards increment the k-bit code i }
            j:=1 SHL (k-1);
            WHILE ((i AND j)<>0) DO
              BEGIN
                i:=i XOR j;
                j:=j SHR 1;
              END;
            i:=i XOR j;
            { backup over finished tables }
            WHILE ((i AND ((1 SHL w) - 1))<>x[h]) DO
              BEGIN
                dec(h);
                dec(w,l);
              END;
          END;
        dec(a);
        inc(k);
      END;
    { Return true (1) if we were given an incomplete table }
    IF ((y<>0) AND (g<>1)) THEN huft_build:=1 ELSE huft_build:=0;
  END;

  FUNCTION huft_free(t:phuft):int;
  { Free the malloc'ed tables built by huft_build(), which makes a linked
    list of the tables it made, with the links in a dummy first entry of
    each table. }
  VAR p,q:phuft;
  BEGIN
  { Go through linked list, freeing from the malloced (t[-1]) address. }
    p:=t;
    WHILE (p<>nil) DO
      BEGIN
        dec(p);
        q:=p^.v.t;
        dec(pointer(p),4);
{DBG(plongint(p)^);}
        freemem(p,plongint(p)^);
        p:=q;
      END;
    huft_free:=0;
  END;

VAR
  slide:pWindow;
  IDATcount:longint;
  bb:ulg;      { bit buffer }
  bk:unsigned; { bits in bit buffer }
  wp:longint;    { current position within slide }

  FUNCTION NEXTBYTE:uch;
  VAR b:byte;
      PNGchunk:TPNGchunk;
      PNGchunkCRC:longint;
      curpos:longint;
  BEGIN
{DBGns;
DBG(IDATcount);
IF (IDATcount<10) THEN DBGw(IDATcount);}
    IF (IDATcount=0) THEN
      BEGIN
        curpos:=stream^.getpos;
        stream^.read(PNGchunkCRC,4);
        stream^.read(PNGchunk,sizeof(PNGchunk));
        swap32(PNGchunk.size);
        IF cmp(PNGchunk.name,'IDAT') THEN
          BEGIN
            IDATcount:=PNGchunk.size;
          END
        ELSE
          BEGIN
            stream^.seek(curpos);
          END;
      END;
    IF (IDATcount>0) THEN
      BEGIN
        stream^.read(b,1);
        NEXTBYTE:=b;
        dec(IDATcount);
      END;
  END;

  PROCEDURE NEEDBITS(var b:ulg;var k:unsigned;n:unsigned);
  BEGIN
    WHILE (k<n) DO
      BEGIN
        b:=b OR ulg(NEXTBYTE) SHL k;
        inc(k,8);
      END;
  END;

  PROCEDURE DUMPBITS(var b:ulg;var k:unsigned;n:unsigned);
  BEGIN
    b:=b SHR n;
    dec(k,n);
  END;

  PROCEDURE flush_output(w:longint);forward;

  FUNCTION inflate_codes(tl:phuft; { literal/length and distance decoder tables }
                         td:phuft; { number of bits decoded by tl[] and td[] }
                         bl:int;
                         bd:int
                        ):int;
   { inflate (decompress) the codes in a deflated (compressed) block.
     Return an error code or zero if it all goes ok. }
  VAR
    e:unsigned;     { table entry flag/number of extra bits }
    n,d:unsigned;   { length and index for copy }
    w:longint;      { current window position }
    t:phuft;        { pointer to table entry }
    ml,md:unsigned; { masks for bl and bd bits }
    b:ulg;          { bit buffer }
    k:unsigned;     { number of bits in bit buffer }
  BEGIN
    { make local copies of globals }
    b:=bb;                       { initialize bit buffer }
    k:=bk;
    w:=wp;                       { initialize window position }
    { inflate the coded data }
    ml:=mask_bits[bl];           { precompute masks for speed }
    md:=mask_bits[bd];
    WHILE TRUE DO                { do until end of block }
      BEGIN
        NEEDBITS(b,k,unsigned(bl));
        t:=tl;inc(t,unsigned(b) AND ml);
        e:=t^.e;
        IF (e>16) THEN
          REPEAT
            IF (e=99) THEN
              BEGIN
                inflate_codes:=1;
                exit;
              END;
            DUMPBITS(b,k,t^.b);
            dec(e,16);
            NEEDBITS(b,k,e);
            t:=t^.v.t;inc(t,(unsigned(b) AND mask_bits[e]));
            e:=t^.e;
          UNTIL (e<=16);
        DUMPBITS(b,k,t^.b);
        IF (e=16) THEN { then it's a literal }
          BEGIN
            slide^[w]:=uch(t^.v.n);
            inc(w);
            IF (w=WSIZE) THEN
              BEGIN
                flush_output(w);
                w:=0;
              END;
          END
        ELSE { it's an EOB or a length }
          BEGIN
            { exit if end of block }
            IF (e=15) THEN break;
            { get length of block to copy }
            NEEDBITS(b,k,e);
            n:=t^.v.n+(unsigned(b) AND mask_bits[e]);
            DUMPBITS(b,k,e);
            { decode distance of block to copy }
            NEEDBITS(b,k,unsigned(bd));
            t:=td;inc(t,(unsigned(b) AND md));
            e:=t^.e;
            IF (e>16) THEN
              REPEAT
                IF (e=99) THEN
                  BEGIN
                    inflate_codes:=1;
                    exit;
                  END;
                DUMPBITS(b,k,t^.b);
                dec(e,16);
                NEEDBITS(b,k,e);
                t:=t^.v.t;inc(t,(unsigned(b) AND mask_bits[e]));
                e:=t^.e;
              UNTIL (e<=16);
            DUMPBITS(b,k,t^.b);
            NEEDBITS(b,k,e);
            d:=w-t^.v.n-(unsigned(b) AND mask_bits[e]);
            DUMPBITS(b,k,e);
            { do the copy }
            REPEAT
              d:=d AND (WSIZE-1);
              IF (d>w) THEN e:=WSIZE-d ELSE e:=WSIZE-w;
              IF (e>n) THEN e:=n;
              dec(n,e);
              REPEAT
                slide^[w]:=slide^[d];
                inc(w);
                inc(d);
                dec(e);
              UNTIL (e=0);
              IF (w=WSIZE) THEN
                BEGIN
                  flush_output(w);
                  w:=0;
                END;
            UNTIL (n=0);
          END;
      END;
    { restore the globals from the locals }
    wp:=w; { restore global window pointer }
    bb:=b; { restore global bit buffer }
    bk:=k;
    { done }
    inflate_codes:=0;
  END;

  FUNCTION inflate_stored:int;
  { "decompress" an inflated type 0 (stored) block. }
  VAR
    n:unsigned; { number of bytes in block }
    w:longint;    { current window position }
    b:ulg;      { bit buffer }
    k:unsigned; { number of bits in bit buffer }
  BEGIN
    { make local copies of globals }
    b:=bb; { initialize bit buffer }
    k:=bk;
    w:=wp; { initialize window position }
    { go to byte boundary }
    n:=k AND 7;
    DUMPBITS(b,k,n);
    { get the length and its complement }
    NEEDBITS(b,k,16);
    n:=(unsigned(b) AND $ffff);
    DUMPBITS(b,k,16);
    NEEDBITS(b,k,16);
    IF (n<>unsigned((NOT b) AND $ffff)) THEN
      BEGIN
        inflate_stored:=1;                   { error in compressed data }
        exit;
      END;
    DUMPBITS(b,k,16);
    { read and output the compressed data }
    WHILE (n>0) DO
      BEGIN
        dec(n);
        NEEDBITS(b,k,8);
        slide^[w]:=uch(b);
        inc(w);
        IF (w=WSIZE) THEN
          BEGIN
            flush_output(w);
            w:=0;
          END;
        DUMPBITS(b,k,8);
      END;
    { restore the globals from the locals }
    wp:=w; { restore global window pointer }
    bb:=b; { restore global bit buffer }
    bk:=k;
    inflate_stored:=0;
  END;
  
  FUNCTION inflate_fixed:int;
  { decompress an inflated type 1 (fixed Huffman codes) block.  We should
     either replace this with a custom decoder, or at least precompute the
     Huffman tables. }
  VAR
    i:int;                       { temporary variable }
    tl:phuft;                    { literal/length code table }
    td:phuft;                    { distance code table }
    bl:int;                      { lookup bits for tl }
    bd:int;                      { lookup bits for td }
    l:array[0..287] of unsigned; { length list for huft_build }
  BEGIN
    { set up literal table }
    FOR i:=0   TO 143 DO l[i]:=8;
    FOR i:=144 TO 255 DO l[i]:=9;
    FOR i:=256 TO 279 DO l[i]:=7;
    FOR i:=280 TO 287 DO l[i]:=8; { make a complete, but wrong code set }
    bl:=7;
    i:=huft_build(@l,288,257,@cplens,@cplext,@tl,@bl);
    IF (i<>0) THEN
      BEGIN
        inflate_fixed:=i;
        exit;
      END;
    { set up distance table }
    FOR i:=0 TO 29 DO l[i]:=5; { make an incomplete code set }
    bd:=5;
    i:=huft_build(@l,30,0,@cpdist,@cpdext,@td,@bd);
    IF (i>1) THEN
      BEGIN
        huft_free(tl);
        inflate_fixed:=i;
        exit;
      END;
    { decompress until an end-of-block code }
    IF (inflate_codes(tl,td,bl,bd)<>0) THEN
      BEGIN
        inflate_fixed:=1;
        huft_free(tl);
        huft_free(td);
        exit;
      END;
    { free the decoding tables, return }
    huft_free(tl);
    huft_free(td);
    inflate_fixed:=0;
  END;

  FUNCTION inflate_dynamic:int;
  { decompress an inflated type 2 (dynamic Huffman codes) block. }
  VAR
    i:int;                             { temporary variables }
    j:unsigned;
    l:unsigned;                        { last length }
    m:unsigned;                        { mask for bit lengths table }
    n:unsigned;                        { number of lengths to get }
    tl:phuft;                          { literal/length code table }
    td:phuft;                          { distance code table }
    bl:int;                            { lookup bits for tl }
    bd:int;                            { lookup bits for td }
    nb:unsigned;                       { number of bit length codes }
    nl:unsigned;                       { number of literal/length codes }
    nd:unsigned;                       { number of distance codes }
    ll:array[0..286+30-1] of unsigned; { literal/length and distance code lengths }
    b:ulg;                             { bit buffer }
    k:unsigned;                        { number of bits in bit buffer }
  BEGIN
    { make local bit buffer }
    b:=bb;
    k:=bk;
    { read in table lengths }
    NEEDBITS(b,k,5);
    nl:=257+(unsigned(b) AND $1f);      { number of literal/length codes }
    DUMPBITS(b,k,5);
    NEEDBITS(b,k,5);
    nd:=1+(unsigned(b) AND $1f);        { number of distance codes }
    DUMPBITS(b,k,5);
    NEEDBITS(b,k,4);
    nb:=4+(unsigned(b) AND $f);         { number of bit length codes }
    DUMPBITS(b,k,4);
    IF ((nl>286) OR (nd>30)) THEN
      BEGIN
        inflate_dynamic:=1;
        exit;  { bad lengths }
      END;
    { read in bit-length-code lengths }
    FOR j:=0 TO nb-1 DO
      BEGIN
        NEEDBITS(b,k,3);
        ll[border[j]]:=unsigned(b) AND 7;
        DUMPBITS(b,k,3);
      END;
    FOR j:=nb TO 18 DO
      BEGIN
        ll[border[j]]:=0;
      END;
    { build decoding table for trees--single level, 7 bit lookup }
    bl:=7;
    i:=huft_build(ll,19,19,nil,nil,@tl,@bl);
    IF (i<>0) THEN
      BEGIN
        IF (i=1) THEN huft_free(tl);
        inflate_dynamic:=i;                   { incomplete code set }
        exit;
      END;
    { read in literal and distance code lengths }
    n:=nl+nd;
    m:=mask_bits[bl];
    i:=0;
    l:=0;
    WHILE (unsigned(i)<n) DO
      BEGIN
        NEEDBITS(b,k,unsigned(bl));
        td:=tl;inc(td,(unsigned(b) AND m));
        j:=td^.b;
        DUMPBITS(b,k,j);
        j:=td^.v.n;
        IF (j<16) THEN      { length of code in bits (0..15) }
          BEGIN
            l:=j;
            ll[i]:=j;          { save last length in l }
            inc(i);
          END
        ELSE IF (j=16) THEN { repeat last length 3 to 6 times }
          BEGIN
            NEEDBITS(b,k,2);
            j:=3+(unsigned(b) AND 3);
            DUMPBITS(b,k,2);
            IF (unsigned(i)+j>n) THEN
              BEGIN
                inflate_dynamic:=1;
                exit;
              END;
            WHILE (j<>0) DO
              BEGIN
                dec(j);
                ll[i]:=l;
                inc(i);
              END;
          END
        ELSE IF (j=17) THEN { 3 to 10 zero length codes }
          BEGIN
            NEEDBITS(b,k,3);
            j:=3+(unsigned(b) AND 7);
            DUMPBITS(b,k,3);
            IF (unsigned(i)+j>n) THEN
              BEGIN
                inflate_dynamic:=1;
                exit;
              END;
            WHILE (j<>0) DO
              BEGIN
                dec(j);
                ll[i]:=0;
                inc(i);
              END;
            l:=0;
          END
        ELSE                { j == 18: 11 to 138 zero length codes }
          BEGIN
            NEEDBITS(b,k,7);
            j:=11+(unsigned(b) AND $7f);
            DUMPBITS(b,k,7);
            IF (unsigned(i)+j>n) THEN
              BEGIN
                inflate_dynamic:=1;
                exit;
              END;
            WHILE (j<>0) DO
              BEGIN
                dec(j);
                ll[i]:=0;
                inc(i);
              END;
            l:=0;
          END;
      END;
    { free decoding table for trees }
    huft_free(tl);
    { restore the global bit buffer }
    bb:=b;
    bk:=k;
    { build the decoding tables for literal/length and distance codes }
    bl:=lbits;
    i:=huft_build(ll,nl,257,cplens,cplext,@tl,@bl);
    IF (i<>0) THEN
      BEGIN
        IF (i=1) THEN
          BEGIN
            { error(" incomplete literal tree\n"); }
            huft_free(tl);
          END;
        inflate_dynamic:=i;                   { incomplete code set }
        exit;
      END;
    bd:=dbits;
    i:=huft_build(@(ll[nl]),nd,0,cpdist,cpdext,@td,@bd);
    IF (i<>0) THEN
      BEGIN
        IF (i=1) THEN
          BEGIN
            {error(" incomplete distance tree\n");}
            huft_free(td);
          END;
        huft_free(tl);
        inflate_dynamic:=i;                   { incomplete code set }
        exit;
      END;
    { decompress until an end-of-block code }
    IF (inflate_codes(tl,td,bl,bd)<>0) THEN
      BEGIN
        inflate_dynamic:=1;
        exit;
      END;
    { free the decoding tables, return }
    huft_free(tl);
    huft_free(td);
    inflate_dynamic:=0;
  END;

  FUNCTION inflate_block(e:pint { last block flag }
                        ):int;
  { decompress an inflated block }
  VAR
    t:unsigned;  { block type }
    b:ulg;       { bit buffer }
    k:unsigned;  { number of bits in bit buffer }
  BEGIN
    { make local bit buffer }
    b:=bb;
    k:=bk;
    { read in last block bit }
    NEEDBITS(b,k,1);
    e^:=int(b) AND 1;
    DUMPBITS(b,k,1);
    { read in block type }
    NEEDBITS(b,k,2);
    t:=unsigned(b) AND 3;
    DUMPBITS(b,k,2);
    { restore the global bit buffer }
    bb:=b;
    bk:=k;
    { inflate that block type }
    IF (t=2) THEN
      BEGIN
        inflate_block:=inflate_dynamic;
        exit;
      END;
    if (t=0) THEN
      BEGIN
        inflate_block:=inflate_stored;
        exit;
      END;
    if (t=1) THEN
      BEGIN
        inflate_block:=inflate_fixed;
        exit;
      END;
    inflate_block:=2; { bad block }
  END;

  FUNCTION inflateblock:longint;
  { decompress an inflated entry }
  VAR
    e:int;      { last block flag }
    r:int;      { result code }
    h:unsigned; { maximum struct huft's malloc'ed }
    { initialize window, bit buffer }
  BEGIN
    new(slide);
    wp:=0;
    bk:=0;
    bb:=0;
    { decompress until the last block }
    h:=0;
    REPEAT
      hufts:=0;
      r:=inflate_block(@e);
      IF (r<>0) THEN
        BEGIN
          inflateblock:=r;
          exit;
        END;
      IF (hufts>h) THEN h:=hufts;
    UNTIL (e<>0);
    { flush out slide }
    flush_output(wp);
    { return success }
    dispose(slide);
    inflateblock:=0;
  END;

{--- LoadImagePNG ---}

CONST CPNGsig:TPNGSig=(137,80,78,71,13,10,26,10);
      Adam7_Xstart:array[1..7] of longint=(0,4,0,2,0,1,0);
      Adam7_Ystart:array[1..7] of longint=(0,0,4,0,2,0,1);
      Adam7_Xstep:array[1..7] of longint= (8,8,4,4,2,2,1);
      Adam7_Ystep:array[1..7] of longint= (8,8,8,4,4,2,2);

{      Adam7_Xd:array[1..7] of longint= (8,4,4,2,2,1,1);
      Adam7_Yd:array[1..7] of longint= (8,8,4,4,2,2,1); }

      Adam7_pnum:array[0..7] of longint= (4,5,7,8,11,12,14,15);

VAR PNGsig:TPNGsig;
    PNGchunk:TPNGchunk;
    PNGchunkCRC:longint;
    IHDR:IHDR_t;
    PLTE:PLTE_t;
    PNGbool:boolean;
    i:longint;
    colarray:array[0..2] of word;
    color:longint;
    startpos:longint;

    imageypos:pointer;
    linedata,linedataptr:pbyte;
    linedatasize:longint;
    priorbuf,linebuf:pbyte;
    sizescanline,sizepixel:longint;

    palette:array[0..255] of longint;

    pass{,curscanlinelength}:longint;
    xcount,ycount,xstep,ystep,pcnt,pmax:longint;

  FUNCTION getcurscanlinepixelcount_adam7:longint;
  BEGIN
    getcurscanlinepixelcount_adam7:=(IHDR.width-adam7_Xstart[pass]+adam7_Xstep[pass]-1) DIV adam7_Xstep[pass];
  END;

  FUNCTION getcurscanlinebytecount_adam7:longint;
  VAR i:longint;
  BEGIN
    i:=(IHDR.width-adam7_Xstart[pass]+adam7_Xstep[pass]-1) DIV adam7_Xstep[pass];
    CASE IHDR.colortype OF
    0:getcurscanlinebytecount_adam7:=((i*IHDR.bitdepth*1+7) SHR 3);
    2:getcurscanlinebytecount_adam7:=((i*IHDR.bitdepth*3+7) SHR 3);
    3:getcurscanlinebytecount_adam7:=((i*IHDR.bitdepth*1+7) SHR 3);
    4:getcurscanlinebytecount_adam7:=((i*IHDR.bitdepth*2+7) SHR 3);
    6:getcurscanlinebytecount_adam7:=((i*IHDR.bitdepth*4+7) SHR 3);
    END;
  END;

  PROCEDURE flush_output(w:longint);
  VAR x,xd,b,c,bitbuf,bitsinbuf:longint;
      fltbyt:byte;
      lp,rp,pp,dp:pbyte;
      ca,cb,cc,cp,pa,pb,pc:longint;

    FUNCTION getpixbits(var p:pbyte;n,swp:longint):longint;
    VAR i,b:byte;
    BEGIN
      WHILE (bitsinbuf<n) DO
        BEGIN
          b:=p^;
          CASE swp OF
          1:ASM
              XOR AX,AX
              MOV AH,b
              MOV CX,8
            @loop:
              SHR AX,1
              ROL AL,2
              LOOP @loop
              ROR AL,1
              MOV b,AL
            END;
          2:ASM
              XOR AX,AX
              MOV AH,b
              MOV CX,4
            @loop:
              SHR AX,2
              ROL AL,4
              LOOP @loop
              ROR AL,4
              MOV b,AL
            END;
          4:ASM
              ROR b,4
            END;
          END;
          bitbuf:=bitbuf OR longint(b) SHL bitsinbuf;
          inc(p);
          inc(bitsinbuf,8);
        END;
      getpixbits:=bitbuf AND ((longint(1) SHL n)-1);
      bitbuf:=bitbuf SHR n;
      dec(bitsinbuf,n);
    END;

{  VAR xx,yy:longint;}

  BEGIN
{DBG('flush',w);}
    rp:=pbyte(slide);
    WHILE (w>=linedatasize) DO
      BEGIN
        move(rp^,linedataptr^,linedatasize);
        inc(rp,linedatasize);
        dec(w,linedatasize);

        ProgressMonitor(pcnt,pmax);
        inc(pcnt);

        CASE IHDR.interlacetype OF
        0:BEGIN
            xd:=img^.width;
            linedatasize:=sizescanline+1;
          END;
        1:BEGIN
            xd:=getcurscanlinepixelcount_adam7;
            linedatasize:=getcurscanlinebytecount_adam7+1;
          END;
        END;

        linedataptr:=linedata;
        lp:=linedata;
        dp:=linebuf+sizepixel;
        pp:=priorbuf+sizepixel;
{DBG(fltbyt);}
        fltbyt:=lp^;
        inc(lp);
{DBG('fltbyt',fltbyt);}
        CASE fltbyt OF
        0:BEGIN {none}
            move(lp^,dp^,linedatasize-1);
        {    inc(dp,linedatasize-1);
            inc(lp,linedatasize-1); }
          END;
        1:BEGIN {sub}
            FOR b:=0 TO linedatasize-2 DO
              BEGIN
                dp^:=lp^+(dp-sizepixel)^;
                inc(dp);
                inc(lp);
              END;
          END;
        2:BEGIN {up}
            FOR b:=0 TO linedatasize-2 DO
              BEGIN
                dp^:=lp^+pp^;
                inc(dp);
                inc(pp);
                inc(lp);
              END;
          END;
        3:BEGIN {average}
            FOR b:=0 TO linedatasize-2 DO
              BEGIN
                dp^:=lp^+((dp-sizepixel)^+pp^) SHR 1;
                inc(dp);
                inc(pp);
                inc(lp);
              END;
          END;
        4:BEGIN {paeth}
            FOR b:=0 TO linedatasize-2 DO
              BEGIN
                ca:=(dp-sizepixel)^;
                cb:=pp^;
                cc:=(pp-sizepixel)^;
                cp:=ca+cb-cc;
                pa:=abs(cp-ca);
                pb:=abs(cp-cb);
                pc:=abs(cp-cc);
                IF (pa<=pb) AND (pa<=pc) THEN dp^:=lp^+ca
                                         ELSE IF (pb<=pc) THEN dp^:=lp^+cb
                                                          ELSE dp^:=lp^+cc;
                inc(dp);
                inc(pp);
                inc(lp);
              END;
          END;
        END;
        dp:=linebuf+sizepixel;
        bitbuf:=0;
        bitsinbuf:=0;
        IF (ycount<img^.height) THEN
        CASE IHDR.colortype OF
        0:FOR x:=0 TO xd-1 DO
            BEGIN
              c:=getpixbits(dp,IHDR.bitdepth,IHDR.bitdepth);
              c:=(c SHL (16-IHDR.bitdepth)) SHR 8;
              c:=rgbcolorRGB(c,c,c);
              move(c,(imageypos+x*xstep*bytperpix)^,bytperpix);
              inc(xcount,xstep);
            END;
        2:CASE IHDR.bitdepth OF
          8:FOR x:=0 TO xd-1 DO
              BEGIN
                c:=rgbcolorRGB((dp+0)^,(dp+1)^,(dp+2)^);
                inc(dp,3);
                move(c,(imageypos+x*xstep*bytperpix)^,bytperpix);

              {  FOR yy:=0 TO adam7_yd[pass]-1 DO
                  FOR xx:=0 TO adam7_xd[pass]-1 DO
                    IF (ycount+yy<img^.height) AND (x*xstep+xx<img^.width) THEN
                      move(c,(imageypos+(yy*img^.bytesperline)+(x*xstep+xx)*bytperpix)^,bytperpix); }

                inc(xcount,xstep);
              END;
         16:FOR x:=0 TO xd-1 DO
              BEGIN
                c:=rgbcolorRGB((dp+0)^,(dp+2)^,(dp+4)^);
                inc(dp,6);
                move(c,(imageypos+x*xstep*bytperpix)^,bytperpix);
                inc(xcount,xstep);
              END;
          END;
        3:FOR x:=0 TO xd-1 DO
            BEGIN
              c:=getpixbits(dp,IHDR.bitdepth,IHDR.bitdepth);
              move(palette[c],(imageypos+x*xstep*bytperpix)^,bytperpix);

  {            c:=-1;
              move(c,(imageypos+x*xstep*bytperpix)^,bytperpix); }

          {    FOR yy:=0 TO adam7_yd[pass]-1 DO
                FOR xx:=0 TO adam7_xd[pass]-1 DO
                  IF (ycount+yy<img^.height) AND (x*xstep+xx<img^.width) THEN
                    move(palette[c],(imageypos+(yy*img^.bytesperline)+(x*xstep+xx)*bytperpix)^,bytperpix); }

              inc(xcount,xstep);
            END;
        4:FOR x:=0 TO xd-1 DO
            BEGIN
              c:=rgbcolorRGB((dp+0)^,(dp+0)^,(dp+0)^);
              inc(dp,sizepixel);
              move(c,(imageypos+x*xstep*bytperpix)^,bytperpix);
              inc(xcount,xstep);
            END;
        6:CASE IHDR.bitdepth OF
          8:FOR x:=0 TO xd-1 DO
              BEGIN
                c:=rgbcolorRGB((dp+0)^,(dp+1)^,(dp+2)^);
                inc(dp,4);
                move(c,(imageypos+x*xstep*bytperpix)^,bytperpix);
                inc(xcount,xstep);
              END;
         16:FOR x:=0 TO xd-1 DO
              BEGIN
                c:=rgbcolorRGB((dp+0)^,(dp+2)^,(dp+4)^);
                inc(dp,8);
                move(c,(imageypos+x*xstep*bytperpix)^,bytperpix);
                inc(xcount,xstep);
              END;
          END;
        END;
        inc(imageypos,ystep*img^.bytesperline);
        inc(ycount,ystep);
        move(linebuf^,priorbuf^,sizepixel+linedatasize-1);
{putimage(0,0,img);}
{zoomimage(0,0,img^.width*8-1,img^.height*8-1,img);}
{readln;}
        IF (ycount>=img^.height) THEN
          BEGIN
            CASE IHDR.interlacetype OF
            1:BEGIN {adam7}
                WHILE (ycount>=img^.height) OR (xcount>=img^.width) DO
                  BEGIN
                    inc(pass);
                    xcount:=adam7_Xstart[pass];
                    ycount:=adam7_Ystart[pass];
                    xstep:=adam7_Xstep[pass];
                    ystep:=adam7_Ystep[pass];
                  END;
                linedatasize:=getcurscanlinebytecount_adam7+1;
                imageypos:=img^.pixeldata+ycount*img^.bytesperline+xcount*bytperpix;
              END;
            END;
            fillchar(linebuf^,sizescanline+sizepixel,0);
            fillchar(priorbuf^,sizescanline+sizepixel,0);
          END;
      END;
{DBG('END w',w);}
    move(rp^,linedataptr^,w);
    dec(linedatasize,w);
    inc(linedataptr,w);
  END;

BEGIN
  LoadImagePNG:=-1;
  IF (nr<>1) THEN exit;
  startpos:=stream^.getpos;
  stream^.read(PNGsig,sizeof(PNGsig));
  PNGbool:=TRUE;
  FOR i:=0 TO 7 DO PNGbool:=PNGbool AND (PNGsig[i]=CPNGsig[i]);
  IF PNGbool THEN
    BEGIN
      REPEAT
        stream^.read(PNGchunk,sizeof(PNGchunk));
        swap32(PNGchunk.size);
{DBG(copy(PNGchunk.name,1,4));}
        IF cmp(PNGchunk.name,'IHDR') THEN
          BEGIN
            stream^.read(IHDR,PNGchunk.size);
            swap32(IHDR.width);
            swap32(IHDR.height);
{IHDR.interlacetype:=0;}
            CASE IHDR.colortype OF
            0:sizepixel:=((IHDR.bitdepth*1+7) SHR 3);
            2:sizepixel:=((IHDR.bitdepth*3+7) SHR 3);
            3:sizepixel:=((IHDR.bitdepth*1+7) SHR 3);
            4:sizepixel:=((IHDR.bitdepth*2+7) SHR 3);
            6:sizepixel:=((IHDR.bitdepth*4+7) SHR 3);
            END;
            CASE IHDR.colortype OF
            0:sizescanline:=((IHDR.width*IHDR.bitdepth*1+7) SHR 3);
            2:sizescanline:=((IHDR.width*IHDR.bitdepth*3+7) SHR 3);
            3:sizescanline:=((IHDR.width*IHDR.bitdepth*1+7) SHR 3);
            4:sizescanline:=((IHDR.width*IHDR.bitdepth*2+7) SHR 3);
            6:sizescanline:=((IHDR.width*IHDR.bitdepth*4+7) SHR 3);
            END;
            img:=CreateImageWH(IHDR.width,IHDR.height);
{DBG(IHDR.colortype);
DBG(IHDR.filtertype);
DBG(IHDR.compressiontype);
DBG(IHDR.interlacetype);
DBG(IHDR.width);
DBGw(IHDR.height);}
          END
        ELSE IF cmp(PNGchunk.name,'PLTE') THEN
          BEGIN
            stream^.read(PLTE,PNGchunk.size);
            FOR i:=0 TO 255 DO palette[i]:=rgbcolorRGB(PLTE[i,0],PLTE[i,1],PLTE[i,2]);
          END
        ELSE IF cmp(PNGchunk.name,'IDAT') THEN
          BEGIN
{DBG(pass);}
            stream^.read(i,2);
            IDATcount:=PNGchunk.size-2;
{DBG(sizescanline);
DBG(sizepixel);}
            getmem(linebuf,sizescanline+sizepixel);
            getmem(priorbuf,sizescanline+sizepixel);
            getmem(linedata,sizescanline+1);
            fillchar(linebuf^,sizescanline+sizepixel,0);
            fillchar(priorbuf^,sizescanline+sizepixel,0);
            linedataptr:=linedata;
            pass:=0;
{DBG('+++');
DBG(memavail);}
            CASE IHDR.interlacetype OF
            0:BEGIN { no interlace }
                xcount:=0;
                ycount:=0;
                xstep:=1;
                ystep:=1;
                linedatasize:=sizescanline+1;
                pmax:=img^.height-1;
              END;
            1:BEGIN {adam7}
                REPEAT
                  inc(pass);
                  xcount:=adam7_Xstart[pass];
                  ycount:=adam7_Ystart[pass];
                  xstep:=adam7_Xstep[pass];
                  ystep:=adam7_Ystep[pass];
                UNTIL (ycount<img^.height) AND (xcount<img^.width);
                linedatasize:=getcurscanlinebytecount_adam7+1;
                pmax:=(img^.height SHR 3)*15+adam7_pnum[img^.height AND NOT 7]-1;
              END;
            END;
            imageypos:=img^.pixeldata+ycount*img^.bytesperline+xcount*bytperpix;
{DBG('a');} pcnt:=0;
            CASE IHDR.compressiontype OF
            $00:inflateblock;
            END;
{DBGw('back');}
{DBG('b');}
{DBG(memavail);
DBG('---');}
{DBG(sizescanline);
DBG(sizepixel);}
{DBG('c1');}
            freemem(linebuf,sizescanline+sizepixel);
{DBG('c2');}
            freemem(priorbuf,sizescanline+sizepixel);
{DBG('c3');}
            freemem(linedata,sizescanline+1);
{DBG('c4');}
{DBG('d');}
            stream^.seek(stream^.getpos+IDATcount);
            LoadImagePNG:=0;
{DBG('e');}
          END
        ELSE IF cmp(PNGchunk.name,'IEND') THEN
          BEGIN
            stream^.seek(stream^.getpos+PNGchunk.size);
          END
        ELSE IF cmp(PNGchunk.name,'bKGD') THEN
          BEGIN
            CASE IHDR.colortype OF
            3:BEGIN
                colarray[0]:=0;
                stream^.read(colarray,PNGchunk.size);
                color:=palette[colarray[0]];
                setimageflags(img,img_transparency);
                setimagetransparencycolor(img,color);
 {   bar(600,440,639,479,color); }
              END;
          0,4:BEGIN
                stream^.read(colarray,PNGchunk.size);
                colarray[0]:=colarray[0] SHL (16-IHDR.bitdepth);
                color:=rgbcolorRGB(colarray[0] SHR 8,colarray[0] SHR 8,colarray[0] SHR 8);
                setimageflags(img,img_transparency);
                setimagetransparencycolor(img,color);
 {   bar(600,440,639,479,color); }
              END;
          2,6:BEGIN
                stream^.read(colarray,PNGchunk.size);
                colarray[0]:=colarray[0] SHL (16-IHDR.bitdepth);
                colarray[1]:=colarray[1] SHL (16-IHDR.bitdepth);
                colarray[2]:=colarray[2] SHL (16-IHDR.bitdepth);
                color:=rgbcolorRGB(colarray[0] SHR 8,colarray[1] SHR 8,colarray[2] SHR 8);
                setimageflags(img,img_transparency);
                setimagetransparencycolor(img,color);
{   bar(600,440,639,479,color); }
              END;
            ELSE stream^.seek(stream^.getpos+PNGchunk.size);
            END;
          END
        ELSE IF cmp(PNGchunk.name,'tRNS') THEN
          BEGIN
            CASE IHDR.colortype OF
            0:BEGIN
                stream^.read(colarray,PNGchunk.size);
                colarray[0]:=colarray[0] SHL (16-IHDR.bitdepth);
                color:=rgbcolorRGB(colarray[0] SHR 8,colarray[0] SHR 8,colarray[0] SHR 8);
                setimageflags(img,img_transparency);
                setimagetransparencycolor(img,color);
{    bar(600,440,639,479,color); }
              END;
            2:BEGIN
                stream^.read(colarray,PNGchunk.size);
                colarray[0]:=colarray[0] SHL (16-IHDR.bitdepth);
                colarray[1]:=colarray[1] SHL (16-IHDR.bitdepth);
                colarray[2]:=colarray[2] SHL (16-IHDR.bitdepth);
                color:=rgbcolorRGB(colarray[0] SHR 8,colarray[1] SHR 8,colarray[2] SHR 8);
                setimageflags(img,img_transparency);
                setimagetransparencycolor(img,color);
{   bar(600,440,639,479,color); }
              END;
            ELSE stream^.seek(stream^.getpos+PNGchunk.size);
            END;
          END
        ELSE
          BEGIN
            stream^.seek(stream^.getpos+PNGchunk.size);
          END;
        stream^.read(PNGchunkCRC,4);
      UNTIL cmp(PNGchunk.name,'IEND') OR (stream^.getpos>=stream^.getsize);
    END;
  stream^.seek(startpos);
END;

{========================== LoadImagePxM ==================================}

FUNCTION LoadImagePxM(stream:pstream;var img:pimage;nr:longint):longint;
CONST numchar=1024;
VAR x,y,z,w,h:longint;
    r,g,b,m,c:longint;
    typ:string;
    byt:byte;
    imgptr:pointer;
    charbuf:array[0..numchar-1] of char;
    charidx:word;
    charend:word;
    eofchar:boolean;
    startpos:longint;

  FUNCTION s2l(sl:string):longint;
  VAR l,io:longint;
  BEGIN
    val(sl,l,io);
    s2l:=l;
  END;

  FUNCTION readchar:char;
  VAR io:longint;
  BEGIN
    IF (charidx=numchar) THEN
      BEGIN
        io:=numchar;
        IF (stream^.getpos+numchar>stream^.getsize) THEN io:=(stream^.getsize-stream^.getpos);
        stream^.read(charbuf,io);
        IF (io<numchar) THEN charend:=io;
        charidx:=0;
      END;
    IF (charidx<=charend) THEN
      BEGIN
        readchar:=charbuf[charidx];
        inc(charidx);
      END;
    eofchar:=(charend<=charidx);
  END;

  FUNCTION get:string;
  VAR s:string;
      c:char;
  BEGIN
    s:='';
    REPEAT
      c:=readchar;
      WHILE (c<=#32) AND NOT eofchar DO c:=readchar;
      WHILE (c>#32) AND (c<>'#') AND NOT eofchar DO
        BEGIN
          s:=s+c;
          c:=readchar;
        END;
      IF (c='#') THEN
        WHILE (c>=#32) AND NOT eofchar DO c:=readchar;
    UNTIL (s<>'') OR eofchar;
    get:=s;
  END;

BEGIN
  LoadImagePxM:=-1;
  IF (nr<>1) THEN exit;
  startpos:=stream^.getpos;
  charidx:=numchar;
  charend:=$FFFF;
  eofchar:=FALSE;
  typ:=get;
  w:=s2l(get);
  h:=s2l(get);
  img:=CreateImageWH(w,h);
  imgptr:=img^.pixeldata;
  IF (typ='P1') THEN
    BEGIN
      FOR y:=0 TO h-1 DO
        BEGIN
          ProgressMonitor(y,h-1);
          FOR x:=0 TO w-1 DO
            BEGIN
              c:=((NOT s2l(get)) AND 1)*$00FFFFFF;
              move(c,(imgptr+x*bytperpix)^,bytperpix);
            END;
          inc(imgptr,img^.bytesperline);
        END;
      LoadImagePxM:=0;
    END
  ELSE IF (typ='P2') THEN
    BEGIN
      m:=s2l(get);
      inc(m);
      FOR y:=0 TO h-1 DO
        BEGIN
          ProgressMonitor(y,h-1);
          FOR x:=0 TO w-1 DO
            BEGIN
              c:=s2l(get);
              c:=rgbcolorRGB((c SHL 8) DIV m,(c SHL 8) DIV m,(c SHL 8) DIV m);
              move(c,(imgptr+x*bytperpix)^,bytperpix);
            END;
          inc(imgptr,img^.bytesperline);
        END;
      LoadImagePxM:=0;
    END
  ELSE IF (typ='P3') THEN
    BEGIN
      m:=s2l(get);
      inc(m);
      FOR y:=0 TO h-1 DO
        BEGIN
          ProgressMonitor(y,h-1);
          FOR x:=0 TO w-1 DO
            BEGIN
              r:=s2l(get);
              g:=s2l(get);
              b:=s2l(get);
              c:=rgbcolorRGB((r SHL 8) DIV m,(g SHL 8) DIV m,(b SHL 8) DIV m);
              move(c,(imgptr+x*bytperpix)^,bytperpix);
            END;
          inc(imgptr,img^.bytesperline);
        END;
      LoadImagePxM:=0;
    END
  ELSE IF (typ='P4') THEN
    BEGIN
      FOR y:=0 TO h-1 DO
        BEGIN
          ProgressMonitor(y,h-1);
          x:=0;
          WHILE (x<w) DO
            BEGIN
              byt:=ord(readchar);
              FOR z:=0 TO 7 DO
                BEGIN
                  c:=longint(((NOT byt) SHR 7) AND 1)*$00FFFFFF;
                  move(c,(imgptr+x*bytperpix)^,bytperpix);
                  byt:=byt SHL 1;
                  inc(x);
                END;
            END;
          inc(imgptr,img^.bytesperline);
        END;
      LoadImagePxM:=0;
    END
  ELSE IF (typ='P5') THEN
    BEGIN
      m:=s2l(get);
      inc(m);
      FOR y:=0 TO h-1 DO
        BEGIN
          ProgressMonitor(y,h-1);
          FOR x:=0 TO w-1 DO
            BEGIN
              c:=ord(readchar);
              c:=(c SHL 8) DIV m;
              c:=rgbcolorRGB(c,c,c);
              move(c,(imgptr+x*bytperpix)^,bytperpix);
            END;
          inc(imgptr,img^.bytesperline);
        END;
      LoadImagePxM:=0;
    END
  ELSE IF (typ='P6') THEN
    BEGIN
      m:=s2l(get);
      inc(m);
      FOR y:=0 TO h-1 DO
        BEGIN
          ProgressMonitor(y,h-1);
          FOR x:=0 TO w-1 DO
            BEGIN
              r:=ord(readchar);
              g:=ord(readchar);
              b:=ord(readchar);
              c:=rgbcolorRGB((r SHL 8) DIV m,(g SHL 8) DIV m,(b SHL 8) DIV m);
              move(c,(imgptr+x*bytperpix)^,bytperpix);
            END;
          inc(imgptr,img^.bytesperline);
        END;
      LoadImagePxM:=0;
    END;
  stream^.seek(startpos);
END;

{========================== LoadImageTGA ==================================}

TYPE TTGAheader=RECORD
       IDlength:byte;
       ColorTabFlag:byte;
       Bildtyp:byte;
       ErsteFarbe:word;
       AnzahlFarben:word;
       BitsproFarbe:byte;
       xpos,ypos:word;
       breite,hoehe:word;
       bitspropix:byte;
       BildFlag:byte;
     END;

FUNCTION LoadImageTGA(stream:pstream;var img:pimage;nr:longint):longint;
VAR TGAhd:TTGAheader;
    bytesprofarbe,bytespropix:longint;
    Codiert:boolean;
    x,y,xd,yd:longint;
    imgxd,linesize:longint;
    linebuf,imgypos:pointer;
    palette:array[0..255] of longint;
    startpos:longint;
    color:longint;
    i:longint;

  PROCEDURE DecodeLine(dst:pointer;count:longint);
  VAR buf:longint;
      c1,c2:longint;
  BEGIN
    c1:=count;
    REPEAT
      c2:=0;
      stream^.Read(c2,1);
      IF (c2 AND $80=$80) THEN
        BEGIN
          dec(c2,$7F);
          dec(c1,c2);
          stream^.Read(buf,bytespropix);
          REPEAT
            move(buf,dst^,bytespropix);
            inc(dst,bytespropix);
            dec(c2);
          UNTIL (c2<=0);
        END
      ELSE
        BEGIN
          inc(c2);
          dec(c1,c2);
          stream^.Read(dst^,c2*bytespropix);
          inc(dst,c2*bytespropix);
        END;
    UNTIL (c1<=0);
  END;

BEGIN
  LoadImageTGA:=-1;
  IF (nr<>1) THEN exit;
  startpos:=stream^.getpos;
  stream^.read(TGAhd,sizeof(TGAhd));
  stream^.seek(stream^.getpos+TGAhd.IDlength);
  IF (TGAhd.ColorTabFlag>0) THEN
    BEGIN
      BytesproFarbe:=(TGAhd.BitsproFarbe+7) SHR 3;
      FOR i:=0 TO TGAhd.AnzahlFarben-1 DO
        BEGIN
          stream^.read(color,bytesprofarbe);
          IF (bytesprofarbe=2) THEN
            ASM
              MOV EAX,color
              SHL EAX,6
              SHR AX,3
              SHR AL,3
              SHL EAX,3
              AND EAX,00F8F8F8h
              MOV color,EAX
            END;
          palette[i]:=rgbcolor(color);
        END;
    END;
  codiert:=(TGAhd.Bildtyp AND $08=$08);
  bytespropix:=TGAhd.bitspropix SHR 3;
  xd:=TGAhd.breite;
  yd:=TGAhd.hoehe;
  img:=CreateImageWH(xd,yd);
  imgxd:=img^.bytesperline;
  imgypos:=img^.pixeldata;
  IF (TGAhd.bildflag AND $20=0) THEN
    BEGIN
      inc(imgypos,imgxd*(yd-1));
      imgxd:=-imgxd;
    END;
  linesize:=(xd*bytespropix+3) AND $7FFC;
  getmem(linebuf,linesize+4);
  FOR y:=0 TO yd-1 DO
    BEGIN
      ProgressMonitor(y,yd-1);
      IF codiert THEN DecodeLine(linebuf,xd) ELSE stream^.read(linebuf^,linesize);
      CASE bytespropix OF
      1:ASM
          MOV EDX,xd
          MOV EBX,bytperpix
          MOV ESI,linebuf
          MOV EDI,imgypos
        @loop1:
          LODSB
          SHL EAX,2
          AND EAX,3FCh
          MOV EAX,[palette+EAX]
          MOV ECX,EBX
        @loop2:
          STOSB
          SHR EAX,8
          DEC ECX
          JNZ @loop2
          DEC EDX
          JNZ @loop1
        END;
      2:ASM
          MOV ECX,xd
          MOV ESI,linebuf
          MOV EDI,imgypos
        @loop2:
          LODSW
          SHL EAX,6
          SHR AX,3
          SHR AL,3
          SHL EAX,3
          PUSH EAX
          CALL rgbcolor
          MOV EDX,bytperpix
        @loop1:
          STOSB
          SHR EAX,8
          DEC EDX
          JNZ @loop1
          DEC ECX
          JNZ @loop2
        END;
      3:ASM
          MOV ECX,xd
          MOV ESI,linebuf
          MOV EDI,imgypos
        @loop2:
          LODSD
          DEC ESI
          PUSH EAX
          CALL rgbcolor
          MOV EDX,bytperpix
        @loop1:
          STOSB
          SHR EAX,8
          DEC EDX
          JNZ @loop1
          DEC ECX
          JNZ @loop2
        END;
      4:ASM
          MOV ECX,xd
          MOV ESI,linebuf
          MOV EDI,imgypos
        @loop2:
          LODSD
          PUSH EAX
          CALL rgbcolor
          MOV EDX,bytperpix
        @loop1:
          STOSB
          SHR EAX,8
          DEC EDX
          JNZ @loop1
          DEC ECX
          JNZ @loop2
        END;
      END;
      inc(imgypos,imgxd);
    END;
  freemem(linebuf,linesize+4);
  stream^.seek(startpos);
  LoadImageTGA:=0;
END;

{========================== LoadImageTIF ==================================}

CONST BYTE_ft=1;
      ASCII_ft=2;
      SHORT_ft=3;
      LONG_ft=4;
      RATIONAL_ft=5;
      SBYTE_ft=6;
      UNDEFINED_ft=7;
      SSHORT_ft=8;
      SLONG_ft=9;
      SRATIONAL_ft=10;
      FLOAT_ft=11;
      DOUBLE_ft=12;

TYPE TIFheader_t=RECORD
       endian:word;
       magic:word;
       IFDofs:dword;
     END;

     IFDentry_t=RECORD
       fieldtag:word;
       fieldtype:word;
       numvalues:dword;
       ofsvalues:dword;
     END;

     fieldtypes=BYTE_ft..DOUBLE_ft;

     notused=0..0;

     PStripOffsets=^TStripOffsets;
     TStripOffsets=array[0..0] of dword;

     PStripByteCounts=^TStripByteCounts;
     TStripByteCounts=array[0..0] of dword;

     pbyte=^byte;

CONST fieldtypesize:array[fieldtypes] of byte=
        (1,1,2,4,8, 1,1,2,4,8, 4,8);

{--- DECOMPRESSOR ---}

PROCEDURE decodeCOPY(src,dst:pointer;srccount,dstcount:longint);
VAR count:longint;
BEGIN
  IF (srccount>dstcount) THEN count:=dstcount ELSE count:=srccount;
  move(src^,dst^,count);
END;

PROCEDURE decodeLZW(src,dst:pbyte;srccount,dstcount:longint);
TYPE Pstr=^Tstr;
     Tstr=RECORD
       prefix:Pstr;
       suffix:longint;
     END;
     Pstrtab=^Tstrtab;
     Tstrtab=array[0..4095] of Tstr;

VAR strtab:Pstrtab;
    oldcode,curcode:longint;
    codelen,codemask:longint;
    stridx:longint;
    bitbuf,bitsinbuf:longint;

  PROCEDURE InitStringTable;
  VAR i:longint;
  BEGIN
    new(strtab);
    FOR i:=0 TO 255 DO
      BEGIN
        strtab^[i].prefix:=nil;
        strtab^[i].suffix:=i;
      END;
    FOR i:=256 TO 4095 DO
      BEGIN
        strtab^[i].prefix:=nil;
        strtab^[i].suffix:=0;
      END;
    stridx:=258;
    codelen:=9;
    codemask:=(1 SHL codelen)-1;
  END;

  PROCEDURE ClearStringTable;
  VAR i:longint;
  BEGIN
    FOR i:=258 TO 4095 DO
      BEGIN
        strtab^[i].prefix:=nil;
        strtab^[i].suffix:=0;
      END;
    stridx:=258;
    codelen:=9;
    codemask:=(1 SHL codelen)-1;
  END;

  PROCEDURE DoneStringTable;
  BEGIN
    dispose(strtab);
  END;

  FUNCTION GetNextCode:longint;
  BEGIN
    WHILE (bitsinbuf<codelen) DO
      BEGIN
        bitbuf:=(bitbuf SHL 8) OR src^;
        inc(src);
        dec(srccount);
        inc(bitsinbuf,8);
      END;
    dec(bitsinbuf,codelen);
    getnextcode:=(bitbuf SHR bitsinbuf) AND codemask;
  END;

  PROCEDURE AddStr2Tab(prefix:Pstr;suffix:longint);
  BEGIN
    strtab^[stridx].prefix:=prefix;
    strtab^[stridx].suffix:=suffix;
    inc(stridx);
    CASE stridx OF
    0..254:codelen:=8;
    255..510:codelen:=9;
    511..1022:codelen:=10;
    1023..2046:codelen:=11;
    2047..4094:codelen:=12;
    END;
    codemask:=(1 SHL codelen)-1;
  END;

  FUNCTION Code2Str(code:longint):Pstr;
  BEGIN
    Code2Str:=addr(strtab^[code]);
  END;

  PROCEDURE WriteStr(s:Pstr);
  BEGIN
    IF (s^.prefix<>nil) THEN WriteStr(s^.prefix);
    IF (dstcount>0) THEN
      BEGIN
        dst^:=s^.suffix;
        inc(dst);
        dec(dstcount);
      END;
  END;

  FUNCTION firstchar(s:Pstr):byte;
  BEGIN
    WHILE (s^.prefix<>nil) DO s:=s^.prefix;
    firstchar:=s^.suffix;
  END;

BEGIN
  bitbuf:=0;
  bitsinbuf:=0;
  InitStringTable;
  curcode:=getnextcode;
  WHILE (curcode<>257) AND (srccount>0) AND (dstcount>0) DO
    BEGIN
      IF (curcode=256) THEN
        BEGIN
          ClearStringTable;
          curcode:=getnextcode;
          IF (curcode=257) THEN break;
          WriteStr(code2str(curcode));
          oldcode:=curcode;
        END
      ELSE
        BEGIN
          IF (curcode<stridx) THEN
            BEGIN
              WriteStr(Code2Str(curcode));
              AddStr2Tab(Code2Str(oldcode),firstchar(Code2Str(curcode)));
              oldcode:=curcode;
            END
          ELSE
            BEGIN
              AddStr2Tab(Code2Str(oldcode),firstchar(Code2Str(oldcode)));
              WriteStr(Code2Str(stridx-1));
              oldcode:=curcode;
            END;
        END;
      curcode:=getnextcode;
    END;
  DoneStringTable;
END;

PROCEDURE decodePACKBITS(src,dst:pbyte;srccount,dstcount:longint);
VAR cnt:byte;
BEGIN
  WHILE (srccount>0) AND (dstcount>0) DO
    BEGIN
      CASE src^ OF
      $00..$7F:
        BEGIN
          move((src+1)^,dst^,src^+1);
          dec(dstcount,src^+1);
          dec(srccount,src^+2);
          inc(dst,src^+1);
          inc(src,src^+2);
        END;
      $80:
        BEGIN
          dec(srccount);
          inc(src);
        END;
      $81..$FF:
        BEGIN
          cnt:=NOT(src^)+2;
          fillchar(dst^,cnt,(src+1)^);
          dec(dstcount,cnt);
          dec(srccount,2);
          inc(dst,cnt);
          inc(src,2);
        END;
      END;
    END;
END;

{--- FILTERING ---}

{PROCEDURE filterXXX(data:pointer;bytesperline,lines,pixelperline,bytesperpixel,samplesperpixel,bitspersample:longint);}
PROCEDURE filterHORIZDIFF(data:pointer;bytesperline,lines,bytesperpixel,bitspersample:longint);
VAR x,y:longint;
    dataptr:pointer;
BEGIN
  dataptr:=data;
{  bytesperpixel:=3; }
  CASE bitspersample OF
  8:BEGIN
      FOR y:=0 TO lines-1 DO
        BEGIN
          FOR x:=bytesperpixel TO bytesperline-1 DO
            inc(byte((dataptr+x)^),byte((dataptr+x-bytesperpixel)^));
          inc(dataptr,bytesperline);
        END;
    END;
  END;
END;

{--- Color-Conversion ---}

FUNCTION cmyk2rgb(cmyk:longint):longint;
VAR c,m,y,k:longint;
BEGIN
  c:=(cmyk SHR $00) AND $FF;
  m:=(cmyk SHR $08) AND $FF;
  y:=(cmyk SHR $10) AND $FF;
  k:=(cmyk SHR $18) AND $FF;
  cmyk2rgb:=rgbcolorRGB(255-c-k,255-m-k,255-y-k);
END;

{--- MAIN ---}

FUNCTION LoadImageTIF(stream:pstream;var img:pimage;nr:longint):longint;
VAR TIFheader:TIFheader_t;
    IFDentry:IFDentry_t;
    numIFDentries:word;
    bigendian:boolean;
    c,i,j,k,x,io,sfp:longint;
    fs,entrycount:longint; {fieldsize}
    palette:array[0..255] of longint;
    numcol:longint;
    imgptr:pointer;
    rowbuf,rowbufptr,rawimgbuf,rawimgbufptr:array[0..2] of pointer;
    rawimgbytecount,rawimglinebytecount:longint;
    src,dst:pbyte;
    srccnt,dstcnt,ycount:longint;
    bitbuf,bitsinbuf:dword;
    readbyte:byte;
    startpos,nextdir:longint;

    Planes:longint;
    BytesPerSample:array[0..3] of longint;
    MaskForSample:array[0..3] of longint;
    MaskForPixel:longint;
    BitsPerPixel:longint;
    BytesPerPixel:longint;
    PixMul:dword;
    StripsPerImage:dword;
    StripOffsetsSize:dword;
    StripByteCountsSize:dword;

        NewSubfileType:notused; { 00FEh (p36) }
        SubfileType:notused; { 00FFh (p40) }
    ImageWidth:dword;                            { 0100h (p18, p34) }
    ImageLength:dword;                           { 0101h (p18, p34) }
    BitsPerSample:array[0..3] of word;           { 0102h (p22, p29) }
    Compression:word;                            { 0103h (p17, p30, p49, p104) }
    PhotometricInterpretation:word;              { 0106h (p17, p37, p90, p111) }
        Threshholding:notused; { 0107h (p41) }
        CellWidth:notused; { 0108h (p29) }
        CellLength:notused; { 0109h (p29) }
    FillOrder:word;                              { 010Ah (p32) }
        DocumentName:notused; { 010Dh (p55) }
        ImageDescription:notused; { 010Eh (p34) }
        Make:notused; { 010Fh (p35) }
        Model:notused; { 0110h (p35) }
    StripOffsets:PStripOffsets;                  { 0111h (p19, p40) }
    Orientation:word;                            { 0112h (p36) }
    SamplesPerPixel:word;                        { 0115h (p24, p39) }
    RowsPerStrip:dword;                          { 0116h (p19, p39) }
    StripByteCounts:PStripByteCounts;            { 0117h (p19, p40) }
        MinSampleValue:notused; { 0118h (p35) }
        MaxSampleValue:notused; { 0119h (p35) }
        XResolution:notused; { 011Ah (p19, p41) }
        YResolution:notused; { 011Bh (p19, p41) }
    PlanarConfiguration:word;                    { 011Ch (p38) }
        PageName:notused; { 011Dh (p55) }
        XPosition:notused; { 011Eh (p55) }
        YPosition:notused; { 011Fh (p56) }
        FreeOffsets:notused; { 0120h (p33) }
        FreeByteCounts:notused; { 0121h (p33) }
        GrayResponseUnit:notused; { 0122h (p33) }
        GrayResponseCurve:notused; { 0123h (p33) }
        T4Options:notused; { 0124h (p51) }
        T6Options:notused; { 0125h (p52) }
        ResolutionUnit:notused; { 0128h (p18, p38) }
        PageNumber:notused; { 0129h (p55) }
        TransferFunction:notused; { 012Dh (p84) }
        Software:notused; { 0131h (p39) }
        DateTime:notused; { 0132h (p31) }
        Artist:notused; { 013Bh (p28) }
        HostComputer:notused; { 013Ch (p34) }
    Predictor:word;                              { 013Dh (p64) }
        WhitePoint:notused; { 013Eh (p83) }
        PrimaryChromaticities:notused; { 013Fh (p83) }
    ColorMap:array[0..767] of word;              { 0140h (p23, p29) }
        HalftoneHints:notused; { 0141h (p72) }
        TileWidth:notused; { 0142h (p67) }
        TileLength:notused; { 0143h (p67) }
        TileOffsets:notused; { 0144h (p68) }
        TileByteCounts:notused; { 0145h (p68) }
        InkSet:notused; { 014Ch (p70) }
        InkNames:notused; { 014Dh (p70) }
        NumberOfInks:notused; { 014Eh (p70) }
        DotRange:notused; { 0150h (p71) }
        TargetPrinter:notused; { 0151h (p71) }
        ExtraSamples:notused; { 0152h (p31, p77) }
        SampleFormat:notused; { 0153h (p80) }
        SMinSampleValue:notused; { 0154h (p80) }
        SMaxSampleValue:notused; { 0155h (p81) }
        TransferRange:notused; { 0156h (p86) }
        JPEGProc:notused; { 0200h (p104) }
        JPEGInterchangeFormat:notused; { 0201h (p105) }
        JPEGRestartInterval:notused; { 0203h (p105) }
        JPEGLosslessPredictors:notused; { 0205h (p106) }
        JPEGPointTranforms:notused; { 0206h (p106) }
        JPEGTables:notused; { 0207h (p107) }
        JPEGDCTables:notused; { 0208h (p107) }
        JPEGACTables:notused; { 0209h (p107) }
        YCbCrCoefficients:notused; { 0211h (p90) }
        YCbCrSubSampling:notused; { 0212h (p91) }
        YCbCrPositioning:notused; { 0213h (p92) }
        ReferenceBlackWhite:notused; { 0214h (p86) }
        Copyright:notused; { 8298h (p31) }

  PROCEDURE swp(var p;n:byte);
  BEGIN
    IF NOT bigendian THEN exit;
    CASE n OF
      2:ASM
        MOV EDI,p
        MOV AX,[EDI]
        XCHG AL,AH
        MOV [EDI],AX
      END;
    4:ASM
        MOV EDI,p
        MOV EAX,[EDI]
        XCHG AL,AH
        ROR EAX,16
        XCHG AL,AH
        MOV [EDI],EAX
      END;
    8:ASM
        MOV EDI,p
        MOV EAX,[EDI]
        MOV EBX,[EDI+4]
        XCHG AL,AH
        XCHG BL,BH
        ROR EAX,16
        ROR EBX,16
        XCHG AL,AH
        XCHG BL,BH
        MOV [EDI],EAX
        MOV [EDI+4],EBX
      END;
    END;
  END;

  PROCEDURE readallvalues(ofsval:dword;var p;fieldsize,numval:dword);
  VAR i,toread:longint;
      pp:pointer;
  BEGIN
    pp:=pointer(p);
    toread:=fieldsize*numval;
    IF (toread<=4) THEN
      BEGIN
        move(ofsval,p,toread);
        exit;
      END;
    stream^.seek(startpos+ofsval);
    stream^.read(p,toread);
    IF NOT bigendian THEN exit;
    FOR i:=0 TO numval-1 DO
      BEGIN
        swp(pp^,fieldsize);
        inc(pp,fieldsize);
      END;
  END;

  PROCEDURE readallvalueslong(ofsval:dword;var p;fieldsize,numval:dword);
  VAR i:longint;
      lp:^longint;
  BEGIN
    IF (numval=1) THEN
      BEGIN
        move(ofsval,p,4);
        exit;
      END;
    lp:=pointer(p);
    stream^.seek(startpos+ofsval);
    FOR i:=0 TO numval-1 DO
      BEGIN
        lp^:=0;
        stream^.read(lp^,fieldsize);
        swp(lp^,fieldsize);
        inc(lp);
      END;
  END;

  PROCEDURE readvalues(var p;fieldsize,numval:dword);
  VAR i,toread:longint;
      pp:pointer;
  BEGIN
    pp:=pointer(p);
    toread:=fieldsize*numval;
    stream^.read(p,toread);
    IF NOT bigendian THEN exit;
    FOR i:=0 TO numval-1 DO
      BEGIN
        swp(pp^,fieldsize);
        inc(pp,fieldsize);
      END;
  END;

BEGIN
  LoadImageTIF:=-1;
  IF (nr<1) THEN exit;
  startpos:=stream^.getpos;
  {--- TIF header ---}
  stream^.read(TIFheader,sizeof(TIFheader_t));
  bigendian:=(TIFheader.endian=$4D4D);
  swp(TIFheader.magic,2);
  swp(TIFheader.IFDofs,4);
  IF (TIFheader.magic=42) THEN
    BEGIN
      stream^.seek(startpos+TIFheader.IFDofs);
      nextdir:=-1;
      WHILE (nr>1) AND (nextdir<>0) DO
        BEGIN
          stream^.read(numIFDentries,sizeof(numIFDentries));
          swp(numIFDentries,2);
          stream^.seek(stream^.getpos+numIFDentries*sizeof(IFDentry_t));
          stream^.read(nextdir,4);
          stream^.seek(startpos+nextdir);
          dec(nr);
        END;
      IF (nextdir=0) THEN exit;
      {--- number of IFD entries ---}
      stream^.read(numIFDentries,sizeof(numIFDentries));
      swp(numIFDentries,2);
      {--- Defaults/Initvalues ---}
      ImageWidth:=0;
      ImageLength:=0;
      BitsPerSample[0]:=1;BitsPerSample[1]:=1;BitsPerSample[2]:=1;
      Compression:=1;
      PhotometricInterpretation:=0;
      FillOrder:=1;
      Orientation:=1;
      SamplesPerPixel:=1;
      RowsPerStrip:=0;
      PlanarConfiguration:=1;
      Predictor:=1;
      StripOffsets:=nil;
      StripByteCounts:=nil;
      {--- IFD entries ---}
      FOR entrycount:=1 TO numIFDentries DO
        BEGIN
          {--- IFD entry ---}
          stream^.read(IFDentry,sizeof(IFDentry_t));
          swp(IFDentry.fieldtag,2);
          swp(IFDentry.fieldtype,2);
          swp(IFDentry.numvalues,4);
          swp(IFDentry.ofsvalues,4);
          fs:=fieldtypesize[IFDentry.fieldtype];
          sfp:=stream^.getpos;
{DBG(hexword(IFDentry.fieldtag));}
          CASE IFDentry.fieldtag OF { (p117) }
          $00FE:BEGIN { NewSubfileType (p36) }
                END;
          $00FF:BEGIN { SubfileType (p40) }
                END;
          $0100:BEGIN { ImageWidth (p18, p34) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,ImageWidth,fs,numvalues);
                END;
          $0101:BEGIN { ImageLength (p18, p34) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,ImageLength,fs,numvalues);
                END;
          $0102:BEGIN { BitsPerSample (p22, p29) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,BitsPerSample,fs,numvalues);
                END;
          $0103:BEGIN { Compression (p17, p30, p49, p104) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,Compression,fs,numvalues);
                END;
          $0106:BEGIN { PhotometricInterpretation (p17, p37, p90, p111) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,PhotometricInterpretation,fs,numvalues);
                END;
          $0107:BEGIN { Threshholding (p41) }
                END;
          $0108:BEGIN { CellWidth (p29) }
                END;
          $0109:BEGIN { CellLength (p29) }
                END;
          $010A:BEGIN { FillOrder (p32) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,FillOrder,fs,numvalues);
                END;
          $010D:BEGIN { DocumentName (p55) }
                END;
          $010E:BEGIN { ImageDescription (p34) }
                END;
          $010F:BEGIN { Make (p35) }
                END;
          $0110:BEGIN { Model (p35) }
                END;
          $0111:BEGIN { StripOffsets (p19, p40) }
                  WITH IFDentry DO
                    BEGIN
{DBG('*');
DBG(numvalues);
DBG(fs);}
                      StripOffsetsSize:=numvalues*4;
                      getmem(StripOffsets,StripOffsetsSize);
                      readallvalues(ofsvalues,StripOffsets^,fs,numvalues);

{                      IF (numvalues=1) THEN
                        BEGIN

                        END;
                      stream^.seek(startpos+ofsvalues);
                      FOR i:=0 TO numvalues-1 DO
                        BEGIN
                          StripOffsets^[i]:=0;
                          readvalues(StripOffsets^[i],fs,1);
DBG(StripOffsets^[i]);
                        END; }
                    END;
                END;
          $0112:BEGIN { Orientation (p36) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,Orientation,fs,numvalues);
                END;
          $0115:BEGIN { SamplesPerPixel (p24, p39) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,SamplesPerPixel,fs,numvalues);
                END;
          $0116:BEGIN { RowsPerStrip (p19, p39) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,RowsPerStrip,fs,numvalues);
                END;
          $0117:BEGIN { StripByteCounts (p19, p40) }
                  WITH IFDentry DO
                    BEGIN
{DBG('**');
DBG(numvalues);
DBG(fs);}
                      StripByteCountsSize:=numvalues*4;
                      getmem(StripByteCounts,StripByteCountsSize);
                      readallvalues(ofsvalues,StripByteCounts^,fs,numvalues);
{                      stream^.seek(startpos+ofsvalues);
                      FOR i:=0 TO numvalues-1 DO
                        BEGIN
                          StripByteCounts^[i]:=0;
                          readvalues(StripByteCounts^[i],fs,1);
DBG(StripByteCounts^[i]);
                        END;}
                    END;
                END;
          $0118:BEGIN { MinSampleValue (p35) }
                END;
          $0119:BEGIN { MaxSampleValue (p35) }
                END;
          $011A:BEGIN { XResolution (p19, p41) }
                END;
          $011B:BEGIN { YResolution (p19, p41) }
                END;
          $011C:BEGIN { PlanarConfiguaration (p38) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,PlanarConfiguration,fs,numvalues);
                END;
          $011D:BEGIN { PageName (p55) }
                END;
          $011E:BEGIN { XPosition (p55) }
                END;
          $011F:BEGIN { YPosition (p56) }
                END;
          $0120:BEGIN { FreeOffsets (p33) }
                END;
          $0121:BEGIN { FreeByteCounts (p33) }
                END;
          $0122:BEGIN { GrayResponseUnit (p33) }
                END;
          $0123:BEGIN { GrayResponseCurve (p33) }
                END;
          $0124:BEGIN { T4Options (p51) }
                END;
          $0125:BEGIN { T6Options (p52) }
                END;
          $0128:BEGIN { ResolutionUnit (p18, p38) }
                END;
          $0129:BEGIN { PageNumber (p55) }
                END;
          $012D:BEGIN { TransferFunction (p84) }
                END;
          $0131:BEGIN { Software (p39) }
                END;
          $0132:BEGIN { DateTime (p31) }
                END;
          $013B:BEGIN { Artist (p28) }
                END;
          $013C:BEGIN { HostComputer (p34) }
                END;
          $013D:BEGIN { Predictor (p64) }
                  WITH IFDentry DO
                    readallvalues(ofsvalues,Predictor,fs,numvalues);
                END;
          $013E:BEGIN { WhitePoint (p83) }
                END;
          $013F:BEGIN { PrimaryChromaticities (p83) }
                END;
          $0140:BEGIN { ColorMap (p23, p29) }
                  WITH IFDentry DO
                    BEGIN
                      numcol:=(1 SHL BitsPerSample[0]);
                      readallvalues(ofsvalues,ColorMap,fs,numvalues);
                      FOR i:=0 TO numcol-1 DO
                        palette[i]:=rgbcolorRGB(ColorMap[numcol*0+i] SHR 8,ColorMap[numcol*1+i] SHR 8,ColorMap[numcol*2+i] SHR 8);
                    END;
                END;
          $0141:BEGIN { HalftoneHints (p72) }
                END;
          $0142:BEGIN { TileWidth (p67) }
                END;
          $0143:BEGIN { TileLength (p67) }
                END;
          $0144:BEGIN { TileOffsets (p68) }
                END;
          $0145:BEGIN { TileByteCounts (p68) }
                END;
          $0146:BEGIN { BadFaxLines }
                END;
          $0147:BEGIN { CleanFaxData }
                END;
          $0148:BEGIN { ConsecutiveBadFaxLines }
                END;
          $014C:BEGIN { InkSet (p70) }
                END;
          $014D:BEGIN { InkNames (p70) }
                END;
          $014E:BEGIN { NumberOfInks (p70) }
                END;
          $0150:BEGIN { DotRange (p71) }
                END;
          $0151:BEGIN { TargetPrinter (p71) }
                END;
          $0152:BEGIN { ExtraSamples (p31, p77) }
                END;
          $0153:BEGIN { SampleFormat (p80) }
                END;
          $0154:BEGIN { SMinSampleValue (p80) }
                END;
          $0155:BEGIN { SMaxSampleValue (p81) }
                END;
          $0156:BEGIN { TransferRange (p86) }
                END;
          $0200:BEGIN { JPEGProc (p104) }
                END;
          $0201:BEGIN { JPEGInterchangeFormat (p105) }
                END;
          $0203:BEGIN { JPEGRestartInterval (p105) }
                END;
          $0205:BEGIN { JPEGLosslessPredictors (p106) }
                END;
          $0206:BEGIN { JPEGPointTranforms (p106) }
                END;
          $0207:BEGIN { JPEGTables (p107) }
                END;
          $0208:BEGIN { JPEGDCTables (p107) }
                END;
          $0209:BEGIN { JPEGACTables (p107) }
                END;
          $0211:BEGIN { YCbCrCoefficients (p90) }
                END;
          $0212:BEGIN { YCbCrSubSampling (p91) }
                END;
          $0213:BEGIN { YCbCrPositioning (p92) }
                END;
          $0214:BEGIN { ReferenceBlackWhite (p86) }
                END;
          $8298:BEGIN { Copyright (p31) }
                END;
          END;
          stream^.seek(sfp);
        END;
{DBGw('press key');}
{DBG('#10');}

      IF (RowsPerStrip>ImageLength) THEN RowsPerStrip:=ImageLength;
      StripsPerImage:=(ImageLength+RowsPerStrip-1) DIV RowsPerStrip;

      img:=CreateImageWH(ImageWidth,ImageLength);
      imgptr:=img^.pixeldata;

      CASE PlanarConfiguration OF
      $0001:planes:=1;
      $0002:planes:=SamplesPerPixel;
      END;

{DBG('#20');}

      FOR j:=0 TO SamplesPerPixel-1 DO
        CASE BitsPerSample[j] OF
        $01..$08:BytesPerSample[j]:=1;
        $09..$10:BytesPerSample[j]:=2;
        $11..$20:BytesPerSample[j]:=4;
        END;

{DBG('#30');}

      FOR j:=0 TO SamplesPerPixel-1 DO
        MaskForSample[j]:=(1 SHL BitsPerSample[j])-1;

      BytesPerPixel:=0;
      CASE PlanarConfiguration OF
      $0001:FOR j:=0 TO SamplesPerPixel-1 DO
              inc(BytesPerPixel,BytesPerSample[j]);
      $0002:BytesPerPixel:=BytesPerSample[0];
      END;

{DBG('#40');}

      CASE PhotometricInterpretation OF
      0,1,3:BitsPerPixel:=BitsPerSample[0];
      2:BitsPerPixel:=BytesPerPixel*8;
      5:BitsPerPixel:=BytesPerPixel*8;
      END;

{DBG('#45');
DBG(BitsPerpixel);}

  {    MaskForPixel:=(dword(1) SHL BitsPerPixel)-1; }

      MaskForPixel:=$FFFFFFFF SHR (32-BitsPerPixel);

{DBG(hexlong(maskforpixel));}

      CASE PhotometricInterpretation OF
      0,1:PixMul:=dword($FFFFFFFF) DIV dword(MaskForPixel);
      END;
{DBG(MaskForPixel);
DBGw(PixMul);}

{DBG('#46');}

      rawimglinebytecount:=(ImageWidth*BitsPerPixel+7) SHR 3;
      rawimgbytecount:=rawimglinebytecount*RowsPerStrip;

{DBG('#50');}

{DBG('===');
DBG(photometricinterpretation);
DBG(planarconfiguration);
DBG(planes);
DBG(bytesperpixel);
DBG(samplesperpixel);
DBG(compression);
DBG(predictor);
DBG(ExtraSamples);
DBG('---');
FOR j:=0 TO SamplesPerPixel-1 DO DBG(BitsPerSample[j]);
DBG('---');
DBG(ImageWidth);
DBG(ImageLength);
DBG(RowsPerStrip);
DBG(StripsPerImage);
DBG(BitsPerPixel);
DBG('===');}

      i:=0;
      ycount:=ImageLength;
      WHILE (i<StripsPerImage) DO
        BEGIN
          FOR j:=0 TO planes-1 DO
            BEGIN
{DBG(rawimgbytecount);
DBG(StripByteCounts^[i+j]);
DBG(StripOffsets^[i+j]);}
              getmem(rowbuf[j],StripByteCounts^[i+j]);
              getmem(rawimgbuf[j],rawimgbytecount);

              stream^.seek(startpos+StripOffsets^[i+j]);
              stream^.read(rowbuf[j]^,StripByteCounts^[i+j]);
              rowbufptr[j]:=rowbuf[j];
              rawimgbufptr[j]:=rawimgbuf[j];
              CASE Compression OF
              $0001:decodeCOPY(rowbuf[j],rawimgbuf[j],StripByteCounts^[i+j],rawimgbytecount);
              $0005:decodeLZW(rowbuf[j],rawimgbuf[j],StripByteCounts^[i+j],rawimgbytecount);
              $8005:decodePACKBITS(rowbuf[j],rawimgbuf[j],StripByteCounts^[i+j],rawimgbytecount);
              END;
              CASE Predictor OF
              $0002:filterHORIZDIFF(rawimgbuf[j],rawimglinebytecount,RowsPerStrip,BytesPerPixel,BitsPerSample[j]);
              END;

              bitbuf:=0;
              bitsinbuf:=0;
            END;
          rawimgbufptr[0]:=rawimgbuf[0];
          FOR k:=0 TO RowsPerStrip-1 DO
            BEGIN
              ProgressMonitor(ImageLength-ycount,ImageLength-1);
              IF (ycount>0) THEN
                BEGIN
                  CASE planes OF
                  1:BEGIN
                     rawimgbufptr[0]:=rawimgbuf[0]+k*rawimglinebytecount;
                     bitbuf:=0;
                     bitsinbuf:=0;
                     FOR x:=0 TO ImageWidth-1 DO
                       BEGIN
                         WHILE (bitsinbuf<BitsPerPixel) DO
                            BEGIN
                              readbyte:=byte(rawimgbufptr[0]^);
                              CASE BitsPerPixel OF
                              1:ASM
                                  XOR AX,AX
                                  MOV AH,readbyte
                                  MOV CX,8
                                @loop:
                                  SHR AX,1
                                  ROL AL,2
                                  LOOP @loop
                                  ROR AL,1
                                  MOV readbyte,AL
                                END;
                              2:ASM
                                  XOR AX,AX
                                  MOV AH,readbyte
                                  MOV CX,4
                                @loop:
                                  SHR AX,2
                                  ROL AL,4
                                  LOOP @loop
                                  ROR AL,4
                                  MOV readbyte,AL
                                END;
                              4:ASM
                                  ROR readbyte,4
                                END;
                              END;
                              bitbuf:=bitbuf OR (longint(readbyte) SHL bitsinbuf);
                              inc(rawimgbufptr[0]);
                              inc(bitsinbuf,8);
                            END;
                          c:=bitbuf AND MaskForPixel;
                          bitbuf:=bitbuf SHR BitsPerPixel;
                          IF (bitsperpixel=32) THEN bitbuf:=0;
                          dec(bitsinbuf,BitsPerPixel);
                          CASE PhotometricInterpretation OF
                          0:BEGIN
                              c:=(c*PixMul) SHR 24;
                              c:=rgbcolorRGB(NOT c,NOT c,NOT c);
                            END;
                          1:BEGIN
                              c:=(c*PixMul) SHR 24;
                              c:=rgbcolorRGB(c,c,c);
                            END;
                          2:BEGIN
                              c:=rgbcolor(bytswp32(c SHL 8));
                            END;
                          3:BEGIN
                              c:=palette[c];
                            END;
                          5:BEGIN
                              c:=cmyk2rgb(c);
                            END;
                          END;
                          move(c,(imgptr+x*bytperpix)^,bytperpix);
                        END;
                    END;
                  3:BEGIN
                      FOR x:=0 TO ImageWidth-1 DO
                        BEGIN
              {      move(rowbuf+j* }
                        END;
                    END;
                  END;
{putimage(0,0,img);}
                  inc(imgptr,img^.bytesperline);
                END;
              dec(ycount);
            END;
          FOR j:=0 TO planes-1 DO
            BEGIN
              freemem(rowbuf[j],StripByteCounts^[i+j]);
              freemem(rawimgbuf[j],rawimgbytecount);
            END;
          inc(i,planes);
        END; { WHILE (i<StripsPerImage) DO }
      freemem(StripOffsets,StripOffsetsSize);
      freemem(StripByteCounts,StripByteCountsSize);
      LoadImageTIF:=0;
    END; { IF (TIFheader.magic=42) THEN }
  stream^.seek(startpos);
END;

{================================ LoadImage =================================}

TYPE Tiddata=array[0..7] of byte;

CONST bytidxBMP:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskBMP:Tiddata=($FF,$FF,$00,$00,$00,$00,$00,$00);
      resultBMP:Tiddata=($42,$4D,$00,$00,$00,$00,$00,$00);
      conditBMP:Tiddata=($01,$01,$80,$80,$80,$80,$80,$80);

      bytidxCUR:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskCUR:Tiddata=($FF,$FF,$FF,$FF,$00,$00,$00,$00);
      resultCUR:Tiddata=($00,$00,$02,$00,$00,$00,$00,$00);
      conditCUR:Tiddata=($00,$00,$01,$00,$FF,$80,$80,$80);

      bytidxGIF:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskGIF:Tiddata=($FF,$FF,$FF,$FF,$00,$FF,$00,$00);
      resultGIF:Tiddata=($47,$49,$46,$38,$00,$61,$00,$00);
      conditGIF:Tiddata=($01,$01,$01,$01,$80,$01,$80,$80);

      bytidxICO:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskICO:Tiddata=($FF,$FF,$FF,$FF,$00,$00,$00,$00);
      resultICO:Tiddata=($00,$00,$01,$00,$00,$00,$00,$00);
      conditICO:Tiddata=($00,$00,$01,$00,$FF,$80,$80,$80);

      bytidxJPG:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskJPG:Tiddata=($FF,$FF,$FF,$F0,$00,$00,$00,$00);
      resultJPG:Tiddata=($FF,$D8,$FF,$E0,$00,$00,$00,$00);
      conditJPG:Tiddata=($01,$01,$01,$01,$80,$80,$80,$80);

      bytidxPCX:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskPCX:Tiddata=($FF,$F8,$FF,$00,$00,$00,$00,$00);
      resultPCX:Tiddata=($0A,$00,$01,$00,$00,$00,$00,$00);
      conditPCX:Tiddata=($01,$80,$01,$FF,$80,$80,$80,$80);

      bytidxPNG:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskPNG:Tiddata=($FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF);
      resultPNG:Tiddata=($89,$50,$4E,$47,$0D,$0A,$1A,$0A);
      conditPNG:Tiddata=($01,$01,$01,$01,$01,$01,$01,$01);

      bytidxPxM:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskPxM:Tiddata=($FF,$F8,$00,$00,$00,$00,$00,$00);
      resultPxM:Tiddata=($50,$30,$00,$00,$00,$00,$00,$00);
      conditPxM:Tiddata=($01,$80,$80,$80,$80,$80,$80,$80);

      bytidxTGA:Tiddata=($00,$01,$02,$07,$10,$05,$06,$08);
      andmskTGA:Tiddata=($00,$FE,$F0,$C7,$C7,$00,$00,$00);
      resultTGA:Tiddata=($00,$00,$00,$00,$00,$00,$00,$00);
      conditTGA:Tiddata=($80,$80,$FF,$80,$FF,$80,$80,$80);

      bytidxTIFi:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskTIFi:Tiddata=($FF,$FF,$FF,$FF,$00,$00,$00,$00);
      resultTIFi:Tiddata=($49,$49,$2A,$00,$00,$00,$00,$00);
      conditTIFi:Tiddata=($01,$01,$01,$01,$80,$80,$80,$80);

      bytidxTIFm:Tiddata=($00,$01,$02,$03,$04,$05,$06,$07);
      andmskTIFm:Tiddata=($FF,$FF,$FF,$FF,$00,$00,$00,$00);
      resultTIFm:Tiddata=($4D,$4D,$00,$2A,$00,$00,$00,$00);
      conditTIFm:Tiddata=($01,$01,$01,$01,$80,$80,$80,$80);

FUNCTION checkfile(stream:Pstream):Timagetype;
CONST maxdata=128;
VAR readdata:array[0..maxdata-1] of byte;
    savepos:longint;
    imagetype:Timagetype;

  FUNCTION check(var bytidx,andmask,checkresult,condit:Tiddata):boolean;
  VAR i,idx:byte;
      b:boolean;
  BEGIN
    b:=TRUE;
    FOR i:=0 TO 7 DO
      BEGIN
        idx:=bytidx[i];
        CASE condit[i] OF
        $00:b:=b AND (readdata[idx]=0);
        $01:b:=b AND (readdata[idx]=checkresult[i]);
        $80:b:=b AND ((readdata[idx] AND andmask[i])=checkresult[i]);
        $FF:b:=b AND (readdata[idx]<>0);
        END;
      END;
    check:=b;
  END;

BEGIN
  imagetype:=itunknown;
  savepos:=stream^.getpos;
  stream^.read(readdata,maxdata);
{DBG('checkfile');}
  IF check(bytidxBMP,andmskBMP,resultBMP,conditBMP) THEN imagetype:=itBMP;
  IF check(bytidxCUR,andmskCUR,resultCUR,conditCUR) THEN imagetype:=itCUR;
  IF check(bytidxGIF,andmskGIF,resultGIF,conditGIF) THEN imagetype:=itGIF;
  IF check(bytidxICO,andmskICO,resultICO,conditICO) THEN imagetype:=itICO;
  IF check(bytidxJPG,andmskJPG,resultJPG,conditJPG) THEN imagetype:=itJPG;
  IF check(bytidxPCX,andmskPCX,resultPCX,conditPCX) THEN imagetype:=itPCX;
  IF check(bytidxPNG,andmskPNG,resultPNG,conditPNG) THEN imagetype:=itPNG;
  IF check(bytidxPxM,andmskPxM,resultPxM,conditPxM) THEN imagetype:=itPxM;
  IF check(bytidxTGA,andmskTGA,resultTGA,conditTGA) THEN imagetype:=itTGA;
  IF check(bytidxTIFi,andmskTIFi,resultTIFi,conditTIFi) THEN imagetype:=itTIF;
  IF check(bytidxTIFm,andmskTIFm,resultTIFm,conditTIFm) THEN imagetype:=itTIF;
{DBG(byte(imagetype));}
  stream^.seek(savepos);
  checkfile:=imagetype;
END;

FUNCTION WhatIsImageStream(stream:pstream):Timagetype;
BEGIN
  WhatIsImageStream:=checkfile(stream);
END;

FUNCTION LoadImageStream(imagetype:Timagetype;stream:pstream;var img:pimage;nr:longint):longint;
BEGIN
  LoadImageStream:=-1;
  IF (nr<1) THEN nr:=1;
  IF (imagetype=itdetect) THEN imagetype:=checkfile(stream);
  CASE imagetype OF
  itBMP:LoadImageStream:=LoadImageBMP(stream,img,nr);
  itGIF:LoadImageStream:=LoadImageGIF(stream,img,nr);
  itCUR:LoadImageStream:=LoadImageICO(stream,img,nr);
  itICO:LoadImageStream:=LoadImageICO(stream,img,nr);
  itJPG:LoadImageStream:=LoadImageJPG(stream,img,nr);
  itPCX:LoadImageStream:=LoadImagePCX(stream,img,nr);
  itPNG:LoadImageStream:=LoadImagePNG(stream,img,nr);
  itPxM:LoadImageStream:=LoadImagePxM(stream,img,nr);
  itTGA:LoadImageStream:=LoadImageTGA(stream,img,nr);
  itTIF:LoadImageStream:=LoadImageTIF(stream,img,nr);
  END;
END;

TYPE PMyStream=^TMyStream;
     TMyStream=OBJECT(TStream)
       f:file;
       buffer,curbufferpos:pointer;
       buffersize:longint;
       bufferstartpos,bufferendpos,bytesinbuffer:longint;
       io:longint;
       fmode:word;
       CONSTRUCTOR Init(name:string;mode,size:word);
       DESTRUCTOR Done;virtual;
       PROCEDURE read(var buf;count:sw_word);virtual;
       PROCEDURE seek(pos:longint);virtual;
       FUNCTION getpos:longint;virtual;
       FUNCTION getsize:longint;virtual;
     END;

CONSTRUCTOR TMyStream.Init(name:string;mode,size:word);
BEGIN
  status:=0;
  fmode:=mode;
  system.assign(f,name);
  system.reset(f,1);
  IF (system.IOresult<>0) THEN
    BEGIN
      status:=stInitError;
      exit;
    END;
  streamsize:=filesize(f);
  if (size>streamsize) THEN size:=streamsize;
  buffersize:=size;
  getmem(buffer,buffersize);
  bytesinbuffer:=0;
  curbufferpos:=buffer;
  position:=0;
END;

DESTRUCTOR TMyStream.Done;
BEGIN
  freemem(buffer,buffersize);
  system.close(f);
END;

PROCEDURE TMyStream.read(var buf;count:sw_word);
VAR dst:pointer;
BEGIN
  dst:=pointer(@buf);
{DBG('RRR');
DBG(count);}
  WHILE (count>0) DO
    BEGIN
      IF (bytesinbuffer=0) THEN
        BEGIN
{DBG('r1');}
          bufferstartpos:=system.filepos(f);
          blockread(f,buffer^,buffersize,io);
          bufferendpos:=system.filepos(f);
          bytesinbuffer:=io;
          curbufferpos:=buffer;
        END;
      IF (bytesinbuffer=0) THEN break;
      IF (count>=bytesinbuffer) THEN
        BEGIN
          inc(position,bytesinbuffer);
          move(curbufferpos^,dst^,bytesinbuffer);
          inc(curbufferpos,bytesinbuffer);
          inc(dst,bytesinbuffer);
          dec(count,bytesinbuffer);
          bytesinbuffer:=0;
        END
      ELSE
        BEGIN
          inc(position,count);
{DBG('r3');
DBG(count);}
          move(curbufferpos^,dst^,count);
          inc(curbufferpos,count);
          inc(dst,count);
          dec(bytesinbuffer,count);
          count:=0;
        END;
    END;
{DBG('r#');}
END;

PROCEDURE TMyStream.seek(pos:longint);
BEGIN
{DBG('s');
DBG(pos);}
  position:=pos;
  IF (position>=bufferstartpos) AND (position<=bufferendpos) THEN
    BEGIN
      curbufferpos:=buffer+position-bufferstartpos;
      bytesinbuffer:=bufferendpos-position;
    END
  ELSE
    BEGIN
      system.seek(f,position);
      bufferstartpos:=system.filepos(f);
      blockread(f,buffer^,buffersize,io);
      bufferendpos:=system.filepos(f);
      bytesinbuffer:=io;
{DBG(bytesinbuffer);}
      curbufferpos:=buffer;
    END;
END;

FUNCTION TMyStream.getpos:longint;
BEGIN
  getpos:=position;
END;

FUNCTION TMyStream.getsize:longint;
BEGIN
  getsize:=streamsize;
END;

TYPE PReadStream=^TReadStream;
     TReadStream=OBJECT(TStream)
       f:file;
       CONSTRUCTOR Init(name:string);
       DESTRUCTOR Done;virtual;
       PROCEDURE read(var buf;count:sw_word);virtual;
       PROCEDURE seek(pos:longint);virtual;
       FUNCTION getpos:longint;virtual;
       FUNCTION getsize:longint;virtual;
     END;

CONSTRUCTOR TReadStream.Init(name:string);
BEGIN
  status:=0;
  system.assign(f,name);
  system.reset(f,1);
  IF (system.IOresult<>0) THEN
    BEGIN
      status:=stInitError;
      exit;
    END;
  streamsize:=filesize(f);
END;

DESTRUCTOR TReadStream.Done;
BEGIN
  IF (status=0) THEN system.close(f);
END;

PROCEDURE TReadStream.read(var buf;count:sw_word);
VAR io:longint;
BEGIN
  system.blockread(f,buf,count,io);
END;

PROCEDURE TReadStream.seek(pos:longint);
BEGIN
  system.seek(f,pos);
END;

FUNCTION TReadStream.getpos:longint;
BEGIN
  getpos:=system.filepos(f);
END;

FUNCTION TReadStream.getsize:longint;
BEGIN
  getsize:=system.filesize(f);
END;

FUNCTION WhatIsImageFile(filename:string):Timagetype;
VAR stream:PReadStream;
BEGIN
{DBG('whatisimagefile: '+filename);}
  WhatIsImageFile:=itunknown;
{  WhatIsImageFile:=itBMP; }
  new(stream,Init(filename{,stOpenRead,32768}));
{DBG('stream opened');}
  IF (stream^.status<>stInitError) THEN
    WhatIsImageFile:=WhatIsImageStream(stream);
  dispose(stream,Done);
{DBG('stream closed');}
END;

FUNCTION LoadImageFile(imagetype:Timagetype;filename:string;var img:pimage;nr:longint):longint;
VAR stream:PMyStream;
BEGIN
  LoadImageFile:=-1;
  new(stream,Init(filename,stOpenRead,32768));
  IF (stream^.status<>stInitError) THEN
    LoadImageFile:=LoadImageStream(imagetype,stream,img,nr);
  dispose(stream,Done);
END;

{==========================================================================}
{=========================== saveimageBMP =================================}

FUNCTION saveimageBMP(filename:string;img:pimage):boolean;
TYPE TBMPfileheader=RECORD
       bfType:word;
       bfSize:longint;
       bfReserved1:word;
       bfReserved2:word;
       bfOffBits:longint;
     END;
     TBMPinfoheader=RECORD
       biSize:longint;
       biWidth:longint;
       biHeight:longint;
       biPlanes:word;
       biBitCount:word;
       biCompression:longint;
       biSizeImage:longint;
       biXPelsPerMeter:longint;
       biYPelsPerMeter:longint;
       biClrUsed:longint;
       biClrImportant:longint;
     END;
VAR BMPF:file;
    BMPfh:TBMPfileheader;
    BMPih:TBMPinfoheader;
    x,y,io,color,writesize:longint;
    ofss,ofsd,linebuf:pointer;
BEGIN
  saveimageBMP:=FALSE;
  assign(BMPF,filename);
  rewrite(BMPF,1);
  IF (IOresult=0) THEN
    BEGIN
      writesize:=(img^.width*3+3) AND $FFFFFFFC;
      BMPfh.bfType:=ord('B')+word(ord('M')) SHL 8;
      BMPfh.bfSize:=sizeof(TBMPfileheader)+sizeof(TBMPinfoheader)+writesize*img^.height;
      BMPfh.bfReserved1:=0;
      BMPfh.bfReserved2:=0;
      BMPfh.bfOffBits:=sizeof(TBMPfileheader)+sizeof(TBMPinfoheader);
      BMPih.biSize:=sizeof(TBMPInfoHeader);
      BMPih.biWidth:=img^.width;
      BMPih.biHeight:=img^.height;
      BMPih.biPlanes:=1;
      BMPih.biBitCount:=24;
      BMPih.biCompression:=0;
      BMPih.biSizeImage:=0;
      BMPih.biXPelsPerMeter:=2836;
      BMPih.biYPelsPerMeter:=2836;
      blockwrite(BMPF,BMPfh,sizeof(TBMPfileheader),io);
      blockwrite(BMPF,BMPih,sizeof(TBMPinfoheader),io);
      getmem(linebuf,writesize);
      FOR y:=BMPih.biHeight-1 DOWNTO 0 DO
        BEGIN
          ofss:=img^.pixeldata+y*img^.bytesperline;
          ofsd:=linebuf;
          FOR x:=1 TO BMPih.biWidth DO
            BEGIN
              move(ofss^,color,bytperpix);
              color:=getrgbcolor32(color);
              move(color,ofsd^,3);
              inc(ofss,bytperpix);
              inc(ofsd,3);
            END;
          blockwrite(BMPF,linebuf^,writesize,io);
        END;
      close(BMPF);
      saveimageBMP:=TRUE;
    END;
END;

{=========================== saveimagePPM =================================}

FUNCTION saveimagePPM(filename:string;img:pimage):boolean;
VAR PPMF:text;
    w,h,x,y,c:longint;
BEGIN
  assign(PPMF,filename);
  rewrite(PPMF);
  IF (IOresult=0) THEN
    BEGIN
      w:=img^.width;
      h:=img^.height;
      writeln(PPMF,'P3');
      writeln(PPMF,w);
      writeln(PPMF,h);
      writeln(PPMF,'255');
      FOR y:=0 TO h-1 DO
        FOR x:=0 TO w-1 DO
          BEGIN
            move((img^.pixeldata+y*img^.bytesperline+x*bytperpix)^,c,bytperpix);
            c:=getrgbcolor32(c);
            write(PPMF,(c SHR 16) AND $FF,' ');
            write(PPMF,(c SHR 8) AND $FF,' ');
            writeln(PPMF,(c SHR 0) AND $FF);
          END;
      close(PPMF);
      saveimagePPM:=TRUE;
    END;
END;

{=========================== saveimageTGA =================================}

FUNCTION saveimageTGA(filename:string;img:pimage):boolean;
TYPE TTGA=RECORD
       IDlength:byte;
       ColorTabFlag:byte;
       Bildtyp:byte;
       ErsteFarbe:word;
       AnzahlFarben:word;
       BitsproFarbe:byte;
       xpos,ypos:word;
       breite,hoehe:word;
       bitspropix:byte;
       BildFlag:byte;
     END;
VAR TGA:TTGA;
    TGAF:file;
    x,y,io,color:longint;
    ofss,ofsd,linebuf:pointer;
BEGIN
  saveimageTGA:=FALSE;
  assign(TGAF,filename);
  rewrite(TGAF,1);
  IF (IOresult=0) THEN
    BEGIN
      TGA.IDlength:=0;
      TGA.ColorTabFlag:=0;
      TGA.Bildtyp:=2;
      TGA.xpos:=0;
      TGA.ypos:=0;
      TGA.breite:=img^.width;
      TGA.hoehe:=img^.height;
      TGA.bitspropix:=24;
      TGA.BildFlag:=$20;
      blockwrite(TGAF,TGA,sizeof(TGA),io);
      getmem(linebuf,TGA.breite*3);
      FOR y:=0 TO TGA.hoehe-1 DO
        BEGIN
          ofss:=img^.pixeldata+y*img^.bytesperline;
          ofsd:=linebuf;
          FOR x:=1 TO TGA.breite DO
            BEGIN
              move(ofss^,color,bytperpix);
              color:=getrgbcolor32(color);
              move(color,ofsd^,3);
              inc(ofss,bytperpix);
              inc(ofsd,3);
            END;
          blockwrite(TGAF,linebuf^,TGA.breite*3,io);
        END;
      close(TGAF);
      saveimageTGA:=TRUE;
    END;
END;

{==========================================================================}

BEGIN
  ProgressMonitor:=@ProgressMonitorDummy;
END.
