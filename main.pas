program editor;
uses graphix,gxtype,gximg,gxcrt,gxdrw,gximeff,gxmouse,gxtext,sysutils,
	math,glib;
var gacc:extended;
const
blur_filter:array[1..5,1..5] of byte=
{	((0,1,2,1,0),
   (1,3,4,3,1),	
   (2,4,5,4,2),
   (1,3,4,3,1),
   (0,1,2,1,0));  }
   ((5,5,5,5,5),
   (5,5,5,5,5),	
   (5,5,5,5,5),
   (5,5,5,5,5),
   (5,5,5,5,5));
  graphresx=1024;
  graphresy=768;

  max_obj_points=100;
  max_obj_triangles=50;
  max_kol_objects=50;
  max_pnt_selected=max_kol_objects*max_obj_points;
  max_kol_buttons=17;
  max_balls=10;

  OBJECT_MODE=0;
  EDIT_MODE=1;

  CURSOR_NORMAL=0;
  CURSOR_HAND=1;
  CURSOR_CREST=2;
  CURSOR_CIRCLE=3;

  GRAB_ACTION=1;
  ROTATE_ACTION=2;
  SCALE_ACTION=3;
  RECT_SEL_ACTION=4;
  CIRCLE_SEL_ACTION=5;

procedure put_image_wmask(bg,img,mask:pimage;x,y:longint);forward;
{$include buttons.inc}
{$include vectors.inc}
type
	Pansistring=^ansistring;

  Tpoint=record
    x,y:longint;
    end;
  Ppoint=^Tpoint;

  Ttriangle=record
    p1,p2,p3:Ppoint;
    tex:pimage;
    end;
  Ptriangle=^Ttriangle;

  Tobject=record
    pnt:array[0..max_obj_points-1]of Ppoint;
    tr:array[0..max_obj_triangles-1]of Ptriangle;
    end;
  Pobject=^Tobject;

function lines_crossed(x11,y11,x12,y12,x21,y21,x22,y22:real;rx,ry:Plongint):boolean;forward;
var
  screenimg,mainbgtex,testtex:pimage;
  main_end,view_scroll,autopivot,edit_by_step,lock_x,lock_y,
  	view_textured:boolean;
  i,prevmb,cur_cursor,mode,view_scroll_sx,view_scroll_sy,action_type,
    grab_x,grab_y,grab_sx,grab_sy,pivot_x,pivot_y,header_y,toolbar_y,
    rotate_sx,rotate_sy,scale_sx,scale_sy,std_bt_size,mx,my,mb,rect_selx1,
    rect_sely1,rect_selx2,rect_sely2,rect_sel,cursordx,cursordy,
    mainx1,mainy1,mainx2,mainy2:longint;
  key_pressed:boolean;
  key:char;
  rotate_ang,scale_koef,bg_dist:extended;
  obj:array[0..max_kol_objects-1]of Pobject;
  sel_obj:array[0..max_kol_objects-1]of Pobject;
  sel_pnt:array[0..max_pnt_selected-1]of Ppoint;
  cursor:array[0..5]of pimage;
  ed_obj:Pobject;
  view:record
    x,y:longint;
    w,h:longint;
    end;
  font:TfontFNT;
  bt:array[0..max_kol_buttons-1]of Pbutton;
  //colors
  main_frame_color,main_shad_color,main_spec_color,main_back_color:longint;
  //
  time_paused:boolean;
  main_timer:pgtimer;
{$include ball.inc}
var
  ball:array[0..max_balls-1]of Pball;
  last_created_ball:Pball;


procedure sort_triangle_points_x(tr:Ptriangle);forward;
procedure sort_triangle_points_y(tr:Ptriangle);forward;
function triangle_copy(dtr:Ptriangle):Ptriangle;forward;
procedure destroy_triangle(var tr:Ptriangle);forward;
function get_point_by_coords(obj:Pobject;x,y:longint):Ppoint;forward;
function get_first_obj_tr_nil(obj:Pobject):longint;forward;
function obj_set_triangle(obj:Pobject;indx:longint;i1,i2,i3:Ppoint):Ptriangle;forward;
procedure prepare_new_workplace(a:integer);forward;
function new_object(objtype:integer):Pobject;forward;
function obj_add_point(obj:Pobject;x0,y0:longint):Ppoint;forward;
procedure createscreenimg(screenimg:pimage;x0,y0:longint;tar:char;dr_mouse:boolean);forward;
{$include graph.inc}
{$include save_load.inc}
function get_first_ball_nil_indx:longint;
var i:longint;
begin
i:=0;
while (ball[i]<>nil)and(i<max_balls)do inc(i);
if(i<max_balls)and(ball[i]=nil)then get_first_ball_nil_indx:=i else get_first_ball_nil_indx:=-1;
end;

function get_minx:longint;
var i,j:longint;
begin
get_minx:=high(get_minx);
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then
	for j:=0 to max_obj_points-1 do if obj[i]^.pnt[j]<>nil then
  	if obj[i]^.pnt[j]^.x<get_minx then get_minx:=obj[i]^.pnt[j]^.x;
end;
function get_miny:longint;
var i,j:longint;
begin
get_miny:=high(get_miny);
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then
	for j:=0 to max_obj_points-1 do if obj[i]^.pnt[j]<>nil then
  	if obj[i]^.pnt[j]^.y<get_miny then get_miny:=obj[i]^.pnt[j]^.y;
end;
function get_maxx:longint;
var i,j:longint;
begin
get_maxx:=low(longint);
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then
	for j:=0 to max_obj_points-1 do if obj[i]^.pnt[j]<>nil then
  	if obj[i]^.pnt[j]^.x>get_maxx then get_maxx:=obj[i]^.pnt[j]^.x;
end;
function get_maxy:longint;
var i,j:longint;
begin
get_maxy:=low(get_maxy);
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then
	for j:=0 to max_obj_points-1 do if obj[i]^.pnt[j]<>nil then
  	if obj[i]^.pnt[j]^.y>get_maxy then get_maxy:=obj[i]^.pnt[j]^.y;
end;

procedure render;
var imgmain,img,mask:pimage;
	x01,y01,x02,y02,i,j:longint;
begin
x01:=get_minx;
y01:=get_miny;
x02:=get_maxx;
y02:=get_maxy;
if x01>mainx1 then x01:=mainx1;
if x02<mainx2 then x02:=mainx2;
if y01>mainy1 then y01:=mainy1;
if y02<mainy2 then y02:=mainy2;
mask:=createimageWH(x02-x01,y02-y01);
fillimage(mask,rgbcolorrgb(0,0,0));
imgmain:=cloneimage(mask);
img:=cloneimage(mask);
createscreenimg(imgmain,x01,y01,'B',false);
createscreenimg(img,x01,y01,'A',false);
createscreenimg(mask,x01,y01,'M',false);
filterimage(mask,mask,blur_filter,2,2,5,5,0);
saveimageTGA('renders\render-bg.tga',imgmain);
saveimageTGA('renders\render-mask.tga',mask);
put_image_wmask(imgmain,img,mask,0,0);
saveimageTGA('renders\render.tga',imgmain);
destroyimage(mask);
destroyimage(imgmain);
destroyimage(img);
end;

function dialog_window(text:ansistring;bt_text1,bt_text2:ansistring;prev_img,img:pimage):integer;
var win_img,bg:pimage;
    b:array[1..2]of Pbutton;
  result,i:integer;
  pmb,mb,mx,my,sx,sy:longint;
begin
g_timer_stop(main_timer);
result:=-1;
pmb:=0;
if img=nil then
    begin
    sx:=getmaxx div 3;
    sy:=getmaxy div 4;
  end
else
    begin
  sx:=getimagewidth(img);
  sy:=getimageheight(img);
  end;
createscreenimg(prev_img,view.x,view.y,'V',false);
bg:=cloneimage(prev_img);
sx:=sx+2;sy:=sy+2;//for frame
win_img:=createimageWH(sx,sy);
fillimage(win_img,rgbcolorrgb(15,15,15));
font.setimage(win_img);

