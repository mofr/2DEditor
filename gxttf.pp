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
              --------------------------------------------
                               G X T T F
              --------------------------------------------
                                 v1.00
              --------------------------------------------
                        TrueType Font for GraphiX
                            Freetype Wrapper
              --------------------------------------------
                    written and (c) by Michael Knapp
              --------------------------------------------
}

{$I gxglobal.cfg}
UNIT gxttf;

INTERFACE

USES gxtext,freetype;
{$I gxlocal.cfg}

TYPE PBytes=^byte;
     PUnicode=^word;

     PGlyph=^TGlyph;
     TGlyph=RECORD
       loaded:longint;
       RM:TT_Raster_Map;
       width,advance:longint;
     END;

     PFontTTF=^TFontTTF;
     TFontTTF=OBJECT(TFont)
       face:TT_Face;
       instance:TT_Instance;
       glyph:TT_Glyph;
       imetrics:TT_Instance_Metrics;
       props:TT_Face_Properties;
       charmap:TT_CharMap;
       glyphtable:PGlyph;
       CONSTRUCTOR LoadFont(name:string);
       PROCEDURE setfontsize(size:longint);virtual;
       PROCEDURE setfontstyle(style:longint);virtual;

       PROCEDURE outbytes(x,y:longint;bc:PBytes;len,col:longint);
       FUNCTION byteslength(bc:PBytes;len:longint):longint;
       FUNCTION bytesheight(bc:PBytes;len:longint):longint;

       PROCEDURE outtext(x,y:longint;s:string;f:longint);virtual;
       FUNCTION textlength(s:string):longint;virtual;
       FUNCTION textheight(s:string):longint;virtual;

       PROCEDURE outunicode(x,y:longint;uc:PUnicode;len,col:longint);
       FUNCTION unicodelength(uc:PUnicode;len:longint):longint;
       FUNCTION unicodeheight(uc:PUnicode;len:longint):longint;

       FUNCTION fontheight:longint;virtual;
       DESTRUCTOR RemoveFont;
       PROCEDURE CheckGlyph(i:longint);
       PROCEDURE ClearGlyphTable;
     END;

IMPLEMENTATION

USES graphix;

{------------------------------}

CONST ASCIItoUnicode:array[0..255] of word=
        ($00,$01,$02,$03,$04,$05,$06,$B7,$08,$09,$0A,$0B,$0C,$0D,$0E,$A4,
         $10,$11,$12,$13,$B6,$A7,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,
         $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,
         $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,
         $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,
         $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F,
         $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F,
         $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$7F,
         $00C7,$00FC,$00E9,$00E2,$00E4,$00E0,$00E5,$00E7,
         $00EA,$00EB,$00E8,$00EF,$00EE,$00EC,$00C4,$00C5,
         $00C9,$00E6,$00C6,$00F4,$00F6,$00F2,$00FB,$00F9,
         $00FF,$00F6,$00DC,$00A2,$00A3,$00A5,   $0,$0192,
         $00E1,$00ED,$00F3,$00FA,$00F1,$00D1,$00AA,$00BA,
         $00BF,$2310,$00AC,$00BD,$00BC,$00A1,$00AB,$00BB,
         $2591,$2592,$2593,$2502,$2524,$2561,$2562,$2556,
         $2555,$2563,$2551,$2557,$255D,$255C,$255B,$2510,
         $2514,$2534,$252C,$251C,$2500,$253C,$255E,$255F,
         $255A,$2554,$2569,$2566,$2560,$2550,$256C,$2567,
         $2568,$2564,$2565,$2559,$2558,$2552,$2553,$256B,
         $256A,$2518,$250C,$2588,   $0,$258C,$2590,   $0,
         $03B1,$03B2,$0393,$03C0,$03A3,$03C3,$03BC,$03C4,
         $03A6,$0398,$03A9,$03B4,$221E,$03D5,$2208,$2229,
         $2261,$00B1,$2265,$2264,$2320,$2321,$00F7,$2248,
         $00B0,$2219,$00B7,$221A,$00B3,$00B2,$220E,$00FF);

CONST load_flag=TT_Load_Scale_Glyph OR TT_Load_Hint_Glyph;

{------------------------------}

CONSTRUCTOR TFontTTF.LoadFont(name:string);
VAR error:TT_error;
    i,platformID,encodingID,len:smallint;
    str:pointer;
