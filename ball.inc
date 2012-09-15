const
KOEF=1;
pixel_in_meter=100;
friction_koef=0.1;
max_forces=10;
FORCE_RESULT=0;
FORCE_GRAVITY=1;
FORCE_PROP_REACTION=2;
FORCE_FRICTION=3;
FORCE_ENVRESIST=4;
FORCE_ELASTIC=5;
all_forces_set=[1..5];

type
byte_set=set of byte;

Tball=object
	mass,r,rot,rot_vel,rot_acc,inertia_moment:double;
  pos,vel:Tvec;
  force:array[0..max_forces-1]of Tvec;
  active_forces:byte_set;
  img,imgmask:pimage;
  procedure initialize;
  function calc_result_force:Tvec;
  procedure activate_all_forces;
  procedure calc_inertia_moment;
  end;
Pball=^Tball;

function Tball.calc_result_force:Tvec;
var i,k:integer;
	res:Tvec;
begin
res:=vec_null;
k:=0;
for i:=1 to max_forces-1 do
  if not vec_eq(force[i],vec_null) then
  	begin
		res:=vec_sum(res,force[i]);
    inc(k);
    end;
if k<>0 then res:=vec_div(res,k)else res:=vec_null;
calc_result_force:=res;
end;

procedure Tball.calc_inertia_moment;
begin
inertia_moment:=mass*sqr(r/pixel_in_meter)/2;
end;

procedure Tball.initialize;
var i:integer;
begin
pos:=vec_null;
mass:=0;r:=0;
rot:=0;rot_vel:=0;rot_acc:=0;
for i:=0 to max_forces-1 do force[i]:=vec_null;
vel:=vec_null;
img:=nil;
imgmask:=nil;
active_forces:=[];
end;

procedure Tball.activate_all_forces;
begin
active_forces:=all_forces_set;
end;

function new_ball:Pball;
begin
new(new_ball);
new_ball^.initialize;
end;

procedure destroy_ball(var ball:Pball);
begin
destroyimage(ball^.img);
destroyimage(ball^.imgmask);
dispose(ball);
ball:=nil;
end;

procedure draw_ball(dimg:pimage;ball:Pball;x0,y0:longint);
var i:longint;
	timg:pimage;
begin
if ball<>nil then
with ball^ do
	begin
  timg:=cloneimage(img);
  rotateimage(timg,img,getimagewidth(timg)div 2,getimageheight(timg)div 2,getimagewidth(timg)div 2,getimageheight(timg)div 2,
  	getimagewidth(timg),getimageheight(timg),round(65536*((rot*180/pi)/360)));
	put_image_wmask(dimg,timg,imgmask,round(pos.x)-x0-getimagewidth(img)div 2,round(pos.y)-y0-getimageheight(img)div 2);
  destroyimage(timg);
//  vec_draw(dimg,force[FORCE_RESULT],round(pos.x)-view.x,round(pos.y)-view.y,rgbcolorrgb(250,250,50));
//  vec_draw(dimg,vec_mul(vel,pixel_in_meter),round(pos.x)-view.x,round(pos.y)-view.y,rgbcolorrgb(50,250,50));
  end;
end;

function dist_point_line(x0,y0,x1,y1,x2,y2:double):double;
var vec:Tvec;
begin
vec:=vec_new(x1,y1,x2,y2);
vec:=vec_norm(vec);
dist_point_line:=abs(vec.x*x1+vec.y*y0-vec.x*x1-vec.y*y1)/vec_len(vec);
end;

function get_ball_cross(ball:Pball;var barrier,prop:Tvec;dtime:double;x,y:Plongint):boolean;
var i,j:longint;
	  pos1,d:Tvec;