i:=1;
b[i]:=bt_new(BTT_REGULAR,' ',std_bt_size*2,std_bt_size,'2222','',win_img);
bt_setpos(b[i],sx div 2-b[i]^.w div 2-sx div 4,sy-b[i]^.h*2);
if bt_text1='' then b[i]^.state:=BTS_DISABLED;
i:=2;
b[i]:=bt_new(BTT_REGULAR,' ',std_bt_size*2,std_bt_size,'2222','',win_img);
bt_setpos(b[i],sx div 2-b[i]^.w div 2+sx div 4,sy-b[i]^.h*2);
if bt_text2='' then b[i]^.state:=BTS_DISABLED;

repeat
	begin
  fillimage(win_img,main_back_color);
  draw_bar(win_img,0,0,sx-1,sy-1,img,true,true);
  mb:=mousebutton;
  mousecoords(mx,my);
  composeimage(prev_img,bg,0,0);
  font.outtext(sx div 2-font.textlength(text)div 2,sy div 2-font.textheight(text)div 2,text,rgbcolorrgb(15,15,15));
  for i:=1 to 2 do
    begin
    if update_button(b[i],pmb,mb,mx-(getmaxx div 2-sx div 2),my-(getmaxy div 2-sy div 2))<>BTA_NOTHING then result:=i;
    draw_button(b[i]);
    end;
  if keypressed then
    case readkey of
    	#27,'n','N':result:=2;
      #13,'y','Y':result:=1;
      end;
  pmb:=mb;
  font.outtext(b[1]^.x+b[1]^.w div 2-font.textlength(bt_text1)div 2,b[1]^.y+b[1]^.h div 2-font.textheight(bt_text1)div 2,bt_text1,rgbcolorrgb(15,15,15));
  font.outtext(b[2]^.x+b[2]^.w div 2-font.textlength(bt_text2)div 2,b[2]^.y+b[2]^.h div 2-font.textheight(bt_text2)div 2,bt_text2,rgbcolorrgb(15,15,15));
  composeimage(prev_img,win_img,getmaxx div 2-sx div 2,getmaxy div 2-sy div 2);
  composeimagec(prev_img,cursor[cur_cursor],mx,my);
  putimage(0,0,prev_img);
  end
until result<>-1;

for i:=1 to 2 do destroy_button(b[i]);
destroyimage(win_img);
destroyimage(bg);
font.setimage(prev_img);
dialog_window:=result;
g_timer_start(main_timer);
end;

function in_viewport(y:longint):boolean;
begin
in_viewport:=(y>header_y+3)and(y<getmaxy-toolbar_y-3);
end;

procedure main_quit;
begin
if dialog_window('Are you really want to quit?','Yes','No',screenimg,nil)=1 then main_end:=true;
end;

procedure bt_help;
var img:pimage;
begin
loadimagefile(itdetect,'gfx\logo.gif',img,0);
dialog_window('','','',screenimg,img);
destroyimage(img);
end;

function pdist(x1,y1,x2,y2:longint):extended;
begin
pdist:=sqrt(sqr(x2-x1)+sqr(y2-y1));
end;

function to_str(int:longint):ansistring;
var s:ansistring;
begin
str(int,s);
to_str:=s;
end;

function lineangle(x1,y1,x2,y2:longint):real;
var d:extended;
begin
d:=pdist(x1,y1,x2,y2);
if d=0 then lineangle:=0 else
lineangle:=arccos((x2-x1)/d)*180/pi;
if y2<y1 then begin lineangle:=-lineangle;lineangle:=lineangle+360;end;
end;

function lines_crossed(x11,y11,x12,y12,x21,y21,x22,y22:real;rx,ry:Plongint):boolean;
var k1,k2,b1,b2,t:double;
    x,y:double;
    h1,h2:boolean;
begin
lines_crossed:=false;

h1:=x12-x11=0;
h2:=x22-x21=0;
if not h1 then k1:=(y12-y11)/(x12-x11) else k1:=0;
if not h2 then k2:=(y22-y21)/(x22-x21) else k2:=0;

if k1<>k2 then
	begin
  if h1 then
  	begin
    b2:=y21-k2*x21;
  	x:=x11;
    y:=k2*x+b2;
    end
  else if h2 then
  	begin
    b1:=y11-k1*x11;
  	x:=x21;
    y:=k1*x+b1;
    end
  else
  	begin
  	b1:=y11-k1*x11;
  	b2:=y21-k2*x21;
  	x:=(b2-b1)/(k1-k2);
  	y:=k1*x+b1;
    end;

  if x11>x12 then begin t:=x11;x11:=x12;x12:=t;end;
  if x21>x22 then begin t:=x21;x21:=x22;x22:=t;end;
  if y11>y12 then begin t:=y11;y11:=y12;y12:=t;end;
  if y21>y22 then begin t:=y21;y21:=y22;y22:=t;end;
  lines_crossed:=(x>=x11)and(x<=x12)and(x>=x21)and(x<=x22)
  	and(y>=y11)and(y<=y12)and(y>=y21)and(y<=y22);
  end;
if lines_crossed then
	begin
  if rx<>nil then rx^:=round(x);
  if ry<>nil then ry^:=round(y);
  end;
end;

function point_in_triangle(x,y:longint;tr:Ptriangle):boolean;
var b:boolean;
	x1,y1,x2,y2:longint;
  ttr:Ptriangle;
begin
b:=false;
if tr<>nil then
	begin
  ttr:=triangle_copy(tr);
  sort_triangle_points_x(ttr);
  with ttr^ do
  	begin
  	x1:=p1^.x;x2:=p3^.x;
    end;
  sort_triangle_points_y(ttr);
  with ttr^ do
  	begin
    y1:=p1^.y;y2:=p3^.y;
    end;
  destroy_triangle(ttr);
  with tr^ do
  b:=((x>x1)and(x<x2)and(y>y1)and(y<y2))and
    (
  	not lines_crossed(p1^.x,p1^.y,x,y,p2^.x,p2^.y,p3^.x,p3^.y,nil,nil)
  	and not lines_crossed(p2^.x,p2^.y,x,y,p1^.x,p1^.y,p3^.x,p3^.y,nil,nil)
    and not lines_crossed(p3^.x,p3^.y,x,y,p1^.x,p1^.y,p2^.x,p2^.y,nil,nil)
    );
  end;
point_in_triangle:=b;
end;

function point_in_object(x,y:longint;obj:Pobject):boolean;
var b:boolean;
    i:longint;
begin
i:=0;
b:=false;
if obj<>nil then
while (i<max_obj_triangles)and not b do
    begin
  b:=point_in_triangle(x,y,obj^.tr[i]);
  inc(i);
  end;
point_in_object:=b;
end;

function obj_selected(p:pointer):boolean;
var i:longint;
    b:boolean;
begin
i:=0;
b:=false;
if p<>nil then
while (not b)and(i<max_kol_objects)do
    begin
  if p=sel_obj[i]then b:=true;
  inc(i);
  end;
obj_selected:=b;
end;

procedure reset_view(a:integer);
begin
view.x:=-view.w div 2;
view.y:=-view.h div 2;
end;

function get_sel_pnt_indx_by_indx(indx:integer):integer;
var i:longint;
    found:boolean;
  res:integer;
begin
res:=-1;
i:=0;
inc(indx);
found:=false;
while (i<max_pnt_selected)and not found do
    begin
  if sel_pnt[i]<>nil then dec(indx);
  if indx=0 then begin found:=true;res:=i;end;
  inc(i);
  end;
get_sel_pnt_indx_by_indx:=res;
end;

function pnt_selected(pnt:Ppoint):boolean;
var i:longint;
    b:boolean;
begin
i:=0;
b:=false;
if pnt<>nil then
while (not b)and(i<max_pnt_selected)do
    begin
  if pnt=sel_pnt[i]then b:=true;
  inc(i);
  end;