BEGIN
  INHERITED LoadFont;
  fontloaded:=false;
  fontsize:=12;

  fillchar(face,sizeof(face),0);
  fillchar(glyph,sizeof(glyph),0);
  fillchar(instance,sizeof(instance),0);
  fillchar(charmap,sizeof(charmap),0);
  fillchar(props,sizeof(props),0);

  error:=TT_Open_Face(name,face);
  IF (error<>TT_Err_Ok) THEN exit;
  TT_Get_Face_Properties(face,props);
  error:=TT_New_Glyph(face,glyph);
  IF (error<>TT_Err_Ok) THEN exit;
  error:=TT_New_Instance(face,instance);
  IF (error<>TT_Err_Ok) THEN exit;

  encodingID:=-1;
  platformID:=-1;
  FOR i:=1 TO TT_Get_CharMap_Count(face) DO
    BEGIN
      TT_Get_CharMap_ID(face,i,platformID,encodingID);
{inittext;
writeln(platformid,' - ',encodingid);
readln;}
      IF (platformID=3) AND (encodingID=0) THEN
        BEGIN
          TT_Get_CharMap(face,i,charmap);
          break;
        END;
      IF (platformID=3) AND (encodingID=1) THEN
        BEGIN
          TT_Get_CharMap(face,i,charmap);
          break;
        END;
    END;

  TT_Set_Instance_Resolutions(instance,96,96);
  TT_Set_Instance_Transforms(instance,FALSE,TRUE);

  getmem(glyphtable,props.num_Glyphs*sizeof(TGlyph));
  fillchar(glyphtable^,props.num_Glyphs*sizeof(TGlyph),0);

  setfontsize(12);

{  TT_Get_Name_ID(face,0,platform,encoding,language,nameid); }
  fontname:='Truetype Font';
  IF (TT_Get_Name_String(face,4,str,len)=TT_Err_Ok) THEN
    BEGIN
      fontname:='';
      FOR i:=0 TO len-1 DO fontname:=fontname+char((str+i)^);
    END;
  fontloaded:=TRUE;
END;

PROCEDURE TFontTTF.CheckGlyph(i:longint);
CONST matrix:TT_Matrix=(xx:65536;xy:16384;yx:0;yy:65536);
VAR metrics:TT_Glyph_Metrics;
    outline:TT_Outline;
    bbox:TT_BBox;
BEGIN
  WITH glyphtable[i] DO
    IF (loaded=0) THEN
      BEGIN
        IF (TT_Load_Glyph(instance,glyph,i,load_flag)=TT_Err_Ok) THEN
          BEGIN
            loaded:=1;
            RM.width:=imetrics.x_ppem*2;
            RM.rows:=imetrics.y_ppem;
            RM.flow:=TT_Flow_Down;
            RM.cols:=(RM.width+7) DIV 8;
            RM.size:=RM.rows*RM.cols;
            getmem(RM.buffer,RM.size);
            fillchar(RM.buffer^,RM.size,0);
            advance:=0;
            width:=0;
            TT_Get_Glyph_Metrics(glyph,metrics);
            CASE (fontstyle AND $00F0) OF
            fts_normal:
              BEGIN
                TT_Get_Glyph_Bitmap(glyph,RM,0,(RM.rows-fontsize)*64);
                advance:=(metrics.advance+63) DIV 64;
                width:=(metrics.advance+63) DIV 64;
              END;
            fts_italic:
              BEGIN
                TT_Get_Glyph_Outline(glyph,outline);
                TT_Transform_Outline(outline,matrix);
                TT_Translate_Outline(outline,0,(RM.rows-fontsize)*64);
                TT_Get_Outline_Bitmap(outline,RM);
                TT_Get_Outline_BBox(outline,bbox);
                advance:=(metrics.advance+63) DIV 64;
                width:=(bbox.ymax+63) DIV 64;
              END;
            END;
            IF (width=0) THEN width:=RM.width;
          END;
      END;
END;

PROCEDURE TFontTTF.ClearGlyphTable;
VAR i:longint;
BEGIN
  FOR i:=0 TO props.num_glyphs-1 DO
    WITH glyphtable[i] DO
      IF (loaded>0) THEN freemem(RM.buffer,RM.size);
  fillchar(glyphtable^,props.num_Glyphs*sizeof(TGlyph),0);
END;

PROCEDURE TFontTTF.setfontsize(size:longint);
BEGIN
  INHERITED setfontsize(size);
  TT_Set_Instance_CharSize(instance,fontsize*64);
  TT_Get_Instance_Metrics(instance,imetrics);
  ClearGlyphTable;
END;

PROCEDURE TFontTTF.setfontstyle(style:longint);
BEGIN
  INHERITED setfontstyle(style);
  ClearGlyphTable;
END;

PROCEDURE TFontTTF.outbytes(x,y:longint;bc:PBytes;len,col:longint);
VAR metrics:TT_Glyph_Metrics;
    i,j,xx:longint;
    l:dword;
BEGIN
  IF (fontorigin=fto_baseline) THEN dec(y,fontsize-1);
  IF (len=-1) THEN l:=$FFFFFFFF ELSE l:=len;
  xx:=0;
  FOR i:=0 TO l-1 DO
    BEGIN
      IF (len=-1) THEN IF (bc^=0) THEN exit;
{      j:=TT_Char_Index(charmap,bc^); }
      j:=bc^-29;
      inc(bc);
      CheckGlyph(j);
      WITH glyphtable[j] DO
        BEGIN
          IF (RM.size>0) THEN
            oputbitmap(x+xx,y,width,RM.rows,RM.cols,col,RM.buffer^);
          inc(xx,advance);
        END;
    END;
END;

PROCEDURE TFontTTF.outtext(x,y:longint;s:string;f:longint);
VAR metrics:TT_Glyph_Metrics;
    i,j,xx:longint;
