program anttest;
uses graphix,gxtype,gximg,gxmouse,gxcrt,gximeff,gxdrw,gxtext,math;
type
Tpoint=record
    x,y:longint;
    end;
  Ppoint=^Tpoint;

  Ttriangle=record
    p1,p2,p3:Ppoint;
    tex:pimage;
    end;
  Ptriangle=^Ttriangle;
var
  scr_img:pimage;
  test_tr:Ptriangle;
  mx,my:longint;
{$include vectors.inc}
{$include graph.inc}
procedure putpixelc(dimg:pimage;x0,y0,col,alpha:longint);
var point:pimage;
begin
point:=createimageWH(1,1);
fillimage(point,col);
draw_image_alpha(dimg,point,x0,y0,alpha);
destroyimage(point);
end;

procedure swap_pointers(var p1,p2:pointer);
var p:pointer;
begin
p:=p1;
p1:=p2;
p2:=p;
end;

procedure destroy_triangle(var tr:Ptriangle);
begin
dispose(tr^.p1);dispose(tr^.p2);dispose(tr^.p3);
dispose(tr);
tr:=nil;
end;

function line_crossH(y:longint;p1,p2:Ppoint;var x:longint):boolean;
var k,b:extended;
    x1,x2:longint;
  y1,y2:longint;
begin
line_crossH:=false;
k:=p2^.x-p1^.x;
if k<>0 then
    begin
    k:=(p2^.y-p1^.y)/k;
  b:=p1^.y-k*p1^.x;
  x:=round((y-b)/k);
  if p1^.x>p2^.x then
    begin x1:=p2^.x;x2:=p1^.x;end
  else
    begin x2:=p2^.x;x1:=p1^.x;end;
  if (x>=x1)and(x<=x2) then line_crossH:=true;
    end
else
    begin
  x:=p1^.x;
  if p1^.y>p2^.y then
    begin y1:=p2^.y;y2:=p1^.y;end
  else
    begin y2:=p2^.y;y1:=p1^.y;end;
  if(y>=y1)and(y<=y2)then line_crossH:=true;
  end;
end;

procedure sort_triangle_points_y(tr:Ptriangle);
begin
with tr^ do
    begin
  if p1^.y>p2^.y then swap_pointers(p1,p2);
  if p2^.y>p3^.y then swap_pointers(p2,p3);
  if p1^.y>p2^.y then swap_pointers(p1,p2);
  end;
end;

function triangle_copy(dtr:Ptriangle):Ptriangle;
var tr:Ptriangle;
begin
new(tr);
new(tr^.p1);new(tr^.p2);new(tr^.p3);
tr^.p1^.x:=dtr^.p1^.x;
tr^.p1^.y:=dtr^.p1^.y;
tr^.p2^.x:=dtr^.p2^.x;
tr^.p2^.y:=dtr^.p2^.y;
tr^.p3^.x:=dtr^.p3^.x;
tr^.p3^.y:=dtr^.p3^.y;
tr^.tex:=dtr^.tex;
triangle_copy:=tr;
end;

procedure swap_lint(var a,b:longint);
var t:longint;
begin
t:=a;
a:=b;
b:=t;
end;

procedure triangleA(dtr:Ptriangle;col:longint;texture:boolean;img,tex:pimage);
var y,x1,x2,edges_col,i,px1,a:longint;
    tr:Ptriangle;
    nor:Tvec;
begin
px1:=-1;
edges_col:=rgbcolorrgb(255,100,255);
tr:=triangle_copy(dtr);
sort_triangle_points_y(tr);
with tr^ do
    begin
  //part1
  if (p1^.y<>p2^.y)then
    for y:=p1^.y to p2^.y do
    if (line_crossH(y,p1,p2,x1))and(line_crossH(y,p1,p3,x2)) then
    begin
    if x1>x2 then begin x2:=x1+x2;x1:=x2-x1;x2:=x2-x1;end;
    if (tex<>nil)and texture then
    for i:=x1 to x2 do
      imageputpixel(img,i,y,imagegetpixel(tex,(i+getmaxx) mod getimagewidth(tex),(y+getmaxy) mod getimageheight(tex)))
    else imagelineH(img,x1,x2,y,col);
    x2:=px1;
//    if x2<x1 then swap_lint(x1,x2);
    if y<>p1^.y then
    	for i:=x1 to x2-1 do
      	begin
        a:=300-round(255*((x2-i)/(x2-x1)));
        if a<0 then a:=0;
        if a>255 then a:=255;
        putpixelc(img,i,y-1,col,a);
        end;
    px1:=x1;
    end;
  //part2
  if (p2^.y<>p3^.y)then
  for y:=p2^.y+1 to p3^.y do
    if (line_crossH(y,p2,p3,x1))and(line_crossH(y,p1,p3,x2)) then
    begin
    if x1>x2 then begin x2:=x1+x2;x1:=x2-x1;x2:=x2-x1;end;
    if (tex<>nil)and texture then
    for i:=x1 to x2 do
      imageputpixel(img,i,y,imagegetpixel(tex,(i+getmaxx) mod getimagewidth(tex),(y+getmaxy) mod getimageheight(tex)))
    else imagelineH(img,x1,x2,y,col);
    end;
  end;
destroy_triangle(tr);
end;

begin
initgraphix(ig_lfb,ig_vesa);
setmodegraphix(1024,768,ig_col32);
initmouse;
disablemouse;
scr_img:=createimageWH(getmaxx+1,getmaxy+1);
new(test_tr);
with test_tr^ do
	begin
  new(p1);new(p2);new(p3);
  with p1^ do begin x:=getmaxx div 4;y:=getmaxy div 3+5;end;
  with p2^ do begin x:=getmaxx*2 div 3;y:=getmaxy div 3;end;
  with p3^ do begin x:=getmaxx-10;y:=getmaxy-20;end;
  end;
repeat
  begin
  fillimage(scr_img,rgbcolorrgb(0,0,0));
  triangleA(test_tr,rgbcolorrgb(255,255,255),false,scr_img,nil);
  putimage(0,0,scr_img);
  mousecoords(mx,my);
  with test_tr^.p1^ do begin x:=mx;y:=my;end;
  end
until keypressed;
donegraphix;
end.