pnt_selected:=b;
end;

procedure select_all;
var i:longint;
begin
case mode of
    OBJECT_MODE:for i:=0 to max_kol_objects-1 do
    begin
    sel_obj[i]:=obj[i];
    if sel_obj[i]<>nil then ed_obj:=sel_obj[i];
    end;
  EDIT_MODE:for i:=0 to max_obj_points-1 do sel_pnt[i]:=ed_obj^.pnt[i];
  end;
end;
procedure deselect_all;
var i:longint;
begin
case mode of
  OBJECT_MODE:for i:=0 to max_kol_objects-1 do sel_obj[i]:=nil;
  EDIT_MODE:for i:=0 to max_pnt_selected-1 do sel_pnt[i]:=nil;
  end;
end;

function kol_sel_pnt:longint;
var k:longint;
begin
k:=0;
for i:=0 to max_pnt_selected-1 do if sel_pnt[i]<>nil then inc(k);
kol_sel_pnt:=k;
end;
function kol_sel_obj:longint;
var k:longint;
begin
k:=0;
for i:=0 to max_kol_objects-1 do if sel_obj[i]<>nil then inc(k);
kol_sel_obj:=k;
end;

procedure add_obj_to_sel(obj:Pobject);
var i:longint;
begin
i:=0;
if not obj_selected(obj)then
    begin
    while (sel_obj[i]<>nil)and(i<max_kol_objects)do inc(i);
    if i<max_kol_objects then sel_obj[i]:=obj;
  end;
end;

procedure add_pnt_to_sel(pnt:Ppoint);
var i:longint;
begin
i:=0;
if not pnt_selected(pnt)then
    begin
    while (sel_pnt[i]<>nil)and(i<max_pnt_selected)do inc(i);
    if i<max_pnt_selected then sel_pnt[i]:=pnt;
  end;
end;

procedure deselect_pnt(pnt:Ppoint);
var i:longint;
    b:boolean;
begin
i:=0;
b:=false;
while (i<max_pnt_selected)and not b do
    begin
  if sel_pnt[i]=pnt then b:=true;
  inc(i);
  end;
if b then sel_pnt[i-1]:=nil;
end;

procedure deselect_obj(obj:Pobject);
var i:longint;
    b:boolean;
begin
i:=0;
b:=false;
if obj<>nil then
while (i<max_kol_objects)and not b do
    begin
  if sel_obj[i]=obj then b:=true;
  inc(i);
  end;
if b then sel_obj[i-1]:=nil;
end;

procedure sel_desel(x,y:longint);
var i,j:longint;
    found:boolean;
begin
i:=0;
found:=false;
if mode=EDIT_MODE then
while (i<max_kol_objects)and not found do
    begin
  j:=0;
    if (obj[i]<>nil)and(obj[i]=ed_obj) then with obj[i]^ do
    while(j<max_obj_points)and not found do
        begin
      if (pnt[j]<>nil)and(pdist(pnt[j]^.x,pnt[j]^.y,view.x+x,view.y+y){sqrt(sqr(pnt[j]^.x-view.x-x)+sqr(pnt[j]^.y-view.y-y))}<=10) then
            begin
        if pnt_selected(pnt[j]) then deselect_pnt(pnt[j])
            else add_pnt_to_sel(pnt[j]);
        found:=true;
        end;
      inc(j);
      end;
  inc(i);
  end;

if mode=OBJECT_MODE then
while (i<max_kol_objects)and not found do
    begin
  found:=point_in_object(view.x+x,view.y+y,obj[i]);
  if found then
    if obj_selected(obj[i]) then deselect_obj(obj[i])
          else begin add_obj_to_sel(obj[i]);ed_obj:=obj[i];end;
  inc(i);
  end;
end;

procedure calc_pivot;
var i,j,sumx,sumy,k:longint;
begin
k:=0;
sumx:=0;
sumy:=0;
case mode of
    OBJECT_MODE:for j:=0 to max_kol_objects-1 do
    if obj_selected(obj[j])then
      for i:=0 to max_obj_points-1 do
            if obj[j]^.pnt[i]<>nil then
                begin
            inc(k);
            sumx:=sumx+obj[j]^.pnt[i]^.x;
            sumy:=sumy+obj[j]^.pnt[i]^.y;
            end;
  EDIT_MODE:for i:=0 to max_pnt_selected-1 do
    if sel_pnt[i]<>nil then
        begin
      inc(k);
      sumx:=sumx+sel_pnt[i]^.x;
      sumy:=sumy+sel_pnt[i]^.y;
      end;
  end;
pivot_x:=round(sumx/k);
pivot_y:=round(sumy/k);
end;

procedure rotate_point(p:Ppoint;cx,cy:longint;ang:extended);
var dist:extended;
begin
dist:=pdist(cx,cy,p^.x,p^.y);
ang:=(ang+lineangle(cx,cy,p^.x,p^.y))*pi/180;
with p^ do
	begin
  if not lock_x then x:=cx+round(cos(ang)*dist);
  if not lock_y then y:=cy+round((sin(ang))*dist);
  end;
end;

procedure scale_point(p:Ppoint;scale_koef:extended;cx,cy:longint);
begin
if not lock_x then p^.x:=p^.x+round((p^.x-cx)*(scale_koef-1));
if not lock_y then p^.y:=p^.y+round((p^.y-cy)*(scale_koef-1));
end;

procedure grab_point(p:Ppoint;dx,dy:longint);
begin
if not lock_x then p^.x:=p^.x+dx;
if not lock_y then p^.y:=p^.y+dy;
end;

procedure terminate_action;
begin
case action_type of
    GRAB_ACTION:begin
    grab_x:=0;
    grab_y:=0;
    end;
  ROTATE_ACTION:begin
    rotate_ang:=0;
    end;
  SCALE_ACTION:begin
    scale_koef:=1;
    end;
  RECT_SEL_ACTION:begin
    cursordx:=0;cursordy:=0;
    cur_cursor:=CURSOR_NORMAL;
    end;
  CIRCLE_SEL_ACTION:begin
    cursordx:=0;cursordy:=0;
    cur_cursor:=CURSOR_NORMAL;
    end;
  end;
action_type:=0;
end;

procedure apply_action;
var i,j:longint;
begin
case action_type of
    RECT_SEL_ACTION:begin
    inc(rect_selx1,view.x);
    inc(rect_selx2,view.x);
    inc(rect_sely1,view.y);
    inc(rect_sely2,view.y);
    if rect_selx1>rect_selx2 then
        begin i:=rect_selx1;rect_selx1:=rect_selx2;rect_selx2:=i;end;
    if rect_sely1>rect_sely2 then
        begin i:=rect_sely1;rect_sely1:=rect_sely2;rect_sely2:=i;end;
    case mode of
        OBJECT_MODE:for i:=0 to max_kol_objects-1 do
        if obj[i]<>nil then
            begin
          for j:=0 to max_obj_points-1 do
            if (obj[i]^.pnt[j]<>nil)and(obj[i]^.pnt[j]^.x>=rect_selx1)and(obj[i]^.pnt[j]^.x<=rect_selx2)
                and(obj[i]^.pnt[j]^.y>=rect_sely1)and(obj[i]^.pnt[j]^.y<=rect_sely2)
                then add_obj_to_sel(obj[i]);
          end;
      EDIT_MODE:with ed_obj^ do
            begin
          for j:=0 to max_obj_points-1 do
            if (pnt[j]<>nil)and(pnt[j]^.x>=rect_selx1)and(pnt[j]^.x<=rect_selx2)
                and(pnt[j]^.y>=rect_sely1)and(pnt[j]^.y<=rect_sely2)
                then add_pnt_to_sel(pnt[j]);
          end;
      end;
    cursordx:=0;cursordy:=0;
    cur_cursor:=CURSOR_NORMAL;
    end;
    GRAB_ACTION,ROTATE_ACTION,SCALE_ACTION:
    	case mode of
        OBJECT_MODE:for i:=0 to max_kol_objects-1 do
        if sel_obj[i]<>nil then
            with sel_obj[i]^ do
            begin
          for j:=0 to max_obj_points-1 do
            if pnt[j]<>nil then case action_type of
            	GRAB_ACTION:grab_point(pnt[j],grab_x,grab_y);
              ROTATE_ACTION:rotate_point(pnt[j],pivot_x,pivot_y,rotate_ang);
              SCALE_ACTION:scale_point(pnt[j],scale_koef,pivot_x,pivot_y);
              end;
          end;{obj case}
      EDIT_MODE:with ed_obj^ do
            begin
          for j:=0 to max_obj_points-1 do
            if (pnt[j]<>nil)and pnt_selected(pnt[j]) then
            	if pnt[j]<>nil then case action_type of
            	GRAB_ACTION:grab_point(pnt[j],grab_x,grab_y);
              ROTATE_ACTION:rotate_point(pnt[j],pivot_x,pivot_y,rotate_ang);
              SCALE_ACTION:scale_point(pnt[j],scale_koef,pivot_x,pivot_y);
              end;
          end;{edit case}
      end;{mode case}
  end;{action case}
