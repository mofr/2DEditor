procedure draw_image_alpha(dimg,img:pimage;x,y:longint;alpha:byte);
var t,bg:pimage;
begin
bg:=createimageWH(getimagewidth(img),getimageheight(img));
t:=createimageWH(getimagewidth(img),getimageheight(img));
if dimg<>nil then imagegetimage(dimg,x,y,bg) else getimage(x,y,bg);
copyimage(t,bg);
composeimagec(t,img,0,0);
blendimagealphaimage(t,t,alpha,bg);
if dimg<>nil then
  composeimagec(dimg,t,x,y)
else putimagec(x,y,t);
destroyimage(bg);
destroyimage(t);
end;

procedure put_image_wmask(bg,img,mask:pimage;x,y:longint);
var timg:pimage;
begin
timg:=cloneimage(img);
composeimage(timg,bg,-x,-y);
blendimagemaskimage(timg,img,mask,timg);
composeimagec(bg,timg,x,y);
destroyimage(timg);
end;
  {
procedure draw_bar(dimg:pimage;x1,y1,x2,y2:longint;img:pimage;dr_frame,bulg:boolean);
var sx,sy,c3:longint;
  c1,c2:^longint;
  p:pointer;
begin
sx:=abs(x2-x1);
sy:=abs(y2-y1);
if img<>nil then composeimage(dimg,img,0,0) else imagebar(dimg,x1,y1,x2,y2,main_back_color);
if bulg then
  begin
  c1:=@main_spec_color;
  c2:=@main_shad_color;
  end
else
  begin
  c2:=@main_spec_color;
  c1:=@main_shad_color;
  end;
if dr_frame then imagerectangle(dimg,x1,y1,x2,y2,main_frame_color);
imagelineH(dimg,x1+1,x2-1,y1+1,c1^);
imagelineV(dimg,x1+1,y1+1,y2-1,c1^);
imagelineH(dimg,x1+1,x2-1,y2-1,c2^);
imagelineV(dimg,x2-1,y1+1,y2-1,c2^);
end;  }
