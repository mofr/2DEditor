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
                                GXIMEFF
                  ------------------------------------
                                v1.10
                  ------------------------------------

VERSION HISTORY

Version 1.20 (27.05.2000)
  + imageSADDcolor - saturated ADD
  + imageSSUBcolor - saturated SUB
  + imageSADDimage - saturated ADD
  + imageSSUBimage - saturated SUB

Version 1.10 (15.08.1999)
  + rotateimage
  + mosaicimage
  + averageimage
  + filterimage
  + UserDataToImageRGB
  + UserDataToImagePAL

Version 1.00
  + blendimageALPHA
  + blendimageALPHAcolor
  + blendimageALPHAimage
  + blendimageMASK
  + blendimageMASKcolor
  + blendimageMASKimage
  + imageADDcolor
  + imageSUBcolor
  + imageANDcolor
  + imageORcolor
  + imageXORcolor
  + imageADDimage
  + imageSUBimage
  + imageANDimage
  + imageORimage
  + imageXORimage
  + fillimage
  + flipimageH
  + flipimageV
  + scaleimage
  + composeimage
  + composeimageC
}

{$I gxglobal.cfg}
UNIT gximeff;

INTERFACE

USES gxtype,gxsup;
{$I gxlocal.cfg}

TYPE
  blendimageALPHAproc=function(dst,src:pimage;alpha:longint):pimage;
  blendimageALPHAcolorproc=function(dst,src:pimage;alpha:longint;color:longint):pimage;
  blendimageALPHAimageproc=function(dst,src:pimage;alpha:longint;image:pimage):pimage;
  blendimageMASKproc=function(dst,src,mask:pimage):pimage;
  blendimageMASKcolorproc=function(dst,src,mask:pimage;color:longint):pimage;
  blendimageMASKimageproc=function(dst,src,mask:pimage;image:pimage):pimage;
  imageOPcolorproc=function(dst,src:pimage;color:longint):pimage;
  imageOPimageproc=function(dst,src1,src2:pimage):pimage;
  fillimageproc=function(dst:pimage;color:longint):pimage;
  flipimageHproc=function(dst,src:pimage):pimage;
  flipimageVproc=function(dst,src:pimage):pimage;
  composeimageproc=function(dst,image:pimage;x,y:longint):pimage;
  composeimageCproc=function(dst,image:pimage;x,y:longint):pimage;
  scaleimageproc=function(dst,src:pimage):pimage;
  rotateimageproc=function(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;
  mosaicimageproc=function(dst,src:pimage;xc,yc,fx,fy:longint):pimage;
  averageimageproc=function(dst,src:pimage;xc,yc,fx,fy:longint):pimage;
  filterimageproc=function(dst,src:pimage;var filter;xc,yc,fx,fy,offs:longint):pimage;
  userdatatoimagergbproc=function(dst:pimage;src:pointer;bpp:longint;Rpos,Rsiz,Gpos,Gsiz,Bpos,Bsiz:byte):pimage;
  userdatatoimagepalproc=function(dst:pimage;src:pointer;bpp,idxbits:longint;var palette):pimage;

VAR
  blendimageALPHA:blendimageALPHAproc;
  blendimageALPHAcolor:blendimageALPHAcolorproc;
  blendimageALPHAimage:blendimageALPHAimageproc;
  blendimageMASK:blendimageMASKproc;
  blendimageMASKcolor:blendimageMASKcolorproc;
  blendimageMASKimage:blendimageMASKimageproc;
  imageADDcolor:imageOPcolorproc;
  imageSUBcolor:imageOPcolorproc;
  imageSADDcolor:imageOPcolorproc;
  imageSSUBcolor:imageOPcolorproc;
  imageANDcolor:imageOPcolorproc;
  imageORcolor:imageOPcolorproc;
  imageXORcolor:imageOPcolorproc;
  imageADDimage:imageOPimageproc;
  imageSUBimage:imageOPimageproc;
  imageSADDimage:imageOPimageproc;
  imageSSUBimage:imageOPimageproc;
  imageANDimage:imageOPimageproc;
  imageORimage:imageOPimageproc;
  imageXORimage:imageOPimageproc;
  fillimage:fillimageproc;
  flipimageH:flipimageHproc;
  flipimageV:flipimageVproc;
  composeimage:composeimageproc;
  composeimageC:composeimageCproc;
  scaleimage:scaleimageproc;
  rotateimage:rotateimageproc;
  mosaicimage:mosaicimageproc;
  averageimage:averageimageproc;
  filterimage:filterimageproc;
  userdatatoimagergb:userdatatoimagergbproc;
  userdatatoimagepal:userdatatoimagepalproc;

{PROCEDURE InitGXIMEFF;}

IMPLEMENTATION

USES gxbase,graphix;

{--------------------------- blendimage_alpha -------------------------------}

FUNCTION blendimageALPHAL8(dst,src:pimage;alpha:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  SHR EBX,5
@bia8_loop1:
  LODSW
  SHL EAX,8
  MOV AL,AH
  SHL AH,1
  SHL AX,2
  ROR EAX,16
  MOV AH,AL
  SHL AH,1
  AND EAX,0E38C38E3h
  MUL EBX
  AND EAX,01C61C718h
  SHL EDX,20
  SHR EAX,3
  OR EAX,EDX
  SHR AH,1
  OR AL,AH
  ROR EAX,16
  SHL AX,6
  SHR EAX,8
  STOSW
  DEC ECX
  JNZ @bia8_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAL15(dst,src:pimage;alpha:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  SHR EBX,3
@bia15_loop1:
  LODSW
  MOV EDX,EAX
  SHL EAX,22
  MOV AX,DX
  AND EAX,0F8007C1Fh
  MUL EBX
  AND EAX,000F83E0h
  SHL EDX,10
  OR EAX,EDX
  SHR EAX,5
  STOSW
  DEC ECX
  JNZ @bia15_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAL16(dst,src:pimage;alpha:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  SHR EBX,3
@bia16_loop1:
  LODSW
  MOV EDX,EAX
  SHL EAX,21
  MOV AX,DX
  AND EAX,0F800F81Fh
  MUL EBX
  AND EAX,001F03E0h
  SHL EDX,11
  OR EAX,EDX
  SHR EAX,5
  STOSW
  DEC ECX
  JNZ @bia16_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHALtc(dst,src:pimage;alpha:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@biatc_loop1:
  LODSD
  MOV EBX,EAX
  AND EAX,00FF00FFh
  SHR EBX,8
  AND EBX,00FF00FFh
  MUL alpha
  SHR EAX,8
  XCHG EAX,EBX
  MUL alpha
  AND EBX,000FF00FFh
  AND EAX,0FF00FF00h
  OR EAX,EBX
  STOSD
  DEC ECX
  JNZ @biatc_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHALMtc(dst,src:pimage;alpha:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  PXOR MM0,MM0
  PXOR MM7,MM7
  MOV EBX,alpha
  MOV BH,BL
  MOVD MM7,EBX
  PUNPCKLBW MM7,MM0
  PUNPCKLDQ MM7,MM7
@biamtc_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM3,MM1
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM3,MM0
  PMULLW MM1,MM7
  PMULLW MM3,MM7
  PSRLW MM1,8
  PSRLW MM3,8
  PACKUSWB MM1,MM3
  MOVQ [EDI],MM1
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @biamtc_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- blendimage_color -------------------------------}

FUNCTION blendimageALPHAcolorL8(dst,src:pimage;alpha:longint;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  SHR EBX,5
  XOR BL,07h
  MOV EAX,color
  MOV AH,AL
  SHL EAX,8
  MOV AL,AH
  SHL AH,1
  SHL AX,2
  ROR EAX,16
  MOV AH,AL
  SHL AH,1
  AND EAX,0E38C38E3h
  MUL EBX
  AND EAX,01C61C718h
  SHL EDX,20
  SHR EAX,3
  OR EAX,EDX
  MOV color,EAX
  XOR BL,07h
@biac8_loop1:
  LODSW
  SHL EAX,8
  MOV AL,AH
  SHL AH,1
  SHL AX,2
  ROR EAX,16
  MOV AH,AL
  SHL AH,1
  AND EAX,0E38C38E3h
  MUL EBX
  AND EAX,01C61C718h
  SHL EDX,20
  SHR EAX,3
  OR EAX,EDX
  ADD EAX,color
  SHR AH,1
  OR AL,AH
  ROR EAX,16
  SHL AX,6
  SHR EAX,8
  STOSW
  DEC ECX
  JNZ @biac8_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAcolorL15(dst,src:pimage;alpha:longint;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  SHR BL,3
  XOR BL,1Fh
  MOV EAX,color
  MOV EDX,EAX
  SHL EAX,22
  MOV AX,DX
  AND EAX,0F8007C1Fh
  MUL EBX
  AND EAX,000F83E0h
  SHL EDX,10
  OR EAX,EDX
  SHR EAX,5
  MOV color,EAX
  XOR BL,1Fh
@bic15_loop1:
  LODSW
  MOV EDX,EAX
  SHL EAX,22
  MOV AX,DX
  AND EAX,0F8007C1Fh
  MUL EBX
  AND EAX,000F83E0h
  SHL EDX,10
  OR EAX,EDX
  SHR EAX,5
  ADD EAX,color
  STOSW
  DEC ECX
  JNZ @bic15_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAcolorL16(dst,src:pimage;alpha:longint;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  SHR BL,3
  XOR BL,1Fh
  MOV EAX,color
  MOV EDX,EAX
  SHL EAX,21
  MOV AX,DX
  AND EAX,0F800F81Fh
  MUL EBX
  AND EAX,001F03E0h
  SHL EDX,11
  OR EAX,EDX
  SHR EAX,5
  MOV color,EAX
  XOR BL,1Fh
@bic16_loop1:
  LODSW
  MOV EDX,EAX
  SHL EAX,21
  MOV AX,DX
  AND EAX,0F800F81Fh
  MUL EBX
  AND EAX,001F03E0h
  SHL EDX,11
  OR EAX,EDX
  SHR EAX,5
  ADD EAX,color
  STOSW
  DEC ECX
  JNZ @bic16_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAcolorL24(dst,src:pimage;alpha:longint;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  NOT BL
  MOV EAX,color
  AND EAX,00FF00FFh
  MUL EBX
  MOV AL,AH
  ROR EAX,8
  MOV DL,AL
  MOV AL,BYTE PTR [color+1]
  MUL BL
  MOV AL,DL
  MOV color,EAX
@bic24_loop1:
  LODSD
  MOV EBX,EAX
  AND EAX,00FF00FFh
  SHR EBX,8
  AND EBX,00FF00FFh
  MUL alpha
  SHR EAX,8
  XCHG EAX,EBX
  MUL alpha
  AND EBX,000FF00FFh
  AND EAX,0FF00FF00h
  OR EAX,EBX
  MOV EDX,color
  ADD EAX,EDX
  MOV DL,DH
  ROR EDX,8
  MOV color,EDX
  STOSD
  DEC ECX
  JNZ @bic24_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAcolorLM24(dst,src:pimage;alpha:longint;color:longint):pimage;assembler;
VAR col:int64;
    cnt:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EBX,[EDI+timage.bytesperline]
  MOV EAX,[EDI+timage.height]
  SHR EBX,3
  MUL EBX
  MOV cnt,EBX
  MOV ECX,EAX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  PXOR MM0,MM0
  PXOR MM7,MM7
  MOV EBX,alpha
  MOV BH,BL
  MOVD MM7,EBX
  NOT BX
  MOVD MM5,EBX
  PUNPCKLBW MM7,MM0
  PUNPCKLBW MM5,MM0
  PUNPCKLDQ MM7,MM7
  PUNPCKLDQ MM5,MM5
  MOV EBX,color
  AND EBX,00FFFFFFh
  MOVD MM6,EBX
  PUNPCKLBW MM6,MM0
  PMULLW MM6,MM5
  PSRLW MM6,8
  PACKUSWB MM6,MM0
  MOVQ MM3,MM6
  PSLLQ MM3,24
  POR MM6,MM3
  PSLLQ MM3,24
  POR MM6,MM3
  MOVQ col,MM6
  MOV EAX,cnt
@bicm24_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM3,MM1
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM3,MM0
  PMULLW MM1,MM7
  PMULLW MM3,MM7
  PSRLW MM1,8
  PSRLW MM3,8
  PACKUSWB MM1,MM3
  PADDB MM1,MM6
  MOVQ [EDI],MM1
  MOVQ MM3,MM6
  PSRLQ MM6,16
  PSLLQ MM3,32
  POR MM6,MM3

  DEC EAX
  JNZ @bicm24_nocol
  MOVQ MM6,col
  MOV EAX,cnt
@bicm24_nocol:

  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @bicm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION blendimageALPHAcolorL32(dst,src:pimage;alpha:longint;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,alpha
  NOT BL
  MOV EAX,color
  AND EAX,00FF00FFh
  MUL EBX
  SHR EAX,8
  MOV DL,AL
  MOV AL,BYTE PTR [color+1]
  MUL BL
  MOV AL,DL
  MOV color,EAX
  NOT BL
@bic32_loop1:
  LODSD
  AND EAX,00FF00FFh
  MUL EBX
  SHR EAX,8
  MOV DL,AL
  MOV AL,[ESI+1-4]
  MUL BL
  MOV AL,DL
  ADD EAX,color
  STOSD
  DEC ECX
  JNZ @bic32_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAcolorLM32(dst,src:pimage;alpha:longint;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  PXOR MM0,MM0
  PXOR MM7,MM7
  MOV EBX,alpha
  MOV BH,BL
  MOVD MM7,EBX
  NOT BX
  MOVD MM5,EBX
  PUNPCKLBW MM7,MM0
  PUNPCKLBW MM5,MM0
  PUNPCKLDQ MM7,MM7
  PUNPCKLDQ MM5,MM5
  MOV EBX,color
  MOVD MM6,EBX
  PUNPCKLBW MM6,MM0
  PMULLW MM6,MM5
  PSRLW MM6,8
  PACKUSWB MM6,MM6
@bicm32_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM3,MM1
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM3,MM0
  PMULLW MM1,MM7
  PMULLW MM3,MM7
  PSRLW MM1,8
  PSRLW MM3,8
  PACKUSWB MM1,MM3
  PADDB MM1,MM6
  MOVQ [EDI],MM1
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @bicm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- blendimageALPHAimage ---------------------------}

FUNCTION blendimageALPHAimageL8(dst,src:pimage;alpha:longint;image:pimage):pimage;assembler;
VAR a,ia:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  MOV EBX,alpha
  MOV EAX,8
  SHR EBX,5
  SUB EAX,EBX
  MOV a,EBX
  MOV ia,EAX
@biai8_loop1:
  PUSH ECX
  PUSH EDX
  MOV AX,[ESI]
  MOV CX,[ESI+EDX]
  SHL EAX,16
  SHL ECX,16
  MOV AX,[ESI]
  MOV CX,[ESI+EDX]
  SHL AH,1
  SHL CH,1
  AND EAX,0E31C38E3h
  AND ECX,0E31C38E3h
  MUL a
  MOV EBX,EDX
  XCHG ECX,EAX
  MUL ia
  ADD ECX,EAX
  ADC EDX,EBX
  ADD ESI,2
  SHRD ECX,EDX,3
  AND ECX,0E31C38E3h
  MOV EAX,ECX
  SHR ECX,16
  SHR AH,1
  OR EAX,ECX
  STOSW
  POP EDX
  POP ECX
  DEC ECX
  JNZ @biai8_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAimageL15(dst,src:pimage;alpha:longint;image:pimage):pimage;assembler;
VAR a,ia:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  MOV EBX,alpha
  MOV EAX,32
  SHR EBX,3
  SUB EAX,EBX
  MOV a,EBX
  MOV ia,EAX
@bii15_loop1:
  PUSH ECX
  MOV AX,[ESI]
  MOV CX,[ESI+EDX]
  SHL EAX,15
  SHL ECX,15
  MOV AX,[ESI]
  MOV CX,[ESI+EDX]
  AND EAX,01F07C1Fh
  AND ECX,01F07C1Fh
  IMUL EAX,a
  ADD ESI,2
  IMUL ECX,ia
  ADD EAX,ECX
  MOV ECX,EAX
  AND EAX,000F83E0h
  AND ECX,3E000000h
  SHR EAX,5
  SHR ECX,20
  OR EAX,ECX
  STOSW
  POP ECX
  DEC ECX
  JNZ @bii15_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAimageL16(dst,src:pimage;alpha:longint;image:pimage):pimage;assembler;
VAR a,ia:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  MOV EBX,alpha
  MOV EAX,32
  SHR EBX,3
  SUB EAX,EBX
  MOV a,EBX
  MOV ia,EAX
@bii16_loop1:
  PUSH ECX
  MOV AX,[ESI]
  MOV CX,[ESI+EDX]
  SHL EAX,15
  SHL ECX,15
  MOV AX,[ESI]
  MOV CX,[ESI+EDX]
  SHR AH,1
  SHR CH,1
  AND EAX,03F07C1Fh
  AND ECX,03F07C1Fh
  IMUL EAX,a
  ADD ESI,2
  IMUL ECX,ia
  ADD EAX,ECX
  MOV ECX,EAX
  AND EAX,000F83E0h
  AND ECX,7E000000h
  SHR EAX,5
  SHR ECX,20
  SHL AH,1
  OR EAX,ECX
  STOSW
  POP ECX
  DEC ECX
  JNZ @bii16_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAimageLtc(dst,src:pimage;alpha:longint;image:pimage):pimage;assembler;
VAR NOTalpha:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EDX,image
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  MOV EAX,alpha
  NEG EAX
  ADD EAX,256
  MOV NOTalpha,EAX
@biaitc_loop1:
  PUSH ECX
  PUSH EDX
  MOV ECX,[ESI+EDX]
  LODSD
  MOV EBX,EAX
  MOV EDX,ECX
  SHR EAX,8
  SHR ECX,8
  AND EAX,000FF00FFh
  AND EBX,000FF00FFh
  AND ECX,000FF00FFh
  AND EDX,000FF00FFh
  IMUL EAX,alpha
  IMUL EBX,alpha
  IMUL ECX,NOTalpha
  IMUL EDX,NOTalpha
  ADD EAX,ECX
  ADD EBX,EDX
  AND EAX,0FF00FF00h
  AND EBX,0FF00FF00h
  SHR EBX,8
  OR EAX,EBX
  STOSD
  POP EDX
  POP ECX
  DEC ECX
  JNZ @biaitc_loop1
  MOV EAX,dst
END;

FUNCTION blendimageALPHAimageLMtc(dst,src:pimage;alpha:longint;image:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EDX,ESI
  PXOR MM0,MM0
  MOV EBX,alpha
  MOVD MM7,EBX
  PUNPCKLWD MM7,MM7
  PUNPCKLWD MM7,MM7
  MOV EAX,00FF00FFh
  MOVD MM6,EAX
  PUNPCKLWD MM6,MM6
@biimtc_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM3,[ESI+EDX]
  MOVQ MM2,MM1
  MOVQ MM4,MM3
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM2,MM0
  PUNPCKLBW MM3,MM0
  PUNPCKHBW MM4,MM0
  PSUBW MM1,MM3
  PSUBW MM2,MM4
  PMULLW MM1,MM7
  PMULLW MM2,MM7
  PSRLW MM1,8
  PSRLW MM2,8
  PADDW MM1,MM3
  PADDW MM2,MM4
  PAND MM1,MM6
  PAND MM2,MM6
  ADD ESI,8
  ADD EDI,8
  PACKUSWB MM1,MM2
  MOVQ [EDI-8],MM1
  DEC ECX
  JNZ @biimtc_loop1
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{--------------------------- blendimageMASK ---------------------------------}

FUNCTION blendimageMASKL8(dst,src,mask:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
@bim8_loop1:
  PUSH EBX
  MOV BX,[ESI+EBX]
  LODSW
  SHL EBX,14
  SHL EAX,14
  MUL BX
  SHR DX,14
  ROR EDX,2
  XOR BX,BX
  SHR EBX,3
  SHR EAX,3
  MUL BX
  SHR DX,13
  ROR EDX,3
  XOR BX,BX
  SHR EBX,3
  SHR EAX,3
  MUL BX
  SHR DX,13
  ROR EDX,3
  XOR BX,BX
  SHR EBX,2
  SHR EAX,2
  MUL BX
  SHR DX,14
  ROR EDX,2
  XOR BX,BX
  SHR EBX,3
  SHR EAX,3
  MUL BX
  SHR DX,13
  ROR EDX,3
  XOR BX,BX
  SHR EBX,3
  SHR EAX,3
  MUL BX
  SHR DX,13
  ROL EDX,13
  MOV EAX,EDX
  STOSW
  POP EBX
  DEC ECX
  JNZ @bim8_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKL15(dst,src,mask:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
@bim15_loop1:
  MOV DX,[ESI+EBX]
  LODSW
  SHL EDX,11
  SHL EAX,11
  MUL DX
  SHR DX,11
  SHR EAX,5
  ROR EDX,5
  MUL DX
  SHR DX,11
  SHR EAX,5
  ROR EDX,5
  MUL DX
  SHR DX,11
  ROL EDX,10
  MOV AX,DX
  STOSW
  DEC ECX
  JNZ @bim15_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKL16(dst,src,mask:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
@bim16_loop1:
  MOV DX,[ESI+EBX]
  LODSW
  SHL EDX,11
  SHL EAX,11
  MUL DX
  SHR DX,11
  ROR EDX,6
  SHR EAX,6
  MUL DX
  SHR DX,10
  SHL EDX,1
  SHR DX,1
  ROR EDX,6
  SHR EAX,5
  MUL DX
  SHR DX,11
  ROR EDX,21
  MOV AX,DX
  STOSW
  DEC ECX
  JNZ @bim16_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKLtc(dst,src,mask:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
@bimitc_loop1:
  PUSH EBX
  MOV EDX,[ESI+EBX]
  LODSD
  MOV EBX,EAX
  MOV AL,BL
  MUL DL
  MOV BL,AH
  ROL EAX,8
  ROL EDX,8
  ROL EBX,8
  MOV AL,BL
  MUL DL
  MOV BL,AH
  ROL EAX,8
  ROL EDX,8
  ROL EBX,8
  MOV AL,BL
  MUL DL
  MOV BL,AH
  ROL EAX,8
  ROL EDX,8
  ROL EBX,8
  MOV AL,BL
  MUL DL
  MOV BL,AH
  ROL EBX,8
  MOV EAX,EBX
  STOSD
  POP EBX
  DEC ECX
  JNZ @bimitc_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKLMtc(dst,src,mask:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  PXOR MM0,MM0
@bimcmtc_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM2,MM1
  MOVQ MM5,[ESI+EBX]
  MOVQ MM6,MM5
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM2,MM0
  PUNPCKLBW MM5,MM0
  PUNPCKHBW MM6,MM0
  PMULLW MM1,MM5
  PMULLW MM2,MM6
  PSRLW MM1,8
  PSRLW MM2,8
  PACKUSWB MM1,MM2
  MOVQ [EDI],MM1
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @bimcmtc_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- blendimageMASKcolor ---------------------------}

FUNCTION blendimageMASKcolorL8(dst,src,mask:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI

  MOV EAX,color
  MOV AH,AL
  SHL EAX,14
  MOV color,EAX

@bim8_loop1:
  PUSH EBX
  PUSH ECX
  MOV BX,[ESI+EBX]
  LODSW
  MOV ECX,color

  SHL EBX,14
  SHL EAX,14

  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,13
  ROR EDX,2

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROR EDX,3

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROR EDX,3

  XOR CX,CX
  XOR BX,BX

  SHR ECX,2
  SHR EBX,2
  SHR EAX,2
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,13
  ROR EDX,2

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROR EDX,3

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROL EDX,13
  MOV EAX,EDX

  STOSW
  POP ECX
  POP EBX
  DEC ECX
  JNZ @bim8_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKcolorL15(dst,src,mask:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EDX,mask
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  MOV EBX,color
  SHL EBX,6
  SHR BX,1
  SHL EBX,6
  SHR BX,1
  AND EBX,07DF7C00h
  MOV color,EBX
  XOR EAX,EAX
@bimc15_loop1:
  PUSH EDX
  MOV DX,[ESI+EDX]
  LODSW
  SHL EDX,11
  SHL EAX,11
  MOV EBX,color
  SHR AX,1
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  XOR BX,BX
  SHR EAX,5
  ROR EDX,5
  SHR EBX,6
  SHR AX,1
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  XOR BX,BX
  SHR EAX,6
  ROR EDX,5
  SHR EBX,6
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  ROR EDX,22
  MOV AX,DX
  STOSW
  POP EDX
  DEC ECX
  JNZ @bimc15_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKcolorL16(dst,src,mask:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EDX,mask
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  MOV EBX,color
  SHL EBX,5
  SHR BX,1
  SHL EBX,7
  SHR BX,1
  AND EBX,0FBF7C00h
  MOV color,EBX
  XOR EAX,EAX
@bimc16_loop1:
  PUSH EDX
  MOV DX,[ESI+EDX]
  LODSW
  SHL EDX,11
  SHL EAX,11
  MOV EBX,color
  SHR AX,1
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  XOR BX,BX
  SHR EAX,6
  ROR EDX,6
  SHR EBX,7
  SHR AX,1
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,9
  SHL EDX,1
  SHR DX,1
  XOR BX,BX
  SHR EAX,6
  ROR EDX,6
  SHR EBX,6
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  ROR EDX,21
  MOV AX,DX
  STOSW
  POP EDX
  DEC ECX
  JNZ @bimc16_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKcolorL24(dst,src,mask:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]

  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI

  MOV EAX,color
  SHL EAX,8
  MOV AL,AH
  ROR EAX,8
  MOV color,EAX

@bimi24_loop1:
  PUSH EBX
  PUSH ECX

  MOV ECX,color
  PUSH ECX
  SHL ECX,16

  MOV EBX,[ESI+EBX]
  PUSH EBX
  SHL EBX,16

  XOR EAX,EAX
  LODSW
  ROR EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8

  XOR BL,BL
  XOR CL,CL
  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8
  SHR EAX,8
  STOSW

  POP EBX
  XOR BX,BX
  POP ECX
  XOR CX,CX
  XOR EAX,EAX
  LODSW
  ROR EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8

  XOR BL,BL
  XOR CL,CL
  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8
  SHR EAX,8
  STOSW

  MOV EBX,color
  MOV BL,BH
  ROR EBX,8
  MOV color,EBX

  POP ECX
  POP EBX
  DEC ECX
  JNZ @bimi24_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKcolorLM24(dst,src,mask:pimage;color:longint):pimage;assembler;
VAR col1,col2:int64;
    cnt:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EBX,[EDI+timage.bytesperline]
  MOV EAX,[EDI+timage.height]
  SHR EBX,3
  MUL EBX
  MOV cnt,EBX
  MOV ECX,EAX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  PXOR MM0,MM0
  MOV EAX,color
  AND EAX,00FFFFFFh
  MOVD MM3,EAX
  PUNPCKLBW MM3,MM0

  MOVQ MM7,MM3
  PSLLQ MM7,48
  POR MM3,MM7
  MOVQ MM4,MM3
  MOVQ MM7,MM3
  PSRLQ MM4,16
  PSLLQ MM7,32
  POR MM4,MM7
  MOVQ col1,MM3
  MOVQ col2,MM4
  MOV EAX,cnt

@bimcm24_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM5,[ESI+EBX]
  MOVQ MM2,MM1
  MOVQ MM6,MM5
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM2,MM0
  PUNPCKLBW MM5,MM0
  PUNPCKHBW MM6,MM0
  PSRLW MM5,1
  PSRLW MM6,1
  PSUBW MM1,MM3
  PSUBW MM2,MM4
  PMULLW MM1,MM5
  PMULLW MM2,MM6
  PSRAW MM1,7
  PSRAW MM2,7
  PADDW MM1,MM3
  PADDW MM2,MM4
  PACKUSWB MM1,MM2
  MOVQ [EDI],MM1

  MOVQ MM7,MM4
  MOVQ MM4,MM3
  PSLLQ MM7,32
  PSRLQ MM3,32
  POR MM3,MM7

  DEC EAX
  JNZ @bimcm24_nocol
  MOVQ MM3,col1
  MOVQ MM4,col2
  MOV EAX,cnt
@bimcm24_nocol:

  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @bimcm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION blendimageMASKcolorL32(dst,src,mask:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI

@bimi32_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,color
  LODSD

  ROL EAX,16
  ROL EBX,16
  ROL ECX,16
  XOR AH,AH
  XOR BH,BH
  XOR CH,CH
  SUB AX,CX
  IMUL BX
  SHL CX,8
  ADD AX,CX

  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  XOR AH,AH
  XOR BH,BH
  XOR CH,CH
  SUB AX,CX
  IMUL BX
  SHL CX,8
  ADD AX,CX

  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  XOR AH,AH
  XOR BH,BH
  XOR CH,CH
  SUB AX,CX
  IMUL BX
  SHL CX,8
  ADD AX,CX

  SHR EAX,8
  STOSD

  POP ECX
  POP EBX
  DEC ECX
  JNZ @bimi32_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKcolorLM32(dst,src,mask:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  PXOR MM0,MM0
  MOV EAX,color
  MOVD MM3,EAX
  PUNPCKLBW MM3,MM0
@bimcm32_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM2,MM1
  MOVQ MM5,[ESI+EBX]
  MOVQ MM6,MM5
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM2,MM0
  PUNPCKLBW MM5,MM0
  PUNPCKHBW MM6,MM0
  PSRLW MM5,1
  PSRLW MM6,1
  PSUBW MM1,MM3
  PSUBW MM2,MM3
  PMULLW MM1,MM5
  PMULLW MM2,MM6
  PSRAW MM1,7
  PSRAW MM2,7
  PADDW MM1,MM3
  PADDW MM2,MM3
  PACKUSWB MM1,MM2
  MOVQ [EDI],MM1
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @bimcm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- blendimageMASKimage ---------------------------}

FUNCTION blendimageMASKimageL8(dst,src,mask:pimage;image:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI

@bim8_loop1:
  PUSH EBX
  PUSH ECX
  PUSH EDX
  MOV CX,[ESI+EDX]
  MOV BX,[ESI+EBX]
  LODSW
  SHL ECX,14
  SHL EBX,14
  SHL EAX,14

  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,13
  ROR EDX,2

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROR EDX,3

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROR EDX,3

  XOR CX,CX
  XOR BX,BX

  SHR ECX,2
  SHR EBX,2
  SHR EAX,2
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,13
  ROR EDX,2

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROR EDX,3

  XOR CX,CX
  XOR BX,BX

  SHR ECX,3
  SHR EBX,3
  SHR EAX,3
  SHR CX,1
  SHR AX,1
  SHR BX,1
  SUB AX,CX
  IMUL BX
  SAL DX,1
  ADD DX,CX
  SHR DX,12
  ROL EDX,13
  MOV EAX,EDX

  STOSW
  POP EDX
  POP ECX
  POP EBX
  DEC ECX
  JNZ @bim8_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKimageL15(dst,src,mask:pimage;image:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,image
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  MOV EDX,mask
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  XOR EAX,EAX
@bimi15_loop1:
  PUSH EBX
  PUSH EDX
  MOV DX,[ESI+EDX]
  MOV BX,[ESI+EBX]
  LODSW
  SHL EDX,11
  SHL EAX,11
  SHL EBX,11
  SHR AX,1
  SHR DX,1
  SHR BX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  SHR EAX,5
  ROR EDX,5
  SHR EBX,5
  SHR AX,1
  SHR DX,1
  SHR BX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  SHR EAX,5
  ROR EDX,5
  SHR EBX,5
  SHR AX,1
  SHR DX,1
  SHR BX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  ROL EDX,10
  MOV AX,DX
  STOSW
  POP EDX
  POP EBX
  DEC ECX
  JNZ @bimi15_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKimageL16(dst,src,mask:pimage;image:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,image
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  MOV EDX,mask
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
@bimi16_loop1:
  PUSH EBX
  PUSH EDX
  XOR EAX,EAX
  MOVZX EDX,WORD PTR [ESI+EDX]
  MOVZX EBX,WORD PTR [ESI+EBX]
  LODSW
  SHL EAX,11
  SHL EBX,11
  SHL EDX,11
  SHR AX,1
  SHR BX,1
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,9
  XOR BX,BX
  SHR EAX,6
  SHR EBX,6
  ROR EDX,6
  SHR AX,1
  SHR BX,1
  SHR DX,1
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,9
  XOR BX,BX
  SHR EAX,6
  SHR EBX,6
  ROR EDX,6
  SUB AX,BX
  IMUL DX
  SAL DX,1
  ADD DX,BX
  SHR DX,10
  ROL EDX,11
  MOV AX,DX
  STOSW

  POP EDX
  POP EBX
  DEC ECX
  JNZ @bimi16_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKimageL24(dst,src,mask:pimage;image:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]

  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI

@bimi24_loop1:
  PUSH EBX
  PUSH ECX
  PUSH EDX

  MOV ECX,[ESI+EDX]
  PUSH ECX
  SHL ECX,16

  MOV EBX,[ESI+EBX]
  PUSH EBX
  SHL EBX,16

  XOR EAX,EAX
  LODSW
  ROR EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8

  XOR BL,BL
  XOR CL,CL
  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8
  SHR EAX,8
  STOSW

  POP EBX
  XOR BX,BX
  POP ECX
  XOR CX,CX
  XOR EAX,EAX
  LODSW
  ROR EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8

  XOR BL,BL
  XOR CL,CL
  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  SUB AX,CX
  IMUL BX
  SAR AX,8
  ADD AX,CX
  SHL AX,8
  SHR EAX,8
  STOSW

  POP EDX
  POP ECX
  POP EBX
  DEC ECX
  JNZ @bimi24_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKimageL32(dst,src,mask:pimage;image:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]

  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI
  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI

@bimi32_loop1:
  PUSH EBX
  PUSH ECX
  PUSH EDX
  MOV EBX,[ESI+EBX]
  MOV ECX,[ESI+EDX]
  LODSD

  ROL EAX,16
  ROL EBX,16
  ROL ECX,16
  XOR AH,AH
  XOR BH,BH
  XOR CH,CH
  SUB AX,CX
  IMUL BX
  SHL CX,8
  ADD AX,CX

  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  XOR AH,AH
  XOR BH,BH
  XOR CH,CH
  SUB AX,CX
  IMUL BX
  SHL CX,8
  ADD AX,CX

  ROL EAX,8
  ROL EBX,8
  ROL ECX,8
  XOR AH,AH
  XOR BH,BH
  XOR CH,CH
  SUB AX,CX
  IMUL BX
  SHL CX,8
  ADD AX,CX

  SHR EAX,8
  STOSD

  POP EDX
  POP ECX
  POP EBX
  DEC ECX
  JNZ @bimi32_loop1
  MOV EAX,dst
END;

FUNCTION blendimageMASKimageLMtc(dst,src,mask:pimage;image:pimage):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]

  MOV EDX,image
  MOV EDX,[EDX+timage.pixeldata]
  SUB EDX,ESI
  MOV EBX,mask
  MOV EBX,[EBX+timage.pixeldata]
  SUB EBX,ESI

  PXOR MM0,MM0
@bimimtc_loop1:
  MOVQ MM1,[ESI]
  MOVQ MM2,MM1
  MOVQ MM3,[ESI+EDX]
  MOVQ MM4,MM3
  MOVQ MM5,[ESI+EBX]
  MOVQ MM6,MM5
  PUNPCKLBW MM1,MM0
  PUNPCKHBW MM2,MM0
  PUNPCKLBW MM3,MM0
  PUNPCKHBW MM4,MM0
  PUNPCKLBW MM5,MM0
  PUNPCKHBW MM6,MM0
  PSRLW MM5,1
  PSRLW MM6,1
  PSUBW MM1,MM3
  PSUBW MM2,MM4
  PMULLW MM1,MM5
  PMULLW MM2,MM6
  PSRAW MM1,7
  PSRAW MM2,7
  PADDW MM1,MM3
  PADDW MM2,MM4
  PACKUSWB MM1,MM2
  MOVQ [EDI],MM1
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @bimimtc_loop1
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{--------------------------- imageADDcolor ----------------------------------}

FUNCTION imageADDcolorL8(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV BH,BL
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
@icadd8_loop1:
  LODSD
  MOV EDX,EAX
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  ADD EAX,EBX
  ADD EDX,EBX
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  STOSD
  DEC ECX
  JNZ @icadd8_loop1
  MOV EAX,dst
END;

FUNCTION imageADDcolorLM8(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM4,EAX
  PUNPCKLBW MM4,MM4
  PUNPCKLWD MM4,MM4
  PUNPCKLDQ MM4,MM4
  MOV EAX,01CE31CE3h
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,0E31CE31Ch
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@icaddm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  PAND MM0,MM2
  PAND MM1,MM3
  PADDB MM0,MM4
  PADDB MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageADDcolorL15(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
@icadd15_loop1:
  LODSD
  MOV EDX,EAX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  ADD EAX,EBX
  ADD EDX,EBX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  STOSD
  DEC ECX
  JNZ @icadd15_loop1
  MOV EAX,dst
END;

FUNCTION imageADDcolorLM15(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM4,EAX
  PUNPCKLWD MM4,MM4
  PUNPCKLDQ MM4,MM4
  MOV EAX,83E07C1Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,7C1F83E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@icaddm15_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  PAND MM0,MM2
  PAND MM1,MM3
  PADDW MM0,MM4
  PADDW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm15_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageADDcolorL16(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
@icadd16_loop1:
  LODSD
  MOV EDX,EAX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  ADD EAX,EBX
  ADD EDX,EBX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  STOSD
  DEC ECX
  JNZ @icadd16_loop1
  MOV EAX,dst
END;

FUNCTION imageADDcolorLM16(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM4,EAX
  PUNPCKLWD MM4,MM4
  PUNPCKLDQ MM4,MM4
  MOV EAX,07E0F81Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,0F81F07E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@icaddm16_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  PAND MM0,MM2
  PAND MM1,MM3
  PADDW MM0,MM4
  PADDW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageADDcolorL24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  SHL EBX,8
  MOV BL,BH
  ROR EBX,8
@icadd24_loop1:
  LODSD
  ADD AL,BL
  ADD AH,BH
  ROR EAX,16
  ROR EBX,16
  ADD AL,BL
  ADD AH,BH
  ROR EAX,16
  ROR EBX,16
  STOSD
  MOV BL,BH
  ROR EBX,8
  DEC ECX
  JNZ @icadd24_loop1
  MOV EAX,dst
END;

FUNCTION imageADDcolorLM24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@icaddm24_loop1:
  MOVQ MM2,MM1
  MOVQ MM0,[ESI]
  PADDB MM0,MM1
  MOVQ [EDI],MM0
  PSRLQ MM1,16
  PSLLQ MM2,32
  ADD ESI,8
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @icaddm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageADDcolorL32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
@icadd32_loop1:
  LODSD
  ADD AL,BL
  ADD AH,BH
  ROR EAX,16
  ROR EBX,16
  ADD AL,BL
  ROR EAX,16
  ROR EBX,16
  STOSD
  DEC ECX
  JNZ @icadd32_loop1
  MOV EAX,dst
END;

FUNCTION imageADDcolorLM32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLDQ MM1,MM1
@icaddm32_loop1:
  MOVQ MM0,[ESI]
  PADDB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageSUBcolor ----------------------------------}

FUNCTION imageSUBcolorL8(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV BH,BL
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
@icadd8_loop1:
  LODSD
  MOV EDX,EAX
  OR EAX,0E31CE31Ch
  OR EDX,01CE31CE3h
  SUB EAX,EBX
  SUB EDX,EBX
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  STOSD
  DEC ECX
  JNZ @icadd8_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBcolorLM8(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM4,EAX
  PUNPCKLBW MM4,MM4
  PUNPCKLWD MM4,MM4
  PUNPCKLDQ MM4,MM4
  MOV EAX,01CE31CE3h
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,0E31CE31Ch
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@icsubm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  POR MM0,MM3
  POR MM1,MM2
  PSUBB MM0,MM4
  PSUBB MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSUBcolorL15(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  sHL EBX,16
  MOV BX,AX
@icsub15_loop1:
  LODSD
  MOV EDX,EAX
  OR EAX,7C1F83E0h
  OR EDX,83E07C1Fh
  SUB EAX,EBX
  SUB EDX,EBX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  STOSD
  DEC ECX
  JNZ @icsub15_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBcolorLM15(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM4,EAX
  PUNPCKLWD MM4,MM4
  PUNPCKLDQ MM4,MM4
  MOV EAX,83E07C1Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,7C1F83E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@icsubm15_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  POR MM0,MM3
  POR MM1,MM2
  PSUBW MM0,MM4
  PSUBW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm15_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSUBcolorL16(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  sHL EBX,16
  MOV BX,AX
@icsub16_loop1:
  LODSD
  MOV EDX,EAX
  OR EAX,0F81F07E0h
  OR EDX,07E0F81Fh
  SUB EAX,EBX
  SUB EDX,EBX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  STOSD
  DEC ECX
  JNZ @icsub16_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBcolorLM16(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM4,EAX
  PUNPCKLWD MM4,MM4
  PUNPCKLDQ MM4,MM4
  MOV EAX,07E0F81Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,0F81F07E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@icsubm16_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  POR MM0,MM3
  POR MM1,MM2
  PSUBW MM0,MM4
  PSUBW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSUBcolorL24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  SHL EBX,8
  MOV BL,BH
  ROR EBX,8
@icsub24_loop1:
  LODSD
  SUB AL,BL
  SUB AH,BH
  ROR EAX,16
  ROR EBX,16
  SUB AL,BL
  SUB AH,BH
  ROR EAX,16
  ROR EBX,16
  STOSD
  MOV BL,BH
  ROR EBX,8
  DEC ECX
  JNZ @icsub24_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBcolorLM24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@icsubm24_loop1:
  MOVQ MM2,MM1
  MOVQ MM0,[ESI]
  PSUBB MM0,MM1
  MOVQ [EDI],MM0
  PSRLQ MM1,16
  PSLLQ MM2,32
  ADD ESI,8
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @icsubm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSUBcolorL32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
@icsub32_loop1:
  LODSD
  SUB AL,BL
  SUB AH,BH
  ROR EAX,16
  ROR EBX,16
  SUB AL,BL
  ROR EAX,16
  ROR EBX,16
  STOSD
  DEC ECX
  JNZ @icsub32_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBcolorLM32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLDQ MM1,MM1
@icsubm32_loop1:
  MOVQ MM0,[ESI]
  PSUBB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageSADDcolor ----------------------------------}

FUNCTION imageSADDcolorL8(dst,src:pimage;color:longint):pimage;assembler;
VAR rbg,grb:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV BH,BL
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV EAX,EBX
  AND EAX,01CE31CE3h
  AND EBX,0E31CE31Ch
  MOV grb,EAX
  MOV rbg,EBX
@icadd8_loop1:
  LODSD
  PUSH ECX
  MOV EDX,EAX
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
{---}
  ADD EAX,grb
  MOV ECX,EAX
  RCR ECX,1
  AND ECX,010821082h
  OR EAX,ECX
  SHR ECX,1
  OR EAX,ECX
  SHR ECX,1
  OR EAX,ECX
{---}
  ADD EDX,rbg
  MOV ECX,EDX
  RCR ECX,1
  AND ECX,082108210h
  OR EDX,ECX
  SHR ECX,1
  OR EDX,ECX
  SHR ECX,1
  OR EDX,ECX
{---}
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  POP ECX
  STOSD
  DEC ECX
  JNZ @icadd8_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDcolorLM8(dst,src:pimage;color:longint):pimage;assembler;
CONST m1CE3:array[0..3] of word=($1CE3,$1CE3,$1CE3,$1CE3);
      m2004:array[0..3] of word=($2004,$2004,$2004,$2004);
      m0100:array[0..3] of word=($0100,$0100,$0100,$0100);
      m00FF:array[0..3] of word=($00FF,$00FF,$00FF,$00FF);
      m1C03:array[0..3] of word=($1C03,$1C03,$1C03,$1C03);
      m00E0:array[0..3] of word=($00E0,$00E0,$00E0,$00E0);
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM7,EAX
  PUNPCKLBW MM7,MM7
  PUNPCKLWD MM7,MM7
  PUNPCKLDQ MM7,MM7
  PAND MM7,m1CE3
@icaddm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI]
  PUNPCKLBW MM0,MM0
  PUNPCKHBW MM1,MM1
  PAND MM0,m1CE3
  PAND MM1,m1CE3
  PADDW MM0,MM7
  PADDW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM0
  MOVQ MM4,MM1
  MOVQ MM5,MM1
  PAND MM2,m2004
  PAND MM3,m0100
  PAND MM4,m2004
  PAND MM5,m0100
  PCMPEQB MM2,m2004
  PCMPEQW MM3,m0100
  PCMPEQB MM4,m2004
  PCMPEQW MM5,m0100
  PAND MM2,m1C03
  PAND MM3,m00E0
  PAND MM4,m1C03
  PAND MM5,m00E0
  POR MM0,MM2
  POR MM1,MM4
  POR MM0,MM3
  POR MM1,MM5
  MOVQ MM5,MM0
  MOVQ MM6,MM1
  PSRLW MM5,8
  PSRLW MM6,8
  POR MM0,MM5
  POR MM1,MM6
  PAND MM0,m00FF
  PAND MM1,m00FF
  PACKUSWB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSADDcolorL15(dst,src:pimage;color:longint):pimage;assembler;
VAR rbg,grb:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV EAX,EBX
  AND EAX,03E07C1Fh
  AND EBX,7C1F03E0h
  MOV grb,EAX
  MOV rbg,EBX
@icadd15_loop1:
  PUSH ECX
  LODSD
  MOV EDX,EAX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  ADD EAX,grb
  ADD EDX,rbg
  MOV EBX,EAX
  AND EBX,04008020h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  OR EAX,ECX
  MOV EBX,EDX
  AND EBX,80200400h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  OR EDX,ECX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  POP ECX
  STOSD
  DEC ECX
  JNZ @icadd15_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDcolorLM15(dst,src:pimage;color:longint):pimage;assembler;
CONST m7C1F:array[0..3] of word=($7C1F,$7C1F,$7C1F,$7C1F);
      m03E0:array[0..3] of word=($03E0,$03E0,$03E0,$03E0);
      m8020:array[0..3] of word=($8020,$8020,$8020,$8020);
      m0400:array[0..3] of word=($0400,$0400,$0400,$0400);
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM6,EAX
  PUNPCKLWD MM6,MM6
  PUNPCKLDQ MM6,MM6
  MOVQ MM7,MM6
  PAND MM6,m7C1F
  PAND MM7,m03E0
@icaddm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI]
  PAND MM0,m7C1F
  PAND MM1,m03E0
  PADDB MM0,MM6
  PADDW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m8020
  PAND MM3,m0400
  PCMPEQB MM2,m8020
  PCMPEQW MM3,m0400
  PAND MM2,m7C1F
  PAND MM3,m03E0
  PAND MM0,m7C1F
  PAND MM1,m03E0
  POR MM0,MM2
  POR MM0,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSADDcolorL16(dst,src:pimage;color:longint):pimage;assembler;
VAR rbg,grb:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV EAX,EBX
  AND EAX,07E0F81Fh
  AND EBX,0F81F07E0h
  MOV grb,EAX
  MOV rbg,EBX
@icadd16_loop1:
  PUSH ECX
  LODSD
  MOV EDX,EAX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  ADD EAX,grb
  ADD EDX,rbg
  PUSHF
  MOV EBX,EAX
  AND EBX,08010020h
  MOV ECX,EBX
  SHR EBX,6
  SBB ECX,EBX
  OR EAX,ECX
  MOV EBX,EDX
  AND EBX,00200800h
  MOV ECX,EBX
  POPF
  RCR EBX,1
  SHR EBX,5
  SUB ECX,EBX
  OR EDX,ECX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  POP ECX
  STOSD
  DEC ECX
  JNZ @icadd16_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDcolorLM16(dst,src:pimage;color:longint):pimage;assembler;
CONST mF81F:array[0..3] of word=($F81F,$F81F,$F81F,$F81F);
      m07E0:array[0..3] of word=($07E0,$07E0,$07E0,$07E0);
      m0020:array[0..3] of word=($FF20,$FF20,$FF20,$FF20);
      m0800:array[0..3] of word=($0800,$0800,$0800,$0800);
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM6,EAX
  PUNPCKLWD MM6,MM6
  PUNPCKLDQ MM6,MM6
  MOVQ MM7,MM6
  PAND MM6,mF81F
  PAND MM7,m07E0
@icaddm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI]
  PAND MM0,mF81F
  PAND MM1,m07E0
  PADDUSB MM0,MM6
  PADDW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m0020
  PAND MM3,m0800
  PCMPEQB MM2,m0020
  PCMPEQW MM3,m0800
  PAND MM2,mF81F
  PAND MM3,m07E0
  PAND MM0,mF81F
  PAND MM1,m07E0
  POR MM0,MM2
  POR MM0,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSADDcolorL24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  SHL EBX,8
  MOV BL,BH
  ROR EBX,8
@icadd24_loop1:
  LODSD
  ADD AL,BL
  SETC DL
  ADD AH,BH
  SETC DH
  NEG DL
  NEG DH
  OR AX,DX
  ROR EAX,16
  ROR EBX,16
  ADD AL,BL
  SETC DL
  ADD AH,BH
  SETC DH
  NEG DL
  NEG DH
  OR AX,DX
  ROR EAX,16
  ROR EBX,16
  STOSD
  MOV BL,BH
  ROR EBX,8
  DEC ECX
  JNZ @icadd24_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDcolorLM24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@icaddm24_loop1:
  MOVQ MM2,MM1
  MOVQ MM0,[ESI]
  PADDUSB MM0,MM1
  MOVQ [EDI],MM0
  PSRLQ MM1,16
  PSLLQ MM2,32
  ADD ESI,8
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @icaddm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSADDcolorL32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
@icadd32_loop1:
  LODSD
  ADD AL,BL
  SETC DL
  ADD AH,BH
  SETC DH
  NEG DL
  NEG DH
  OR AX,DX
  ROR EAX,16
  ROR EBX,16
  ADD AL,BL
  SETC DL
  NEG DL
  NEG DH
  OR AL,DL
  ROR EAX,16
  ROR EBX,16
  STOSD
  DEC ECX
  JNZ @icadd32_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDcolorLM32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLDQ MM1,MM1
@icaddm32_loop1:
  MOVQ MM0,[ESI]
  PADDUSB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icaddm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageSUBcolor ----------------------------------}

FUNCTION imageSSUBcolorL8(dst,src:pimage;color:longint):pimage;assembler;
VAR rbg,grb:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV BH,BL
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV EAX,EBX
  AND EAX,01CE31CE3h
  AND EBX,0E31CE31Ch
  MOV grb,EAX
  MOV rbg,EBX
@icsub8_loop1:
  LODSD
  PUSH ECX
  MOV EDX,EAX
  OR EAX,0E31CE31Ch
  OR EDX,01CE31CE3h
{---}
  SUB EAX,grb
  MOV ECX,EAX
  RCR ECX,1
  OR ECX,0EF7DEF7Dh
  AND EAX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EAX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EAX,ECX
{---}
  SUB EDX,rbg
  MOV ECX,EDX
  RCR ECX,1
  XOR ECX,80000000h
  OR ECX,07DEF7DEFh
  AND EDX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EDX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EDX,ECX
{---}
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  POP ECX
  STOSD
  DEC ECX
  JNZ @icsub8_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorLM8(dst,src:pimage;color:longint):pimage;assembler;
CONST m1CE3:array[0..3] of word=($1CE3,$1CE3,$1CE3,$1CE3);
      mE31C:array[0..3] of word=($E31C,$E31C,$E31C,$E31C);
      m2004:array[0..3] of word=($2004,$2004,$2004,$2004);
      m0100:array[0..3] of word=($0100,$0100,$0100,$0100);
      m00FF:array[0..3] of word=($00FF,$00FF,$00FF,$00FF);
      m1C03:array[0..3] of word=($1C03,$1C03,$1C03,$1C03);
      m00E0:array[0..3] of word=($00E0,$00E0,$00E0,$00E0);
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM7,EAX
  PUNPCKLBW MM7,MM7
  PUNPCKLWD MM7,MM7
  PUNPCKLDQ MM7,MM7
  PAND MM7,m1CE3
@icsubm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI]
  PUNPCKLBW MM0,MM0
  PUNPCKHBW MM1,MM1
  POR MM0,mE31C
  POR MM1,mE31C
  PSUBW MM0,MM7
  PSUBW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM0
  MOVQ MM4,MM1
  MOVQ MM5,MM1
  PAND MM2,m2004
  PAND MM3,m0100
  PAND MM4,m2004
  PAND MM5,m0100
  PCMPEQB MM2,m2004
  PCMPEQW MM3,m0100
  PCMPEQB MM4,m2004
  PCMPEQW MM5,m0100
  PAND MM2,m1C03
  PAND MM3,m00E0
  PAND MM4,m1C03
  PAND MM5,m00E0
  POR MM2,MM3
  POR MM4,MM5
  PAND MM0,MM2
  PAND MM1,MM4
  MOVQ MM5,MM0
  MOVQ MM6,MM1
  PSRLW MM5,8
  PSRLW MM6,8
  POR MM0,MM5
  POR MM1,MM6
  PAND MM0,m00FF
  PAND MM1,m00FF
  PACKUSWB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorL15(dst,src:pimage;color:longint):pimage;assembler;
VAR rbg,grb:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV EAX,EBX
  AND EAX,03E07C1Fh
  AND EBX,7C1F03E0h
  MOV grb,EAX
  MOV rbg,EBX
@icsub15_loop1:
  PUSH ECX
  LODSD
  MOV EDX,EAX
  OR EAX,7C1F83E0h
  OR EDX,83E07C1Fh
  SUB EAX,grb
  SUB EDX,rbg
  MOV EBX,EAX
  AND EBX,04008020h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  AND EAX,ECX
  MOV EBX,EDX
  AND EBX,80200400h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  AND EDX,ECX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  POP ECX
  STOSD
  DEC ECX
  JNZ @icsub15_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorLM15(dst,src:pimage;color:longint):pimage;assembler;
CONST m7C1F:array[0..3] of word=($7C1F,$7C1F,$7C1F,$7C1F);
      m03E0:array[0..3] of word=($83E0,$83E0,$83E0,$83E0);
      m8020:array[0..3] of word=($8020,$8020,$8020,$8020);
      m0400:array[0..3] of word=($0400,$0400,$0400,$0400);
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM6,EAX
  PUNPCKLWD MM6,MM6
  PUNPCKLDQ MM6,MM6
  MOVQ MM7,MM6
  PAND MM6,m7C1F
  PAND MM7,m03E0
@icsubm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI]
  POR MM0,m03E0
  POR MM1,m7C1F
  PSUBB MM0,MM6
  PSUBW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m8020
  PAND MM3,m0400
  PCMPEQB MM2,m8020
  PCMPEQW MM3,m0400
  PAND MM2,m7C1F
  PAND MM3,m03E0
  PAND MM0,m7C1F
  PAND MM1,m03E0
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorL16(dst,src:pimage;color:longint):pimage;assembler;
VAR rbg,grb:dword;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV EAX,EBX
  AND EAX,007E0F81Fh
  AND EBX,0F81F07E0h
  MOV grb,EAX
  MOV rbg,EBX
@icsub16_loop1:
  PUSH ECX
  LODSD
  MOV EDX,EAX
  OR EAX,0F81F07E0h
  OR EDX,007E0F81Fh
  SUB EAX,grb
  SUB EDX,rbg
  PUSHF
  MOV EBX,EAX
  AND EBX,08010020h
  MOV ECX,EBX
  SHR EBX,6
  SBB ECX,EBX
  AND EAX,ECX
  MOV EBX,EDX
  AND EBX,00200800h
  MOV ECX,EBX
  POPF
  RCR EBX,1
  XOR EBX,80000000h
  SHR EBX,5
  SUB ECX,EBX
  AND EDX,ECX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  POP ECX
  STOSD
  DEC ECX
  JNZ @icsub16_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorLM16(dst,src:pimage;color:longint):pimage;assembler;
CONST mF81F:array[0..3] of word=($F81F,$F81F,$F81F,$F81F);
      m07E0:array[0..3] of word=($07E0,$07E0,$07E0,$07E0);
      m0020:array[0..3] of word=($0020,$0020,$0020,$0020);
      m0800:array[0..3] of word=($0800,$0800,$0800,$0800);
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM6,EAX
  PUNPCKLWD MM6,MM6
  PUNPCKLDQ MM6,MM6
  MOVQ MM7,MM6
  PAND MM6,mF81F
  PAND MM7,m07E0
@icsubm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI]
  POR MM0,m07E0
  POR MM1,mF81F
  PSUBUSB MM0,MM6
  PSUBW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m0020
  PAND MM3,m0800
  PCMPEQB MM2,m0020
  PCMPEQW MM3,m0800
  PAND MM2,mF81F
  PAND MM3,m07E0
  PAND MM0,mF81F
  PAND MM1,m07E0

  PAND MM0,MM2
  PAND MM1,MM3

  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorL24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  SHL EBX,8
  MOV BL,BH
  ROR EBX,8
@icsub24_loop1:
  LODSD
  SUB AL,BL
  SETNC DL
  SUB AH,BH
  SETNC DH
  NEG DL
  NEG DH
  AND AX,DX
  ROR EAX,16
  ROR EBX,16
  SUB AL,BL
  SETNC DL
  SUB AH,BH
  SETNC DH
  NEG DL
  NEG DH
  AND AX,DX
  ROR EAX,16
  ROR EBX,16
  STOSD
  MOV BL,BH
  ROR EBX,8
  DEC ECX
  JNZ @icsub24_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorLM24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@icsubm24_loop1:
  MOVQ MM2,MM1
  MOVQ MM0,[ESI]
  PSUBUSB MM0,MM1
  MOVQ [EDI],MM0
  PSRLQ MM1,16
  PSLLQ MM2,32
  ADD ESI,8
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @icsubm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorL32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
@icsub32_loop1:
  LODSD
  SUB AL,BL
  SETNC DL
  SUB AH,BH
  SETNC DH
  NEG DL
  NEG DH
  AND AX,DX
  ROR EAX,16
  ROR EBX,16
  SUB AL,BL
  SETNC DL
  NEG DL
  AND AL,DL
  ROR EAX,16
  ROR EBX,16
  STOSD
  DEC ECX
  JNZ @icsub32_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBcolorLM32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLDQ MM1,MM1
@icsubm32_loop1:
  MOVQ MM0,[ESI]
  PSUBUSB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icsubm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageANDcolor ----------------------------------}

FUNCTION imageANDcolorLbyte(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EBX,color
  MOV BH,BL
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@iand8_loop1:
  LODSD
  AND EAX,EBX
  STOSD
  DEC ECX
  JNZ @iand8_loop1
  MOV EAX,dst
END;

FUNCTION imageANDcolorLMbyte(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLBW MM1,MM1
  PUNPCKLWD MM1,MM1
  PUNPCKLDQ MM1,MM1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icandm8_loop1:
  MOVQ MM0,[ESI]
  PAND MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icandm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageANDcolorLword(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@iand16_loop1:
  LODSD
  AND EAX,EBX
  STOSD
  DEC ECX
  JNZ @iand16_loop1
  MOV EAX,dst
END;

FUNCTION imageANDcolorLMword(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLWD MM1,MM1
  PUNPCKLDQ MM1,MM1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icandm16_loop1:
  MOVQ MM0,[ESI]
  PAND MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icandm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageANDcolorL24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  SHL EBX,8
  MOV BL,BH
  ROR EBX,8
@iand24_loop1:
  LODSD
  AND EAX,EBX
  STOSD
  MOV BL,BH
  ROR EBX,8
  DEC ECX
  JNZ @iand24_loop1
  MOV EAX,dst
END;

FUNCTION imageANDcolorLM24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@icandm24_loop1:
  MOVQ MM2,MM1
  MOVQ MM0,[ESI]
  PAND MM0,MM1
  MOVQ [EDI],MM0
  PSRLQ MM1,16
  PSLLQ MM2,32
  ADD ESI,8
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @icandm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageANDcolorL32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
@iand32_loop1:
  LODSD
  AND EAX,EBX
  STOSD
  DEC ECX
  JNZ @iand32_loop1
  MOV EAX,dst
END;

FUNCTION imageANDcolorLM32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLDQ MM1,MM1
@icandm32_loop1:
  MOVQ MM0,[ESI]
  PAND MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icandm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageORcolor ----------------------------------}

FUNCTION imageORcolorLbyte(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EBX,color
  MOV BH,BL
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@ior8_loop1:
  LODSD
  OR EAX,EBX
  STOSD
  DEC ECX
  JNZ @ior8_loop1
  MOV EAX,dst
END;

FUNCTION imageORcolorLMbyte(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLBW MM1,MM1
  PUNPCKLWD MM1,MM1
  PUNPCKLDQ MM1,MM1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icorm8_loop1:
  MOVQ MM0,[ESI]
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icorm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageORcolorLword(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icor16_loop1:
  LODSD
  OR EAX,EBX
  STOSD
  DEC ECX
  JNZ @icor16_loop1
  MOV EAX,dst
END;

FUNCTION imageORcolorLMword(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLWD MM1,MM1
  PUNPCKLDQ MM1,MM1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icorm16_loop1:
  MOVQ MM0,[ESI]
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icorm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageORcolorL24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  SHL EBX,8
  MOV BL,BH
  ROR EBX,8
@icor24_loop1:
  LODSD
  OR EAX,EBX
  STOSD
  MOV BL,BH
  ROR EBX,8
  DEC ECX
  JNZ @icor24_loop1
  MOV EAX,dst
END;

FUNCTION imageORcolorLM24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@icorm24_loop1:
  MOVQ MM2,MM1
  MOVQ MM0,[ESI]
  POR MM0,MM1
  MOVQ [EDI],MM0
  PSRLQ MM1,16
  PSLLQ MM2,32
  ADD ESI,8
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @icorm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageORcolorL32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
@icor32_loop1:
  LODSD
  OR EAX,EBX
  STOSD
  DEC ECX
  JNZ @icor32_loop1
  MOV EAX,dst
END;

FUNCTION imageORcolorLM32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLDQ MM1,MM1
@icorm32_loop1:
  MOVQ MM0,[ESI]
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icorm32_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageXORcolor ----------------------------------}

FUNCTION imageXORcolorLbyte(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EBX,color
  MOV BH,BL
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@ixor8_loop1:
  LODSD
  XOR EAX,EBX
  STOSD
  DEC ECX
  JNZ @ixor8_loop1
  MOV EAX,dst
END;

FUNCTION imageXORcolorLMbyte(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLBW MM1,MM1
  PUNPCKLWD MM1,MM1
  PUNPCKLDQ MM1,MM1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icxorm8_loop1:
  MOVQ MM0,[ESI]
  PXOR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icxorm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageXORcolorLword(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EBX,color
  MOV AX,BX
  SHL EBX,16
  MOV BX,AX
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icxor16_loop1:
  LODSD
  XOR EAX,EBX
  STOSD
  DEC ECX
  JNZ @icxor16_loop1
  MOV EAX,dst
END;

FUNCTION imageXORcolorLMword(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLWD MM1,MM1
  PUNPCKLDQ MM1,MM1
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
@icxorm16_loop1:
  MOVQ MM0,[ESI]
  PXOR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icxorm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageXORcolorL24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
  SHL EBX,8
  MOV BL,BH
  ROR EBX,8
@icxor24_loop1:
  LODSD
  XOR EAX,EBX
  STOSD
  MOV BL,BH
  ROR EBX,8
  DEC ECX
  JNZ @icxor24_loop1
  MOV EAX,dst
END;

FUNCTION imageXORcolorLM24(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@icxorm24_loop1:
  MOVQ MM2,MM1
  MOVQ MM0,[ESI]
  PXOR MM0,MM1
  MOVQ [EDI],MM0
  PSRLQ MM1,16
  PSLLQ MM2,32
  ADD ESI,8
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @icxorm24_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageXORcolorL32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,color
@icxor32_loop1:
  LODSD
  XOR EAX,EBX
  STOSD
  DEC ECX
  JNZ @icxor32_loop1
  MOV EAX,dst
END;

FUNCTION imageXORcolorLM32(dst,src:pimage;color:longint):pimage;assembler;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM1,EAX
  PUNPCKLDQ MM1,MM1
@icxorm32_loop1:
  MOVQ MM0,[ESI]
  PXOR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @icxorm32_loop1
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{--------------------------- imageADDimage ----------------------------------}

FUNCTION imageADDimageL8(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiadd8_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  LODSD
  MOV EDX,EAX
  AND EAX,01CE31CE3h
  AND EBX,01CE31CE3h
  AND ECX,0E31CE31Ch
  AND EDX,0E31CE31Ch
  ADD EAX,EBX
  ADD EDX,ECX
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @iiadd8_loop1
  MOV EAX,dst
END;

FUNCTION imageADDimageLM8(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiaddm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  MOVQ MM4,[ESI+EBX]
  MOVQ MM5,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  PAND MM4,MM2
  PAND MM5,MM3
  PADDB MM0,MM4
  PADDB MM1,MM5
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageADDimageL15(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiadd15_loop1:
  PUSH EBX
  MOV EBX,[ESI+EBX]
  LODSD
  MOV EDX,EAX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  ADD EAX,EBX
  ADD EDX,EBX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  STOSD
  POP EBX
  DEC ECX
  JNZ @iiadd15_loop1
  MOV EAX,dst
END;

FUNCTION imageADDimageLM15(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
  MOV EAX,83E07C1Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,7C1F83E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@iiaddm15_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  MOVQ MM4,[ESI+EBX]
  PAND MM0,MM2
  PAND MM1,MM3
  PADDW MM0,MM4
  PADDW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddm15_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageADDimageL16(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiadd16_loop1:
  PUSH EBX
  MOV EBX,[ESI+EBX]
  LODSD
  MOV EDX,EAX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  ADD EAX,EBX
  ADD EDX,EBX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  STOSD
  POP EBX
  DEC ECX
  JNZ @iiadd16_loop1
  MOV EAX,dst
END;

FUNCTION imageADDimageLM16(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
  MOV EAX,07E0F81Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,0F81F07E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@iiaddm16_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  MOVQ MM4,[ESI+EBX]
  PAND MM0,MM2
  PAND MM1,MM3
  PADDW MM0,MM4
  PADDW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageADDimageLtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiaddtc_loop1:
  MOV EDX,[ESI+EBX]
  LODSD
  ADD AL,DL
  ADD AH,DH
  ROR EAX,16
  ROR EDX,16
  ADD AL,DL
  ADD AH,DH
  ROR EAX,16
  ROR EDX,16
  STOSD
  DEC ECX
  JNZ @iiaddtc_loop1
  MOV EAX,dst
END;

FUNCTION imageADDimageLMtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiaddmtc_loop1:
  MOVQ MM0,[ESI]
  PADDB MM0,[ESI+EBX]
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddmtc_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageSUBimage ----------------------------------}

FUNCTION imageSUBimageL8(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisub8_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  LODSD
  MOV EDX,EAX
  OR EAX,0E31CE31Ch
  OR EDX,01CE31CE3h
  AND EBX,01CE31CE3h
  AND ECX,0E31CE31Ch
  SUB EAX,EBX
  SUB EDX,ECX
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @iisub8_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBimageLM8(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisubm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  MOVQ MM4,[ESI+EBX]
  MOVQ MM5,MM4
  POR MM0,MM3
  POR MM1,MM2
  PAND MM4,MM2
  PAND MM5,MM3
  PSUBB MM0,MM4
  PSUBB MM1,MM5
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSUBimageL15(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisub15_loop1:
  PUSH EBX
  MOV EBX,[ESI+EBX]
  LODSD
  MOV EDX,EAX
  OR EAX,7C1F83E0h
  OR EDX,83E07C1Fh
  SUB EAX,EBX
  SUB EDX,EBX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  STOSD
  POP EBX
  DEC ECX
  JNZ @iisub15_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBimageLM15(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
  MOV EAX,83E07C1Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,7C1F83E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@iisubm15_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  MOVQ MM4,[ESI+EBX]
  POR MM0,MM3
  POR MM1,MM2
  PSUBW MM0,MM4
  PSUBW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubm15_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSUBimageL16(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisub16_loop1:
  PUSH EBX
  MOV EBX,[ESI+EBX]
  LODSD
  MOV EDX,EAX
  OR EAX,0F81F07E0h
  OR EDX,07E0F81Fh
  SUB EAX,EBX
  SUB EDX,EBX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  STOSD
  POP EBX
  DEC ECX
  JNZ @iisub16_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBimageLM16(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
  MOV EAX,07E0F81Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,0F81F07E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@iisubm16_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM1,MM0
  MOVQ MM4,[ESI+EBX]
  POR MM0,MM3
  POR MM1,MM2
  PSUBW MM0,MM4
  PSUBW MM1,MM4
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSUBimageLtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisubtc_loop1:
  MOV EDX,[ESI+EBX]
  LODSD
  SUB AL,DL
  SUB AH,DH
  ROR EAX,16
  ROR EDX,16
  SUB AL,DL
  SUB AH,DH
  ROR EAX,16
  ROR EDX,16
  STOSD
  DEC ECX
  JNZ @iisubtc_loop1
  MOV EAX,dst
END;

FUNCTION imageSUBimageLMtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisubmtc_loop1:
  MOVQ MM0,[ESI]
  PSUBB MM0,[ESI+EBX]
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubmtc_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageSADDimage ---------------------------------}

FUNCTION imageSADDimageL8(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@icadd8_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  AND ECX,01CE31CE3h
  AND EBX,0E31CE31Ch
  LODSD
  MOV EDX,EAX
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
{---}
  ADD EAX,ECX
  MOV ECX,EAX
  RCR ECX,1
  AND ECX,010821082h
  OR EAX,ECX
  SHR ECX,1
  OR EAX,ECX
  SHR ECX,1
  OR EAX,ECX
{---}
  ADD EDX,EBX
  MOV ECX,EDX
  RCR ECX,1
  AND ECX,082108210h
  OR EDX,ECX
  SHR ECX,1
  OR EDX,ECX
  SHR ECX,1
  OR EDX,ECX
{---}
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @icadd8_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDimageLM8(dst,src1,src2:pimage):pimage;assembler;
CONST m1CE3:array[0..3] of word=($1CE3,$1CE3,$1CE3,$1CE3);
      m2004:array[0..3] of word=($2004,$2004,$2004,$2004);
      m0100:array[0..3] of word=($0100,$0100,$0100,$0100);
      m00FF:array[0..3] of word=($00FF,$00FF,$00FF,$00FF);
      m1C03:array[0..3] of word=($1C03,$1C03,$1C03,$1C03);
      m00E0:array[0..3] of word=($00E0,$00E0,$00E0,$00E0);
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiaddm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM6,[ESI+EBX]
  MOVQ MM1,MM0
  MOVQ MM7,MM6
  PUNPCKLBW MM0,MM0
  PUNPCKHBW MM1,MM1
  PUNPCKLBW MM6,MM6
  PUNPCKHBW MM7,MM7
  PAND MM0,m1CE3
  PAND MM1,m1CE3
  PAND MM6,m1CE3
  PAND MM7,m1CE3
  PADDW MM0,MM6
  PADDW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM0
  MOVQ MM4,MM1
  MOVQ MM5,MM1
  PAND MM2,m2004
  PAND MM3,m0100
  PAND MM4,m2004
  PAND MM5,m0100
  PCMPEQB MM2,m2004
  PCMPEQW MM3,m0100
  PCMPEQB MM4,m2004
  PCMPEQW MM5,m0100
  PAND MM2,m1C03
  PAND MM3,m00E0
  PAND MM4,m1C03
  PAND MM5,m00E0
  POR MM0,MM2
  POR MM1,MM4
  POR MM0,MM3
  POR MM1,MM5
  MOVQ MM5,MM0
  MOVQ MM6,MM1
  PSRLW MM5,8
  PSRLW MM6,8
  POR MM0,MM5
  POR MM1,MM6
  PAND MM0,m00FF
  PAND MM1,m00FF
  PACKUSWB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSADDimageL15(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@icadd15_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  AND ECX,03E07C1Fh
  AND EBX,7C1F03E0h
  LODSD
  MOV EDX,EAX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  ADD EAX,ECX
  ADD EDX,EBX
  MOV EBX,EAX
  AND EBX,04008020h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  OR EAX,ECX
  MOV EBX,EDX
  AND EBX,80200400h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  OR EDX,ECX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @icadd15_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDimageLM15(dst,src1,src2:pimage):pimage;assembler;
CONST m7C1F:array[0..3] of word=($7C1F,$7C1F,$7C1F,$7C1F);
      m03E0:array[0..3] of word=($03E0,$03E0,$03E0,$03E0);
      m8020:array[0..3] of word=($8020,$8020,$8020,$8020);
      m0400:array[0..3] of word=($0400,$0400,$0400,$0400);
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiaddm15_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM6,[ESI+EBX]
  MOVQ MM1,MM0
  MOVQ MM7,MM6
  PAND MM0,m7C1F
  PAND MM1,m03E0
  PAND MM6,m7C1F
  PAND MM7,m03E0
  PADDB MM0,MM6
  PADDW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m8020
  PAND MM3,m0400
  PCMPEQB MM2,m8020
  PCMPEQW MM3,m0400
  PAND MM2,m7C1F
  PAND MM3,m03E0
  PAND MM0,m7C1F
  PAND MM1,m03E0
  POR MM0,MM2
  POR MM0,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddm15_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSADDimageL16(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@icadd16_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  AND ECX,07E0F81Fh
  AND EBX,0F81F07E0h
  LODSD
  MOV EDX,EAX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  ADD EAX,ECX
  ADD EDX,EBX
  PUSHF
  MOV EBX,EAX
  AND EBX,08010020h
  MOV ECX,EBX
  SHR EBX,6
  SBB ECX,EBX
  OR EAX,ECX
  MOV EBX,EDX
  AND EBX,00200800h
  MOV ECX,EBX
  POPF
  RCR EBX,1
  SHR EBX,5
  SUB ECX,EBX
  OR EDX,ECX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @icadd16_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDimageLM16(dst,src1,src2:pimage):pimage;assembler;
CONST mF81F:array[0..3] of word=($F81F,$F81F,$F81F,$F81F);
      m07E0:array[0..3] of word=($07E0,$07E0,$07E0,$07E0);
      m0020:array[0..3] of word=($FF20,$FF20,$FF20,$FF20);
      m0800:array[0..3] of word=($0800,$0800,$0800,$0800);
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiaddm16_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM6,[ESI+EBX]
  MOVQ MM1,MM0
  MOVQ MM7,MM6
  PAND MM0,mF81F
  PAND MM1,m07E0
  PAND MM6,mF81F
  PAND MM7,m07E0
  PADDUSB MM0,MM6
  PADDW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m0020
  PAND MM3,m0800
  PCMPEQB MM2,m0020
  PCMPEQW MM3,m0800
  PAND MM2,mF81F
  PAND MM3,m07E0
  PAND MM0,mF81F
  PAND MM1,m07E0
  POR MM0,MM2
  POR MM0,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSADDimageLtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@icadd32_loop1:
  PUSH EBX
  MOV EBX,[ESI+EBX]
  LODSD
  ADD AL,BL
  SETC DL
  ADD AH,BH
  SETC DH
  NEG DL
  NEG DH
  OR AX,DX
  ROR EAX,16
  ROR EBX,16
  ADD AL,BL
  SETC DL
  NEG DL
  NEG DH
  OR AL,DL
  ROR EAX,16
  ROR EBX,16
  STOSD
  POP EBX
  DEC ECX
  JNZ @icadd32_loop1
  MOV EAX,dst
END;

FUNCTION imageSADDimageLMtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiaddmtc_loop1:
  MOVQ MM0,[ESI]
  PADDUSB MM0,[ESI+EBX]
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiaddmtc_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageSSUBimage ---------------------------------}

FUNCTION imageSSUBimageL8(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI

@icsub8_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  AND ECX,01CE31CE3h
  AND EBX,0E31CE31Ch
  LODSD
  MOV EDX,EAX
  OR EAX,0E31CE31Ch
  OR EDX,01CE31CE3h
{---}
  SUB EAX,ECX
  MOV ECX,EAX
  RCR ECX,1
  OR ECX,0EF7DEF7Dh
  AND EAX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EAX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EAX,ECX
{---}
  SUB EDX,EBX
  MOV ECX,EDX
  RCR ECX,1
  XOR ECX,80000000h
  OR ECX,07DEF7DEFh
  AND EDX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EDX,ECX
  SHR ECX,1
  OR ECX,80000000h
  AND EDX,ECX
{---}
  AND EAX,01CE31CE3h
  AND EDX,0E31CE31Ch
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @icsub8_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBimageLM8(dst,src1,src2:pimage):pimage;assembler;
CONST m1CE3:array[0..3] of word=($1CE3,$1CE3,$1CE3,$1CE3);
      mE31C:array[0..3] of word=($E31C,$E31C,$E31C,$E31C);
      m2004:array[0..3] of word=($2004,$2004,$2004,$2004);
      m0100:array[0..3] of word=($0100,$0100,$0100,$0100);
      m00FF:array[0..3] of word=($00FF,$00FF,$00FF,$00FF);
      m1C03:array[0..3] of word=($1C03,$1C03,$1C03,$1C03);
      m00E0:array[0..3] of word=($00E0,$00E0,$00E0,$00E0);
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisubm8_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM6,[ESI+EBX]
  MOVQ MM1,MM0
  MOVQ MM7,MM6
  PUNPCKLBW MM0,MM0
  PUNPCKHBW MM1,MM1
  PUNPCKLBW MM6,MM6
  PUNPCKHBW MM7,MM7
  POR MM0,mE31C
  POR MM1,mE31C
  PAND MM6,m1CE3
  PAND MM7,m1CE3
  PSUBW MM0,MM6
  PSUBW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM0
  MOVQ MM4,MM1
  MOVQ MM5,MM1
  PAND MM2,m2004
  PAND MM3,m0100
  PAND MM4,m2004
  PAND MM5,m0100
  PCMPEQB MM2,m2004
  PCMPEQW MM3,m0100
  PCMPEQB MM4,m2004
  PCMPEQW MM5,m0100
  PAND MM2,m1C03
  PAND MM3,m00E0
  PAND MM4,m1C03
  PAND MM5,m00E0
  POR MM2,MM3
  POR MM4,MM5
  PAND MM0,MM2
  PAND MM1,MM4
  MOVQ MM5,MM0
  MOVQ MM6,MM1
  PSRLW MM5,8
  PSRLW MM6,8
  POR MM0,MM5
  POR MM1,MM6
  PAND MM0,m00FF
  PAND MM1,m00FF
  PACKUSWB MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubm8_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSSUBimageL15(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@icsub15_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  AND ECX,03E07C1Fh
  AND EBX,7C1F03E0h
  LODSD
  MOV EDX,EAX
  OR EAX,7C1F83E0h
  OR EDX,83E07C1Fh
  SUB EAX,ECX
  SUB EDX,EBX
  MOV EBX,EAX
  AND EBX,04008020h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  AND EAX,ECX
  MOV EBX,EDX
  AND EBX,80200400h
  MOV ECX,EBX
  SHR EBX,5
  SUB ECX,EBX
  AND EDX,ECX
  AND EAX,03E07C1Fh
  AND EDX,7C1F03E0h
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @icsub15_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBimageLM15(dst,src1,src2:pimage):pimage;assembler;
CONST m7C1F:array[0..3] of word=($7C1F,$7C1F,$7C1F,$7C1F);
      m03E0:array[0..3] of word=($83E0,$83E0,$83E0,$83E0);
      m8020:array[0..3] of word=($8020,$8020,$8020,$8020);
      m0400:array[0..3] of word=($0400,$0400,$0400,$0400);
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisubm15_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM6,[ESI+EBX]
  MOVQ MM1,MM0
  MOVQ MM7,MM6
  POR MM0,m03E0
  POR MM1,m7C1F
  PAND MM6,m7C1F
  PAND MM7,m03E0
  PSUBB MM0,MM6
  PSUBW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m8020
  PAND MM3,m0400
  PCMPEQB MM2,m8020
  PCMPEQW MM3,m0400
  PAND MM2,m7C1F
  PAND MM3,m03E0
  PAND MM0,m7C1F
  PAND MM1,m03E0
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubm15_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSSUBimageL16(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@icsub16_loop1:
  PUSH EBX
  PUSH ECX
  MOV EBX,[ESI+EBX]
  MOV ECX,EBX
  AND ECX,007E0F81Fh
  AND EBX,0F81F07E0h
  LODSD
  MOV EDX,EAX
  OR EAX,0F81F07E0h
  OR EDX,007E0F81Fh
  SUB EAX,ECX
  SUB EDX,EBX
  PUSHF
  MOV EBX,EAX
  AND EBX,08010020h
  MOV ECX,EBX
  SHR EBX,6
  SBB ECX,EBX
  AND EAX,ECX
  MOV EBX,EDX
  AND EBX,00200800h
  MOV ECX,EBX
  POPF
  RCR EBX,1
  XOR EBX,80000000h
  SHR EBX,5
  SUB ECX,EBX
  AND EDX,ECX
  AND EAX,07E0F81Fh
  AND EDX,0F81F07E0h
  OR EAX,EDX
  STOSD
  POP ECX
  POP EBX
  DEC ECX
  JNZ @icsub16_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBimageLM16(dst,src1,src2:pimage):pimage;assembler;
CONST mF81F:array[0..3] of word=($F81F,$F81F,$F81F,$F81F);
      m07E0:array[0..3] of word=($07E0,$07E0,$07E0,$07E0);
      m0020:array[0..3] of word=($0020,$0020,$0020,$0020);
      m0800:array[0..3] of word=($0800,$0800,$0800,$0800);
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
  MOV EAX,07E0F81Fh
  MOVD MM2,EAX
  PUNPCKLDQ MM2,MM2
  MOV EAX,0F81F07E0h
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM3
@iisubm16_loop1:
  MOVQ MM0,[ESI]
  MOVQ MM6,[ESI+EBX]
  MOVQ MM1,MM0
  MOVQ MM7,MM6
  POR MM0,m07E0
  POR MM1,mF81F
  PAND MM6,mF81F
  PAND MM7,m07E0
  PSUBUSB MM0,MM6
  PSUBW MM1,MM7
  MOVQ MM2,MM0
  MOVQ MM3,MM1
  PAND MM2,m0020
  PAND MM3,m0800
  PCMPEQB MM2,m0020
  PCMPEQW MM3,m0800
  PAND MM2,mF81F
  PAND MM3,m07E0
  PAND MM0,mF81F
  PAND MM1,m07E0
  PAND MM0,MM2
  PAND MM1,MM3
  POR MM0,MM1
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubm16_loop1
  EMMS
  MOV EAX,dst
END;

FUNCTION imageSSUBimageLtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@icsub32_loop1:
  PUSH EBX
  MOV EBX,[ESI+EBX]
  LODSD
  SUB AL,BL
  SETNC DL
  SUB AH,BH
  SETNC DH
  NEG DL
  NEG DH
  AND AX,DX
  ROR EAX,16
  ROR EBX,16
  SUB AL,BL
  SETNC DL
  NEG DL
  AND AL,DL
  ROR EAX,16
  ROR EBX,16
  STOSD
  POP EBX
  DEC ECX
  JNZ @icsub32_loop1
  MOV EAX,dst
END;

FUNCTION imageSSUBimageLMtc(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iisubmtc_loop1:
  MOVQ MM0,[ESI]
  PSUBUSB MM0,[ESI+EBX]
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iisubmtc_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageANDimage ----------------------------------}

FUNCTION imageANDimageLall(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iand16_loop1:
  MOV EDX,[ESI+EBX]
  LODSD
  AND EAX,EDX
  STOSD
  DEC ECX
  JNZ @iand16_loop1
  MOV EAX,dst
END;

FUNCTION imageANDimageLMall(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiandm16_loop1:
  MOVQ MM0,[ESI]
  PAND MM0,[ESI+EBX]
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiandm16_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageORimage ----------------------------------}

FUNCTION imageORimageLall(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iior16_loop1:
  MOV EDX,[ESI+EBX]
  LODSD
  OR EAX,EDX
  STOSD
  DEC ECX
  JNZ @iior16_loop1
  MOV EAX,dst
END;

FUNCTION imageORimageLMall(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iiorm16_loop1:
  MOVQ MM0,[ESI]
  POR MM0,[ESI+EBX]
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iiorm16_loop1
  EMMS
  MOV EAX,dst
END;

{--------------------------- imageXORimage ----------------------------------}

FUNCTION imageXORimageLall(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iixor16_loop1:
  MOV EDX,[ESI+EBX]
  LODSD
  XOR EAX,EDX
  STOSD
  DEC ECX
  JNZ @iixor16_loop1
  MOV EAX,dst
END;

FUNCTION imageXORimageLMall(dst,src1,src2:pimage):pimage;assembler;
ASM
  MOV ESI,src1
  MOV EBX,src2
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV ESI,[ESI+timage.pixeldata]
  MOV EBX,[EBX+timage.pixeldata]
  MOV EDI,[EDI+timage.pixeldata]
  SUB EBX,ESI
@iixorm16_loop1:
  MOVQ MM0,[ESI]
  PXOR MM0,[ESI+EBX]
  MOVQ [EDI],MM0
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @iixorm16_loop1
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{--------------------------------- fillimage --------------------------------}

FUNCTION fillimageLbyte(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOV AH,AL
  SHL EAX,8
  MOV AL,AH
  SHL EAX,8
  MOV AL,AH
  REP STOSD
  MOV EAX,dst
END;

FUNCTION fillimageLMbyte(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM0,EAX
  PUNPCKLBW MM0,MM0
  PUNPCKLWD MM0,MM0
  PUNPCKLDQ MM0,MM0
@fim8_loop:
  MOVQ [EDI],MM0
  ADD EDI,8
  DEC ECX
  JNZ @fim8_loop
  EMMS
  MOV EAX,dst
END;

FUNCTION fillimageLword(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOV BX,AX
  SHL EAX,16
  MOV AX,BX
  REP STOSD
  MOV EAX,dst
END;

FUNCTION fillimageLMword(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM0,EAX
  PUNPCKLWD MM0,MM0
  PUNPCKLDQ MM0,MM0
@fim16_loop:
  MOVQ [EDI],MM0
  ADD EDI,8
  DEC ECX
  JNZ @fim16_loop
  EMMS
  MOV EAX,dst
END;

FUNCTION fillimageL24(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  SHL EAX,8
  MOV AL,AH
  ROR EAX,8
@fi24_loop:
  STOSD
  MOV AL,AH
  ROR EAX,8
  DEC ECX
  JNZ @fi24_loop
  MOV EAX,dst
END;

FUNCTION fillimageLM24(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  PXOR MM0,MM0
  MOVD MM0,EAX
  MOVQ MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
  PSLLQ MM1,24
  POR MM1,MM0
@fim24_loop:
  MOVQ MM2,MM1
  MOVQ [EDI],MM1
  PSRLQ MM1,16
  PSLLQ MM2,32
  POR MM1,MM2
  ADD EDI,8
  DEC ECX
  JNZ @fim24_loop
  EMMS
  MOV EAX,dst
END;

FUNCTION fillimageL32(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,2
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  REP STOSD
  MOV EAX,dst
END;

FUNCTION fillimageLM32(dst:pimage;color:longint):pimage;assembler;
ASM
  MOV EDI,dst
  MOV EAX,[EDI+timage.height]
  MUL DWORD PTR [EDI+timage.bytesperline]
  MOV ECX,EAX
  SHR ECX,3
  MOV EDI,[EDI+timage.pixeldata]
  MOV EAX,color
  MOVD MM0,EAX
  PUNPCKLDQ MM0,MM0
@fim32_loop:
  MOVQ [EDI],MM0
  ADD EDI,8
  DEC ECX
  JNZ @fim32_loop
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{--------------------------------- flipimageH -------------------------------}

FUNCTION flipimageHLbyte(dst,src:pimage):pimage;assembler;
ASM
  MOV EDI,dst
  MOV ESI,src
  MOV EBX,[EDI+timage.width]
  MOV ECX,[EDI+timage.height]
  MOV EDX,[EDI+timage.bytesperline]
  DEC EBX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]
@fih8_loop1:
  PUSH ECX
  PUSH EDI
  MOV EDI,graphbuf
  ADD ESI,EBX
  MOV ECX,EBX
@fih8_loop2:
  MOV AL,[ESI]
  STOSB
  DEC ESI
  DEC ECX
  JNZ @fih8_loop2
  ADD ESI,EDX
  POP EDI
  PUSH ESI
  MOV ECX,EDX
  SHR ECX,2
  MOV ESI,graphbuf
  REP MOVSD
  POP ESI
  POP ECX
  DEC ECX
  JNZ @fih8_loop1
  MOV EAX,dst
END;

FUNCTION flipimageHLword(dst,src:pimage):pimage;assembler;
ASM
  MOV EDI,dst
  MOV ESI,src
  MOV EBX,[EDI+timage.width]
  MOV ECX,[EDI+timage.height]
  MOV EDX,[EDI+timage.bytesperline]
  DEC EBX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]
@fih16_loop1:
  PUSH ECX
  PUSH EDI
  MOV EDI,graphbuf
  LEA ESI,[ESI+EBX*2]
  MOV ECX,EBX
@fih16_loop2:
  MOV AX,[ESI]
  STOSW
  SUB ESI,2
  DEC ECX
  JNZ @fih16_loop2
  ADD ESI,EDX
  POP EDI
  PUSH ESI
  MOV ECX,EDX
  SHR ECX,2
  MOV ESI,graphbuf
  REP MOVSD
  POP ESI
  POP ECX
  DEC ECX
  JNZ @fih16_loop1
  MOV EAX,dst
END;

FUNCTION flipimageHL24(dst,src:pimage):pimage;assembler;
ASM
  MOV EDI,dst
  MOV ESI,src
  MOV EBX,[EDI+timage.width]
  MOV ECX,[EDI+timage.height]
  MOV EDX,[EDI+timage.bytesperline]
  DEC EBX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]
@fih24_loop1:
  PUSH ECX
  PUSH EDI
  MOV EDI,graphbuf
  LEA ESI,[ESI+EBX*2]
  ADD ESI,EBX
  MOV ECX,EBX
@fih24_loop2:
  MOVSW
  MOVSB
  SUB ESI,6
  DEC ECX
  JNZ @fih24_loop2
  ADD ESI,EDX
  POP EDI
  PUSH ESI
  MOV ECX,EDX
  SHR ECX,2
  MOV ESI,graphbuf
  REP MOVSD
  POP ESI
  POP ECX
  DEC ECX
  JNZ @fih24_loop1
  MOV EAX,dst
END;

FUNCTION flipimageHL32(dst,src:pimage):pimage;assembler;
ASM
  MOV EDI,dst
  MOV ESI,src
  MOV EBX,[EDI+timage.width]
  MOV ECX,[EDI+timage.height]
  MOV EDX,[EDI+timage.bytesperline]
  DEC EBX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]
@fih32_loop1:
  PUSH ECX
  PUSH EDI
  MOV EDI,graphbuf
  LEA ESI,[ESI+EBX*4]
  MOV ECX,EBX
@fih32_loop2:
  MOV EAX,[ESI]
  STOSD
  SUB ESI,4
  DEC ECX
  JNZ @fih32_loop2
  ADD ESI,EDX
  POP EDI
  PUSH ESI
  MOV ECX,EDX
  SHR ECX,2
  MOV ESI,graphbuf
  REP MOVSD
  POP ESI
  POP ECX
  DEC ECX
  JNZ @fih32_loop1
  MOV EAX,dst
END;

{--------------------------------- flipimageV -------------------------------}

FUNCTION flipimageVLall(dst,src:pimage):pimage;assembler;
VAR srctop,srcbot,dsttop,dstbot:pimage;
    count,bytes:longint;
ASM
  MOV EDI,dst
  MOV ESI,src
  MOV EBX,[EDI+timage.height]
  MOV ECX,[EDI+timage.bytesperline]

  MOV EAX,EBX
  MUL ECX
  SUB EAX,ECX

  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  INC EBX
  SHR EBX,1

  MOV srctop,ESI
  ADD ESI,EAX
  MOV srcbot,ESI

  MOV dsttop,EDI
  ADD EDI,EAX
  MOV dstbot,EDI

  MOV bytes,ECX
  SHR ECX,2
  MOV count,ECX

@fiv_loop1:
  MOV ECX,count
  MOV ESI,srctop
  MOV EDI,graphbuf
  REP MOVSD

  MOV ECX,count
  MOV ESI,srcbot
  MOV EDI,dsttop
  REP MOVSD

  MOV ECX,count
  MOV ESI,graphbuf
  MOV EDI,dstbot
  REP MOVSD

  MOV ECX,bytes
  ADD srctop,ECX
  ADD dsttop,ECX
  SUB srcbot,ECX
  SUB dstbot,ECX

  DEC EBX
  JNZ @fiv_loop1

  MOV EAX,dst
END;

FUNCTION flipimageVLMall(dst,src:pimage):pimage;assembler;
ASM
  MOV EDI,dst
  MOV ESI,src
  MOV EBX,[EDI+timage.height]
  MOV ECX,[EDI+timage.bytesperline]
  MOV EAX,EBX
  MUL ECX
  SUB EAX,ECX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]
  MOV EDX,ECX
  INC EBX
  SHR EBX,1
@fivm_loop1:
  MOV ECX,EDX
  SHR ECX,3
@fivm_loop2:
  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI+EAX]
  MOVQ [EDI+EAX],MM0
  MOVQ [EDI],MM1
  ADD ESI,8
  ADD EDI,8
  DEC ECX
  JNZ @fivm_loop2
  SUB EAX,EDX
  SUB EAX,EDX
  DEC EBX
  JNZ @fivm_loop1
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{--------------------------------- composeimage -----------------------------}

FUNCTION composeimageL8(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX

  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @ci8_ende
  CMP EAX,dyd
  JG @ci8_ende
  CMP EBX,0
  JL @ci8_ende
  CMP ECX,0
  JL @ci8_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @ci8_w1
  MOV ESI,EDI
  NEG ESI
{  SHL ESI,2} {bytperpix }
  MOV EDI,0
@ci8_w1:

  CMP EAX,0
  JGE @ci8_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@ci8_w2:

  CMP EBX,dxd
  JLE @ci8_w3
  MOV EBX,dxd
@ci8_w3:

  CMP ECX,dyd
  JLE @ci8_w4
  MOV ECX,dyd
@ci8_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

{  SHL EDI,2} {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }

  ADD ESI,s
  ADD EDI,d

{  SHL EBX,2} {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
{  SHR EBX,2 }
  CLD
@ci8_loop:
  PUSH ECX
  MOV ECX,EBX
  SHR ECX,2
  REP MOVSD
  MOV ECX,EBX
  AND ECX,3
  REP MOVSB
  POP ECX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @ci8_loop
@ci8_ende:
  MOV EAX,dst
END;

FUNCTION composeimageL16(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX

  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @ci16_ende
  CMP EAX,dyd
  JG @ci16_ende
  CMP EBX,0
  JL @ci16_ende
  CMP ECX,0
  JL @ci16_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @ci16_w1
  MOV ESI,EDI
  NEG ESI
  SHL ESI,1 {bytperpix }
  MOV EDI,0
@ci16_w1:

  CMP EAX,0
  JGE @ci16_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@ci16_w2:

  CMP EBX,dxd
  JLE @ci16_w3
  MOV EBX,dxd
@ci16_w3:

  CMP ECX,dyd
  JLE @ci16_w4
  MOV ECX,dyd
@ci16_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

  SHL EDI,1 {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }
  ADD ESI,s
  ADD EDI,d


  SHL EBX,1 {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
  SHR EBX,1
  CLD
@ci16_loop:
  PUSH ECX
  MOV ECX,EBX
  SHR ECX,1
  REP MOVSD
  MOV ECX,EBX
  AND ECX,1
  REP MOVSW
  POP ECX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @ci16_loop
@ci16_ende:
  MOV EAX,dst
END;

FUNCTION composeimageL24(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX

  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX

  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @ci24_ende
  CMP EAX,dyd
  JG @ci24_ende
  CMP EBX,0
  JL @ci24_ende
  CMP ECX,0
  JL @ci24_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @ci24_w1
  MOV ESI,EDI
  NEG ESI
  LEA ESI,[ESI+ESI*2] {bytperpix }
  MOV EDI,0
@ci24_w1:

  CMP EAX,0
  JGE @ci24_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@ci24_w2:

  CMP EBX,dxd
  JLE @ci24_w3
  MOV EBX,dxd
@ci24_w3:

  CMP ECX,dyd
  JLE @ci24_w4
  MOV ECX,dyd
@ci24_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

  LEA EDI,[EDI+EDI*2] {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }
  ADD ESI,s
  ADD EDI,d

  LEA EBX,[EBX+EBX*2] {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
  CLD
@ci24_loop:
  PUSH ECX
  MOV ECX,EBX
  SHR ECX,2
  REP MOVSD
  MOV ECX,EBX
  AND ECX,3
  REP MOVSB
  POP ECX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @ci24_loop
@ci24_ende:
  MOV EAX,dst
END;

FUNCTION composeimageL32(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX

  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @ci32_ende
  CMP EAX,dyd
  JG @ci32_ende
  CMP EBX,0
  JL @ci32_ende
  CMP ECX,0
  JL @ci32_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @ci32_w1
  MOV ESI,EDI
  NEG ESI
  SHL ESI,2 {bytperpix }
  MOV EDI,0
@ci32_w1:

  CMP EAX,0
  JGE @ci32_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@ci32_w2:

  CMP EBX,dxd
  JLE @ci32_w3
  MOV EBX,dxd
@ci32_w3:

  CMP ECX,dyd
  JLE @ci32_w4
  MOV ECX,dyd
@ci32_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

  SHL EDI,2 {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }
  ADD ESI,s
  ADD EDI,d

  SHL EBX,2 {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
  SHR EBX,2
  CLD
@ci32_loop:
  PUSH ECX
  MOV ECX,EBX
  REP MOVSD
  POP ECX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @ci32_loop
@ci32_ende:
  MOV EAX,dst
END;

{--------------------------------- composeimageC ----------------------------}

FUNCTION composeimageCL8(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,color,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX

  MOV EAX,[ESI+timage.transparencycolor]
  MOV color,EAX
  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @cic8_ende
  CMP EAX,dyd
  JG @cic8_ende
  CMP EBX,0
  JL @cic8_ende
  CMP ECX,0
  JL @cic8_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @cic8_w1
  MOV ESI,EDI
  NEG ESI
{  SHL ESI,2} {bytperpix }
  MOV EDI,0
@cic8_w1:

  CMP EAX,0
  JGE @cic8_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@cic8_w2:

  CMP EBX,dxd
  JLE @cic8_w3
  MOV EBX,dxd
@cic8_w3:

  CMP ECX,dyd
  JLE @cic8_w4
  MOV ECX,dyd
@cic8_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

{  SHL EDI,2} {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }
  ADD ESI,s
  ADD EDI,d

{  SHL EBX,2} {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
{  SHR EBX,2 }
@cic8_loop1:
  PUSH EAX
  PUSH ECX
  MOV ECX,EBX
@cic8_loop2:
  LODSB
  CMP AL,BYTE PTR color
  JE @cic8_nopix
  MOV [EDI],AL
@cic8_nopix:
  INC EDI
  DEC ECX
  JNZ @cic8_loop2
  POP ECX
  POP EAX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @cic8_loop1
@cic8_ende:
  MOV EAX,dst
END;

FUNCTION composeimageCL16(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,color,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX
  MOV EAX,[ESI+timage.transparencycolor]
  MOV color,EAX

  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @cic16_ende
  CMP EAX,dyd
  JG @cic16_ende
  CMP EBX,0
  JL @cic16_ende
  CMP ECX,0
  JL @cic16_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @cic16_w1
  MOV ESI,EDI
  NEG ESI
  SHL ESI,1 {bytperpix }
  MOV EDI,0
@cic16_w1:

  CMP EAX,0
  JGE @cic16_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@cic16_w2:

  CMP EBX,dxd
  JLE @cic16_w3
  MOV EBX,dxd
@cic16_w3:

  CMP ECX,dyd
  JLE @cic16_w4
  MOV ECX,dyd
@cic16_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

  SHL EDI,1 {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }
  ADD ESI,s
  ADD EDI,d

  SHL EBX,1 {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
  SHR EBX,1
@cic16_loop1:
  PUSH EAX
  PUSH ECX
  MOV ECX,EBX
@cic16_loop2:
  LODSW
  CMP AX,WORD PTR color
  JE @cic16_nopix
  MOV [EDI],AX
@cic16_nopix:
  ADD EDI,2
  DEC ECX
  JNZ @cic16_loop2
  POP ECX
  POP EAX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @cic16_loop1
@cic16_ende:
  MOV EAX,dst
END;

FUNCTION composeimageCL24(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,color,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX
  MOV EAX,[ESI+timage.transparencycolor]
  MOV color,EAX

  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @cic24_ende
  CMP EAX,dyd
  JG @cic24_ende
  CMP EBX,0
  JL @cic24_ende
  CMP ECX,0
  JL @cic24_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @cic24_w1
  MOV ESI,EDI
  NEG ESI
  LEA ESI,[ESI+ESI*2] {bytperpix }
  MOV EDI,0
@cic24_w1:

  CMP EAX,0
  JGE @cic24_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@cic24_w2:

  CMP EBX,dxd
  JLE @cic24_w3
  MOV EBX,dxd
@cic24_w3:

  CMP ECX,dyd
  JLE @cic24_w4
  MOV ECX,dyd
@cic24_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

  LEA EDI,[EDI+EDI*2] {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }
  ADD ESI,s
  ADD EDI,d

  PUSH EBX
  LEA EBX,[EBX+EBX*2] {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
  POP EBX
  SHL color,8
@cic24_loop1:
  PUSH EAX
  PUSH ECX
  MOV ECX,EBX
@cic24_loop2:
  DEC ESI
  LODSD
  XOR AL,AL
  CMP EAX,color
  JE @cic24_nopix
  MOV [EDI],AH
  SHR EAX,16
  MOV [EDI+1],AX
@cic24_nopix:
  ADD EDI,3
  DEC ECX
  JNZ @cic24_loop2
  POP ECX
  POP EAX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @cic24_loop1
@cic24_ende:
  MOV EAX,dst
END;

FUNCTION composeimageCL32(dst,image:pimage;x,y:longint):pimage;assembler;
VAR dxd,dyd,imgxd,dstxd,color,d,s:longint;
ASM
  MOV EDI,dst
  MOV ESI,image
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
  MOV EAX,[ESI+timage.pixeldata]
  MOV s,EAX
  MOV EAX,[ESI+timage.transparencycolor]
  MOV color,EAX

  MOV EAX,[EDI+timage.width]
  DEC EAX
  MOV dxd,EAX
  MOV EAX,[EDI+timage.height]
  DEC EAX
  MOV dyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstxd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

  MOV EDI,x
  MOV EAX,y

  MOV EBX,EDI
  ADD EBX,[ESI+timage.width]
  DEC EBX
  MOV ECX,EAX
  ADD ECX,[ESI+timage.height]
  DEC ECX

  CMP EDI,dxd
  JG @cic32_ende
  CMP EAX,dyd
  JG @cic32_ende
  CMP EBX,0
  JL @cic32_ende
  CMP ECX,0
  JL @cic32_ende

  XOR ESI,ESI

  CMP EDI,0
  JGE @cic32_w1
  MOV ESI,EDI
  NEG ESI
  SHL ESI,2 {bytperpix }
  MOV EDI,0
@cic32_w1:

  CMP EAX,0
  JGE @cic32_w2
  NEG EAX
  MUL imgxd
  ADD ESI,EAX
  MOV EAX,0
@cic32_w2:

  CMP EBX,dxd
  JLE @cic32_w3
  MOV EBX,dxd
@cic32_w3:

  CMP ECX,dyd
  JLE @cic32_w4
  MOV ECX,dyd
@cic32_w4:

  SUB EBX,EDI
  SUB ECX,EAX
  INC EBX
  INC ECX

  SHL EDI,2 {bytperpix}
  MUL dstxd
  ADD EDI,EAX

{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart
  ADD ESI,image
  ADD EDI,dst }
  ADD ESI,s
  ADD EDI,d

  SHL EBX,2 {bytperpix}
  MOV EAX,imgxd
  MOV EDX,dstxd
  SUB EAX,EBX
  SUB EDX,EBX
  SHR EBX,2
@cic32_loop1:
  PUSH EAX
  PUSH ECX
  MOV ECX,EBX
@cic32_loop2:
  LODSD
  CMP EAX,color
  JE @cic32_nopix
  MOV [EDI],EAX
@cic32_nopix:
  ADD EDI,4
  DEC ECX
  JNZ @cic32_loop2
  POP ECX
  POP EAX
  ADD ESI,EAX
  ADD EDI,EDX
  DEC ECX
  JNZ @cic32_loop1
@cic32_ende:
  MOV EAX,dst
END;

{============================================================================}
{--------------------------------- scaleimage -------------------------------}

FUNCTION scaleimageLbyte(dst,src:pimage):pimage;assembler;
VAR pix,piy,diff,idiff,nxd,nyd,imgxd:longint;
ASM
  MOV EDI,dst
  MOV ESI,src

  MOV ECX,[EDI+timage.width]
  MOV EBX,[EDI+timage.height]

  XOR EDX,EDX
  MOV EAX,[ESI+timage.width]
  SHL EAX,16
  DIV ECX
  MOV pix,EAX

  XOR EDX,EDX
  MOV EAX,[ESI+timage.height]
  SHL EAX,16
  DIV EBX
  MOV piy,EAX

  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

{--------------------}
{  ADD ESI,imagedatastart}
  MOV ESI,[ESI+timage.pixeldata]
  MOV nxd,ECX
  MOV nyd,EBX

  MOV EAX,ECX
{  MUL bytperpix }
  MOV EDX,[EDI+timage.bytesperline]
  SUB EDX,EAX
  MOV diff,EDX

  MOV EAX,ECX
  DEC EAX
  MUL pix
  SHR EAX,16
  INC EAX
{  MOV EDX,bytperpix
  MUL EDX }
  MOV idiff,EAX

{--------------------}
  MOV EDX,0
  MOV ECX,nyd
  MOV EDI,[EDI+timage.pixeldata]
@zi8_loop12:
  CMP EDX,00010000h
  JL @zi8_draw1
  SUB EDX,00010000h
  ADD ESI,imgxd
  JMP @zi8_loop12
@zi8_draw1:
  PUSH ECX

  PUSH EDX
  MOV EBX,00010000h
  MOV EDX,pix
  MOV ECX,nxd
@zi8_loop3:
  SUB EBX,00010000h
  LODSB
@zi8_loop4:
  CMP EBX,00010000h
  JGE @zi8_loop3
  STOSB
  ADD EBX,EDX
  DEC ECX
  JNZ @zi8_loop4
  POP EDX

  SUB ESI,idiff
  ADD EDI,diff
  ADD EDX,piy
  POP ECX
  DEC ECX
  JNZ @zi8_loop12
@zi8_ende:
  MOV EAX,dst
END;

FUNCTION scaleimageLword(dst,src:pimage):pimage;assembler;
VAR pix,piy,diff,idiff,nxd,nyd,imgxd:longint;
ASM
  MOV EDI,dst
  MOV ESI,src

  MOV ECX,[EDI+timage.width]
  MOV EBX,[EDI+timage.height]

  XOR EDX,EDX
  MOV EAX,[ESI+timage.width]
  SHL EAX,16
  DIV ECX
  MOV pix,EAX

  XOR EDX,EDX
  MOV EAX,[ESI+timage.height]
  SHL EAX,16
  DIV EBX
  MOV piy,EAX

  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

{--------------------}
{  ADD ESI,imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV nxd,ECX
  MOV nyd,EBX

  MOV EAX,ECX
  MUL bytperpix
  MOV EDX,[EDI+timage.bytesperline]
  SUB EDX,EAX
  MOV diff,EDX

  MOV EAX,ECX
  DEC EAX
  MUL pix
  SHR EAX,16
  INC EAX
  MOV EDX,bytperpix
  MUL EDX
  MOV idiff,EAX

{--------------------}
  MOV EDX,0
  MOV ECX,nyd
  MOV EDI,[EDI+timage.pixeldata]
@zi16_loop12:
  CMP EDX,00010000h
  JL @zi16_draw1
  SUB EDX,00010000h
  ADD ESI,imgxd
  JMP @zi16_loop12
@zi16_draw1:
  PUSH ECX

  PUSH EDX
  MOV EBX,00010000h
  MOV EDX,pix
  MOV ECX,nxd
@zi16_loop3:
  SUB EBX,00010000h
  LODSW
@zi16_loop4:
  CMP EBX,00010000h
  JGE @zi16_loop3
  STOSW
  ADD EBX,EDX
  DEC ECX
  JNZ @zi16_loop4
  POP EDX

  SUB ESI,idiff
  ADD EDI,diff
  ADD EDX,piy
  POP ECX
  DEC ECX
  JNZ @zi16_loop12
@zi16_ende:
  MOV EAX,dst
END;

FUNCTION scaleimageL24(dst,src:pimage):pimage;assembler;
VAR pix,piy,diff,idiff,nxd,nyd,imgxd:longint;
ASM
  MOV EDI,dst
  MOV ESI,src

  MOV ECX,[EDI+timage.width]
  MOV EBX,[EDI+timage.height]

  XOR EDX,EDX
  MOV EAX,[ESI+timage.width]
  SHL EAX,16
  DIV ECX
  MOV pix,EAX

  XOR EDX,EDX
  MOV EAX,[ESI+timage.height]
  SHL EAX,16
  DIV EBX
  MOV piy,EAX

  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

{--------------------}
{  ADD ESI,imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV nxd,ECX
  MOV nyd,EBX

  MOV EAX,ECX
  MUL bytperpix
  MOV EDX,[EDI+timage.bytesperline]
  SUB EDX,EAX
  MOV diff,EDX

  MOV EAX,ECX
  DEC EAX
  MUL pix
  SHR EAX,16
  INC EAX
  MOV EDX,bytperpix
  MUL EDX
  MOV idiff,EAX

{--------------------}
  MOV EDX,0
  MOV ECX,nyd
  MOV EDI,[EDI+timage.pixeldata]
@zi24_loop12:
  CMP EDX,00010000h
  JL @zi24_draw1
  SUB EDX,00010000h
  ADD ESI,imgxd
  JMP @zi24_loop12
@zi24_draw1:
  PUSH ECX

  PUSH EDX
  MOV EBX,00010000h
  MOV EDX,pix
  MOV ECX,nxd
@zi24_loop3:
  SUB EBX,00010000h
  LODSW
  ROR EAX,16
  LODSB
  ROR EAX,16
@zi24_loop4:
  CMP EBX,00010000h
  JGE @zi24_loop3
  STOSW
  ROR EAX,16
  STOSB
  ROR EAX,16
  ADD EBX,EDX
  DEC ECX
  JNZ @zi24_loop4
  POP EDX

  SUB ESI,idiff
  ADD EDI,diff
  ADD EDX,piy
  POP ECX
  DEC ECX
  JNZ @zi24_loop12
@zi24_ende:
  MOV EAX,dst
END;

FUNCTION scaleimageL32(dst,src:pimage):pimage;assembler;
VAR pix,piy,diff,idiff,nxd,nyd,imgxd:longint;
ASM
  MOV EDI,dst
  MOV ESI,src

  MOV ECX,[EDI+timage.width]
  MOV EBX,[EDI+timage.height]

  XOR EDX,EDX
  MOV EAX,[ESI+timage.width]
  SHL EAX,16
  DIV ECX
  MOV pix,EAX

  XOR EDX,EDX
  MOV EAX,[ESI+timage.height]
  SHL EAX,16
  DIV EBX
  MOV piy,EAX

  MOV EAX,[ESI+timage.bytesperline]
  MOV imgxd,EAX

{--------------------}
{  ADD ESI,imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV nxd,ECX
  MOV nyd,EBX

  MOV EAX,ECX
  MUL bytperpix
  MOV EDX,[EDI+timage.bytesperline]
  SUB EDX,EAX
  MOV diff,EDX

  MOV EAX,ECX
  DEC EAX
  MUL pix
  SHR EAX,16
  INC EAX
  MOV EDX,bytperpix
  MUL EDX
  MOV idiff,EAX

{--------------------}
  MOV EDX,0
  MOV ECX,nyd
  MOV EDI,[EDI+timage.pixeldata]

@zi32_loop12:
  CMP EDX,00010000h
  JL @zi32_draw1
  SUB EDX,00010000h
  ADD ESI,imgxd
  JMP @zi32_loop12
@zi32_draw1:
  PUSH ECX

  PUSH EDX
  MOV EBX,00010000h
  MOV EDX,pix
  MOV ECX,nxd
@zi32_loop3:
  SUB EBX,00010000h
  LODSD
@zi32_loop4:
  CMP EBX,00010000h
  JGE @zi32_loop3
  STOSD
  ADD EBX,EDX
  DEC ECX
  JNZ @zi32_loop4
  POP EDX

  SUB ESI,idiff
  ADD EDI,diff
  ADD EDX,piy
  POP ECX
  DEC ECX
  JNZ @zi32_loop12
@zi32_ende:
  MOV EAX,dst
END;

{----------------------------- rotateimage ----------------------------------}

FUNCTION sinus(w:longint):longint;
BEGIN
  sinus:=trunc(sin((w*3.141593)/32768)*32768);
END;

FUNCTION cosinus(w:longint):longint;
BEGIN
  cosinus:=trunc(cos((w*3.141593)/32768)*32768);
END;

FUNCTION rotateimageLbyte(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
VAR xdx,xdy,ydx,ydy:longint;
    px1,py1,px2,py2:longint;
    lx1,ly1,lx2,ly2:longint;
    sxd,syd,smxd,smxdfxp,sadr,dxd,dyd,dmxd,dc,vdxd,vdyd:longint;
    mx,my,mxd,myd:longint;
    mx1,my1,mx2,my2:longint;
    ww,tx1,ty1,tx2,ty2:longint;
    d:longint;
ASM
{---------------------------}
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
  SHL EAX,16
  MOV smxdfxp,EAX
{  ADD ESI,imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  SHL rx,15
  SHL ry,15

  MOV EAX,w
  MOV EBX,EAX
  ADD EBX,16384

  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX
  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX

  CALL sinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdx,EAX

  CALL cosinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdy,EAX

  CALL sinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydx,EAX

  CALL cosinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydy,EAX
{---------------------------}
  MOV EDI,graphbuf
  MOV ECX,rx
  MOV EDX,ry
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@ril8_loop1:
  LODSD
  CMP EAX,px1
  JGE @ril8_w1
  MOV px1,EAX
@ril8_w1:
  CMP EAX,px2
  JLE @ril8_w2
  MOV px2,EAX
@ril8_w2:
  LODSD
  CMP EAX,py1
  JGE @ril8_w3
  MOV py1,EAX
@ril8_w3:
  CMP EAX,py2
  JLE @ril8_w4
  MOV py2,EAX
@ril8_w4:
  ADD ESI,8
  DEC ECX
  JNZ @ril8_loop1
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @ril8_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @ril8_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @ril8_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@ril8_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @ril8_loop2
{---------------------------}
  MOV ESI,graphbuf
  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  MOV ECX,4
@ril8_loop3:
  PUSH ECX

  MOV EAX,lx2
  MOV lx1,EAX
  MOV EAX,ly2
  MOV ly1,EAX
  MOV EAX,mx2
  MOV mx1,EAX
  MOV EAX,my2
  MOV my1,EAX

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  PUSH ESI

  MOV ECX,ly2
  SUB ECX,ly1
  JZ @ril8_w5

  MOV EBX,mx1
  MOV EAX,mx2
  SHL EBX,16
  SHL EAX,16
  MOV mx,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV mxd,EAX

  MOV EBX,my1
  MOV EAX,my2
  SHL EBX,16
  SHL EAX,16
  MOV my,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV myd,EAX

  MOV EAX,lx1
  MOV EDI,ly1
  MOV EDX,lx2
  MOV ECX,ly2

  CMP EDI,ECX
  JE @ril8_w5
  JL @ril8_w6
  XCHG EAX,EDX
  XCHG EDI,ECX
  PUSH EAX
  MOV EAX,mx2
  SHL EAX,16
  MOV mx,EAX
  MOV EAX,my2
  SHL EAX,16
  MOV my,EAX
  POP EAX
@ril8_w6:

  SUB EDX,EAX
  SUB ECX,EDI

  SHL EAX,16
  SHL EDX,16

  PUSH EAX
  MOV EAX,EDX
  CDQ
  IDIV ECX
  MOV dc,EAX
  POP EAX

  MOV EDX,mx
  MOV ESI,my

  SHL EDI,5
  ADD EDI,256
  ADD EDI,graphbuf
@ril8_loop4:
  MOV EBX,[EDI]
  INC EBX
  MOV [EDI],EBX
  MOV [EDI+EBX*4],EAX
  MOV [EDI+EBX*8],EDX
  MOV [EDI+EBX*8+4],ESI
  ADD EDI,32
  ADD EAX,dc
  ADD EDX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril8_loop4
@ril8_w5:
  POP ESI
  POP ECX
  DEC ECX
  JNZ @ril8_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @ril8_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@ril8_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @ril8_w10
  MOV ECX,vdyd
  INC ECX
@ril8_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd

{  ADD EDI,dst
  ADD EDI,imagedatastart }
  ADD EDI,d

@ril8_loop5:
  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI+0]
  MOV ECX,[ESI+4]
  SAR EBX,16
  SAR ECX,16
  MOV EDX,ESI
  ADD EDX,8
  MOV EAX,EDX
  ADD EDX,8

  CMP EBX,ECX
  JL @ril8_w12
  XCHG EBX,ECX
  XCHG EAX,EDX
@ril8_w12:

  MOV ESI,[EAX+0]
  MOV tx1,ESI
  MOV ESI,[EAX+4]
  MOV ty1,ESI
  MOV ESI,[EDX+0]
  MOV tx2,ESI
  MOV ESI,[EDX+4]
  MOV ty2,ESI

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI
  MOV dc,ESI

  XOR ESI,ESI

  CMP EBX,vdxd
  JG @ril8_noline
  CMP ECX,0
  JL @ril8_noline

  CMP EBX,0
  JGE @ril8_w13
  SUB ESI,EBX
  MOV EBX,0
@ril8_w13:

  CMP ECX,vdxd
  JLE @ril8_w14
  MOV ECX,vdxd
@ril8_w14:

  SUB ECX,EBX
  INC ECX

{  SHL EBX,2} {bytperpix}
  ADD EDI,EBX

  PUSH ECX
  MOV EAX,tx2
  MOV EBX,tx1
  SUB EAX,EBX
  CDQ
  IDIV dc
  MOV mxd,EAX
  MUL ESI
  ADD EBX,EAX

  MOV EAX,ty2
  MOV ECX,ty1
  SUB EAX,ECX
  CDQ
  IDIV dc
  MOV myd,EAX
  MUL ESI
  ADD ECX,EAX

  MOV ESI,ECX
  POP ECX
@ril8_loop0:
  MOV EAX,ESI
  AND EAX,0FFFF0000h
  IMUL smxdfxp
  MOV EAX,EBX
  ADD EDX,sadr
  SAR EAX,16
  MOV AL,[EDX+EAX]
  STOSB
  ADD EBX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril8_loop0

@ril8_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @ril8_loop5
@ril8_ende:
  MOV EAX,dst
END;

FUNCTION rotateimageLMbyte(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
TYPE TPt=RECORD x,y:longint; END;
VAR px1,py1,px2,py2:longint;
    L1,L2,M1,M2,T1,T2,PYSB:TPt;
    sxd,syd,smxd,sadr,dxd,dyd,dmxd,vdxd,vdyd:longint;
    sinx,siny,cosx,cosy:longint;
    d:longint;
ASM
  MOV EAX,w
  PUSH EAX
  PUSH EAX
  ADD EAX,16384
  PUSH EAX
  PUSH EAX
  CALL sinus
  MOV sinx,EAX
  CALL cosinus
  MOV cosx,EAX
  CALL sinus
  MOV siny,EAX
  CALL cosinus
  MOV cosy,EAX

  SHL rx,15
  SHL ry,15

{---------------------------}

  MOV EBX,fx
  MOV EAX,sinx
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  SUB ry,EAX
  MOV EBX,fy
  MOV EAX,siny
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,xd
  MOV EAX,sinx
  IMUL EAX,EBX
  MOVD MM2,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  MOVD MM3,EAX
  MOV EBX,yd
  MOV EAX,siny
  IMUL EAX,EBX
  MOVD MM4,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  MOVD MM5,EAX

  MOV ECX,rx
  MOV EDX,ry
  MOVD MM0,ECX
  MOVD MM1,EDX
  PUNPCKLDQ MM0,MM1
  PUNPCKLDQ MM2,MM3
  PUNPCKLDQ MM4,MM5

{---------------------------}
  PXOR MM5,MM5
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  DEC EAX
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM5
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  DEC EAX
  MOVD MM7,EAX
  PUNPCKLDQ MM5,MM7
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
{  ADD ESI,imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  MOV EDI,graphbuf
  PXOR MM7,MM7
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+00h],MM6
  MOVQ [EDI+08h],MM7
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PSRAD MM6,15
  MOVQ [EDI+10h],MM6
  MOVQ [EDI+18h],MM3
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+20h],MM6
  MOVQ MM6,MM3
  PADDD MM6,MM5
  MOVQ [EDI+28h],MM6
  MOVQ MM6,MM0
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+30h],MM6
  MOVQ [EDI+38h],MM5
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+40h],MM6
  MOVQ [EDI+48h],MM7
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@rilm8_loop1:
  LODSD
  CMP EAX,px1
  JGE @rilm8_w1
  MOV px1,EAX
@rilm8_w1:
  CMP EAX,px2
  JLE @rilm8_w2
  MOV px2,EAX
@rilm8_w2:
  LODSD
  CMP EAX,py1
  JGE @rilm8_w3
  MOV py1,EAX
@rilm8_w3:
  CMP EAX,py2
  JLE @rilm8_w4
  MOV py2,EAX
@rilm8_w4:
  ADD ESI,8
  DEC ECX
  JNZ @rilm8_loop1

  PXOR MM0,MM0
  MOV EAX,py1
  MOVD MM1,EAX
  PUNPCKLDQ MM0,MM1
  MOVQ PYSB,MM0
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @rilm8_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @rilm8_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @rilm8_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@rilm8_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @rilm8_loop2
{---------------------------}
  MOV ESI,graphbuf

  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI+8]
  PSUBD MM0,PYSB
  MOVQ M2,MM1
  MOVQ L2,MM0
  ADD ESI,16

  MOV EBX,4
@rilm8_loop3:
  MOVQ MM6,L2
  MOVQ MM4,M2
  MOVQ L1,MM6
  MOVQ M1,MM4

  MOVQ MM7,[ESI]
  MOVQ MM5,[ESI+8]
  PSUBD MM7,PYSB
  MOVQ M2,MM5
  MOVQ L2,MM7
  ADD ESI,16

  MOVQ MM2,MM4
  MOV ECX,L2.y
  SUB ECX,L1.y
  JZ @rilm8_w5
  JNS @rilm8_w6
  MOVQ MM1,MM6
  MOVQ MM6,MM7
  MOVQ MM7,MM1
  MOVQ MM2,MM5
@rilm8_w6:

  PSUBD MM5,MM4
  PSLLD MM5,16
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM0,EAX
  PSRLQ MM5,32
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM5,EAX
  PUNPCKLDQ MM0,MM5

  PSUBD MM7,MM6 {MM7=L2-L1,MM6=L1}
  PSLLD MM2,16  {MM2=start textcoord}
  MOVQ MM1,MM6
  PSLLD MM7,16  {MM7=dy|dx}
  PSLLD MM1,16  {L1.x - MM1=line start X }
  MOVD EAX,MM7  {EAX=dx}
  PSRLQ MM6,32
  PSRLQ MM7,48
  MOVD EDI,MM6  {EDI=line start Y }
  MOVD ECX,MM7  {ECX=dy}
  CDQ
  IDIV ECX
  MOVD MM7,EAX  {MM7=(dx/dy)}

  SHL EDI,5
  ADD EDI,256
  MOV EDX,1
  ADD EDI,graphbuf
@rilm8_loop4:
  ADD EDX,[EDI]
  MOVD DWORD PTR [EDI+EDX*4],MM1
  MOVQ [EDI+EDX*8],MM2
  PADDD MM1,MM7
  MOV [EDI],EDX
  PADDD MM2,MM0
  ADD EDI,32
  MOV EDX,1
  DEC ECX
  JNZ @rilm8_loop4
@rilm8_w5:
  DEC EBX
  JNZ @rilm8_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @rilm8_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@rilm8_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @rilm8_w10
  MOV ECX,vdyd
  INC ECX
@rilm8_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd
{  ADD EDI,dst
  ADD EDI,imagedatastart }
  ADD EDI,d

@rilm8_loop5:

  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI]
  MOV ECX,[ESI+4]
  MOVQ MM0,[ESI+8]
  MOVQ MM1,[ESI+16]
  SAR EBX,16
  SAR ECX,16

  CMP EBX,ECX
  JL @rilm8_w12
  XCHG EBX,ECX
  MOVQ MM7,MM0
  MOVQ MM0,MM1
  MOVQ MM1,MM7
@rilm8_w12:

  CMP EBX,vdxd
  JG @rilm8_noline
  CMP ECX,0
  JL @rilm8_noline

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI

  PSUBD MM1,MM0
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM3,EAX
  PSRLQ MM1,32
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM1,EAX
  PXOR MM4,MM4
  PUNPCKLDQ MM3,MM1

  CMP EBX,0
  JGE @rilm8_w13
  NEG EBX
  MOVD MM7,EBX
  PUNPCKLWD MM7,MM7
  MOVD EAX,MM3
  MUL EBX
  MOVD MM4,EAX
  MOVD EAX,MM1
  MUL EBX
  MOVD MM5,EAX
  PUNPCKLDQ MM4,MM5
  MOV EBX,0
@rilm8_w13:
  PADDD MM0,MM4

  CMP ECX,vdxd
  JLE @rilm8_w14
  MOV ECX,vdxd
@rilm8_w14:

  SUB ECX,EBX
  INC ECX
  LEA EDI,[EDI+EBX] {bytperpix}

  MOV EAX,smxd
  SHL EAX,16
  OR EAX,1 {bytperpix}
  MOVD MM4,EAX
  MOV EDX,sadr

@rilm8_loop0:
  MOVQ MM1,MM0
  PSRLD MM1,16
  PACKSSDW MM1,MM5
  PMADDWD MM1,MM4
  MOVD EAX,MM1
  PADDD MM0,MM3
  MOV AL,[EAX+EDX]
  DEC ECX
  STOSB
  JNZ @rilm8_loop0
@rilm8_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @rilm8_loop5
@rilm8_ende:
  EMMS
  MOV EAX,dst
END;

FUNCTION rotateimageLword(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
VAR xdx,xdy,ydx,ydy:longint;
    px1,py1,px2,py2:longint;
    lx1,ly1,lx2,ly2:longint;
    sxd,syd,smxd,smxdfxp,sadr,dxd,dyd,dmxd,dc,vdxd,vdyd:longint;
    mx,my,mxd,myd:longint;
    mx1,my1,mx2,my2:longint;
    ww,tx1,ty1,tx2,ty2:longint;
    d:longint;
ASM
{---------------------------}
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
  SHL EAX,16
  MOV smxdfxp,EAX
{  ADD ESI,imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  SHL rx,15
  SHL ry,15

  MOV EAX,w
  MOV EBX,EAX
  ADD EBX,16384

  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX
  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX

  CALL sinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdx,EAX

  CALL cosinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdy,EAX

  CALL sinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydx,EAX

  CALL cosinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydy,EAX
{---------------------------}
  MOV EDI,graphbuf
  MOV ECX,rx
  MOV EDX,ry
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@ril16_loop1:
  LODSD
  CMP EAX,px1
  JGE @ril16_w1
  MOV px1,EAX
@ril16_w1:
  CMP EAX,px2
  JLE @ril16_w2
  MOV px2,EAX
@ril16_w2:
  LODSD
  CMP EAX,py1
  JGE @ril16_w3
  MOV py1,EAX
@ril16_w3:
  CMP EAX,py2
  JLE @ril16_w4
  MOV py2,EAX
@ril16_w4:
  ADD ESI,8
  DEC ECX
  JNZ @ril16_loop1
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @ril16_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @ril16_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @ril16_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@ril16_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @ril16_loop2
{---------------------------}
  MOV ESI,graphbuf
  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  MOV ECX,4
@ril16_loop3:
  PUSH ECX

  MOV EAX,lx2
  MOV lx1,EAX
  MOV EAX,ly2
  MOV ly1,EAX
  MOV EAX,mx2
  MOV mx1,EAX
  MOV EAX,my2
  MOV my1,EAX

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  PUSH ESI

  MOV ECX,ly2
  SUB ECX,ly1
  JZ @ril16_w5

  MOV EBX,mx1
  MOV EAX,mx2
  SHL EBX,16
  SHL EAX,16
  MOV mx,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV mxd,EAX

  MOV EBX,my1
  MOV EAX,my2
  SHL EBX,16
  SHL EAX,16
  MOV my,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV myd,EAX

  MOV EAX,lx1
  MOV EDI,ly1
  MOV EDX,lx2
  MOV ECX,ly2

  CMP EDI,ECX
  JE @ril16_w5
  JL @ril16_w6
  XCHG EAX,EDX
  XCHG EDI,ECX
  PUSH EAX
  MOV EAX,mx2
  SHL EAX,16
  MOV mx,EAX
  MOV EAX,my2
  SHL EAX,16
  MOV my,EAX
  POP EAX
@ril16_w6:

  SUB EDX,EAX
  SUB ECX,EDI

  SHL EAX,16
  SHL EDX,16

  PUSH EAX
  MOV EAX,EDX
  CDQ
  IDIV ECX
  MOV dc,EAX
  POP EAX

  MOV EDX,mx
  MOV ESI,my

  SHL EDI,5
  ADD EDI,256
  ADD EDI,graphbuf
@ril16_loop4:
  MOV EBX,[EDI]
  INC EBX
  MOV [EDI],EBX
  MOV [EDI+EBX*4],EAX
  MOV [EDI+EBX*8],EDX
  MOV [EDI+EBX*8+4],ESI
  ADD EDI,32
  ADD EAX,dc
  ADD EDX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril16_loop4
@ril16_w5:
  POP ESI
  POP ECX
  DEC ECX
  JNZ @ril16_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @ril16_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@ril16_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @ril16_w10
  MOV ECX,vdyd
  INC ECX
@ril16_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd
{  ADD EDI,dst
  ADD EDI,_imagedatastart }
  ADD EDI,d

@ril16_loop5:

  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI]
  MOV ECX,[ESI+4]
  SAR EBX,16
  SAR ECX,16
  MOV EDX,ESI
  ADD EDX,8
  MOV EAX,EDX
  ADD EDX,8

  CMP EBX,ECX
  JL @ril16_w12
  XCHG EBX,ECX
  XCHG EAX,EDX
@ril16_w12:

  MOV ESI,[EAX+0]
  MOV tx1,ESI
  MOV ESI,[EAX+4]
  MOV ty1,ESI
  MOV ESI,[EDX+0]
  MOV tx2,ESI
  MOV ESI,[EDX+4]
  MOV ty2,ESI

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI
  MOV dc,ESI

  XOR ESI,ESI

  CMP EBX,vdxd
  JG @ril16_noline
  CMP ECX,0
  JL @ril16_noline

  CMP EBX,0
  JGE @ril16_w13
  SUB ESI,EBX
  MOV EBX,0
@ril16_w13:

  CMP ECX,vdxd
  JLE @ril16_w14
  MOV ECX,vdxd
@ril16_w14:

  SUB ECX,EBX
  INC ECX
  SHL EBX,1 {bytperpix}
  ADD EDI,EBX

  PUSH ECX
  MOV EAX,tx2
  MOV EBX,tx1
  SUB EAX,EBX
  CDQ
  IDIV dc
  MOV mxd,EAX
  MUL ESI
  ADD EBX,EAX

  MOV EAX,ty2
  MOV ECX,ty1
  SUB EAX,ECX
  CDQ
  IDIV dc
  MOV myd,EAX
  MUL ESI
  ADD ECX,EAX

  MOV ESI,ECX
  POP ECX
@ril16_loop0:
  MOV EAX,ESI
  AND EAX,0FFFF0000h
  IMUL smxdfxp
  MOV EAX,EBX
  ADD EDX,sadr
  SAR EAX,16
  MOV AX,[EDX+EAX*2]
  STOSW
  ADD EBX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril16_loop0

@ril16_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @ril16_loop5
@ril16_ende:
  MOV EAX,dst
END;

FUNCTION rotateimageLMword(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
TYPE TPt=RECORD x,y:longint; END;
VAR px1,py1,px2,py2:longint;
    L1,L2,M1,M2,T1,T2,PYSB:TPt;
    sxd,syd,smxd,sadr,dxd,dyd,dmxd,vdxd,vdyd:longint;
    sinx,siny,cosx,cosy:longint;
    d:longint;
ASM
  MOV EAX,w
  PUSH EAX
  PUSH EAX
  ADD EAX,16384
  PUSH EAX
  PUSH EAX
  CALL sinus
  MOV sinx,EAX
  CALL cosinus
  MOV cosx,EAX
  CALL sinus
  MOV siny,EAX
  CALL cosinus
  MOV cosy,EAX

  SHL rx,15
  SHL ry,15

{---------------------------}

  MOV EBX,fx
  MOV EAX,sinx
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  SUB ry,EAX
  MOV EBX,fy
  MOV EAX,siny
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,xd
  MOV EAX,sinx
  IMUL EAX,EBX
  MOVD MM2,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  MOVD MM3,EAX
  MOV EBX,yd
  MOV EAX,siny
  IMUL EAX,EBX
  MOVD MM4,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  MOVD MM5,EAX

  MOV ECX,rx
  MOV EDX,ry
  MOVD MM0,ECX
  MOVD MM1,EDX
  PUNPCKLDQ MM0,MM1
  PUNPCKLDQ MM2,MM3
  PUNPCKLDQ MM4,MM5

{---------------------------}
  PXOR MM5,MM5
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  DEC EAX
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM5
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  DEC EAX
  MOVD MM7,EAX
  PUNPCKLDQ MM5,MM7
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
{  ADD ESI,imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  MOV EDI,graphbuf
  PXOR MM7,MM7
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+00h],MM6
  MOVQ [EDI+08h],MM7
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PSRAD MM6,15
  MOVQ [EDI+10h],MM6
  MOVQ [EDI+18h],MM3
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+20h],MM6
  MOVQ MM6,MM3
  PADDD MM6,MM5
  MOVQ [EDI+28h],MM6
  MOVQ MM6,MM0
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+30h],MM6
  MOVQ [EDI+38h],MM5
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+40h],MM6
  MOVQ [EDI+48h],MM7
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@rilm16_loop1:
  LODSD
  CMP EAX,px1
  JGE @rilm16_w1
  MOV px1,EAX
@rilm16_w1:
  CMP EAX,px2
  JLE @rilm16_w2
  MOV px2,EAX
@rilm16_w2:
  LODSD
  CMP EAX,py1
  JGE @rilm16_w3
  MOV py1,EAX
@rilm16_w3:
  CMP EAX,py2
  JLE @rilm16_w4
  MOV py2,EAX
@rilm16_w4:
  ADD ESI,8
  DEC ECX
  JNZ @rilm16_loop1

  PXOR MM0,MM0
  MOV EAX,py1
  MOVD MM1,EAX
  PUNPCKLDQ MM0,MM1
  MOVQ PYSB,MM0
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @rilm16_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @rilm16_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @rilm16_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@rilm16_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @rilm16_loop2
{---------------------------}
  MOV ESI,graphbuf

  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI+8]
  PSUBD MM0,PYSB
  MOVQ M2,MM1
  MOVQ L2,MM0
  ADD ESI,16

  MOV EBX,4
@rilm16_loop3:
  MOVQ MM6,L2
  MOVQ MM4,M2
  MOVQ L1,MM6
  MOVQ M1,MM4

  MOVQ MM7,[ESI]
  MOVQ MM5,[ESI+8]
  PSUBD MM7,PYSB
  MOVQ M2,MM5
  MOVQ L2,MM7
  ADD ESI,16

  MOVQ MM2,MM4
  MOV ECX,L2.y
  SUB ECX,L1.y
  JZ @rilm16_w5
  JNS @rilm16_w6
  MOVQ MM1,MM6
  MOVQ MM6,MM7
  MOVQ MM7,MM1
  MOVQ MM2,MM5
@rilm16_w6:

  PSUBD MM5,MM4
  PSLLD MM5,16
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM0,EAX
  PSRLQ MM5,32
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM5,EAX
  PUNPCKLDQ MM0,MM5

  PSUBD MM7,MM6 {MM7=L2-L1,MM6=L1}
  PSLLD MM2,16  {MM2=start textcoord}
  MOVQ MM1,MM6
  PSLLD MM7,16  {MM7=dy|dx}
  PSLLD MM1,16  {L1.x - MM1=line start X }
  MOVD EAX,MM7  {EAX=dx}
  PSRLQ MM6,32
  PSRLQ MM7,48
  MOVD EDI,MM6  {EDI=line start Y }
  MOVD ECX,MM7  {ECX=dy}
  CDQ
  IDIV ECX
  MOVD MM7,EAX  {MM7=(dx/dy)}

  SHL EDI,5
  ADD EDI,256
  MOV EDX,1
  ADD EDI,graphbuf
@rilm16_loop4:
  ADD EDX,[EDI]
  MOVD DWORD PTR [EDI+EDX*4],MM1
  MOVQ [EDI+EDX*8],MM2
  PADDD MM1,MM7
  MOV [EDI],EDX
  PADDD MM2,MM0
  ADD EDI,32
  MOV EDX,1
  DEC ECX
  JNZ @rilm16_loop4
@rilm16_w5:
  DEC EBX
  JNZ @rilm16_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @rilm16_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@rilm16_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @rilm16_w10
  MOV ECX,vdyd
  INC ECX
@rilm16_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd
{  ADD EDI,dst
  ADD EDI,_imagedatastart }
  ADD EDI,d


@rilm16_loop5:

  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI]
  MOV ECX,[ESI+4]
  MOVQ MM0,[ESI+8]
  MOVQ MM1,[ESI+16]
  SAR EBX,16
  SAR ECX,16

  CMP EBX,ECX
  JL @rilm16_w12
  XCHG EBX,ECX
  MOVQ MM7,MM0
  MOVQ MM0,MM1
  MOVQ MM1,MM7
@rilm16_w12:

  CMP EBX,vdxd
  JG @rilm16_noline
  CMP ECX,0
  JL @rilm16_noline

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI

  PSUBD MM1,MM0
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM3,EAX
  PSRLQ MM1,32
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM1,EAX
  PXOR MM4,MM4
  PUNPCKLDQ MM3,MM1

  CMP EBX,0
  JGE @rilm16_w13
  NEG EBX
  MOVD MM7,EBX
  PUNPCKLWD MM7,MM7
  MOVD EAX,MM3
  MUL EBX
  MOVD MM4,EAX
  MOVD EAX,MM1
  MUL EBX
  MOVD MM5,EAX
  PUNPCKLDQ MM4,MM5
  MOV EBX,0
@rilm16_w13:
  PADDD MM0,MM4

  CMP ECX,vdxd
  JLE @rilm16_w14
  MOV ECX,vdxd
@rilm16_w14:

  SUB ECX,EBX
  INC ECX
  LEA EDI,[EDI+EBX*2] {bytperpix}

  MOV EAX,smxd
  SHL EAX,16
  OR EAX,2 {bytperpix}
  MOVD MM4,EAX
  MOV EDX,sadr

@rilm16_loop0:
  MOVQ MM1,MM0
  PSRLD MM1,16
  PACKSSDW MM1,MM5
  PMADDWD MM1,MM4
  MOVD EAX,MM1
  PADDD MM0,MM3
  MOV AX,[EAX+EDX]
  DEC ECX
  STOSW
  JNZ @rilm16_loop0
@rilm16_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @rilm16_loop5
@rilm16_ende:
  EMMS
  MOV EAX,dst
END;

FUNCTION rotateimageL24(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
VAR xdx,xdy,ydx,ydy:longint;
    px1,py1,px2,py2:longint;
    lx1,ly1,lx2,ly2:longint;
    sxd,syd,smxd,smxdfxp,sadr,dxd,dyd,dmxd,dc,vdxd,vdyd:longint;
    mx,my,mxd,myd:longint;
    mx1,my1,mx2,my2:longint;
    ww,tx1,ty1,tx2,ty2:longint;
    d:longint;
ASM
{---------------------------}
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
  SHL EAX,16
  MOV smxdfxp,EAX
{  ADD ESI,_imagedatastart }

  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  SHL rx,15
  SHL ry,15

  MOV EAX,w
  MOV EBX,EAX
  ADD EBX,16384

  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX
  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX

  CALL sinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdx,EAX

  CALL cosinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdy,EAX

  CALL sinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydx,EAX

  CALL cosinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydy,EAX
{---------------------------}
  MOV EDI,graphbuf
  MOV ECX,rx
  MOV EDX,ry
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@ril24_loop1:
  LODSD
  CMP EAX,px1
  JGE @ril24_w1
  MOV px1,EAX
@ril24_w1:
  CMP EAX,px2
  JLE @ril24_w2
  MOV px2,EAX
@ril24_w2:
  LODSD
  CMP EAX,py1
  JGE @ril24_w3
  MOV py1,EAX
@ril24_w3:
  CMP EAX,py2
  JLE @ril24_w4
  MOV py2,EAX
@ril24_w4:
  ADD ESI,8
  DEC ECX
  JNZ @ril24_loop1
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @ril24_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @ril24_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @ril24_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@ril24_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @ril24_loop2
{---------------------------}
  MOV ESI,graphbuf
  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  MOV ECX,4
@ril24_loop3:
  PUSH ECX

  MOV EAX,lx2
  MOV lx1,EAX
  MOV EAX,ly2
  MOV ly1,EAX
  MOV EAX,mx2
  MOV mx1,EAX
  MOV EAX,my2
  MOV my1,EAX

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  PUSH ESI

  MOV ECX,ly2
  SUB ECX,ly1
  JZ @ril24_w5

  MOV EBX,mx1
  MOV EAX,mx2
  SHL EBX,16
  SHL EAX,16
  MOV mx,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV mxd,EAX

  MOV EBX,my1
  MOV EAX,my2
  SHL EBX,16
  SHL EAX,16
  MOV my,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV myd,EAX

  MOV EAX,lx1
  MOV EDI,ly1
  MOV EDX,lx2
  MOV ECX,ly2

  CMP EDI,ECX
  JE @ril24_w5
  JL @ril24_w6
  XCHG EAX,EDX
  XCHG EDI,ECX
  PUSH EAX
  MOV EAX,mx2
  SHL EAX,16
  MOV mx,EAX
  MOV EAX,my2
  SHL EAX,16
  MOV my,EAX
  POP EAX
@ril24_w6:

  SUB EDX,EAX
  SUB ECX,EDI

  SHL EAX,16
  SHL EDX,16

  PUSH EAX
  MOV EAX,EDX
  CDQ
  IDIV ECX
  MOV dc,EAX
  POP EAX

  MOV EDX,mx
  MOV ESI,my

  SHL EDI,5
  ADD EDI,256
  ADD EDI,graphbuf
@ril24_loop4:
  MOV EBX,[EDI]
  INC EBX
  MOV [EDI],EBX
  MOV [EDI+EBX*4],EAX
  MOV [EDI+EBX*8],EDX
  MOV [EDI+EBX*8+4],ESI
  ADD EDI,32
  ADD EAX,dc
  ADD EDX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril24_loop4
@ril24_w5:
  POP ESI
  POP ECX
  DEC ECX
  JNZ @ril24_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @ril24_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@ril24_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @ril24_w10
  MOV ECX,vdyd
  INC ECX
@ril24_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd
{  ADD EDI,dst
  ADD EDI,_imagedatastart }
  ADD EDI,d

@ril24_loop5:

  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI]
  MOV ECX,[ESI+4]
  SAR EBX,16
  SAR ECX,16
  MOV EDX,ESI
  ADD EDX,8
  MOV EAX,EDX
  ADD EDX,8

  CMP EBX,ECX
  JL @ril24_w12
  XCHG EBX,ECX
  XCHG EAX,EDX
@ril24_w12:

  MOV ESI,[EAX+0]
  MOV tx1,ESI
  MOV ESI,[EAX+4]
  MOV ty1,ESI
  MOV ESI,[EDX+0]
  MOV tx2,ESI
  MOV ESI,[EDX+4]
  MOV ty2,ESI

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI
  MOV dc,ESI

  XOR ESI,ESI

  CMP EBX,vdxd
  JG @ril24_noline
  CMP ECX,0
  JL @ril24_noline

  CMP EBX,0
  JGE @ril24_w13
  SUB ESI,EBX
  MOV EBX,0
@ril24_w13:

  CMP ECX,vdxd
  JLE @ril24_w14
  MOV ECX,vdxd
@ril24_w14:

  SUB ECX,EBX
  INC ECX

  LEA EBX,[EBX+EBX*2] {bytperpix}
  ADD EDI,EBX

  PUSH ECX

  MOV EAX,tx2
  MOV EBX,tx1
  SUB EAX,EBX
  CDQ
  IDIV dc
  MOV mxd,EAX
  MUL ESI
  ADD EBX,EAX

  MOV EAX,ty2
  MOV ECX,ty1
  SUB EAX,ECX
  CDQ
  IDIV dc
  MOV myd,EAX
  MUL ESI
  ADD ECX,EAX

  MOV ESI,ECX
  POP ECX

@ril24_loop0:
  MOV EAX,ESI
  AND EAX,0FFFF0000h
  IMUL smxdfxp
  MOV EAX,EBX
  ADD EDX,sadr
  SAR EAX,16
  ADD EDX,EAX
  MOV EAX,[EDX+EAX*2-1]
  SHR EAX,8
  STOSW
  SHR EAX,16
  STOSB
  ADD EBX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril24_loop0

@ril24_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @ril24_loop5
@ril24_ende:
  MOV EAX,dst
END;

FUNCTION rotateimageLM24(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
TYPE TPt=RECORD x,y:longint; END;
VAR px1,py1,px2,py2:longint;
    L1,L2,M1,M2,T1,T2,PYSB:TPt;
    sxd,syd,smxd,sadr,dxd,dyd,dmxd,vdxd,vdyd:longint;
    sinx,siny,cosx,cosy:longint;
    d:longint;
ASM
  MOV EAX,w
  PUSH EAX
  PUSH EAX
  ADD EAX,16384
  PUSH EAX
  PUSH EAX
  CALL sinus
  MOV sinx,EAX
  CALL cosinus
  MOV cosx,EAX
  CALL sinus
  MOV siny,EAX
  CALL cosinus
  MOV cosy,EAX

  SHL rx,15
  SHL ry,15

{---------------------------}

  MOV EBX,fx
  MOV EAX,sinx
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  SUB ry,EAX
  MOV EBX,fy
  MOV EAX,siny
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,xd
  MOV EAX,sinx
  IMUL EAX,EBX
  MOVD MM2,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  MOVD MM3,EAX
  MOV EBX,yd
  MOV EAX,siny
  IMUL EAX,EBX
  MOVD MM4,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  MOVD MM5,EAX

  MOV ECX,rx
  MOV EDX,ry
  MOVD MM0,ECX
  MOVD MM1,EDX
  PUNPCKLDQ MM0,MM1
  PUNPCKLDQ MM2,MM3
  PUNPCKLDQ MM4,MM5

{---------------------------}
  PXOR MM5,MM5
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  DEC EAX
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM5
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  DEC EAX
  MOVD MM7,EAX
  PUNPCKLDQ MM5,MM7
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
{  ADD ESI,_imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  MOV EDI,graphbuf
  PXOR MM7,MM7
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+00h],MM6
  MOVQ [EDI+08h],MM7
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PSRAD MM6,15
  MOVQ [EDI+10h],MM6
  MOVQ [EDI+18h],MM3
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+20h],MM6
  MOVQ MM6,MM3
  PADDD MM6,MM5
  MOVQ [EDI+28h],MM6
  MOVQ MM6,MM0
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+30h],MM6
  MOVQ [EDI+38h],MM5
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+40h],MM6
  MOVQ [EDI+48h],MM7
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@rilm24_loop1:
  LODSD
  CMP EAX,px1
  JGE @rilm24_w1
  MOV px1,EAX
@rilm24_w1:
  CMP EAX,px2
  JLE @rilm24_w2
  MOV px2,EAX
@rilm24_w2:
  LODSD
  CMP EAX,py1
  JGE @rilm24_w3
  MOV py1,EAX
@rilm24_w3:
  CMP EAX,py2
  JLE @rilm24_w4
  MOV py2,EAX
@rilm24_w4:
  ADD ESI,8
  DEC ECX
  JNZ @rilm24_loop1

  PXOR MM0,MM0
  MOV EAX,py1
  MOVD MM1,EAX
  PUNPCKLDQ MM0,MM1
  MOVQ PYSB,MM0
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @rilm24_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @rilm24_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @rilm24_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@rilm24_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @rilm24_loop2
{---------------------------}
  MOV ESI,graphbuf

  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI+8]
  PSUBD MM0,PYSB
  MOVQ M2,MM1
  MOVQ L2,MM0
  ADD ESI,16

  MOV EBX,4
@rilm24_loop3:
  MOVQ MM6,L2
  MOVQ MM4,M2
  MOVQ L1,MM6
  MOVQ M1,MM4

  MOVQ MM7,[ESI]
  MOVQ MM5,[ESI+8]
  PSUBD MM7,PYSB
  MOVQ M2,MM5
  MOVQ L2,MM7
  ADD ESI,16

  MOVQ MM2,MM4
  MOV ECX,L2.y
  SUB ECX,L1.y
  JZ @rilm24_w5
  JNS @rilm24_w6
  MOVQ MM1,MM6
  MOVQ MM6,MM7
  MOVQ MM7,MM1
  MOVQ MM2,MM5
@rilm24_w6:

  PSUBD MM5,MM4
  PSLLD MM5,16
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM0,EAX
  PSRLQ MM5,32
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM5,EAX
  PUNPCKLDQ MM0,MM5

  PSUBD MM7,MM6 {MM7=L2-L1,MM6=L1}
  PSLLD MM2,16  {MM2=start textcoord}
  MOVQ MM1,MM6
  PSLLD MM7,16  {MM7=dy|dx}
  PSLLD MM1,16  {L1.x - MM1=line start X }
  MOVD EAX,MM7  {EAX=dx}
  PSRLQ MM6,32
  PSRLQ MM7,48
  MOVD EDI,MM6  {EDI=line start Y }
  MOVD ECX,MM7  {ECX=dy}
  CDQ
  IDIV ECX
  MOVD MM7,EAX  {MM7=(dx/dy)}

  SHL EDI,5
  ADD EDI,256
  MOV EDX,1
  ADD EDI,graphbuf
@rilm24_loop4:
  ADD EDX,[EDI]
  MOVD DWORD PTR [EDI+EDX*4],MM1
  MOVQ [EDI+EDX*8],MM2
  PADDD MM1,MM7
  MOV [EDI],EDX
  PADDD MM2,MM0
  ADD EDI,32
  MOV EDX,1
  DEC ECX
  JNZ @rilm24_loop4
@rilm24_w5:
  DEC EBX
  JNZ @rilm24_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @rilm24_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@rilm24_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @rilm24_w10
  MOV ECX,vdyd
  INC ECX
@rilm24_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd
{  ADD EDI,dst
  ADD EDI,_imagedatastart }
  ADD EDI,d

@rilm24_loop5:

  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI]
  MOV ECX,[ESI+4]
  MOVQ MM0,[ESI+8]
  MOVQ MM1,[ESI+16]
  SAR EBX,16
  SAR ECX,16

  CMP EBX,ECX
  JL @rilm24_w12
  XCHG EBX,ECX
  MOVQ MM7,MM0
  MOVQ MM0,MM1
  MOVQ MM1,MM7
@rilm24_w12:

  CMP EBX,vdxd
  JG @rilm24_noline
  CMP ECX,0
  JL @rilm24_noline

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI

  PSUBD MM1,MM0
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM3,EAX
  PSRLQ MM1,32
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM1,EAX
  PXOR MM4,MM4
  PUNPCKLDQ MM3,MM1

  CMP EBX,0
  JGE @rilm24_w13
  NEG EBX
  MOVD MM7,EBX
  PUNPCKLWD MM7,MM7
  MOVD EAX,MM3
  MUL EBX
  MOVD MM4,EAX
  MOVD EAX,MM1
  MUL EBX
  MOVD MM5,EAX
  PUNPCKLDQ MM4,MM5
  MOV EBX,0
@rilm24_w13:
  PADDD MM0,MM4

  CMP ECX,vdxd
  JLE @rilm24_w14
  MOV ECX,vdxd
@rilm24_w14:

  SUB ECX,EBX
  INC ECX
  ADD EDI,EBX
  LEA EDI,[EDI+EBX*2] {bytperpix}

  MOV EAX,smxd
  SHL EAX,16
  OR EAX,3 {bytperpix}
  MOVD MM4,EAX
  MOV EDX,sadr
  DEC EDX
@rilm24_loop0:
  MOVQ MM1,MM0
  PSRLD MM1,16
  PACKSSDW MM1,MM5
  PMADDWD MM1,MM4
  MOVD EAX,MM1
  PADDD MM0,MM3
  MOV EAX,[EAX+EDX]
  SHR EAX,8
  STOSW
  SHR EAX,16
  STOSB
  DEC ECX
  JNZ @rilm24_loop0
@rilm24_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @rilm24_loop5
@rilm24_ende:
  EMMS
  MOV EAX,dst
END;

FUNCTION rotateimageL32(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
VAR xdx,xdy,ydx,ydy:longint;
    px1,py1,px2,py2:longint;
    lx1,ly1,lx2,ly2:longint;
    sxd,syd,smxd,smxdfxp,sadr,dxd,dyd,dmxd,dc,vdxd,vdyd:longint;
    mx,my,mxd,myd:longint;
    mx1,my1,mx2,my2:longint;
    ww,tx1,ty1,tx2,ty2:longint;
    d:longint;
ASM
{---------------------------}
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
  SHL EAX,16
  MOV smxdfxp,EAX
{  ADD ESI,_imagedatastart }
  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  SHL rx,15
  SHL ry,15

  MOV EAX,w
  MOV EBX,EAX
  ADD EBX,16384

  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX
  PUSH EAX
  PUSH EAX
  PUSH EBX
  PUSH EBX

  CALL sinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fx
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB rx,EAX

  CALL cosinus
  MOV EBX,fy
  IMUL EAX,EBX
  SUB ry,EAX

  CALL sinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdx,EAX

  CALL cosinus
  MOV EBX,xd
  IMUL EAX,EBX
  MOV xdy,EAX

  CALL sinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydx,EAX

  CALL cosinus
  MOV EBX,yd
  IMUL EAX,EBX
  MOV ydy,EAX
{---------------------------}
  MOV EDI,graphbuf
  MOV ECX,rx
  MOV EDX,ry
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,xdx
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,xdy
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,sxd
  DEC EAX
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  ADD EAX,ydx
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  ADD EAX,ydy
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,syd
  DEC EAX
  STOSD
  MOV EAX,ECX {---}
  SAR EAX,15
  STOSD
  MOV EAX,EDX
  SAR EAX,15
  STOSD
  MOV EAX,0
  STOSD
  MOV EAX,0
  STOSD
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@ril32_loop1:
  LODSD
  CMP EAX,px1
  JGE @ril32_w1
  MOV px1,EAX
@ril32_w1:
  CMP EAX,px2
  JLE @ril32_w2
  MOV px2,EAX
@ril32_w2:
  LODSD
  CMP EAX,py1
  JGE @ril32_w3
  MOV py1,EAX
@ril32_w3:
  CMP EAX,py2
  JLE @ril32_w4
  MOV py2,EAX
@ril32_w4:
  ADD ESI,8
  DEC ECX
  JNZ @ril32_loop1
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @ril32_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @ril32_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @ril32_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@ril32_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @ril32_loop2
{---------------------------}
  MOV ESI,graphbuf
  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  MOV ECX,4
@ril32_loop3:
  PUSH ECX

  MOV EAX,lx2
  MOV lx1,EAX
  MOV EAX,ly2
  MOV ly1,EAX
  MOV EAX,mx2
  MOV mx1,EAX
  MOV EAX,my2
  MOV my1,EAX

  LODSD
  MOV lx2,EAX
  LODSD
  SUB EAX,py1
  MOV ly2,EAX
  LODSD
  MOV mx2,EAX
  LODSD
  MOV my2,EAX

  PUSH ESI

  MOV ECX,ly2
  SUB ECX,ly1
  JZ @ril32_w5

  MOV EBX,mx1
  MOV EAX,mx2
  SHL EBX,16
  SHL EAX,16
  MOV mx,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV mxd,EAX

  MOV EBX,my1
  MOV EAX,my2
  SHL EBX,16
  SHL EAX,16
  MOV my,EBX
  SUB EAX,EBX
  CDQ
  IDIV ECX
  MOV myd,EAX

  MOV EAX,lx1
  MOV EDI,ly1
  MOV EDX,lx2
  MOV ECX,ly2

  CMP EDI,ECX
  JE @ril32_w5
  JL @ril32_w6
  XCHG EAX,EDX
  XCHG EDI,ECX
  PUSH EAX
  MOV EAX,mx2
  SHL EAX,16
  MOV mx,EAX
  MOV EAX,my2
  SHL EAX,16
  MOV my,EAX
  POP EAX
@ril32_w6:

  SUB EDX,EAX
  SUB ECX,EDI

  SHL EAX,16
  SHL EDX,16

  PUSH EAX
  MOV EAX,EDX
  CDQ
  IDIV ECX
  MOV dc,EAX
  POP EAX

  MOV EDX,mx
  MOV ESI,my

  SHL EDI,5
  ADD EDI,256
  ADD EDI,graphbuf
@ril32_loop4:
  MOV EBX,[EDI]
  INC EBX
  MOV [EDI],EBX
  MOV [EDI+EBX*4],EAX
  MOV [EDI+EBX*8],EDX
  MOV [EDI+EBX*8+4],ESI
  ADD EDI,32
  ADD EAX,dc
  ADD EDX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril32_loop4
@ril32_w5:
  POP ESI
  POP ECX
  DEC ECX
  JNZ @ril32_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @ril32_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@ril32_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @ril32_w10
  MOV ECX,vdyd
  INC ECX
@ril32_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd
{  ADD EDI,dst
  ADD EDI,_imagedatastart }
  ADD EDI,d


@ril32_loop5:

  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI]
  MOV ECX,[ESI+4]
  SAR EBX,16
  SAR ECX,16
  MOV EDX,ESI
  ADD EDX,8
  MOV EAX,EDX
  ADD EDX,8

  CMP EBX,ECX
  JL @ril32_w12
  XCHG EBX,ECX
  XCHG EAX,EDX
@ril32_w12:

  MOV ESI,[EAX+0]
  MOV tx1,ESI
  MOV ESI,[EAX+4]
  MOV ty1,ESI
  MOV ESI,[EDX+0]
  MOV tx2,ESI
  MOV ESI,[EDX+4]
  MOV ty2,ESI

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI
  MOV dc,ESI

  XOR ESI,ESI

  CMP EBX,vdxd
  JG @ril32_noline
  CMP ECX,0
  JL @ril32_noline

  CMP EBX,0
  JGE @ril32_w13
  SUB ESI,EBX
  MOV EBX,0
@ril32_w13:

  CMP ECX,vdxd
  JLE @ril32_w14
  MOV ECX,vdxd
@ril32_w14:

  SUB ECX,EBX
  INC ECX

  SHL EBX,2 {bytperpix}
  ADD EDI,EBX

  PUSH ECX

  MOV EAX,tx2
  MOV EBX,tx1
  SUB EAX,EBX
  CDQ
  IDIV dc
  MOV mxd,EAX
  MUL ESI
  ADD EBX,EAX

  MOV EAX,ty2
  MOV ECX,ty1
  SUB EAX,ECX
  CDQ
  IDIV dc
  MOV myd,EAX
  MUL ESI
  ADD ECX,EAX

  MOV ESI,ECX
  POP ECX

@ril32_loop0:
  MOV EAX,ESI
  AND EAX,0FFFF0000h
  IMUL smxdfxp
  MOV EAX,EBX
  ADD EDX,sadr
  SAR EAX,16
  MOV EAX,[EDX+EAX*4]
  STOSD
  ADD EBX,mxd
  ADD ESI,myd
  DEC ECX
  JNZ @ril32_loop0

@ril32_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @ril32_loop5
@ril32_ende:
  MOV EAX,dst
END;

FUNCTION rotateimageLM32(dst,src:pimage;rx,ry,fx,fy,xd,yd,w:longint):pimage;assembler;
TYPE TPt=RECORD x,y:longint; END;
VAR px1,py1,px2,py2:longint;
    L1,L2,M1,M2,T1,T2,PYSB:TPt;
    sxd,syd,smxd,sadr,dxd,dyd,dmxd,vdxd,vdyd:longint;
    sinx,siny,cosx,cosy:longint;
    d:longint;
ASM
  MOV EAX,w
  PUSH EAX
  PUSH EAX
  ADD EAX,16384
  PUSH EAX
  PUSH EAX
  CALL sinus
  MOV sinx,EAX
  CALL cosinus
  MOV cosx,EAX
  CALL sinus
  MOV siny,EAX
  CALL cosinus
  MOV cosy,EAX

  SHL rx,15
  SHL ry,15

{---------------------------}

  MOV EBX,fx
  MOV EAX,sinx
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  SUB ry,EAX
  MOV EBX,fy
  MOV EAX,siny
  IMUL EAX,EBX
  SUB rx,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  SUB ry,EAX

  MOV EBX,xd
  MOV EAX,sinx
  IMUL EAX,EBX
  MOVD MM2,EAX
  MOV EAX,cosx
  IMUL EAX,EBX
  MOVD MM3,EAX
  MOV EBX,yd
  MOV EAX,siny
  IMUL EAX,EBX
  MOVD MM4,EAX
  MOV EAX,cosy
  IMUL EAX,EBX
  MOVD MM5,EAX

  MOV ECX,rx
  MOV EDX,ry
  MOVD MM0,ECX
  MOVD MM1,EDX
  PUNPCKLDQ MM0,MM1
  PUNPCKLDQ MM2,MM3
  PUNPCKLDQ MM4,MM5

{---------------------------}
  PXOR MM5,MM5
  MOV ESI,src
  MOV EAX,[ESI+timage.width]
  MOV sxd,EAX
  DEC EAX
  MOVD MM3,EAX
  PUNPCKLDQ MM3,MM5
  MOV EAX,[ESI+timage.height]
  MOV syd,EAX
  DEC EAX
  MOVD MM7,EAX
  PUNPCKLDQ MM5,MM7
  MOV EAX,[ESI+timage.bytesperline]
  MOV smxd,EAX
{  ADD ESI,_imagedatastart }

  MOV ESI,[ESI+timage.pixeldata]
  MOV sadr,ESI
{---------------------------}
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV dxd,EAX
  DEC EAX
  MOV vdxd,EAX
  MOV EAX,[EDI+timage.height]
  MOV dyd,EAX
  DEC EAX
  MOV vdyd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV dmxd,EAX
  MOV EAX,[EDI+timage.pixeldata]
  MOV d,EAX
{---------------------------}
  MOV EDI,graphbuf
  PXOR MM7,MM7
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+00h],MM6
  MOVQ [EDI+08h],MM7
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PSRAD MM6,15
  MOVQ [EDI+10h],MM6
  MOVQ [EDI+18h],MM3
  MOVQ MM6,MM0
  PADDD MM6,MM2
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+20h],MM6
  MOVQ MM6,MM3
  PADDD MM6,MM5
  MOVQ [EDI+28h],MM6
  MOVQ MM6,MM0
  PADDD MM6,MM4
  PSRAD MM6,15
  MOVQ [EDI+30h],MM6
  MOVQ [EDI+38h],MM5
  MOVQ MM6,MM0
  PSRAD MM6,15
  MOVQ [EDI+40h],MM6
  MOVQ [EDI+48h],MM7
{---------------------------}
  MOV ESI,graphbuf
  MOV ECX,4
  MOV px1,7FFFFFFFh
  MOV py1,7FFFFFFFh
  MOV px2,80000000h
  MOV py2,80000000h
@rilm32_loop1:
  LODSD
  CMP EAX,px1
  JGE @rilm32_w1
  MOV px1,EAX
@rilm32_w1:
  CMP EAX,px2
  JLE @rilm32_w2
  MOV px2,EAX
@rilm32_w2:
  LODSD
  CMP EAX,py1
  JGE @rilm32_w3
  MOV py1,EAX
@rilm32_w3:
  CMP EAX,py2
  JLE @rilm32_w4
  MOV py2,EAX
@rilm32_w4:
  ADD ESI,8
  DEC ECX
  JNZ @rilm32_loop1

  PXOR MM0,MM0
  MOV EAX,py1
  MOVD MM1,EAX
  PUNPCKLDQ MM0,MM1
  MOVQ PYSB,MM0
{---------------------------}
  MOV EAX,vdyd
  CMP EAX,py1
  JLE @rilm32_ende
  MOV EAX,0
  CMP EAX,py2
  JGE @rilm32_ende
{---------------------------}
  MOV ECX,py2
  SUB ECX,py1
  JZ @rilm32_ende
  MOV EDI,graphbuf
  ADD EDI,256
  MOV EAX,1
@rilm32_loop2:
  MOV [EDI],EAX
  ADD EDI,32
  DEC ECX
  JNZ @rilm32_loop2
{---------------------------}
  MOV ESI,graphbuf

  MOVQ MM0,[ESI]
  MOVQ MM1,[ESI+8]
  PSUBD MM0,PYSB
  MOVQ M2,MM1
  MOVQ L2,MM0
  ADD ESI,16

  MOV EBX,4
@rilm32_loop3:
  MOVQ MM6,L2
  MOVQ MM4,M2
  MOVQ L1,MM6
  MOVQ M1,MM4

  MOVQ MM7,[ESI]
  MOVQ MM5,[ESI+8]
  PSUBD MM7,PYSB
  MOVQ M2,MM5
  MOVQ L2,MM7
  ADD ESI,16

  MOVQ MM2,MM4
  MOV ECX,L2.y
  SUB ECX,L1.y
  JZ @rilm32_w5
  JNS @rilm32_w6
  MOVQ MM1,MM6
  MOVQ MM6,MM7
  MOVQ MM7,MM1
  MOVQ MM2,MM5
@rilm32_w6:

  PSUBD MM5,MM4
  PSLLD MM5,16
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM0,EAX
  PSRLQ MM5,32
  MOVD EAX,MM5
  CDQ
  IDIV ECX
  MOVD MM5,EAX
  PUNPCKLDQ MM0,MM5

  PSUBD MM7,MM6 {MM7=L2-L1,MM6=L1}
  PSLLD MM2,16  {MM2=start textcoord}
  MOVQ MM1,MM6
  PSLLD MM7,16  {MM7=dy|dx}
  PSLLD MM1,16  {L1.x - MM1=line start X }
  MOVD EAX,MM7  {EAX=dx}
  PSRLQ MM6,32
  PSRLQ MM7,48
  MOVD EDI,MM6  {EDI=line start Y }
  MOVD ECX,MM7  {ECX=dy}
  CDQ
  IDIV ECX
  MOVD MM7,EAX  {MM7=(dx/dy)}

  SHL EDI,5
  ADD EDI,256
  MOV EDX,1
  ADD EDI,graphbuf
@rilm32_loop4:
  ADD EDX,[EDI]
  MOVD DWORD PTR [EDI+EDX*4],MM1
  MOVQ [EDI+EDX*8],MM2
  PADDD MM1,MM7
  MOV [EDI],EDX
  PADDD MM2,MM0
  ADD EDI,32
  MOV EDX,1
  DEC ECX
  JNZ @rilm32_loop4
@rilm32_w5:
  DEC EBX
  JNZ @rilm32_loop3
{--- Zeichnen der X-Werte --}

  MOV EDI,py1
  XOR ESI,ESI

  CMP EDI,0
  JGE @rilm32_w9
  MOV ESI,EDI
  NEG ESI
  SHL ESI,5
  MOV EDI,0
@rilm32_w9:

  MOV ECX,py2
  CMP ECX,vdyd
  JLE @rilm32_w10
  MOV ECX,vdyd
  INC ECX
@rilm32_w10:

  ADD ESI,graphbuf
  ADD ESI,264

  SUB ECX,EDI
  IMUL EDI,dmxd
{  ADD EDI,dst
  ADD EDI,_imagedatastart }
  ADD EDI,d

@rilm32_loop5:

  PUSH EDI
  PUSH ESI
  PUSH ECX

  MOV EBX,[ESI]
  MOV ECX,[ESI+4]
  MOVQ MM0,[ESI+8]
  MOVQ MM1,[ESI+16]
  SAR EBX,16
  SAR ECX,16

  CMP EBX,ECX
  JL @rilm32_w12
  XCHG EBX,ECX
  MOVQ MM7,MM0
  MOVQ MM0,MM1
  MOVQ MM1,MM7
@rilm32_w12:

  CMP EBX,vdxd
  JG @rilm32_noline
  CMP ECX,0
  JL @rilm32_noline

  MOV ESI,ECX
  SUB ESI,EBX
  INC ESI

  PSUBD MM1,MM0
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM3,EAX
  PSRLQ MM1,32
  MOVD EAX,MM1
  CDQ
  IDIV ESI
  MOVD MM1,EAX
  PXOR MM4,MM4
  PUNPCKLDQ MM3,MM1

  CMP EBX,0
  JGE @rilm32_w13
  NEG EBX
  MOVD MM7,EBX
  PUNPCKLWD MM7,MM7
  MOVD EAX,MM3
  MUL EBX
  MOVD MM4,EAX
  MOVD EAX,MM1
  MUL EBX
  MOVD MM5,EAX
  PUNPCKLDQ MM4,MM5
  MOV EBX,0
@rilm32_w13:
  PADDD MM0,MM4

  CMP ECX,vdxd
  JLE @rilm32_w14
  MOV ECX,vdxd
@rilm32_w14:

  SUB ECX,EBX
  INC ECX
  LEA EDI,[EDI+EBX*4] {bytperpix}

  MOV EAX,smxd
  SHL EAX,16
  OR EAX,4 {bytperpix}
  MOVD MM4,EAX
  MOV EDX,sadr

@rilm32_loop0:
  MOVQ MM1,MM0
  PSRLD MM1,16
  PACKSSDW MM1,MM5
  PMADDWD MM1,MM4
  MOVD EAX,MM1
  PADDD MM0,MM3
  MOV EAX,[EAX+EDX]
  DEC ECX
  STOSD
  JNZ @rilm32_loop0
@rilm32_noline:
  POP ECX
  POP ESI
  POP EDI

  ADD EDI,dmxd
  ADD ESI,32
  DEC ECX
  JNZ @rilm32_loop5
@rilm32_ende:
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{----------------------------- mosaicimage ----------------------------------}

FUNCTION mosaicimageL8(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    d1,d2,d3,mxd,myd,mfx,mfy,count:longint;
    dr_xd,dr_yd:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  XOR EDX,EDX
  MOV EAX,xc
  DIV fx
  MOV EAX,fx
  SUB EAX,EDX
  MOV xc,EAX
  XOR EDX,EDX
  MOV EAX,yc
  DIV fy
  MOV EAX,fy
  SUB EAX,EDX
  MOV yc,EAX

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  SUB EDI,EAX
  MOV EAX,xc
{  MUL bytperpix }
  SUB ESI,EAX
  SUB EDI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV EAX,fx
{  MUL bytperpix }
  MOV d1,EAX
  MOV EAX,fy
  MUL imgxd
  MOV d2,EAX

  MOV EAX,xd
  DEC EAX
  MOV mxd,EAX
  MOV EAX,yd
  DEC EAX
  MOV myd,EAX
  MOV EAX,fx
  DEC EAX
  MOV mfx,EAX
  MOV EAX,fy
  DEC EAX
  MOV mfy,EAX

  MOV ECX,yd
  ADD ECX,yc
@mil8_loop1:
  PUSH ECX
  PUSH ESI
  PUSH EDI
  MOV EAX,yd
  SUB EAX,ECX
  MOV yy1,EAX

  MOV ECX,xd
  ADD ECX,xc
@mil8_loop2:
  PUSH ECX
  PUSH ESI
  PUSH EDI

  MOV EAX,xd
  SUB EAX,ECX
  MOV xx1,EAX

  MOV EBX,xx1
  CMP EBX,0
  JGE @mil8r_w1
  NEG EBX
{  SHL EBX,2 } {bytperpix}
  ADD EDI,EBX
  ADD ESI,EBX
  MOV EBX,0
@mil8r_w1:

  MOV EAX,yy1
  CMP EAX,0
  JGE @mil8r_w2
  NEG EAX
  MUL imgxd
  ADD EDI,EAX
  ADD ESI,EAX
  MOV EAX,0
@mil8r_w2:

  MOV ECX,xx1
  MOV EDX,yy1
  ADD ECX,mfx
  ADD EDX,mfy

  CMP ECX,mxd
  JLE @mil8r_w3
  MOV ECX,mxd
@mil8r_w3:

  CMP EDX,myd
  JLE @mil8r_w4
  MOV EDX,myd
@mil8r_w4:

  SUB ECX,EBX
  JS @mil8_nodraw
  SUB EDX,EAX
  JS @mil8_nodraw
  INC ECX
  INC EDX
  MOV dr_xd,ECX
  MOV dr_yd,EDX

  MOV EAX,ECX
  MUL EDX
  MOV count,EAX
  MOV EAX,imgxd
{  SHL ECX,2 } {bytperpix}
  SUB EAX,ECX
  MOV d3,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  MOV EBX,dr_yd
@mil8_rloop1:
  MOV ECX,dr_xd
@mil8_rloop2:
  XOR EDX,EDX
  LODSB
  MOV EDX,EAX
  AND EDX,00000003h
  ADD Bcol,EDX
  MOV EDX,EAX
  AND EDX,0000001Ch
  ADD Gcol,EDX
  MOV EDX,EAX
  AND EDX,000000E0h
  ADD Rcol,EDX
  DEC ECX
  JNZ @mil8_rloop2
  ADD ESI,d3
  DEC EBX
  JNZ @mil8_rloop1

  MOV EBX,count
  XOR ECX,ECX
  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,000000E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,0000001Ch
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,00000003h
  OR EAX,ECX

  MOV EBX,dr_yd
@mil8wloop:
  MOV ECX,dr_xd
  REP STOSB
  ADD EDI,d3
  DEC EBX
  JNZ @mil8wloop
@mil8_nodraw:

  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d1
  ADD EDI,d1
  SUB ECX,fx
  JG @mil8_loop2
  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d2
  ADD EDI,d2
  SUB ECX,fy
  JG @mil8_loop1
  MOV EAX,dst
END;

FUNCTION mosaicimageL15(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    d1,d2,d3,mxd,myd,mfx,mfy,count:longint;
    dr_xd,dr_yd:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  XOR EDX,EDX
  MOV EAX,xc
  DIV fx
  MOV EAX,fx
  SUB EAX,EDX
  MOV xc,EAX
  XOR EDX,EDX
  MOV EAX,yc
  DIV fy
  MOV EAX,fy
  SUB EAX,EDX
  MOV yc,EAX

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  SUB EDI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
  SUB EDI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV EAX,fx
  MUL bytperpix
  MOV d1,EAX
  MOV EAX,fy
  MUL imgxd
  MOV d2,EAX

  MOV EAX,xd
  DEC EAX
  MOV mxd,EAX
  MOV EAX,yd
  DEC EAX
  MOV myd,EAX
  MOV EAX,fx
  DEC EAX
  MOV mfx,EAX
  MOV EAX,fy
  DEC EAX
  MOV mfy,EAX

  MOV ECX,yd
  ADD ECX,yc
@mil15_loop1:
  PUSH ECX
  PUSH ESI
  PUSH EDI
  MOV EAX,yd
  SUB EAX,ECX
  MOV yy1,EAX

  MOV ECX,xd
  ADD ECX,xc
@mil15_loop2:
  PUSH ECX
  PUSH ESI
  PUSH EDI

  MOV EAX,xd
  SUB EAX,ECX
  MOV xx1,EAX

  MOV EBX,xx1
  CMP EBX,0
  JGE @mil15r_w1
  NEG EBX
  SHL EBX,1  {bytperpix}
  ADD EDI,EBX
  ADD ESI,EBX
  MOV EBX,0
@mil15r_w1:

  MOV EAX,yy1
  CMP EAX,0
  JGE @mil15r_w2
  NEG EAX
  MUL imgxd
  ADD EDI,EAX
  ADD ESI,EAX
  MOV EAX,0
@mil15r_w2:

  MOV ECX,xx1
  MOV EDX,yy1
  ADD ECX,mfx
  ADD EDX,mfy

  CMP ECX,mxd
  JLE @mil15r_w3
  MOV ECX,mxd
@mil15r_w3:

  CMP EDX,myd
  JLE @mil15r_w4
  MOV EDX,myd
@mil15r_w4:

  SUB ECX,EBX
  JS @mil15_nodraw
  SUB EDX,EAX
  JS @mil15_nodraw
  INC ECX
  INC EDX
  MOV dr_xd,ECX
  MOV dr_yd,EDX

  MOV EAX,ECX
  MUL EDX
  MOV count,EAX
  MOV EAX,imgxd
  SHL ECX,1 {bytperpix}
  SUB EAX,ECX
  MOV d3,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  MOV EBX,dr_yd
@mil15_rloop1:
  MOV ECX,dr_xd
@mil15_rloop2:
  XOR EDX,EDX
  LODSW
  MOV EDX,EAX
  AND EDX,0000001Fh
  ADD Bcol,EDX
  MOV EDX,EAX
  AND EDX,000003E0h
  ADD Gcol,EDX
  MOV EDX,EAX
  AND EDX,00007C00h
  ADD Rcol,EDX
  DEC ECX
  JNZ @mil15_rloop2
  ADD ESI,d3
  DEC EBX
  JNZ @mil15_rloop1

  MOV EBX,count
  XOR ECX,ECX
  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,00007C00h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,000003E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,0000001Fh
  OR EAX,ECX

  MOV EBX,dr_yd
@mil15wloop:
  MOV ECX,dr_xd
  REP STOSW
  ADD EDI,d3
  DEC EBX
  JNZ @mil15wloop
@mil15_nodraw:

  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d1
  ADD EDI,d1
  SUB ECX,fx
  JG @mil15_loop2
  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d2
  ADD EDI,d2
  SUB ECX,fy
  JG @mil15_loop1
  MOV EAX,dst
END;

FUNCTION mosaicimageL16(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    d1,d2,d3,mxd,myd,mfx,mfy,count:longint;
    dr_xd,dr_yd:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  XOR EDX,EDX
  MOV EAX,xc
  DIV fx
  MOV EAX,fx
  SUB EAX,EDX
  MOV xc,EAX
  XOR EDX,EDX
  MOV EAX,yc
  DIV fy
  MOV EAX,fy
  SUB EAX,EDX
  MOV yc,EAX

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  SUB EDI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
  SUB EDI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV EAX,fx
  MUL bytperpix
  MOV d1,EAX
  MOV EAX,fy
  MUL imgxd
  MOV d2,EAX

  MOV EAX,xd
  DEC EAX
  MOV mxd,EAX
  MOV EAX,yd
  DEC EAX
  MOV myd,EAX
  MOV EAX,fx
  DEC EAX
  MOV mfx,EAX
  MOV EAX,fy
  DEC EAX
  MOV mfy,EAX

  MOV ECX,yd
  ADD ECX,yc
@mil16_loop1:
  PUSH ECX
  PUSH ESI
  PUSH EDI
  MOV EAX,yd
  SUB EAX,ECX
  MOV yy1,EAX

  MOV ECX,xd
  ADD ECX,xc
@mil16_loop2:
  PUSH ECX
  PUSH ESI
  PUSH EDI

  MOV EAX,xd
  SUB EAX,ECX
  MOV xx1,EAX

  MOV EBX,xx1
  CMP EBX,0
  JGE @mil16r_w1
  NEG EBX
  SHL EBX,1  {bytperpix}
  ADD EDI,EBX
  ADD ESI,EBX
  MOV EBX,0
@mil16r_w1:

  MOV EAX,yy1
  CMP EAX,0
  JGE @mil16r_w2
  NEG EAX
  MUL imgxd
  ADD EDI,EAX
  ADD ESI,EAX
  MOV EAX,0
@mil16r_w2:

  MOV ECX,xx1
  MOV EDX,yy1
  ADD ECX,mfx
  ADD EDX,mfy

  CMP ECX,mxd
  JLE @mil16r_w3
  MOV ECX,mxd
@mil16r_w3:

  CMP EDX,myd
  JLE @mil16r_w4
  MOV EDX,myd
@mil16r_w4:

  SUB ECX,EBX
  JS @mil16_nodraw
  SUB EDX,EAX
  JS @mil16_nodraw
  INC ECX
  INC EDX
  MOV dr_xd,ECX
  MOV dr_yd,EDX

  MOV EAX,ECX
  MUL EDX
  MOV count,EAX
  MOV EAX,imgxd
  SHL ECX,1 {bytperpix}
  SUB EAX,ECX
  MOV d3,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  MOV EBX,dr_yd
@mil16_rloop1:
  MOV ECX,dr_xd
@mil16_rloop2:
  XOR EDX,EDX
  LODSW
  MOV EDX,EAX
  AND EDX,0000001Fh
  ADD Bcol,EDX
  MOV EDX,EAX
  AND EDX,000007E0h
  ADD Gcol,EDX
  MOV EDX,EAX
  AND EDX,0000F800h
  ADD Rcol,EDX
  DEC ECX
  JNZ @mil16_rloop2
  ADD ESI,d3
  DEC EBX
  JNZ @mil16_rloop1

  MOV EBX,count
  XOR ECX,ECX
  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,0000F800h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,000007E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,0000001Fh
  OR EAX,ECX

  MOV EBX,dr_yd
@mil16wloop:
  MOV ECX,dr_xd
  REP STOSW
  ADD EDI,d3
  DEC EBX
  JNZ @mil16wloop
@mil16_nodraw:

  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d1
  ADD EDI,d1
  SUB ECX,fx
  JG @mil16_loop2
  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d2
  ADD EDI,d2
  SUB ECX,fy
  JG @mil16_loop1
  MOV EAX,dst
END;

FUNCTION mosaicimageL24(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    d1,d2,d3,mxd,myd,mfx,mfy,count:longint;
    dr_xd,dr_yd:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  XOR EDX,EDX
  MOV EAX,xc
  DIV fx
  MOV EAX,fx
  SUB EAX,EDX
  MOV xc,EAX
  XOR EDX,EDX
  MOV EAX,yc
  DIV fy
  MOV EAX,fy
  SUB EAX,EDX
  MOV yc,EAX

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  SUB EDI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
  SUB EDI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV EAX,fx
  MUL bytperpix
  MOV d1,EAX
  MOV EAX,fy
  MUL imgxd
  MOV d2,EAX

  MOV EAX,xd
  DEC EAX
  MOV mxd,EAX
  MOV EAX,yd
  DEC EAX
  MOV myd,EAX
  MOV EAX,fx
  DEC EAX
  MOV mfx,EAX
  MOV EAX,fy
  DEC EAX
  MOV mfy,EAX

  MOV ECX,yd
  ADD ECX,yc
@mil24_loop1:
  PUSH ECX
  PUSH ESI
  PUSH EDI
  MOV EAX,yd
  SUB EAX,ECX
  MOV yy1,EAX

  MOV ECX,xd
  ADD ECX,xc
@mil24_loop2:
  PUSH ECX
  PUSH ESI
  PUSH EDI

  MOV EAX,xd
  SUB EAX,ECX
  MOV xx1,EAX

  MOV EBX,xx1
  CMP EBX,0
  JGE @mil24r_w1
  NEG EBX
  LEA EBX,[EBX+EBX*2] {bytperpix}
  ADD EDI,EBX
  ADD ESI,EBX
  MOV EBX,0
@mil24r_w1:

  MOV EAX,yy1
  CMP EAX,0
  JGE @mil24r_w2
  NEG EAX
  MUL imgxd
  ADD EDI,EAX
  ADD ESI,EAX
  MOV EAX,0
@mil24r_w2:

  MOV ECX,xx1
  MOV EDX,yy1
  ADD ECX,mfx
  ADD EDX,mfy

  CMP ECX,mxd
  JLE @mil24r_w3
  MOV ECX,mxd
@mil24r_w3:

  CMP EDX,myd
  JLE @mil24r_w4
  MOV EDX,myd
@mil24r_w4:

  SUB ECX,EBX
  JS @mil24_nodraw
  SUB EDX,EAX
  JS @mil24_nodraw
  INC ECX
  INC EDX
  MOV dr_xd,ECX
  MOV dr_yd,EDX

  MOV EAX,ECX
  MUL EDX
  MOV count,EAX
  MOV EAX,imgxd
  LEA ECX,[ECX+ECX*2] {bytperpix}
  SUB EAX,ECX
  MOV d3,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  MOV EBX,dr_yd
@mil24_rloop1:
  MOV ECX,dr_xd
@mil24_rloop2:
  XOR EDX,EDX
  DEC ESI
  LODSD
  SHR EAX,8
  MOV DL,AL
  ADD Bcol,EDX
  SHR EAX,8
  MOV DL,AL
  ADD Gcol,EDX
  SHR EAX,8
  MOV DL,AL
  ADD Rcol,EDX
  DEC ECX
  JNZ @mil24_rloop2
  ADD ESI,d3
  DEC EBX
  JNZ @mil24_rloop1

  MOV EBX,count
  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Gcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Bcol
  DIV EBX
  MOV CL,AL
  MOV EAX,ECX

  MOV EBX,dr_yd
@mil24wloop1:
  MOV ECX,dr_xd
@mil24wloop2:
  STOSW
  ROR EAX,16
  STOSB
  ROR EAX,16
  DEC ECX
  JNZ @mil24wloop2
  ADD EDI,d3
  DEC EBX
  JNZ @mil24wloop1
@mil24_nodraw:

  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d1
  ADD EDI,d1
  SUB ECX,fx
  JG @mil24_loop2
  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d2
  ADD EDI,d2
  SUB ECX,fy
  JG @mil24_loop1
  MOV EAX,dst
END;

FUNCTION mosaicimageL32(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    d1,d2,d3,mxd,myd,mfx,mfy,count:longint;
    dr_xd,dr_yd:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  XOR EDX,EDX
  MOV EAX,xc
  DIV fx
  MOV EAX,fx
  SUB EAX,EDX
  MOV xc,EAX
  XOR EDX,EDX
  MOV EAX,yc
  DIV fy
  MOV EAX,fy
  SUB EAX,EDX
  MOV yc,EAX

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  SUB EDI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
  SUB EDI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV EAX,fx
  MUL bytperpix
  MOV d1,EAX
  MOV EAX,fy
  MUL imgxd
  MOV d2,EAX

  MOV EAX,xd
  DEC EAX
  MOV mxd,EAX
  MOV EAX,yd
  DEC EAX
  MOV myd,EAX
  MOV EAX,fx
  DEC EAX
  MOV mfx,EAX
  MOV EAX,fy
  DEC EAX
  MOV mfy,EAX

  MOV ECX,yd
  ADD ECX,yc
@mil32_loop1:
  PUSH ECX
  PUSH ESI
  PUSH EDI
  MOV EAX,yd
  SUB EAX,ECX
  MOV yy1,EAX

  MOV ECX,xd
  ADD ECX,xc
@mil32_loop2:
  PUSH ECX
  PUSH ESI
  PUSH EDI

  MOV EAX,xd
  SUB EAX,ECX
  MOV xx1,EAX

  MOV EBX,xx1
  CMP EBX,0
  JGE @mil32r_w1
  NEG EBX
  SHL EBX,2  {bytperpix}
  ADD EDI,EBX
  ADD ESI,EBX
  MOV EBX,0
@mil32r_w1:

  MOV EAX,yy1
  CMP EAX,0
  JGE @mil32r_w2
  NEG EAX
  MUL imgxd
  ADD EDI,EAX
  ADD ESI,EAX
  MOV EAX,0
@mil32r_w2:

  MOV ECX,xx1
  MOV EDX,yy1
  ADD ECX,mfx
  ADD EDX,mfy

  CMP ECX,mxd
  JLE @mil32r_w3
  MOV ECX,mxd
@mil32r_w3:

  CMP EDX,myd
  JLE @mil32r_w4
  MOV EDX,myd
@mil32r_w4:

  SUB ECX,EBX
  JS @mil32_nodraw
  SUB EDX,EAX
  JS @mil32_nodraw
  INC ECX
  INC EDX
  MOV dr_xd,ECX
  MOV dr_yd,EDX

  MOV EAX,ECX
  MUL EDX
  MOV count,EAX
  MOV EAX,imgxd
  SHL ECX,2 {bytperpix}
  SUB EAX,ECX
  MOV d3,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  MOV EBX,dr_yd
@mil32_rloop1:
  MOV ECX,dr_xd
@mil32_rloop2:
  XOR EDX,EDX
  LODSD
  MOV DL,AL
  ADD Bcol,EDX
  SHR EAX,8
  MOV DL,AL
  ADD Gcol,EDX
  SHR EAX,8
  MOV DL,AL
  ADD Rcol,EDX
  DEC ECX
  JNZ @mil32_rloop2
  ADD ESI,d3
  DEC EBX
  JNZ @mil32_rloop1

  MOV EBX,count
  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Gcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Bcol
  DIV EBX
  MOV CL,AL
  MOV EAX,ECX

  MOV EBX,dr_yd
@mil32wloop:
  MOV ECX,dr_xd
  REP STOSD
  ADD EDI,d3
  DEC EBX
  JNZ @mil32wloop
@mil32_nodraw:

  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d1
  ADD EDI,d1
  SUB ECX,fx
  JG @mil32_loop2
  POP EDI
  POP ESI
  POP ECX
  ADD ESI,d2
  ADD EDI,d2
  SUB ECX,fy
  JG @mil32_loop1
  MOV EAX,dst
END;

{----------------------------- averageimage ---------------------------------}

FUNCTION averageimageL8(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@ail8_loop1:
  PUSH ECX
  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@ail8_loop2:
  PUSH ECX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0
  MOV EBX,0

  MOV ECX,fy
@ail8_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @ail8_nopixY
  CMP EAX,yd
  JGE @ail8_nopixY

  MOV ECX,fx
@ail8_loop4:
  MOV EAX,xx1
  SUB EAX,ECX
  JL @ail8_nopixX
  CMP EAX,xd
  JGE @ail8_nopixX

  MOV DX,[ESI]
  MOV EAX,EDX
  AND EAX,00000003h
  ADD Bcol,EAX
  MOV EAX,EDX
  AND EAX,0000001Ch
  ADD Gcol,EAX
  MOV EAX,EDX
  AND EAX,000000E0h
  ADD Rcol,EAX
  INC EBX

@ail8_nopixX:
  INC ESI
  DEC ECX
  JNZ @ail8_loop4
  ADD ESI,srcdiff1
@ail8_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @ail8_loop3

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,000000E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,0000001Ch
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,00000003h
  OR EAX,ECX
  STOSB
  ADD ESI,srcdiff2

  POP ECX
  DEC ECX
  JNZ @ail8_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @ail8_loop1
  MOV EAX,dst
END;

FUNCTION averageimageL15(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@ail15_loop1:
  PUSH ECX
  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@ail15_loop2:
  PUSH ECX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0
  MOV EBX,0

  MOV ECX,fy
@ail15_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @ail15_nopixY
  CMP EAX,yd
  JGE @ail15_nopixY

  MOV ECX,fx
@ail15_loop4:
  MOV EAX,xx1
  SUB EAX,ECX
  JL @ail15_nopixX
  CMP EAX,xd
  JGE @ail15_nopixX

  MOV DX,[ESI]
  MOV EAX,EDX
  AND EAX,0000001Fh
  ADD Bcol,EAX
  MOV EAX,EDX
  AND EAX,000003E0h
  ADD Gcol,EAX
  MOV EAX,EDX
  AND EAX,00007C00h
  ADD Rcol,EAX
  INC EBX

@ail15_nopixX:
  ADD ESI,2
  DEC ECX
  JNZ @ail15_loop4
  ADD ESI,srcdiff1
@ail15_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @ail15_loop3

{  MOV EDX,EBX
  SHR EDX,2
  ADD bcol,EDX
  SHL EDX,5
  ADD gcol,EDX
  SHL EDX,5
  ADD rcol,EDX }

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,00007C00h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,000003E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,0000001Fh
  OR EAX,ECX
  STOSW
  ADD ESI,srcdiff2

  POP ECX
  DEC ECX
  JNZ @ail15_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @ail15_loop1
  MOV EAX,dst
END;

FUNCTION averageimageL16(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@ail16_loop1:
  PUSH ECX
  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@ail16_loop2:
  PUSH ECX
  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0
  MOV EBX,0

  MOV ECX,fy
@ail16_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @ail16_nopixY
  CMP EAX,yd
  JGE @ail16_nopixY

  MOV ECX,fx
@ail16_loop4:
  MOV EAX,xx1
  SUB EAX,ECX
  JL @ail16_nopixX
  CMP EAX,xd
  JGE @ail16_nopixX

  MOV DX,[ESI]
  MOV EAX,EDX
  AND EAX,0000001Fh
  ADD Bcol,EAX
  MOV EAX,EDX
  AND EAX,000007E0h
  ADD Gcol,EAX
  MOV EAX,EDX
  AND EAX,0000F800h
  ADD Rcol,EAX
  INC EBX
@ail16_nopixX:
  ADD ESI,2
  DEC ECX
  JNZ @ail16_loop4
  ADD ESI,srcdiff1
@ail16_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @ail16_loop3

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,0000F800h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,000007E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,0000001Fh
  OR EAX,ECX
  STOSW
  ADD ESI,srcdiff2

  POP ECX
  DEC ECX
  JNZ @ail16_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @ail16_loop1
  MOV EAX,dst
END;

FUNCTION averageimageL24(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@ail24_loop1:
  PUSH ECX
  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@ail24_loop2:
  PUSH ECX
  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0
  MOV EBX,0

  MOV ECX,fy
@ail24_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @ail24_nopixY
  CMP EAX,yd
  JGE @ail24_nopixY

  MOV ECX,fx
@ail24_loop4:
  MOV EAX,xx1
  SUB EAX,ECX
  JL @ail24_nopixX
  CMP EAX,xd
  JGE @ail24_nopixX

  MOV EDX,[ESI-1]
  SHR EDX,8
  MOVZX EAX,DL
  ADD Bcol,EAX
  SHR EDX,8
  MOVZX EAX,DL
  ADD Gcol,EAX
  SHR EDX,8
  MOVZX EAX,DL
  ADD Rcol,EAX
  INC EBX

@ail24_nopixX:
  ADD ESI,3
  DEC ECX
  JNZ @ail24_loop4
  ADD ESI,srcdiff1
@ail24_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @ail24_loop3

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Gcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Bcol
  DIV EBX
  MOV CL,AL
  MOV [EDI],CX
  SHR ECX,16
  MOV [EDI+2],CL
  ADD EDI,3
  ADD ESI,srcdiff2

  POP ECX
  DEC ECX
  JNZ @ail24_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @ail24_loop1
  MOV EAX,dst
END;

FUNCTION averageimageL32(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@ail32_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@ail32_loop2:
  PUSH ECX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  MOV EBX,0

  MOV ECX,fy
@ail32_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @ail32_nopixY
  CMP EAX,yd
  JGE @ail32_nopixY

  MOV ECX,fx
@ail32_loop4:
  MOV EAX,xx1
  SUB EAX,ECX
  JL @ail32_nopixX
  CMP EAX,xd
  JGE @ail32_nopixX

  XOR EAX,EAX
  MOV EDX,[ESI]
  MOV AL,DL
  ADD Bcol,EAX
  SHR EDX,8
  MOV AL,DL
  ADD Gcol,EAX
  SHR EDX,8
  MOV AL,DL
  ADD Rcol,EAX
  INC EBX

@ail32_nopixX:
  ADD ESI,4
  DEC ECX
  JNZ @ail32_loop4
  ADD ESI,srcdiff1
@ail32_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @ail32_loop3

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Gcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Bcol
  DIV EBX
  MOV CL,AL
  MOV [EDI],ECX
  ADD EDI,4
  ADD ESI,srcdiff2

  POP ECX
  DEC ECX
  JNZ @ail32_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @ail32_loop1
  MOV EAX,dst
END;

FUNCTION averageimageLM32(dst,src:pimage;xc,yc,fx,fy:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  PXOR MM0,MM0

  MOV ECX,yd
@ailm32_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@ailm32_loop2:
  PUSH ECX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  PXOR MM6,MM6
  PXOR MM7,MM7
  MOV EBX,0

  MOV ECX,fy
@ailm32_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @ailm32_nopixY
  CMP EAX,yd
  JGE @ailm32_nopixY

  MOV ECX,fx
@ailm32_loop4:
  MOV EAX,xx1
  SUB EAX,ECX
  JL @ailm32_nopixX
  CMP EAX,xd
  JGE @ailm32_nopixX

  MOV EAX,[ESI]
  MOVD MM2,EAX
  PUNPCKLBW MM2,MM0
  MOVQ MM3,MM2
  PUNPCKLWD MM2,MM0
  PUNPCKHWD MM3,MM0
  PADDD MM6,MM2
  PADDD MM7,MM3
  INC EBX
@ailm32_nopixX:
  ADD ESI,4
  DEC ECX
  JNZ @ailm32_loop4
  ADD ESI,srcdiff1
@ailm32_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @ailm32_loop3

  XOR EDX,EDX
  MOVD EAX,MM7
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOVQ MM5,MM6
  PSRLQ MM5,32
  MOVD EAX,MM5
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOVD EAX,MM6
  DIV EBX
  MOV CL,AL
  MOV [EDI],ECX
  ADD EDI,4
  ADD ESI,srcdiff2

  POP ECX
  DEC ECX
  JNZ @ailm32_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @ailm32_loop1
  EMMS
  MOV EAX,dst
END;

{----------------------------- filterimage ----------------------------------}

FUNCTION filterimageL8(dst,src:pimage;var filter;xc,yc,fx,fy,offs:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,fy
  MUL fx
  MOV EBX,EAX
  ADD EBX,filter

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@fil8_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@fil8_loop2:
  PUSH ECX
  PUSH EBX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  PUSH EDI  {ANFANG: EDI = summe der alpha-werte }
  MOV EDI,offs

  MOV ECX,fy
@fil8_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @fil8_nopixY
  CMP EAX,yd
  JGE @fil8_nopixY

  MOV ECX,fx
@fil8_loop4:
  PUSH ECX
  DEC EBX

  MOV EAX,xx1
  SUB EAX,ECX
  JL @fil8_nopixX
  CMP EAX,xd
  JGE @fil8_nopixX

  PUSH EBX
  MOVZX ECX,BYTE PTR [EBX]
  MOV BX,[ESI]
  MOV EAX,EBX
  AND EAX,00000003h
  MUL ECX
  ADD Bcol,EAX
  MOV EAX,EBX
  AND EAX,0000001Ch
  MUL ECX
  ADD Gcol,EAX
  MOV EAX,EBX
  AND EAX,000000E0h
  MUL ECX
  ADD Rcol,EAX
  ADD EDI,ECX
  POP EBX

@fil8_nopixX:
  INC ESI
  POP ECX
  DEC ECX
  JNZ @fil8_loop4
  ADD ESI,srcdiff1
@fil8_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @fil8_loop3

  MOV EBX,EDI
  OR EBX,EBX
  JNE @fil8_notzero
  MOV EBX,1
@fil8_notzero:
  POP EDI {ENDE: EDI = summe der alpha-werte }

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,000000E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,0000001Ch
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,00000003h
  OR EAX,ECX
  STOSB
  ADD ESI,srcdiff2

  POP EBX
  POP ECX
  DEC ECX
  JNZ @fil8_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @fil8_loop1
  MOV EAX,dst
END;

FUNCTION filterimageL15(dst,src:pimage;var filter;xc,yc,fx,fy,offs:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,fy
  MUL fx
  MOV EBX,EAX
  ADD EBX,filter

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@fil15_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@fil15_loop2:
  PUSH ECX
  PUSH EBX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  PUSH EDI  {ANFANG: EDI = summe der alpha-werte }
  MOV EDI,offs

  MOV ECX,fy
@fil15_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @fil15_nopixY
  CMP EAX,yd
  JGE @fil15_nopixY

  MOV ECX,fx
@fil15_loop4:
  PUSH ECX
  DEC EBX

  MOV EAX,xx1
  SUB EAX,ECX
  JL @fil15_nopixX
  CMP EAX,xd
  JGE @fil15_nopixX

  PUSH EBX
  MOVZX ECX,BYTE PTR [EBX]
  MOV BX,[ESI]
  MOV EAX,EBX
  AND EAX,0000001Fh
  MUL ECX
  ADD Bcol,EAX
  MOV EAX,EBX
  AND EAX,000003E0h
  MUL ECX
  ADD Gcol,EAX
  MOV EAX,EBX
  AND EAX,00007C00h
  MUL ECX
  ADD Rcol,EAX
  ADD EDI,ECX
  POP EBX

@fil15_nopixX:
  ADD ESI,2
  POP ECX
  DEC ECX
  JNZ @fil15_loop4
  ADD ESI,srcdiff1
@fil15_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @fil15_loop3

  MOV EBX,EDI
  OR EBX,EBX
  JNE @fil15_notzero
  MOV EBX,1
@fil15_notzero:
  POP EDI {ENDE: EDI = summe der alpha-werte }

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,00007C00h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,000003E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,0000001Fh
  OR EAX,ECX
  STOSW
  ADD ESI,srcdiff2

  POP EBX
  POP ECX
  DEC ECX
  JNZ @fil15_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @fil15_loop1
  MOV EAX,dst
END;

FUNCTION filterimageL16(dst,src:pimage;var filter;xc,yc,fx,fy,offs:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,fy
  MUL fx
  MOV EBX,EAX
  ADD EBX,filter

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@fil16_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@fil16_loop2:
  PUSH ECX
  PUSH EBX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  PUSH EDI  {ANFANG: EDI = summe der alpha-werte }
  MOV EDI,offs

  MOV ECX,fy
@fil16_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @fil16_nopixY
  CMP EAX,yd
  JGE @fil16_nopixY

  MOV ECX,fx
@fil16_loop4:
  PUSH ECX
  DEC EBX

  MOV EAX,xx1
  SUB EAX,ECX
  JL @fil16_nopixX
  CMP EAX,xd
  JGE @fil16_nopixX

  PUSH EBX
  MOVZX ECX,BYTE PTR [EBX]
  MOV BX,[ESI]
  MOV EAX,EBX
  AND EAX,0000001Fh
  MUL ECX
  ADD Bcol,EAX
  MOV EAX,EBX
  AND EAX,000007E0h
  MUL ECX
  ADD Gcol,EAX
  MOV EAX,EBX
  AND EAX,0000F800h
  MUL ECX
  ADD Rcol,EAX
  ADD EDI,ECX
  POP EBX

@fil16_nopixX:
  ADD ESI,2
  POP ECX
  DEC ECX
  JNZ @fil16_loop4
  ADD ESI,srcdiff1
@fil16_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @fil16_loop3

  MOV EBX,EDI
  OR EBX,EBX
  JNE @fil16_notzero
  MOV EBX,1
@fil16_notzero:
  POP EDI {ENDE: EDI = summe der alpha-werte }

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  AND EAX,0000F800h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Gcol
  DIV EBX
  AND EAX,000007E0h
  OR ECX,EAX
  XOR EDX,EDX
  MOV EAX,Bcol
  DIV EBX
  AND EAX,0000001Fh
  OR EAX,ECX
  STOSW
  ADD ESI,srcdiff2

  POP EBX
  POP ECX
  DEC ECX
  JNZ @fil16_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @fil16_loop1
  MOV EAX,dst
END;

FUNCTION filterimageL24(dst,src:pimage;var filter;xc,yc,fx,fy,offs:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,fy
  MUL fx
  MOV EBX,EAX
  ADD EBX,filter

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@fil24_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@fil24_loop2:
  PUSH ECX
  PUSH EBX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  PUSH EDI  {ANFANG: EDI = summe der alpha-werte }
  MOV EDI,offs

  MOV ECX,fy
@fil24_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @fil24_nopixY
  CMP EAX,yd
  JGE @fil24_nopixY

  MOV ECX,fx
@fil24_loop4:
  PUSH ECX
  DEC EBX

  MOV EAX,xx1
  SUB EAX,ECX
  JL @fil24_nopixX
  CMP EAX,xd
  JGE @fil24_nopixX

  MOVZX ECX,BYTE PTR [EBX]
  MOV EDX,[ESI-1]
  SHR EDX,8
  MOVZX EAX,DL
  MUL CL
  ADD Bcol,EAX
  SHR EDX,8
  MOVZX EAX,DL
  MUL CL
  ADD Gcol,EAX
  SHR EDX,8
  MOVZX EAX,DL
  MUL CL
  ADD Rcol,EAX
  ADD EDI,ECX

@fil24_nopixX:
  ADD ESI,3
  POP ECX
  DEC ECX
  JNZ @fil24_loop4
  ADD ESI,srcdiff1
@fil24_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @fil24_loop3

  MOV EBX,EDI
  OR EBX,EBX
  JNE @fil24_notzero
  MOV EBX,1
@fil24_notzero:
  POP EDI {ENDE: EDI = summe der alpha-werte }

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Gcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Bcol
  DIV EBX
  MOV CL,AL
  MOV [EDI],CX
  SHR ECX,16
  MOV [EDI+2],CL
  ADD EDI,3
  ADD ESI,srcdiff2

  POP EBX
  POP ECX
  DEC ECX
  JNZ @fil24_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @fil24_loop1
  MOV EAX,dst
END;

FUNCTION filterimageL32(dst,src:pimage;var filter;xc,yc,fx,fy,offs:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,fy
  MUL fx
  MOV EBX,EAX
  ADD EBX,filter

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  MOV ECX,yd
@fil32_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@fil32_loop2:
  PUSH ECX
  PUSH EBX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0

  PUSH EDI  {ANFANG: EDI = summe der alpha-werte }
  MOV EDI,offs

  MOV ECX,fy
@fil32_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @fil32_nopixY
  CMP EAX,yd
  JGE @fil32_nopixY

  MOV ECX,fx
@fil32_loop4:
  PUSH ECX
  DEC EBX

  MOV EAX,xx1
  SUB EAX,ECX
  JL @fil32_nopixX
  CMP EAX,xd
  JGE @fil32_nopixX

  MOVZX ECX,BYTE PTR [EBX]
  MOV EDX,[ESI]
  MOVZX EAX,DL
  MUL CL
  ADD Bcol,EAX
  SHR EDX,8
  MOVZX EAX,DL
  MUL CL
  ADD Gcol,EAX
  SHR EDX,8
  MOVZX EAX,DL
  MUL CL
  ADD Rcol,EAX
  ADD EDI,ECX

@fil32_nopixX:
  ADD ESI,4
  POP ECX
  DEC ECX
  JNZ @fil32_loop4
  ADD ESI,srcdiff1
@fil32_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @fil32_loop3

  MOV EBX,EDI
  OR EBX,EBX
  JNE @fil32_notzero
  MOV EBX,1
@fil32_notzero:
  POP EDI {ENDE: EDI = summe der alpha-werte }

  XOR EDX,EDX
  MOV EAX,Rcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Gcol
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOV EAX,Bcol
  DIV EBX
  MOV CL,AL
  MOV [EDI],ECX
  ADD EDI,4
  ADD ESI,srcdiff2

  POP EBX
  POP ECX
  DEC ECX
  JNZ @fil32_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @fil32_loop1
  MOV EAX,dst
END;

FUNCTION filterimageLM32(dst,src:pimage;var filter;xc,yc,fx,fy,offs:longint):pimage;assembler;
VAR xx1,yy1,imgxd,xd,yd:longint;
    Rcol,Gcol,Bcol:longint;
    imgdiff1,srcdiff1,srcdiff2:longint;
ASM
  MOV ESI,src
  MOV EDI,dst
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV EAX,[EDI+timage.height]
  MOV yd,EAX
  MOV EAX,[EDI+timage.bytesperline]
  MOV imgxd,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV ESI,[ESI+timage.pixeldata]

  MOV EAX,fy
  MUL fx
  MOV EBX,EAX
  ADD EBX,filter

  MOV EAX,yc
  MUL imgxd
  SUB ESI,EAX
  MOV EAX,xc
  MUL bytperpix
  SUB ESI,EAX
{  ADD ESI,imagedatastart
  ADD EDI,imagedatastart }

  MOV ECX,imgxd
  MOV EAX,xd
  MUL bytperpix
  SUB ECX,EAX
  MOV imgdiff1,ECX

  MOV EAX,fx
  MUL bytperpix
  NEG EAX
  MOV srcdiff1,EAX

  MOV ECX,bytperpix
  MOV EAX,fy
  MUL imgxd
  SUB ECX,EAX
  MOV srcdiff2,ECX

  PXOR MM0,MM0

  MOV ECX,yd
@film32_loop1:
  PUSH ECX

  MOV EAX,yd
  SUB EAX,ECX
  ADD EAX,fy
  SUB EAX,yc
  MOV yy1,EAX

  MOV ECX,xd
@film32_loop2:
  PUSH ECX
  PUSH EBX

  MOV EAX,xd
  SUB EAX,ECX
  ADD EAX,fx
  SUB EAX,xc
  MOV xx1,EAX

{  MOV Rcol,0
  MOV Gcol,0
  MOV Bcol,0 }

  PXOR MM6,MM6
  PXOR MM7,MM7

{  PUSH EDI  } {ANFANG: MM4 = summe der alpha-werte }
{  MOV EDI,0 }
{  PXOR MM4,MM4 }
  MOVD MM4,offs
  PUNPCKLDQ MM4,MM4

  MOV ECX,fy
@film32_loop3:
  PUSH ECX
  MOV EAX,yy1
  SUB EAX,ECX
  JL @film32_nopixY
  CMP EAX,yd
  JGE @film32_nopixY

  MOV ECX,fx
@film32_loop4:
  DEC EBX

  MOV EAX,xx1
  SUB EAX,ECX
  JL @film32_nopixX
  CMP EAX,xd
  JGE @film32_nopixX

  MOVZX EAX,BYTE PTR [EBX]
  MOVD MM1,EAX
  PUNPCKLBW MM1,MM1
  MOV EAX,[ESI]
  PUNPCKLWD MM1,MM1
  MOVD MM2,EAX
  PUNPCKLBW MM1,MM0
  PUNPCKLBW MM2,MM0
  PMULLW MM2,MM1
  MOVQ MM3,MM2
  PUNPCKLWD MM1,MM0
  PUNPCKLWD MM2,MM0
  PUNPCKHWD MM3,MM0
  PADDD MM6,MM2
  PADDD MM7,MM3
  PADDW MM4,MM1

@film32_nopixX:
  ADD ESI,4
  DEC ECX
  JNZ @film32_loop4
  ADD ESI,srcdiff1
@film32_nopixY:
  ADD ESI,imgxd
  POP ECX
  DEC ECX
  JNZ @film32_loop3

  MOVD EBX,MM4
  OR EBX,EBX
  JNE @film32_notzero
  MOV EBX,1
@film32_notzero:

  XOR EDX,EDX
  MOVD EAX,MM7
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOVQ MM5,MM6
  PSRLQ MM5,32
  MOVD EAX,MM5
  DIV EBX
  MOV CL,AL
  XOR EDX,EDX
  SHL ECX,8
  MOVD EAX,MM6
  DIV EBX
  MOV CL,AL
  MOV [EDI],ECX
  ADD EDI,4
  ADD ESI,srcdiff2

  POP EBX
  POP ECX
  DEC ECX
  JNZ @film32_loop2
  MOV EAX,imgdiff1
  ADD EDI,EAX
  ADD ESI,EAX
  POP ECX
  DEC ECX
  JNZ @film32_loop1
  EMMS
  MOV EAX,dst
END;

{============================================================================}
{----------------------------- userdatatoimageRGB ---------------------------}

FUNCTION userdatatoimageRGBLbyte(dst:pimage;src:pointer;bpp:longint;Rpos,Rsiz,Gpos,Gsiz,Bpos,Bsiz:byte):pimage;assembler;
VAR Rmask,Gmask,Bmask,rotate:longint;
    xd,dstbpl:longint;
ASM
  MOV BL,4
  SUB BL,BYTE PTR bpp
  SHL BL,3

  MOV EDX,1
  MOV CL,gxredsize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Rsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Rpos
  ADD CL,BL
  ROL EAX,CL
  MOV Rmask,EAX

  MOV EDX,1
  MOV CL,gxgreensize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Gsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Gpos
  ADD CL,BL
  ROL EAX,CL
  MOV Gmask,EAX

  MOV EDX,1
  MOV CL,gxbluesize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Bsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Bpos
  ADD CL,BL
  ROL EAX,CL
  MOV Bmask,EAX

  MOV AL,gxredpos
  ADD AL,gxredsize
  SUB AL,Rpos
  SUB AL,Rsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxgreenpos
  ADD AL,gxgreensize
  SUB AL,Gpos
  SUB AL,Gsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxbluepos
  ADD AL,gxbluesize
  SUB AL,Bpos
  SUB AL,Bsiz
  SUB AL,BL
  ROR EAX,16
  AND EAX,001F1F1Fh
  MOV rotate,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
@udtir8_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtir8_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtir8_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtir8_loop1
  MOV EDX,EAX
  MOV ECX,rotate
  XOR EAX,EAX
  MOV EBX,EDX
  AND EBX,Rmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Gmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Bmask
  ROL EBX,CL
  OR EAX,EBX
  STOSB
  POP ECX
  DEC ECX
  JNZ @udtir8_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtir8_loop3
  MOV EAX,dst
END;

FUNCTION userdatatoimageRGBLword(dst:pimage;src:pointer;bpp:longint;Rpos,Rsiz,Gpos,Gsiz,Bpos,Bsiz:byte):pimage;assembler;
VAR Rmask,Gmask,Bmask,rotate:longint;
    xd,dstbpl:longint;
ASM
  MOV BL,4
  SUB BL,BYTE PTR bpp
  SHL BL,3

  MOV EDX,1
  MOV CL,gxredsize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Rsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Rpos
  ADD CL,BL
  ROL EAX,CL
  MOV Rmask,EAX

  MOV EDX,1
  MOV CL,gxgreensize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Gsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Gpos
  ADD CL,BL
  ROL EAX,CL
  MOV Gmask,EAX

  MOV EDX,1
  MOV CL,gxbluesize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Bsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Bpos
  ADD CL,BL
  ROL EAX,CL
  MOV Bmask,EAX

  MOV AL,gxredpos
  ADD AL,gxredsize
  SUB AL,Rpos
  SUB AL,Rsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxgreenpos
  ADD AL,gxgreensize
  SUB AL,Gpos
  SUB AL,Gsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxbluepos
  ADD AL,gxbluesize
  SUB AL,Bpos
  SUB AL,Bsiz
  SUB AL,BL
  ROR EAX,16
  AND EAX,001F1F1Fh
  MOV rotate,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
@udtir16_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtir16_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtir16_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtir16_loop1
  MOV EDX,EAX
  MOV ECX,rotate
  XOR EAX,EAX
  MOV EBX,EDX
  AND EBX,Rmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Gmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Bmask
  ROL EBX,CL
  OR EAX,EBX
  STOSW
  POP ECX
  DEC ECX
  JNZ @udtir16_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtir16_loop3
  MOV EAX,dst
END;

FUNCTION userdatatoimageRGBL24(dst:pimage;src:pointer;bpp:longint;Rpos,Rsiz,Gpos,Gsiz,Bpos,Bsiz:byte):pimage;assembler;
VAR Rmask,Gmask,Bmask,rotate:longint;
    xd,dstbpl:longint;
ASM
  MOV BL,4
  SUB BL,BYTE PTR bpp
  SHL BL,3

  MOV EDX,1
  MOV CL,gxredsize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Rsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Rpos
  ADD CL,BL
  ROL EAX,CL
  MOV Rmask,EAX

  MOV EDX,1
  MOV CL,gxgreensize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Gsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Gpos
  ADD CL,BL
  ROL EAX,CL
  MOV Gmask,EAX

  MOV EDX,1
  MOV CL,gxbluesize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Bsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Bpos
  ADD CL,BL
  ROL EAX,CL
  MOV Bmask,EAX

  MOV AL,gxredpos
  ADD AL,gxredsize
  SUB AL,Rpos
  SUB AL,Rsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxgreenpos
  ADD AL,gxgreensize
  SUB AL,Gpos
  SUB AL,Gsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxbluepos
  ADD AL,gxbluesize
  SUB AL,Bpos
  SUB AL,Bsiz
  SUB AL,BL
  ROR EAX,16
  AND EAX,001F1F1Fh
  MOV rotate,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
@udtir24_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtir24_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtir24_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtir24_loop1
  MOV EDX,EAX
  MOV ECX,rotate
  XOR EAX,EAX
  MOV EBX,EDX
  AND EBX,Rmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Gmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Bmask
  ROL EBX,CL
  OR EAX,EBX
  STOSW
  SHR EAX,16
  STOSB
  POP ECX
  DEC ECX
  JNZ @udtir24_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtir24_loop3
  MOV EAX,dst
END;

FUNCTION userdatatoimageRGBL32(dst:pimage;src:pointer;bpp:longint;Rpos,Rsiz,Gpos,Gsiz,Bpos,Bsiz:byte):pimage;assembler;
VAR Rmask,Gmask,Bmask,rotate:longint;
    xd,dstbpl:longint;
ASM
  MOV BL,4
  SUB BL,BYTE PTR bpp
  SHL BL,3

  MOV EDX,1
  MOV CL,gxredsize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Rsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Rpos
  ADD CL,BL
  ROL EAX,CL
  MOV Rmask,EAX

  MOV EDX,1
  MOV CL,gxgreensize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Gsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Gpos
  ADD CL,BL
  ROL EAX,CL
  MOV Gmask,EAX

  MOV EDX,1
  MOV CL,gxbluesize
  SHL EDX,CL
  DEC EDX
  ROR EDX,CL
  MOV EAX,1
  MOV CL,Bsiz
  SHL EAX,CL
  DEC EAX
  ROR EAX,CL
  AND EAX,EDX
  ADD CL,Bpos
  ADD CL,BL
  ROL EAX,CL
  MOV Bmask,EAX

  MOV AL,gxredpos
  ADD AL,gxredsize
  SUB AL,Rpos
  SUB AL,Rsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxgreenpos
  ADD AL,gxgreensize
  SUB AL,Gpos
  SUB AL,Gsiz
  SUB AL,BL
  ROR EAX,8
  MOV AL,gxbluepos
  ADD AL,gxbluesize
  SUB AL,Bpos
  SUB AL,Bsiz
  SUB AL,BL
  ROR EAX,16
  AND EAX,001F1F1Fh
  MOV rotate,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
@udtir32_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtir32_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtir32_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtir32_loop1
  MOV EDX,EAX
  MOV ECX,rotate
  XOR EAX,EAX
  MOV EBX,EDX
  AND EBX,Rmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Gmask
  ROL EBX,CL
  OR EAX,EBX
  SHR ECX,8
  MOV EBX,EDX
  AND EBX,Bmask
  ROL EBX,CL
  OR EAX,EBX
  STOSD
  POP ECX
  DEC ECX
  JNZ @udtir32_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtir32_loop3
  MOV EAX,dst
END;

{----------------------------- userdatatoimagePAL ---------------------------}

FUNCTION userdatatoimagePALLbyte(dst:pimage;src:pointer;bpp,idxbits:longint;var palette):pimage;assembler;
VAR xd,dstbpl,idxbitsmask:longint;
ASM
  MOV DL,4
  SUB DL,BYTE PTR bpp
  SHL DL,3
  SUB DL,2

  MOV CL,BYTE PTR idxbits
  MOV EAX,1
  SHL EAX,CL
  DEC EAX
  SHL EAX,2
  MOV idxbitsmask,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,palette
@udtip8_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtip8_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtip8_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtip8_loop1
  MOV CL,DL
  SHR EAX,CL
  AND EAX,idxbitsmask
  MOV EAX,[EBX+EAX]
  STOSB
  POP ECX
  DEC ECX
  JNZ @udtip8_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtip8_loop3
  MOV EAX,dst
END;

FUNCTION userdatatoimagePALLword(dst:pimage;src:pointer;bpp,idxbits:longint;var palette):pimage;assembler;
VAR xd,dstbpl,idxbitsmask:longint;
ASM
  MOV DL,4
  SUB DL,BYTE PTR bpp
  SHL DL,3
  SUB DL,2

  MOV CL,BYTE PTR idxbits
  MOV EAX,1
  SHL EAX,CL
  DEC EAX
  SHL EAX,2
  MOV idxbitsmask,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,palette
@udtip16_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtip16_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtip16_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtip16_loop1
  MOV CL,DL
  SHR EAX,CL
  AND EAX,idxbitsmask
  MOV EAX,[EBX+EAX]
  STOSW
  POP ECX
  DEC ECX
  JNZ @udtip16_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtip16_loop3
  MOV EAX,dst
END;

FUNCTION userdatatoimagePALL24(dst:pimage;src:pointer;bpp,idxbits:longint;var palette):pimage;assembler;
VAR xd,dstbpl,idxbitsmask:longint;
ASM
  MOV DL,4
  SUB DL,BYTE PTR bpp
  SHL DL,3
  SUB DL,2

  MOV CL,BYTE PTR idxbits
  MOV EAX,1
  SHL EAX,CL
  DEC EAX
  SHL EAX,2
  MOV idxbitsmask,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,palette
@udtip24_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtip24_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtip24_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtip24_loop1
  MOV CL,DL
  SHR EAX,CL
  AND EAX,idxbitsmask
  MOV EAX,[EBX+EAX]
  STOSW
  SHR EAX,16
  STOSB
  POP ECX
  DEC ECX
  JNZ @udtip24_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtip24_loop3
  MOV EAX,dst
END;

FUNCTION userdatatoimagePALL32(dst:pimage;src:pointer;bpp,idxbits:longint;var palette):pimage;assembler;
VAR xd,dstbpl,idxbitsmask:longint;
ASM
  MOV DL,4
  SUB DL,BYTE PTR bpp
  SHL DL,3
  SUB DL,2

  MOV CL,BYTE PTR idxbits
  MOV EAX,1
  SHL EAX,CL
  DEC EAX
  SHL EAX,2
  MOV idxbitsmask,EAX

  MOV EDI,dst
  MOV ESI,src
  MOV EAX,[EDI+timage.width]
  MOV xd,EAX
  MOV ECX,[EDI+timage.height]
  MOV EAX,[EDI+timage.bytesperline]
  MOV dstbpl,EAX
  MOV EDI,[EDI+timage.pixeldata]
  MOV EBX,palette
@udtip32_loop3:
  PUSH ECX
  MOV ECX,xd
  PUSH EDI
@udtip32_loop2:
  PUSH ECX
  MOV ECX,bpp
@udtip32_loop1:
  LODSB
  ROR EAX,8
  DEC ECX
  JNZ @udtip32_loop1
  MOV CL,DL
  SHR EAX,CL
  AND EAX,idxbitsmask
  MOV EAX,[EBX+EAX]
  STOSD
  POP ECX
  DEC ECX
  JNZ @udtip32_loop2
  POP EDI
  ADD EDI,dstbpl
  POP ECX
  DEC ECX
  JNZ @udtip32_loop3
  MOV EAX,dst
END;

{============================================================================}

PROCEDURE InitGXIMEFF;
BEGIN
  IF MMXavail THEN
    CASE gxcurcol OF
      ig_col8:
        BEGIN
          blendimageALPHA:=@blendimageALPHAL8;
          blendimageALPHAcolor:=@blendimageALPHAcolorL8;
          blendimageALPHAimage:=@blendimageALPHAimageL8;
          blendimageMASK:=@blendimageMASKL8;
          blendimageMASKcolor:=@blendimageMASKcolorL8;
          blendimageMASKimage:=@blendimageMASKimageL8;
          imageADDcolor:=@imageADDcolorLM8;
          imageSUBcolor:=@imageSUBcolorLM8;
          imageSADDcolor:=@imageSADDcolorLM8;
          imageSSUBcolor:=@imageSSUBcolorLM8;
          imageANDcolor:=@imageANDcolorLMbyte;
          imageORcolor :=@imageORcolorLMbyte;
          imageXORcolor:=@imageXORcolorLMbyte;
          imageADDimage:=@imageADDimageLM8;
          imageSUBimage:=@imageSUBimageLM8;
          imageSADDimage:=@imageSADDimageLM8;
          imageSSUBimage:=@imageSSUBimageLM8;
          imageANDimage:=@imageANDimageLall;
          imageORimage :=@imageORimageLall;
          imageXORimage:=@imageXORimageLall;
          fillimage:=@fillimageLMbyte;
          flipimageH:=@flipimageHLbyte;
          flipimageV:=@flipimageVLMall;
          composeimage:=@composeimageL8;
          composeimageC:=@composeimageCL8;
          scaleimage:=@scaleimageLbyte;
          rotateimage:=@rotateimageLMbyte;
          mosaicimage:=@mosaicimageL8;
          averageimage:=@averageimageL8;
          filterimage:=@filterimageL8;
          userdatatoimagergb:=@userdatatoimageRGBLbyte;
          userdatatoimagepal:=@userdatatoimagePALLbyte;
        END;
      ig_col15:
        BEGIN
          blendimageALPHA:=@blendimageALPHAL15;
          blendimageALPHAcolor:=@blendimageALPHAcolorL15;
          blendimageALPHAimage:=@blendimageALPHAimageL15;
          blendimageMASK:=@blendimageMASKL15;
          blendimageMASKcolor:=@blendimageMASKcolorL15;
          blendimageMASKimage:=@blendimageMASKimageL15;
          imageADDcolor:=@imageADDcolorLM15;
          imageSUBcolor:=@imageSUBcolorLM15;
          imageSADDcolor:=@imageSADDcolorLM15;
          imageSSUBcolor:=@imageSSUBcolorLM15;
          imageANDcolor:=@imageANDcolorLMword;
          imageORcolor :=@imageORcolorLMword;
          imageXORcolor:=@imageXORcolorLMword;
          imageADDimage:=@imageADDimageLM15;
          imageSUBimage:=@imageSUBimageLM15;
          imageSADDimage:=@imageSADDimageLM15;
          imageSSUBimage:=@imageSSUBimageLM15;
          imageANDimage:=@imageANDimageLMall;
          imageORimage :=@imageORimageLMall;
          imageXORimage:=@imageXORimageLMall;
          fillimage:=@fillimageLMword;
          flipimageH:=@flipimageHLword;
          flipimageV:=@flipimageVLMall;
          composeimage:=@composeimageL16;
          composeimageC:=@composeimageCL16;
          scaleimage:=@scaleimageLword;
          rotateimage:=@rotateimageLMword;
          mosaicimage:=@mosaicimageL15;
          averageimage:=@averageimageL15;
          filterimage:=@filterimageL15;
          userdatatoimagergb:=@userdatatoimageRGBLword;
          userdatatoimagepal:=@userdatatoimagePALLword;
        END;
      ig_col16:
        BEGIN
          blendimageALPHA:=@blendimageALPHAL16;
          blendimageALPHAcolor:=@blendimageALPHAcolorL16;
          blendimageALPHAimage:=@blendimageALPHAimageL16;
          blendimageMASK:=@blendimageMASKL16;
          blendimageMASKcolor:=@blendimageMASKcolorL16;
          blendimageMASKimage:=@blendimageMASKimageL16;
          imageADDcolor:=@imageADDcolorLM16;
          imageSUBcolor:=@imageSUBcolorLM16;
          imageSADDcolor:=@imageSADDcolorLM16;
          imageSSUBcolor:=@imageSSUBcolorLM16;
          imageANDcolor:=@imageANDcolorLMword;
          imageORcolor :=@imageORcolorLMword;
          imageXORcolor:=@imageXORcolorLMword;
          imageADDimage:=@imageADDimageLM16;
          imageSUBimage:=@imageSUBimageLM16;
          imageANDimage:=@imageANDimageLMall;
          imageSADDimage:=@imageSADDimageLM16;
          imageSSUBimage:=@imageSSUBimageLM16;
          imageORimage :=@imageORimageLMall;
          imageXORimage:=@imageXORimageLMall;
          fillimage:=@fillimageLMword;
          flipimageH:=@flipimageHLword;
          flipimageV:=@flipimageVLMall;
          composeimage:=@composeimageL16;
          composeimageC:=@composeimageCL16;
          scaleimage:=@scaleimageLword;
          rotateimage:=@rotateimageLMword;
          mosaicimage:=@mosaicimageL16;
          averageimage:=@averageimageL16;
          filterimage:=@filterimageL16;
          userdatatoimagergb:=@userdatatoimageRGBLword;
          userdatatoimagepal:=@userdatatoimagePALLword;
        END;
      ig_col24:
        BEGIN
          blendimageALPHA:=@blendimageALPHALMtc;
          blendimageALPHAcolor:=@blendimageALPHAcolorLM24;
          blendimageALPHAimage:=@blendimageALPHAimageLMtc;
          blendimageMASK:=@blendimageMASKLMtc;
          blendimageMASKcolor:=@blendimageMASKcolorLM24;
          blendimageMASKimage:=@blendimageMASKimageLMtc;
          imageADDcolor:=@imageADDcolorLM24;
          imageSUBcolor:=@imageSUBcolorLM24;
          imageSADDcolor:=@imageSADDcolorLM24;
          imageSSUBcolor:=@imageSSUBcolorLM24;
          imageANDcolor:=@imageANDcolorLM24;
          imageORcolor :=@imageORcolorLM24;
          imageXORcolor:=@imageXORcolorLM24;
          imageADDimage:=@imageADDimageLMtc;
          imageSUBimage:=@imageSUBimageLMtc;
          imageSADDimage:=@imageSADDimageLMtc;
          imageSSUBimage:=@imageSSUBimageLMtc;
          imageANDimage:=@imageANDimageLMall;
          imageORimage :=@imageORimageLMall;
          imageXORimage:=@imageXORimageLMall;
          fillimage:=@fillimageLM24;
          flipimageH:=@flipimageHL24;
          flipimageV:=@flipimageVLMall;
          composeimage:=@composeimageL24;
          composeimageC:=@composeimageCL24;
          scaleimage:=@scaleimageL24;
          rotateimage:=@rotateimageLM24;
          mosaicimage:=@mosaicimageL24;
          averageimage:=@averageimageL24;
          filterimage:=@filterimageL24;
          userdatatoimagergb:=@userdatatoimageRGBL24;
          userdatatoimagepal:=@userdatatoimagePALL24;
        END;
      ig_col32:
        BEGIN
          blendimageALPHA:=@blendimageALPHALMtc;
          blendimageALPHAcolor:=@blendimageALPHAcolorLM32;
          blendimageALPHAimage:=@blendimageALPHAimageLMtc;
          blendimageMASK:=@blendimageMASKLMtc;
          blendimageMASKcolor:=@blendimageMASKcolorLM32;
          blendimageMASKimage:=@blendimageMASKimageLMtc;
          imageADDcolor:=@imageADDcolorLM32;
          imageSUBcolor:=@imageSUBcolorLM32;
          imageSADDcolor:=@imageSADDcolorLM32;
          imageSSUBcolor:=@imageSSUBcolorLM32;
          imageANDcolor:=@imageANDcolorLM32;
          imageORcolor :=@imageORcolorLM32;
          imageXORcolor:=@imageXORcolorLM32;
          imageADDimage:=@imageADDimageLMtc;
          imageSUBimage:=@imageSUBimageLMtc;
          imageSADDimage:=@imageSADDimageLMtc;
          imageSSUBimage:=@imageSSUBimageLMtc;
          imageANDimage:=@imageANDimageLMall;
          imageORimage :=@imageORimageLMall;
          imageXORimage:=@imageXORimageLMall;
          fillimage:=@fillimageLM32;
          flipimageH:=@flipimageHL32;
          flipimageV:=@flipimageVLMall;
          composeimage:=@composeimageL32;
          composeimageC:=@composeimageCL32;
          scaleimage:=@scaleimageL32;
          rotateimage:=@rotateimageLM32;
          mosaicimage:=@mosaicimageL32;
          averageimage:=@averageimageLM32;
          filterimage:=@filterimageLM32;
          userdatatoimagergb:=@userdatatoimageRGBL32;
          userdatatoimagepal:=@userdatatoimagePALL32;
        END;
    END
  ELSE
    CASE gxcurcol OF
      ig_col8:
        BEGIN
          blendimageALPHA:=@blendimageALPHAL8;
          blendimageALPHAcolor:=@blendimageALPHAcolorL8;
          blendimageALPHAimage:=@blendimageALPHAimageL8;
          blendimageMASK:=@blendimageMASKL8;
          blendimageMASKcolor:=@blendimageMASKcolorL8;
          blendimageMASKimage:=@blendimageMASKimageL8;
          imageADDcolor:=@imageADDcolorL8;
          imageSUBcolor:=@imageSUBcolorL8;
          imageSADDcolor:=@imageSADDcolorL8;
          imageSSUBcolor:=@imageSSUBcolorL8;
          imageANDcolor:=@imageANDcolorLbyte;
          imageORcolor :=@imageORcolorLbyte;
          imageXORcolor:=@imageXORcolorLbyte;
          imageADDimage:=@imageADDimageL8;
          imageSUBimage:=@imageSUBimageL8;
          imageSADDimage:=@imageSADDimageL8;
          imageSSUBimage:=@imageSSUBimageL8;
          imageANDimage:=@imageANDimageLall;
          imageORimage :=@imageORimageLall;
          imageXORimage:=@imageXORimageLall;
          fillimage:=@fillimageLbyte;
          flipimageH:=@flipimageHLbyte;
          flipimageV:=@flipimageVLall;
          composeimage:=@composeimageL8;
          composeimageC:=@composeimageCL8;
          scaleimage:=@scaleimageLbyte;
          rotateimage:=@rotateimageLbyte;
          mosaicimage:=@mosaicimageL8;
          averageimage:=@averageimageL8;
          filterimage:=@filterimageL8;
          userdatatoimagergb:=@userdatatoimageRGBLbyte;
          userdatatoimagepal:=@userdatatoimagePALLbyte;
        END;
      ig_col15:
        BEGIN
          blendimageALPHA:=@blendimageALPHAL15;
          blendimageALPHAcolor:=@blendimageALPHAcolorL15;
          blendimageALPHAimage:=@blendimageALPHAimageL15;
          blendimageMASK:=@blendimageMASKL15;
          blendimageMASKcolor:=@blendimageMASKcolorL15;
          blendimageMASKimage:=@blendimageMASKimageL15;
          imageADDcolor:=@imageADDcolorL15;
          imageSUBcolor:=@imageSUBcolorL15;
          imageSADDcolor:=@imageSADDcolorL15;
          imageSSUBcolor:=@imageSSUBcolorL15;
          imageANDcolor:=@imageANDcolorLword;
          imageORcolor :=@imageORcolorLword;
          imageXORcolor:=@imageXORcolorLword;
          imageADDimage:=@imageADDimageL15;
          imageSUBimage:=@imageSUBimageL15;
          imageSADDimage:=@imageSADDimageL15;
          imageSSUBimage:=@imageSSUBimageL15;
          imageANDimage:=@imageANDimageLall;
          imageORimage :=@imageORimageLall;
          imageXORimage:=@imageXORimageLall;
          fillimage:=@fillimageLword;
          flipimageH:=@flipimageHLword;
          flipimageV:=@flipimageVLall;
          composeimage:=@composeimageL16;
          composeimageC:=@composeimageCL16;
          scaleimage:=@scaleimageLword;
          rotateimage:=@rotateimageLword;
          mosaicimage:=@mosaicimageL15;
          averageimage:=@averageimageL15;
          filterimage:=@filterimageL15;
          userdatatoimagergb:=@userdatatoimageRGBLword;
          userdatatoimagepal:=@userdatatoimagePALLword;
        END;
      ig_col16:
        BEGIN
          blendimageALPHA:=@blendimageALPHAL16;
          blendimageALPHAcolor:=@blendimageALPHAcolorL16;
          blendimageALPHAimage:=@blendimageALPHAimageL16;
          blendimageMASK:=@blendimageMASKL16;
          blendimageMASKcolor:=@blendimageMASKcolorL16;
          blendimageMASKimage:=@blendimageMASKimageL16;
          imageADDcolor:=@imageADDcolorL16;
          imageSUBcolor:=@imageSUBcolorL16;
          imageSADDcolor:=@imageSADDcolorL16;
          imageSSUBcolor:=@imageSSUBcolorL16;
          imageANDcolor:=@imageANDcolorLword;
          imageORcolor :=@imageORcolorLword;
          imageXORcolor:=@imageXORcolorLword;
          imageADDimage:=@imageADDimageL16;
          imageSUBimage:=@imageSUBimageL16;
          imageSADDimage:=@imageSADDimageL16;
          imageSSUBimage:=@imageSSUBimageL16;
          imageANDimage:=@imageANDimageLall;
          imageORimage :=@imageORimageLall;
          imageXORimage:=@imageXORimageLall;
          fillimage:=@fillimageLword;
          flipimageH:=@flipimageHLword;
          flipimageV:=@flipimageVLall;
          composeimage:=@composeimageL16;
          composeimageC:=@composeimageCL16;
          scaleimage:=@scaleimageLword;
          rotateimage:=@rotateimageLword;
          mosaicimage:=@mosaicimageL16;
          averageimage:=@averageimageL16;
          filterimage:=@filterimageL16;
          userdatatoimagergb:=@userdatatoimageRGBLword;
          userdatatoimagepal:=@userdatatoimagePALLword;
        END;
      ig_col24:
        BEGIN
          blendimageALPHA:=@blendimageALPHALtc;
          blendimageALPHAcolor:=@blendimageALPHAcolorL24;
          blendimageALPHAimage:=@blendimageALPHAimageLtc;
          blendimageMASK:=@blendimageMASKLtc;
          blendimageMASKcolor:=@blendimageMASKcolorL24;
          blendimageMASKimage:=@blendimageMASKimageL24;
          imageADDcolor:=@imageADDcolorL24;
          imageSUBcolor:=@imageSUBcolorL24;
          imageSADDcolor:=@imageSADDcolorL24;
          imageSSUBcolor:=@imageSSUBcolorL24;
          imageANDcolor:=@imageANDcolorL24;
          imageORcolor :=@imageORcolorL24;
          imageXORcolor:=@imageXORcolorL24;
          imageADDimage:=@imageADDimageLtc;
          imageSUBimage:=@imageSUBimageLtc;
          imageSADDimage:=@imageSADDimageLtc;
          imageSSUBimage:=@imageSSUBimageLtc;
          imageANDimage:=@imageANDimageLall;
          imageORimage :=@imageORimageLall;
          imageXORimage:=@imageXORimageLall;
          fillimage:=@fillimageL24;
          flipimageH:=@flipimageHL24;
          flipimageV:=@flipimageVLall;
          composeimage:=@composeimageL24;
          composeimageC:=@composeimageCL24;
          scaleimage:=@scaleimageL24;
          rotateimage:=@rotateimageL24;
          mosaicimage:=@mosaicimageL24;
          averageimage:=@averageimageL24;
          filterimage:=@filterimageL24;
          userdatatoimagergb:=@userdatatoimageRGBL24;
          userdatatoimagepal:=@userdatatoimagePALL24;
        END;
      ig_col32:
        BEGIN
          blendimageALPHA:=@blendimageALPHALtc;
          blendimageALPHAcolor:=@blendimageALPHAcolorL32;
          blendimageALPHAimage:=@blendimageALPHAimageLtc;
          blendimageMASK:=@blendimageMASKLtc;
          blendimageMASKcolor:=@blendimageMASKcolorL32;
          blendimageMASKimage:=@blendimageMASKimageL32;
          imageADDcolor:=@imageADDcolorL32;
          imageSUBcolor:=@imageSUBcolorL32;
          imageSADDcolor:=@imageSADDcolorL32;
          imageSSUBcolor:=@imageSSUBcolorL32;
          imageANDcolor:=@imageANDcolorL32;
          imageORcolor :=@imageORcolorL32;
          imageXORcolor:=@imageXORcolorL32;
          imageADDimage:=@imageADDimageLtc;
          imageSUBimage:=@imageSUBimageLtc;
          imageSADDimage:=@imageSADDimageLtc;
          imageSSUBimage:=@imageSSUBimageLtc;
          imageANDimage:=@imageANDimageLall;
          imageORimage :=@imageORimageLall;
          imageXORimage:=@imageXORimageLall;
          fillimage:=@fillimageL32;
          flipimageH:=@flipimageHL32;
          flipimageV:=@flipimageVLall;
          composeimage:=@composeimageL32;
          composeimageC:=@composeimageCL32;
          scaleimage:=@scaleimageL32;
          rotateimage:=@rotateimageL32;
          mosaicimage:=@mosaicimageL32;
          averageimage:=@averageimageL32;
          filterimage:=@filterimageL32;
          userdatatoimagergb:=@userdatatoimageRGBL32;
          userdatatoimagepal:=@userdatatoimagePALL32;
        END;
    END;
END;

{----------------------------------------------------------------------------}

BEGIN
  RegisterGXUnit(@InitGXIMEFF);
END.