terminate_action;
end;

procedure destroy_object(var obj:Pobject);
var i:integer;
begin
if obj<>nil then
 begin
 for i:=0 to max_obj_points-1 do
    begin
    dispose(obj^.pnt[i]);
  obj^.pnt[i]:=nil;
  end;
 for i:=0 to max_obj_triangles-1 do
    begin
    dispose(obj^.tr[i]);
  	obj^.tr[i]:=nil;
  	end;
 dispose(obj);
 obj:=nil;
 end;
end;

procedure destroy_all_objects;
var i:integer;
begin
for i:=0 to max_kol_objects-1 do destroy_object(obj[i]);
end;

procedure swap_pointers(var p1,p2:pointer);
var p:pointer;
begin
p:=p1;
p1:=p2;
p2:=p;
end;

procedure move_triangle(tr:Ptriangle;dx,dy:longint);
begin
tr^.p1^.x:=tr^.p1^.x+dx;
tr^.p1^.y:=tr^.p1^.y+dy;
tr^.p2^.x:=tr^.p2^.x+dx;
tr^.p2^.y:=tr^.p2^.y+dy;
tr^.p3^.x:=tr^.p3^.x+dx;
tr^.p3^.y:=tr^.p3^.y+dy;
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

procedure destroy_triangle(var tr:Ptriangle);
begin
dispose(tr^.p1);dispose(tr^.p2);dispose(tr^.p3);
dispose(tr);
tr:=nil;
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
procedure sort_triangle_points_x(tr:Ptriangle);
begin
with tr^ do
    begin
  if p1^.x>p2^.x then swap_pointers(p1,p2);
  if p2^.x>p3^.x then swap_pointers(p2,p3);
  if p1^.x>p2^.x then swap_pointers(p1,p2);
  end;
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

procedure img_draw_triangle(dtr:Ptriangle;col:longint;dr_edges,dr_normals,texture:boolean;img:pimage);
var y,x1,x2,edges_col,i:longint;
    tr:Ptriangle;
    nor:Tvec;
begin
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
      imageputpixel(img,i,y,imagegetpixel(tex,(i+view.x+getmaxx) mod getimagewidth(tex),(y+view.y+getmaxy) mod getimageheight(tex)))
    else imagelineH(img,x1,x2,y,col);
    if dr_edges then
        begin
        imageputpixel(img,x1-1,y,edges_col);
        imageputpixel(img,x2+1,y,edges_col);
      end;
    end;
  //part2
  if (p2^.y<>p3^.y)then
  for y:=p2^.y+1 to p3^.y do
    if (line_crossH(y,p2,p3,x1))and(line_crossH(y,p1,p3,x2)) then
    begin
    if x1>x2 then begin x2:=x1+x2;x1:=x2-x1;x2:=x2-x1;end;
    if (tex<>nil)and texture then
    for i:=x1 to x2 do
      imageputpixel(img,i,y,imagegetpixel(tex,(i+view.x+getmaxx) mod getimagewidth(tex),(y+view.y+getmaxy) mod getimageheight(tex)))
    else imagelineH(img,x1,x2,y,col);
    if dr_edges then
        begin
        imageputpixel(img,x1-1,y,edges_col);
        imageputpixel(img,x2+1,y,edges_col);
      end;
    end;
  //normals
{  if dr_normals then
  begin
  nor:=vec_mul(vec_unit(vec_norm(vec_new(p1^.x,p1^.y,p2^.x,p2^.y))),25);
  vec_draw(img,nor,(p1^.x+p2^.x)div 2,(p1^.y+p2^.y)div 2,rgbcolorrgb(200,200,100));
  nor:=vec_mul(vec_unit(vec_norm(vec_new(p1^.x,p1^.y,p3^.x,p3^.y))),25);
  vec_draw(img,nor,(p1^.x+p3^.x)div 2,(p1^.y+p3^.y)div 2,rgbcolorrgb(200,200,100));
  nor:=vec_mul(vec_unit(vec_norm(vec_new(p2^.x,p2^.y,p3^.x,p3^.y))),25);
  vec_draw(img,nor,(p2^.x+p3^.x)div 2,(p2^.y+p3^.y)div 2,rgbcolorrgb(200,200,100));
  end;}
  //
  end;
destroy_triangle(tr);
end;

procedure img_draw_object(obj:Pobject;tar:char;dx,dy,gx,gy:longint;ang,scale:extended;img:pimage);
var i,col:longint;
    b,b1,b2,b3,dr_pnt:boolean;
    tr:Ptriangle;
    npnt:Ppoint;
begin
b:=obj_selected(obj);
dr_pnt:=(tar='V')and(obj=ed_obj)and(mode=EDIT_MODE);
case tar of
	'V':if b then col:=rgbcolorrgb(220,220,220)else col:=rgbcolorrgb(180,180,180);
  'M':col:=rgbcolorrgb(255,255,255);
  end;


for i:=0 to max_obj_triangles-1 do
    if obj^.tr[i]<>nil then
    begin
    tr:=triangle_copy(obj^.tr[i]);
    b1:=pnt_selected(obj^.tr[i]^.p1);
    if b1 or ((mode=OBJECT_MODE)and b)then
        begin
      grab_point(tr^.p1,gx,gy);
      rotate_point(tr^.p1,pivot_x,pivot_y,ang);
      scale_point(tr^.p1,scale,pivot_x,pivot_y);
      end;
    b2:=pnt_selected(obj^.tr[i]^.p2);
    if b2 or ((mode=OBJECT_MODE)and b) then
        begin
      grab_point(tr^.p2,gx,gy);
      rotate_point(tr^.p2,pivot_x,pivot_y,ang);
      scale_point(tr^.p2,scale,pivot_x,pivot_y);
      end;
    b3:=pnt_selected(obj^.tr[i]^.p3);
    if b3 or ((mode=OBJECT_MODE)and b) then
        begin
      grab_point(tr^.p3,gx,gy);
      rotate_point(tr^.p3,pivot_x,pivot_y,ang);
      scale_point(tr^.p3,scale,pivot_x,pivot_y);
      end;
    move_triangle(tr,dx,dy);
    img_draw_triangle(tr,col,b and (tar='V'),((tar='V')and not view_textured),(tar='A')or((tar='V')and view_textured),img);
    destroy_triangle(tr);
    end;

