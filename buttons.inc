const
  BTS_NORMAL=0;
  BTS_PRESSED=1;
  BTS_DISABLED=2;

  BTT_REGULAR=0;
  BTT_TOGGLE=1;
  BTT_SLIDER=2;

  BTA_NOTHING=0;
  BTA_ENTER=1;
  BTA_PRESS=2;
  BTA_CLICK=3;

type
    Tbutton=record
        x,y,w,h:longint;
    img,dimg:pimage;
        state,btt:integer;
    tooltip:ansistring;
    bevel:string[4];
    prelighted,mp:boolean;
    //REGULAR
    act:array[0..3]of procedure(a:integer);
    act_prm:array[0..3]of integer;
    //TOGGLE
    var_toggle:^boolean;
        end;
    Pbutton=^Tbutton;

procedure bt_setpos(bt:Pbutton;x,y:longint);
begin
bt^.x:=x;
bt^.y:=y;
end;

function bt_new(btt0:integer;img_path:ansistring;w0,h0:longint;bevel0:string[4];tooltip0:ansistring;dimg0:pimage):Pbutton;
var nbt:Pbutton;
    i:integer;
begin
new(nbt);
with nbt^ do
    begin
  x:=0;y:=0;
  w:=w0;h:=h0;
  mp:=false;
  state:=BTS_NORMAL;
  btt:=btt0;
  if loadimagefile(itdetect,img_path,img,0)=-1 then img:=nil;
  dimg:=dimg0;
  bevel:=bevel0;
  tooltip:=tooltip0;
  for i:=0 to 3 do act[i]:=nil;
    end;
bt_new:=nbt;
end;

procedure destroy_button(var bt:Pbutton);
begin
destroyimage(bt^.img);
dispose(bt);
bt:=nil;
end;

function inbutton(bt:Pbutton;x,y:longint):boolean;
begin
inbutton:=((x>bt^.x)and(x<bt^.x+bt^.w))and((y>bt^.y)and(y<bt^.y+bt^.h));
end;

procedure draw_button(bt:Pbutton);
var
  i
  ,col1//frame
  ,col2//shadow
  ,col3//main color
  ,col4//specular
  ,t:longint;
  bvl:array[1..4]of integer;
begin
for i:=1 to 4 do val(bt^.bevel[i],bvl[i]);
col1:=rgbcolorrgb(70,70,70);
case bt^.btt of
    BTT_REGULAR:begin
        col2:=rgbcolorrgb(140,140,140);
        case bt^.state of
            BTS_NORMAL:if bt^.prelighted then col3:=rgbcolorrgb(215,215,215)else col3:=rgbcolorrgb(200,200,200);
        BTS_PRESSED:if bt^.prelighted then col3:=rgbcolorrgb(165,165,165)else col3:=rgbcolorrgb(150,150,150);
        end;
    end;
  BTT_TOGGLE:begin
        col2:=rgbcolorrgb(133,145,133);
        case bt^.state of
            BTS_NORMAL:if bt^.prelighted then col3:=rgbcolorrgb(208,229,208)else col3:=rgbcolorrgb(193,214,193);
        BTS_PRESSED:if bt^.prelighted then col3:=rgbcolorrgb(158,179,158)else col3:=rgbcolorrgb(143,164,143);
        end;
    end;
  end;


if bt^.state=BTS_PRESSED then
    begin
  col4:=rgbcolorrgb(190,190,190);
  t:=col2;
  col2:=col4;
  col4:=t;
  end else col4:=rgbcolorrgb(240,240,240);

with bt^ do
    begin
  imagelineH(dimg,x+1,x+w-1,y+h-1,col2);
  imagelineV(dimg,x+w-1,y+1,y+h-1,col2);
  imagelineH(dimg,x+1,x+w-1,y+1,col4);
  imagelineV(dimg,x+1,y+1,y+h-1,col4);
  imagebar(dimg,x+2,y+2,x+w-2,y+h-2,col3);

  imagelineH(dimg,x+bvl[1],x+w-bvl[2],y,col1);
  imagelineH(dimg,x+bvl[3],x+w-bvl[4],y+h,col1);
  imagelineV(dimg,x,y+bvl[1],y+h-bvl[3],col1);
  imagelineV(dimg,x+w,y+bvl[2],y+h-bvl[4],col1);
  imageline(dimg,x,y+bvl[1],x+bvl[1],y,col1);
  imageline(dimg,x+w-bvl[2],y,x+w,y+bvl[2],col1);
  imageline(dimg,x,y+h-bvl[3],x+bvl[3],y+h,col1);
  imageline(dimg,x+w-bvl[4],y+h,x+w,y+h-bvl[4],col1);

  if img<>nil then
  composeimagec(dimg,img,x+w div 2-getimagewidth(img)div 2,y+h div 2-getimageheight(img)div 2);
  end;
end;

function update_button(bt:Pbutton;pmb,mb,mx,my:integer):integer;
{returns last action}
var ac:integer;
label end_;
begin
ac:=BTA_NOTHING;
if bt^.state=BTS_DISABLED then goto end_;
if inbutton(bt,mx,my)then bt^.prelighted:=true else bt^.prelighted:=false;
if bt^.prelighted and(mb=1)and(pmb=0) then bt^.mp:=true;
case bt^.btt of
  BTT_REGULAR:if bt^.prelighted and bt^.mp then
            begin
        if (mb=1)then bt^.state:=BTS_PRESSED;
        if (mb=0)and(pmb=1)then ac:=BTA_CLICK;
        end
    else bt^.state:=BTS_NORMAL;
  BTT_TOGGLE:if bt^.mp then case bt^.state of
    BTS_PRESSED:if bt^.prelighted and(mb=0)and(pmb=1)then
        begin
      bt^.state:=BTS_NORMAL;
      bt^.var_toggle^:=false;
      end;
    BTS_NORMAL:if bt^.prelighted and(mb=0)and(pmb=1)then
        begin
      bt^.state:=BTS_PRESSED;
      bt^.var_toggle^:=true;
      end;
    end;
  end;

if mb=0 then bt^.mp:=false;

case bt^.btt of
    BTT_REGULAR:if (ac<>BTA_NOTHING)and(bt^.act[ac]<>nil) then bt^.act[ac](bt^.act_prm[ac]);
  BTT_TOGGLE:if bt^.var_toggle^ then bt^.state:=BTS_PRESSED else bt^.state:=BTS_NORMAL;
  end;
end_:
update_button:=ac;
end;