BEGIN
  IF (fontorigin=fto_baseline) THEN dec(y,fontsize-1);
  xx:=0;
  FOR i:=1 TO length(s) DO
    BEGIN
      j:=TT_Char_Index(charmap,ASCIItoUnicode[ord(s[i])]);
      CheckGlyph(j);
      WITH glyphtable[j] DO
        BEGIN
          IF (RM.size>0) THEN
            oputbitmap(x+xx,y,width,RM.rows,RM.cols,f,RM.buffer^);
          inc(xx,advance);
        END;
    END;
END;

PROCEDURE TFontTTF.outunicode(x,y:longint;uc:PUnicode;len,col:longint);
VAR metrics:TT_Glyph_Metrics;
    i,j,xx:longint;
    l:dword;
BEGIN
  IF (fontorigin=fto_baseline) THEN dec(y,fontsize-1);
  IF (len=-1) THEN l:=$FFFFFFFF ELSE l:=len;
  xx:=0;
  FOR i:=0 TO l-1 DO
    BEGIN
      IF (len=-1) THEN IF (uc^=0) THEN exit;
      j:=TT_Char_Index(charmap,uc^);
      inc(uc);
      CheckGlyph(j);
      WITH glyphtable[j] DO
        BEGIN
          IF (RM.size>0) THEN
            oputbitmap(x+xx,y,width,RM.rows,RM.cols,col,RM.buffer^);
          inc(xx,advance);
        END;
    END;
END;

FUNCTION TFontTTF.byteslength(bc:PBytes;len:longint):longint;
VAR metrics:TT_Glyph_Metrics;
    x,i,j:longint;
    l:dword;
BEGIN
  x:=0;
  IF (len=-1) THEN l:=$FFFFFFFF ELSE l:=len;
  FOR i:=0 TO l-1 DO
    BEGIN
      IF (len=-1) THEN IF (bc^=0) THEN exit;
{      j:=TT_Char_Index(charmap,bc^); }
      j:=bc^-29;
      inc(bc);
      IF (TT_Load_Glyph(instance,glyph,j,load_flag)=TT_Err_Ok) THEN
        BEGIN
          TT_Get_Glyph_Metrics(glyph,metrics);
          inc(x,(metrics.advance+63) DIV 64);
        END;
    END;
  byteslength:=x;
END;

FUNCTION TFontTTF.textlength(s:string):longint;
VAR metrics:TT_Glyph_Metrics;
    x,i,j:longint;
BEGIN
  x:=0;
  FOR i:=1 TO length(s) DO
    BEGIN
      j:=TT_Char_Index(charmap,ASCIItoUnicode[ord(s[i])]);
      IF (TT_Load_Glyph(instance,glyph,j,load_flag)=TT_Err_Ok) THEN
        BEGIN
          TT_Get_Glyph_Metrics(glyph,metrics);
          inc(x,(metrics.advance+63) DIV 64);
        END;
    END;
  textlength:=x;
END;

FUNCTION TFontTTF.unicodelength(uc:PUnicode;len:longint):longint;
VAR metrics:TT_Glyph_Metrics;
    x,i,j:longint;
    l:dword;
BEGIN
  x:=0;
  IF (len=-1) THEN l:=$FFFFFFFF ELSE l:=len;
  FOR i:=0 TO l-1 DO
    BEGIN
      IF (len=-1) THEN IF (uc^=0) THEN exit;
      j:=TT_Char_Index(charmap,uc^);
      inc(uc);
      IF (TT_Load_Glyph(instance,glyph,j,load_flag)=TT_Err_Ok) THEN
        BEGIN
          TT_Get_Glyph_Metrics(glyph,metrics);
          inc(x,(metrics.advance+63) DIV 64);
        END;
    END;
  unicodelength:=x;
END;

FUNCTION TFontTTF.bytesheight(bc:PBytes;len:longint):longint;
BEGIN
  bytesheight:=imetrics.y_ppem;
END;

FUNCTION TFontTTF.textheight(s:string):longint;
BEGIN
  textheight:=imetrics.y_ppem;
END;

FUNCTION TFontTTF.unicodeheight(uc:PUnicode;len:longint):longint;
BEGIN
  unicodeheight:=imetrics.y_ppem;
END;

FUNCTION TFontTTF.fontheight:longint;
BEGIN
  fontheight:=imetrics.y_ppem;
END;

DESTRUCTOR TFontTTF.RemoveFont;
BEGIN
  ClearGlyphTable;
  freemem(glyphtable,props.num_Glyphs*sizeof(TGlyph));
  TT_Done_Instance(instance);
  TT_Done_Glyph(glyph);
  TT_Close_Face(face);
END;

{==========================================================================}

VAR OldExitProc:pointer;

PROCEDURE NewExitProc;
BEGIN
  ExitProc:=OldExitProc;
  TT_Done_FreeType;
END;

BEGIN
  OldExitProc:=ExitProc;
  ExitProc:=@NewExitProc;
  TT_Init_FreeType;
END.