if dr_pnt then
for i:=0 to max_obj_points-1 do
    if obj^.pnt[i]<>nil then
  begin
  b:=pnt_selected(obj^.pnt[i]);
    new(npnt);
  npnt^:=obj^.pnt[i]^;
  if b then col:=rgbcolorrgb(255,255,0) else col:=rgbcolorrgb(255,0,255);
  if b then
    begin
    grab_point(npnt,gx,gy);
    rotate_point(npnt,pivot_x,pivot_y,ang);
    scale_point(npnt,scale,pivot_x,pivot_y);
    end;
  with npnt^ do imagerectangle(img,x-1-view.x,y-1-view.y,x+1-view.x,y+1-view.y,col);
  dispose(npnt);
  end;
end;

function get_first_obj_pnt_nil(obj:Pobject):longint;
var i:longint;
begin
i:=0;
while(obj^.pnt[i]<>nil)and(i<max_obj_points)do inc(i);
if i<max_obj_points then get_first_obj_pnt_nil:=i
    else get_first_obj_pnt_nil:=-1;
end;

function get_first_obj_nil:longint;
var i:longint;
begin
i:=0;
while(obj[i]<>nil)and(i<max_kol_objects)do inc(i);
if i<max_kol_objects then get_first_obj_nil:=i
    else get_first_obj_nil:=-1;
end;

function get_first_obj_tr_nil(obj:Pobject):longint;
var i:longint;
begin
i:=0;
while(obj^.tr[i]<>nil)and(i<max_obj_triangles)do inc(i);
if i<max_obj_triangles then get_first_obj_tr_nil:=i
    else get_first_obj_tr_nil:=-1;
end;

function obj_add_point(obj:Pobject;x0,y0:longint):Ppoint;
var i:longint;
begin
i:=get_first_obj_pnt_nil(obj);
new(obj^.pnt[i]);
with obj^.pnt[i]^ do begin x:=x0;y:=y0;end;
obj_add_point:=obj^.pnt[i];
end;

function obj_set_triangle(obj:Pobject;indx:longint;i1,i2,i3:Ppoint):Ptriangle;
begin
new(obj^.tr[indx]);
with obj^.tr[indx]^ do
	begin
  p1:=i1;
  p2:=i2;
  p3:=i3;
  tex:=testtex;
  end;
obj_set_triangle:=obj^.tr[indx];
end;

function get_point_by_coords(obj:Pobject;x,y:longint):Ppoint;
var i:longint;
    b:boolean;
begin
b:=false;
i:=0;
while (i<max_obj_points)and not b do
    begin
  b:=(obj^.pnt[i]^.x=x)and(obj^.pnt[i]^.y=y);
  if b then get_point_by_coords:=obj^.pnt[i];
  inc(i);
  end;
if not b then get_point_by_coords:=nil;
end;

procedure delete_selected;
var i,j:longint;
begin
case mode of
	OBJECT_MODE:for i:=0 to max_kol_objects-1 do
    if (obj[i]<>nil)and(obj_selected(obj[i])) then
    begin
    deselect_obj(obj[i]);
    destroy_object(obj[i]);
    end;
  EDIT_MODE:for i:=0 to max_obj_points-1 do
  	if (ed_obj^.pnt[i]<>nil)and(pnt_selected(ed_obj^.pnt[i]))then
    	begin
      for j:=0 to max_obj_triangles-1 do
        if (ed_obj^.tr[j]<>nil)and((ed_obj^.pnt[i]=ed_obj^.tr[j]^.p1)or(ed_obj^.pnt[i]=ed_obj^.tr[j]^.p2)or(ed_obj^.pnt[i]=ed_obj^.tr[j]^.p3))then
        	begin
          dispose(ed_obj^.tr[j]);
          ed_obj^.tr[j]:=nil;
          end;
      dispose(ed_obj^.pnt[i]);
      ed_obj^.pnt[i]:=nil;
      end;
  end;
end;

function new_object(objtype:integer):Pobject;
var p:Pobject;
    indx,i,segm:longint;
  p1,p2,p3,p4:Ppoint;
begin
indx:=get_first_obj_nil;
if indx<>-1 then
    begin
    new(obj[indx]);
  for i:=0 to max_obj_points-1 do obj[indx]^.pnt[i]:=nil;
  for i:=0 to max_obj_triangles-1 do obj[indx]^.tr[i]:=nil;
  case objtype of
    -1:;//empty object
    1:begin
    	p1:=obj_add_point(obj[indx],0,25);
    	p2:=obj_add_point(obj[indx],-25,-25);
    	p3:=obj_add_point(obj[indx],25,-25);
      move_triangle(obj_set_triangle(obj[indx],get_first_obj_tr_nil(obj[indx]),p1,p2,p3),pivot_x,pivot_y);
      end;{triangle}
    2:begin
    	p1:=obj_add_point(obj[indx],-25+pivot_x,-25+pivot_y);
      p2:=obj_add_point(obj[indx],25+pivot_x,-25+pivot_y);
      p3:=obj_add_point(obj[indx],-25+pivot_x,25+pivot_y);
      p4:=obj_add_point(obj[indx],25+pivot_x,25+pivot_y);
      obj_set_triangle(obj[indx],get_first_obj_tr_nil(obj[indx]),p1,p2,p3);
      obj_set_triangle(obj[indx],get_first_obj_tr_nil(obj[indx]),p2,p3,p4);
      end;{square}
    3:begin
    	segm:=30;
      p1:=obj_add_point(obj[indx],pivot_x,pivot_y);
    	p2:=obj_add_point(obj[indx],-25+pivot_x,pivot_y);
      p4:=p2;
        for i:=1 to segm-1 do
        begin
        p3:=obj_add_point(obj[indx],-25+pivot_x,pivot_y);
        rotate_point(p3,pivot_x,pivot_y,(360/segm)*(i));
        obj_set_triangle(obj[indx],get_first_obj_tr_nil(obj[indx]),p1,p2,p3);
        p2:=p3;
        end;
      obj_set_triangle(obj[indx],get_first_obj_tr_nil(obj[indx]),p1,p2,p4);
      end;{circle}
    else begin dispose(obj[indx]);obj[indx]:=nil;end;
    end;
  new_object:=obj[indx];
  end
else new_object:=nil;
end;

function get_kol_obj:longint;
var k,i:longint;
begin
k:=0;
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then inc(k);
get_kol_obj:=k;
end;

function get_kol_pnt:longint;
var k,i,j:longint;
begin
k:=0;
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then
    for j:=0 to max_obj_points-1 do if obj[i]^.pnt[j]<>nil then inc(k);
get_kol_pnt:=k;
end;

function get_kol_tr:longint;
var k,i,j:longint;
begin
k:=0;
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then
    for j:=0 to max_obj_triangles-1 do if obj[i]^.tr[j]<>nil then inc(k);
get_kol_tr:=k;
end;

procedure start_grab;
begin
if (((kol_sel_pnt>0) and (mode=EDIT_MODE))or((kol_sel_obj>0) and (mode=OBJECT_MODE))) then
    begin
  action_type:=GRAB_ACTION;
  grab_x:=0;
  grab_y:=0;
  grab_sx:=mx;
  grab_sy:=my;
  end;
end;

procedure start_scale;
begin
if (((kol_sel_pnt>0) and (mode=EDIT_MODE))or((kol_sel_obj>0) and (mode=OBJECT_MODE))) then
    begin
  action_type:=SCALE_ACTION;
  scale_koef:=1;
  scale_sx:=mx;
  scale_sy:=my;
  if autopivot then calc_pivot;
  end;
end;

procedure start_rotate;
begin
if (((kol_sel_pnt>0) and (mode=EDIT_MODE))or((kol_sel_obj>0) and (mode=OBJECT_MODE))) then
    begin
  action_type:=ROTATE_ACTION;
  rotate_ang:=0;
  rotate_sx:=mx;
  rotate_sy:=my;
  if autopivot then calc_pivot;
  end;
end;

procedure start_rect_selection;
begin
action_type:=RECT_SEL_ACTION;
cur_cursor:=CURSOR_CREST;
rect_sel:=0;
cursordx:=-getimagewidth(cursor[cur_cursor])div 2;
cursordy:=-getimageheight(cursor[cur_cursor])div 2;
end;