begin
get_ball_cross:=false;
for i:=0 to max_kol_objects-1 do if obj[i]<>nil then
	for j:=0 to max_obj_triangles-1 do if obj[i]^.tr[j]<>nil then
  with obj[i]^.tr[j]^ do
  with ball^ do
  	begin
    prop:=vec_null;
    if dist_point_line(pos.x,pos.y,p1^.x,p1^.y,p2^.x,p2^.y)<=r+2 then
    	prop:=vec_new(p1^.x,p1^.y,p2^.x,p2^.y);
    if dist_point_line(pos.x,pos.y,p1^.x,p1^.y,p3^.x,p3^.y)<=r+2 then
    	prop:=vec_new(p1^.x,p1^.y,p3^.x,p3^.y);
    if dist_point_line(pos.x,pos.y,p2^.x,p2^.y,p3^.x,p3^.y)<=r+2 then
    	prop:=vec_new(p2^.x,p2^.y,p3^.x,p3^.y);
    pos1:=vec_mul(vec_add(pos,r),KOEF);
    d:=vec_mul(vel,dtime*pixel_in_meter*KOEF);
    if lines_crossed(pos1.x,pos1.y,pos1.x+d.x,pos1.y+d.y,p1^.x*KOEF,p1^.y*KOEF,p2^.x*KOEF,p2^.y*KOEF,x,y)then
    	begin
      barrier:=vec_new(p1^.x,p1^.y,p2^.x,p2^.y);
      get_ball_cross:=true;
      end;
    if lines_crossed(pos1.x,pos1.y,pos1.x+d.x,pos.y+d.y,p1^.x*KOEF,p1^.y*KOEF,p3^.x*KOEF,p3^.y*KOEF,x,y)then
    	begin
      barrier:=vec_new(p1^.x,p1^.y,p3^.x,p3^.y);
      get_ball_cross:=true;
      end;
    if lines_crossed(pos1.x,pos1.y,pos1.x+d.x,pos.y+d.y,p2^.x*KOEF,p2^.y*KOEF,p3^.x*KOEF,p3^.y*KOEF,x,y)then
    	begin
      barrier:=vec_new(p2^.x,p2^.y,p3^.x,p3^.y);
      get_ball_cross:=true;
      end;
    end;
end;

procedure update_ball(ball:Pball;dtime:double);
var barrier,prop,prop_norm:Tvec;
	cross,contact:boolean;
  i,x,y,counter,kol:longint;
begin
kol:=round(dtime/0.001);
dtime:=0.001;
for counter:=1 to kol do
if ball<>nil then
with ball^ do
	begin
  //cross info
  cross:=get_ball_cross(ball,barrier,prop,dtime,@x,@y);
  barrier:=vec_norm(barrier);
	if sqrt(sqr(x+barrier.x-pos.x)+sqr(y+barrier.y-pos.y))>sqrt(sqr(x-barrier.x-pos.x)+sqr(y-barrier.y-pos.y)) then barrier:=vec_neg(barrier);
  barrier:=vec_unit(barrier);
  prop_norm:=vec_norm(prop);
  if sqrt(sqr(x+prop_norm.x-pos.x)+sqr(y+prop_norm.y-pos.y))>sqrt(sqr(x-prop_norm.x-pos.x)+sqr(y-prop_norm.y-pos.y)) then prop_norm:=vec_neg(prop_norm);
  prop_norm:=vec_unit(prop_norm);
  //calc forces
  for i:=0 to max_forces-1 do force[i]:=vec_null;
  with force[FORCE_GRAVITY]do
  	begin
  	y:=mass*gacc;
  	x:=0;
    end;
  force[FORCE_ENVRESIST]:=vec_neg(vec_mul(vel,0.15*pixel_in_meter));
  if cross then
  	begin
		force[FORCE_PROP_REACTION]:=vec_mul(barrier,vec_len(calc_result_force));
    force[FORCE_ELASTIC]:=vec_mul(barrier,vec_len(force[FORCE_GRAVITY])*0.5);
    end;
  if not vec_eq(prop,vec_null) then force[FORCE_FRICTION]:=vec_neg(vec_mul(vel,friction_koef*pixel_in_meter));
  //
  force[FORCE_RESULT]:=calc_result_force;
	vel:=vec_sum(vel,vec_mul(vec_div(force[FORCE_RESULT],mass),dtime));
  if cross then vel:=vec_mul(barrier,vec_len(vel)*0.65);
  pos:=vec_sum(pos,vec_mul(vel,dtime*pixel_in_meter));
  //rotation
  rot_acc:=vec_len(force[FORCE_FRICTION])*r/inertia_moment;
  rot_vel:=rot_vel+rot_acc*dtime;
  rot:=rot+rot_vel*dtime;
  if not vec_eq(prop,vec_null) then pos:=vec_sum(pos,vec_mul(vec_unit(prop),rot_vel*pixel_in_meter*r*dtime));
//  writeln(vec_len(vec_mul(vec_unit(prop),rot_vel*pixel_in_meter*r)):4:4);
  end;
end;
