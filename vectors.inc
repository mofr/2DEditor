type
Tvec=record
  	x,y:double;
  	end;
Pvec=^Tvec;

function vec_sum(vec1,vec2:Tvec):Tvec;
begin
vec_sum.x:=vec1.x+vec2.x;
vec_sum.y:=vec1.y+vec2.y;
end;

function vec_add(vec:Tvec;val:double):Tvec;
begin
vec_add.x:=vec.x+val;
vec_add.y:=vec.y+val;
end;

function vec_null:Tvec;
begin
vec_null.x:=0;
vec_null.y:=0;
end;

function vec_len(vec:Tvec):double;
begin
vec_len:=sqrt(sqr(vec.x)+sqr(vec.y));
end;

function vec_div(vec:Tvec;val:double):Tvec;
begin
if val<>0 then
	begin
	vec_div.x:=vec.x/val;
	vec_div.y:=vec.y/val;
  end;
end;

function vec_mul(vec:Tvec;val:double):Tvec;
begin
vec_mul.x:=vec.x*val;
vec_mul.y:=vec.y*val;
end;

function vec_unit(vec:Tvec):Tvec;
begin
vec_unit:=vec_div(vec,vec_len(vec));
end;

function vec_norm(vec:Tvec):Tvec;
begin
vec_norm.x:=-vec.y;
vec_norm.y:=vec.x;
end;

function vec_neg(vec:Tvec):Tvec;
begin
vec_neg.x:=-vec.x;
vec_neg.y:=-vec.y;
end;

function vec_eq(vec1,vec2:Tvec):boolean;
begin
vec_eq:=(vec1.x=vec2.x)and(vec1.y=vec2.y);
end;

function vec_new(x1,y1,x2,y2:double):Tvec;
begin
vec_new.x:=x2-x1;
vec_new.y:=y2-y1;
end;

procedure vec_draw(img:pimage;vec:Tvec;x0,y0,col:longint);
begin
if img <>nil then
imageline(img,x0,y0,x0+round(vec.x),y0+round(vec.y),col)
else line(x0,y0,x0+round(vec.x),y0+round(vec.y),col);
end;

function vec_ang(vec:Tvec):double;
var l:double;
begin
l:=vec_len(vec);
if l<>0 then vec_ang:=arccos(vec.x/l)else vec_ang:=0;
end;

function vec_refl(vec,dvec:Tvec):Tvec;
var ang,dist:double;
begin
ang:=vec_ang(vec)+vec_ang(dvec);
dist:=vec_len(vec);
vec_refl.x:=cos(ang)*dist;
vec_refl.y:=sin(ang)*dist;
end;