procedure start_circle_selection;
begin
action_type:=CIRCLE_SEL_ACTION;
cur_cursor:=CURSOR_CIRCLE;
cursordx:=-getimagewidth(cursor[cur_cursor])div 2;
cursordy:=-getimageheight(cursor[cur_cursor])div 2;
end;

procedure bt_create_object(objt:integer);
begin
if (action_type=0)and(mode=OBJECT_MODE) then
    begin
  deselect_all;
  ed_obj:=new_object(objt);
  if ed_obj<>nil then
    begin
    add_obj_to_sel(ed_obj);
    mode:=EDIT_MODE;
    select_all;
    end;
  end;
end;

procedure bt_set_triangle(a:integer);
var p1,p2,p3:Ppoint;
begin
if (mode=EDIT_MODE)and(kol_sel_pnt=3)and(ed_obj<>nil)then
    begin
  p1:=sel_pnt[get_sel_pnt_indx_by_indx(0)];
  p2:=sel_pnt[get_sel_pnt_indx_by_indx(1)];
  p3:=sel_pnt[get_sel_pnt_indx_by_indx(2)];
  obj_set_triangle(ed_obj,get_first_obj_tr_nil(ed_obj),p1,p2,p3);
  end;
end;

procedure bt_main_quit(a:integer);
begin
main_quit;
end;

procedure bt_build_triangle(a:integer);
var i:longint;
    p1,p2,p3:Ppoint;
begin
if (mode=EDIT_MODE)and(kol_sel_pnt=2)then
    begin
  p1:=sel_pnt[get_sel_pnt_indx_by_indx(0)];
  p2:=sel_pnt[get_sel_pnt_indx_by_indx(1)];
  p3:=obj_add_point(ed_obj,(p1^.x+p2^.x)div 2,(p1^.y+p2^.y)div 2);
  deselect_all;
  add_pnt_to_sel(p3);
  obj_set_triangle(ed_obj,get_first_obj_tr_nil(ed_obj),p1,p2,p3);
  start_grab;
  end;
end;

procedure bt_build_rectangle(a:integer);
var i:longint;
    p1,p2,p3,p4:Ppoint;
begin
if (mode=EDIT_MODE)and(kol_sel_pnt=2)then
    begin
  p1:=sel_pnt[get_sel_pnt_indx_by_indx(0)];
  p2:=sel_pnt[get_sel_pnt_indx_by_indx(1)];
  p3:=obj_add_point(ed_obj,p1^.x,p1^.y);
  p4:=obj_add_point(ed_obj,p2^.x,p2^.y);
  deselect_all;
  add_pnt_to_sel(p3);
  add_pnt_to_sel(p4);
  obj_set_triangle(ed_obj,get_first_obj_tr_nil(ed_obj),p1,p2,p3);
  obj_set_triangle(ed_obj,get_first_obj_tr_nil(ed_obj),p2,p3,p4);
  start_grab;
  end;
end;

procedure bt_lock_x;
begin
lock_x:=not lock_x;
if lock_x then lock_y:=false;
end;

procedure bt_lock_y;
begin
lock_y:=not lock_y;
if lock_y then lock_x:=false;
end;

procedure createscreenimg(screenimg:pimage;x0,y0:longint;tar:char;dr_mouse:boolean);
var i,j,dx,dy:longint;
	s:ansistring;
  b:boolean;
{tar:
	V:view mode, draw all
  A:draw all
  B:only background
  M:draw object mask}
begin
//DRAW BACKGROUND
case tar of
'V':if view_textured then
	begin
	for i:=-1 to getmaxx div getimagewidth(mainbgtex)+1 do
  for j:=-1 to getmaxy div getimageheight(mainbgtex)+1 do
  	composeimage(screenimg,mainbgtex,i*getimagewidth(mainbgtex)-round(view.x*bg_dist),
    		j*getimageheight(mainbgtex)-round(view.y*bg_dist));
  end else fillimage(screenimg,rgbcolorrgb(80,80,80));
'A','B':for i:=0 to getimagewidth(screenimg)div getimagewidth(mainbgtex)+1 do
	 for j:=0 to getimageheight(screenimg)div getimageheight(mainbgtex)+1 do
   	composeimage(screenimg,mainbgtex,i*getimagewidth(mainbgtex),j*getimageheight(mainbgtex));
'M':fillimage(screenimg,rgbcolorrgb(0,0,0));
end;
//DRAW GRID
if tar='V'then
	begin
	imagelineV(screenimg,-view.x,0,getmaxy,rgbcolorrgb(10,150,10));
	imagelineH(screenimg,0,getmaxx,-view.y,rgbcolorrgb(10,10,150));
	imagerectangle(screenimg,mainx1-view.x,mainy1-view.y,mainx2-view.x,mainy2-view.y,rgbcolorrgb(200,100,100));
  end;
//DRAW OBJECTS
dx:=-x0;
dy:=-y0;
if tar<>'B' then
for i:=0 to max_kol_objects-1 do if (obj[i]<>nil) then
  img_draw_object(obj[i],tar,dx,dy,grab_x,grab_y,rotate_ang,scale_koef,screenimg);
//BALLS
if tar='V' then
for i:=0 to max_balls-1 do draw_ball(screenimg,ball[i],x0,y0);
//DRAW PIVOT
if tar='V' then
	begin
	imagebar(screenimg,pivot_x-1-view.x,pivot_y-1-view.y,pivot_x+1-view.x,pivot_y+1-view.y,rgbcolorrgb(255,0,0));
	imagelineH(screenimg,pivot_x-4-view.x,pivot_x+4-view.x,pivot_y-view.y,rgbcolorrgb(255,0,0));
	imagelineV(screenimg,pivot_x-view.x,pivot_y-4-view.y,pivot_y+4-view.y,rgbcolorrgb(255,0,0));
  end;
//DRAW HEADER
if tar='V'then
begin
imagelineH(screenimg,1,getmaxx-1,header_y+3,rgbcolorrgb(110,110,110));
imagelineH(screenimg,1,getmaxx-1,header_y+2,main_frame_color);
imagelineH(screenimg,1,getmaxx-1,header_y+1,main_shad_color);
imagebar(screenimg,0,0,getmaxx-1,header_y,main_back_color);
s:='Points '+to_str(kol_sel_pnt)+'/'+to_str(get_kol_pnt)+'  '
    +'Triangles '{+to_str(kol_sel_tr)+'/'}+to_str(get_kol_tr)+'  '
  +'Objects '+to_str(kol_sel_obj)+'/'+to_str(get_kol_obj);
font.outtext(getmaxx-10-font.textlength(s),10-font.textheight(s)div 2,s,rgbcolorrgb(35,35,35));
case mode of
    OBJECT_MODE:s:='Object mode';
    EDIT_MODE:s:='Edit mode';
  else s:='Error: unknown mode';
  end;
font.outtext(getmaxx div 2-font.textlength(s)div 2,10-font.textheight(s)div 2,s,rgbcolorrgb(35,35,35));
end;
//DRAW TOOLS
if tar='V'then
begin
imagelineH(screenimg,1,getmaxx-1,getmaxy-toolbar_y-3,rgbcolorrgb(60,60,60));
imagelineH(screenimg,1,getmaxx-1,getmaxy-toolbar_y-2,main_frame_color);
imagelineH(screenimg,1,getmaxx-1,getmaxy-toolbar_y-1,main_spec_color);
imagebar(screenimg,1,getmaxy-toolbar_y,getmaxx-1,getmaxy,main_back_color);
if action_type=0 then
    begin
    if in_viewport(my)then
        s:=to_str(view.x+mx)+', '+to_str(view.y+my)
    else
        begin
        for i:=0 to max_kol_buttons-1 do
    if (bt[i]<>nil)and(inbutton(bt[i],mx,my))then
        s:=bt[i]^.tooltip;
    end;
  end
else
    case action_type of
        GRAB_ACTION:s:='Grabing: '+to_str(grab_x)+', '+to_str(grab_y);
    ROTATE_ACTION:s:='Rotating: '+to_str(trunc(rotate_ang))+'.'+to_str(trunc((rotate_ang-trunc(rotate_ang))*1000));
    SCALE_ACTION:s:='Scaling: '+to_str(trunc(scale_koef))+'.'+to_str(trunc((scale_koef-trunc(scale_koef))*1000));
    end;
font.outtext(getmaxx div 2-font.textlength(s)div 2,getmaxy-toolbar_y div 2-font.textheight(s)div 2,s,rgbcolorrgb(35,35,35));
end;
//DRAW BUTTONS
if tar='V'then
for i:=0 to max_kol_buttons-1 do if bt[i]<>nil then draw_button(bt[i]);
//DRAW ACTIONS
if tar='V'then
case action_type of
    ROTATE_ACTION:begin
    imageline(screenimg,pivot_x-view.x,pivot_y-view.y,mx,my,rgbcolorrgb(128,128,128));
    imageline(screenimg,pivot_x-view.x,pivot_y-view.y,rotate_sx,rotate_sy,rgbcolorrgb(128,128,128));
    end;
  RECT_SEL_ACTION:if rect_sel<>0 then
    begin
    imagelineH(screenimg,rect_selx1,rect_selx2,rect_sely1,rgbcolorrgb(15,15,15));
    imagelineH(screenimg,rect_selx1,rect_selx2,rect_sely2,rgbcolorrgb(15,15,15));
    imagelineV(screenimg,rect_selx1,rect_sely1,rect_sely2,rgbcolorrgb(15,15,15));
    imagelineV(screenimg,rect_selx2,rect_sely1,rect_sely2,rgbcolorrgb(15,15,15));
    end;
  end;
//DRAW CURSOR
if dr_mouse then
composeimagec(screenimg,cursor[cur_cursor],mx+cursordx,my+cursordy);
//
end;

procedure actions;
begin
case action_type of
    GRAB_ACTION:begin
    grab_x:=mx-grab_sx;
    grab_y:=my-grab_sy;
    if edit_by_step then
        begin
      grab_x:=grab_x-grab_x mod 10;
      grab_y:=grab_y-grab_y mod 10;
      end;
    end;
  ROTATE_ACTION:begin
    rotate_ang:=lineangle(view.x+mx,view.y+my,pivot_x,pivot_y)-lineangle(view.x+rotate_sx,view.y+rotate_sy,pivot_x,pivot_y);
    if edit_by_step then rotate_ang:=trunc(rotate_ang-trunc(rotate_ang)mod 5);
    end;
  SCALE_ACTION:begin
    scale_koef:=sqrt(sqr(mx-pivot_x+view.x)+sqr(my-pivot_y+view.y))/sqrt(sqr(scale_sx-pivot_x+view.x)+sqr(scale_sy-pivot_y+view.y));
    if edit_by_step then
        begin
      scale_koef:=trunc(scale_koef*5)/5;
      end;
    end;
  RECT_SEL_ACTION:begin
    rect_selx2:=mx;
    rect_sely2:=my;
    end;
  end;
end;

procedure mouse;
var i,j:longint;
begin
if in_viewport(my)then
case mb of
    4:if (action_type=0)and(not view_scroll) then
        begin
      cur_cursor:=CURSOR_HAND;
      view_scroll:=true;
      view_scroll_sx:=mx;
        view_scroll_sy:=my;
      end else
    if action_type=CIRCLE_SEL_ACTION then
    case mode of
        OBJECT_MODE:for i:=0 to max_kol_objects-1 do
        if obj[i]<>nil then
            begin
          for j:=0 to max_obj_points-1 do
            if (obj[i]^.pnt[j]<>nil)and(pdist(mx+view.x,my+view.y,obj[i]^.pnt[j]^.x,obj[i]^.pnt[j]^.y)<=getimagewidth(cursor[cur_cursor])div 2)
              then deselect_obj(obj[i]);
          end;
      EDIT_MODE:with ed_obj^ do
            begin
          for j:=0 to max_obj_points-1 do
            if (pnt[j]<>nil)and(pdist(mx+view.x,my+view.y,pnt[j]^.x,pnt[j]^.y)<=getimagewidth(cursor[cur_cursor])div 2)
              then deselect_pnt(pnt[j]);
          end;
      end;
  1:if action_type=CIRCLE_SEL_ACTION then
    case mode of
        OBJECT_MODE:for i:=0 to max_kol_objects-1 do
        if obj[i]<>nil then
            begin
          for j:=0 to max_obj_points-1 do
            if (obj[i]^.pnt[j]<>nil)and(pdist(mx+view.x,my+view.y,obj[i]^.pnt[j]^.x,obj[i]^.pnt[j]^.y)<=getimagewidth(cursor[cur_cursor])div 2)
              then add_obj_to_sel(obj[i]);
          end;
      EDIT_MODE:with ed_obj^ do
            begin
          for j:=0 to max_obj_points-1 do
            if (pnt[j]<>nil)and(pdist(mx+view.x,my+view.y,pnt[j]^.x,pnt[j]^.y)<=getimagewidth(cursor[cur_cursor])div 2)
              then add_pnt_to_sel(pnt[j]);
          end;
      end
    else
        if action_type=0 then
        begin
      pivot_x:=mx+view.x;
      pivot_y:=my+view.y;
      end;
  0:begin
    if (view_scroll)and(action_type=0) then
        begin
      cur_cursor:=CURSOR_NORMAL;
      view_scroll:=false;
      end;
    if prevmb=2 then
        if action_type=0 then
        begin
        if not keypressed then deselect_all;
        sel_desel(mx,my);
        end
      else terminate_action;
    if prevmb=1 then
        case action_type of
            GRAB_ACTION,ROTATE_ACTION,SCALE_ACTION:apply_action;
        RECT_SEL_ACTION:case rect_sel of
            0:begin
            rect_selx1:=mx;
            rect_sely1:=my;
            rect_sel:=1;
            end;
          1:apply_action;
          end;
        end;
        end;
    end;
end;

procedure keyboard;
begin
key_pressed:=keypressed;
if (key_pressed) then key:=readkey;
if key_pressed then
case key of
	'p':autopivot:=not autopivot;
  'd':edit_by_step:=not edit_by_step;
  'x':bt_lock_x;
  'y':bt_lock_y;
  'z':view_textured:=not view_textured;
  'h':reset_view(0);
  'g':if action_type=0 then start_grab;
  's':if action_type=0 then start_scale;
  'r':if action_type=0 then start_rotate;
  'b':if action_type=0 then start_rect_selection else
    if action_type=RECT_SEL_ACTION then
        begin
      terminate_action;
      start_circle_selection;
      end else
    if action_type=CIRCLE_SEL_ACTION then terminate_action;
  'q':main_quit;
  #59{F1}:bt_help;
  #60{F2}:save_file(0);
  #61{F3}:load_file(0);
  #62{F4}:load_file(1);
  #63{F5}:time_paused:=not time_paused;
  #67{F9}:render;
  #83{DEL}:delete_selected;
  #27{ESC}:if action_type<>0 then terminate_action;
  end;
if key_pressed then
case mode of
    OBJECT_MODE:
    case key of
    #9:if (action_type=0)and(ed_obj<>nil) then mode:=EDIT_MODE;
    'a':if (action_type=0)then if(kol_sel_obj=0) then select_all else deselect_all;
    end;
  EDIT_MODE:
  case key of
    #32:if (action_type=0) then add_pnt_to_sel(obj_add_point(ed_obj,mx+view.x,my+view.y));
    #9{TAB}:if action_type=0 then
            begin
            deselect_all;
            mode:=OBJECT_MODE;
        end;
    't':bt_build_triangle(0);
    'R':bt_build_rectangle(0);
    'f':bt_set_triangle(0);
    'a':if (action_type=0)then if(kol_sel_pnt=0) then select_all else deselect_all;
    end;
  end;
end;

procedure main;
var i,j,dx,dy:longint;
begin
g_timer_start(main_timer);
mousecoords(mx,my);
mb:=mousebutton;
keyboard;
mouse;
if view_scroll then
	begin
  view.x:=view.x+view_scroll_sx-mx;
  view.y:=view.y+view_scroll_sy-my;
  view_scroll_sx:=mx;
  view_scroll_sy:=my;
  end;
actions;
for i:=0 to max_kol_buttons-1 do if bt[i]<>nil then update_button(bt[i],prevmb,mb,mx,my);
createscreenimg(screenimg,view.x,view.y,'V',true);
putimage(0,0,screenimg);
prevmb:=mb;
key_pressed:=false;
if not time_paused then
for i:=0 to max_balls-1 do update_ball(ball[i],g_timer_elapsed(main_timer,nil));
g_timer_reset(main_timer);
g_timer_stop(main_timer);
end;

procedure reset_actions;
begin
for i:=1 to 3 do begin action_type:=i;terminate_action;end;
action_type:=0;
end;

procedure clear_selection;
begin
for i:=0 to max_kol_objects-1 do sel_obj[i]:=nil;
for i:=0 to max_pnt_selected-1 do sel_pnt[i]:=nil;
end;

procedure prepare_new_workplace(a:integer);
begin
reset_actions;
mode:=OBJECT_MODE;
destroy_all_objects;
clear_selection;
ed_obj:=nil;
end;

begin
main_timer:=g_timer_new();
bg_dist:=0.1;
gacc:=9.8;
time_paused:=true;
view_scroll:=false;
main_end:=false;
autopivot:=true;
view_textured:=false;
cur_cursor:=CURSOR_NORMAL;
for i:=0 to max_kol_buttons-1 do bt[i]:=nil;
for i:=0 to max_balls-1 do ball[i]:=nil;
prepare_new_workplace(0);
initgraphix(ig_vesa,ig_lfb);
setmodegraphix(graphresx,graphresy,ig_col32);
initmouse;
disablemouse;

i:=get_first_ball_nil_indx;
last_created_ball:=ball[get_first_ball_nil_indx];
last_created_ball:=new_ball;
ball[i]:=last_created_ball;
with last_created_ball^ do
	begin
	activate_all_forces;
	loadimagefile(itdetect,'gfx\balls\ball.gif',img,0);
	loadimagefile(itdetect,'gfx\balls\ball.gif',imgmask,2);
	mass:=25;
  r:=getimagewidth(img)/2;
  calc_inertia_moment;
	end;

mainx1:=-getmaxx div 2;
mainy1:=-getmaxy div 2;
mainx2:=getmaxx div 2;
mainy2:=getmaxy div 2;

main_back_color:=rgbcolorrgb(150,150,150);
main_spec_color:=rgbcolorrgb(200,200,200);
main_shad_color:=rgbcolorrgb(90,90,90);
main_frame_color:=rgbcolorrgb(25,25,25);

header_y:=35;
toolbar_y:=35;
std_bt_size:=toolbar_y-6;
view.w:=getmaxx;
view.h:=getmaxy-header_y-6-toolbar_y;
reset_view(0);

loadimagefile(itdetect,'gfx\brick1.gif',testtex,0);
loadimagefile(itdetect,'gfx\cloud.gif',mainbgtex,0);

cursordx:=0;
cursordy:=0;
loadimagefile(itdetect,'gfx\cursors\normal.gif',cursor[CURSOR_NORMAL],0);
loadimagefile(itdetect,'gfx\cursors\hand.gif',cursor[CURSOR_HAND],0);
loadimagefile(itdetect,'gfx\cursors\crest.gif',cursor[CURSOR_CREST],0);
loadimagefile(itdetect,'gfx\cursors\circle.gif',cursor[CURSOR_CIRCLE],0);
clearscreen(rgbcolorrgb(0,0,0));
screenimg:=createimageWH(graphresx,graphresy);
font.loadfont('fonts\fontvga.fnt');
font.setimage(screenimg);
//
i:=0;
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\triang.gif',std_bt_size,std_bt_size,'2020','Create Triangle',screenimg);
bt_setpos(bt[i],5,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@bt_create_object;
bt[i]^.act_prm[BTA_CLICK]:=1;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\square.gif',std_bt_size,std_bt_size,'0000','Create Square',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@bt_create_object;
bt[i]^.act_prm[BTA_CLICK]:=2;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\circle.gif',std_bt_size,std_bt_size,'0202','Create Circle',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@bt_create_object;
bt[i]^.act_prm[BTA_CLICK]:=3;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\triang_fill.gif',std_bt_size,std_bt_size,'2020','Fill Triangle (f)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@bt_set_triangle;
bt[i]^.act_prm[BTA_CLICK]:=0;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\build_triang.gif',std_bt_size,std_bt_size,'0000','Build edge to triangle (t)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@bt_build_triangle;
bt[i]^.act_prm[BTA_CLICK]:=0;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\build_rect.gif',std_bt_size,std_bt_size,'0202','Build edge to rectangle (R)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@bt_build_rectangle;
bt[i]^.act_prm[BTA_CLICK]:=0;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\reset_view.gif',std_bt_size,std_bt_size,'2222','Reset view (h)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@reset_view;
bt[i]^.act_prm[BTA_CLICK]:=0;
//
inc(i);
bt[i]:=bt_new(BTT_TOGGLE,'gfx\buttons\pivot.gif',std_bt_size,std_bt_size,'2222','Auto calc pivot (p)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.var_toggle:=@autopivot;
//
inc(i);
bt[i]:=bt_new(BTT_TOGGLE,'gfx\buttons\ed_by_step.gif',std_bt_size,std_bt_size,'2222','Editing by step (d)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.var_toggle:=@edit_by_step;
//
inc(i);
bt[i]:=bt_new(BTT_TOGGLE,'gfx\buttons\lock_x.gif',std_bt_size,std_bt_size,'2020','Lock X (x)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.var_toggle:=@lock_x;
//
inc(i);
bt[i]:=bt_new(BTT_TOGGLE,'gfx\buttons\lock_y.gif',std_bt_size,std_bt_size,'0202','Lock Y (y)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.var_toggle:=@lock_y;
//
inc(i);
bt[i]:=bt_new(BTT_TOGGLE,'gfx\buttons\textured.gif',std_bt_size,std_bt_size,'2222','Textured view (z)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.var_toggle:=@view_textured;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\new.gif',std_bt_size*3,std_bt_size,'2222','Create new project',screenimg);
bt_setpos(bt[i],10,header_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@prepare_new_workplace;
bt[i]^.act_prm[BTA_CLICK]:=0;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\save.gif',std_bt_size*3,std_bt_size,'2222','Save file (F2)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,header_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@save_file;
bt[i]^.act_prm[BTA_CLICK]:=0;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\load.gif',std_bt_size*3,std_bt_size,'2222','Load file (F3)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,header_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@load_file;
bt[i]^.act_prm[BTA_CLICK]:=0;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\merge.gif',std_bt_size*3,std_bt_size,'2222','Merge with file (F4)',screenimg);
bt_setpos(bt[i],bt[i-1]^.x+bt[i-1]^.w+10,header_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@load_file;
bt[i]^.act_prm[BTA_CLICK]:=1;
//
inc(i);
bt[i]:=bt_new(BTT_REGULAR,'gfx\buttons\exit.gif',std_bt_size*3,std_bt_size,'2222','Quit program (q)',screenimg);
bt_setpos(bt[i],getmaxx-bt[i]^.w-10,getmaxy-toolbar_y div 2-bt[i]^.h div 2);
bt[i]^.act[BTA_CLICK]:=@bt_main_quit;
bt[i]^.act_prm[BTA_CLICK]:=0;
//

repeat main until main_end;

destroyimage(screenimg);
donegraphix;
end.
