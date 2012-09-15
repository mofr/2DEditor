function str_kol_char(s:ansistring;c:char):longint;
var k:longint;
begin
k:=0;
for i:=1 to length(s) do if s[i]=c then inc(k);
str_kol_char:=k;
end;

procedure obj_str_to_triangles(obj:Pobject;source:ansistring);
var tr,s:ansistring;
	p:array[1..3]of Ppoint;
  x,y,i:longint;
begin
while (pos('{',source)<>0)and(pos('}',source)<>0)do
	begin
	tr:=copy(source,pos('{',source)+1,pos('}',source)-pos('{',source)-1);
	source:=copy(source,pos(tr,source)+length(tr)+1,length(source)-pos(tr,source)-length(tr));
  for i:=1 to 3 do
  	begin
    s:=copy(tr,pos('<',tr)+1,pos('>',tr)-pos('<',tr)-1);
    tr:=copy(tr,pos(s,tr)+length(s)+1,length(tr)-pos(s,tr)-length(s));
  	val(copy(s,1,pos(',',s)-1),x);
  	val(copy(s,pos(',',s)+1,length(s)-(pos(',',s))),y);
    p[i]:=get_point_by_coords(obj,x,y);
    end;
  if(p[1]<>nil)and(p[2]<>nil)and(p[3]<>nil)then
	obj_set_triangle(obj,get_first_obj_tr_nil(obj),p[1],p[2],p[3]);
  end;
end;

procedure obj_str_to_points(obj:Pobject;source:ansistring);
var s:ansistring;
	k,x,y:longint;
begin
k:=str_kol_char(source,'"')div 2;
for i:=1 to k do
	begin
  s:='';
  source:=copy(source,pos('"',source)+1,length(source)-(pos('"',source)));
  s:=copy(source,1,pos('"',source)-1);
  source:=copy(source,pos('"',source)+1,length(source)-(pos('"',source)));
  val(copy(s,1,pos(',',s)-1),x);
  val(copy(s,pos(',',s)+1,length(s)-(pos(',',s))),y);
  obj_add_point(obj,x,y);
  end;
end;

function file_select(s:Pansistring;bt_text1,bt_text2:ansistring;prev_img:pimage):integer;
const max_files=1000;
var win_img,bg:pimage;
    b:array[1..2]of Pbutton;
  result,i,d_file,folder_files,page_size:integer;
  pmb,mb,mx,my,sx,sy,ssx,ssy,col,scrollbarx,scrollbary,borderx,
  	bordery1,bordery2:longint;
  filename,dir,curfolder:ansistring;
  file_list:array[0..max_files-1]of ansistring;
  file_attr_list:array[0..max_files-1]of integer;
  key:char;
  key_pressed:boolean;

function prev_folder(curfolder:ansistring):ansistring;
var i:integer;
begin
i:=length(curfolder)-1;
while (curfolder[i]<>'\')and(i>1) do dec(i);
if i>1 then prev_folder:=copy(curfolder,1,i)else prev_folder:='';
end;

procedure add_file_to_list(name:ansistring;attr:integer);
begin
file_list[folder_files]:=name;
file_attr_list[folder_files]:=attr;
inc(folder_files);
end;

procedure sort_list;
var b:boolean;
	i,j:integer;
	procedure swapint(var a,b:integer);
  var t:integer;
  begin
	t:=a;a:=b;b:=t;
  end;
  procedure swapstr(var a,b:ansistring);
  var t:ansistring;
  begin
	t:=a;a:=b;b:=t;
  end;
begin
i:=0;//dir
j:=0;//file
b:=false;
repeat
	begin
  while (i<folder_files-1)and(file_attr_list[i]<>faDirectory) do inc(i);
  while (j<folder_files-1)and(file_attr_list[j]=faDirectory) do inc(j);
  b:=(i=folder_files-1)or(j=folder_files-1);
  if i>j then
  	begin
		swapint(file_attr_list[i],file_attr_list[j]);
  	swapstr(file_list[i],file_list[j]);
    inc(j);
    end;
  inc(i);
  end
  until b;
end;

procedure build_file_list(var searchdir:ansistring);
var srec:Tsearchrec;
	i:integer;
  s:string;
begin
folder_files:=0;
if length(curfolder)>2 then
	begin
	if searchdir[length(searchdir)]<>'\' then searchdir:=searchdir+'\';
    if (findfirst(searchdir+'*',faAnyFile,srec)=0) then
  	repeat
		add_file_to_list(srec.name,srec.attr)
  	until findnext(srec)<>0;
	end
else
	begin
  for i:=2 to 26 do
  	if disksize(i)<>-1 then
    	begin
      add_file_to_list(chr(i+64)+':\',faDirectory);
      end;
  end;
sort_list;
scrollbary:=round((ssy-10)*(page_size/folder_files));
if scrollbary>ssy-1 then scrollbary:=ssy-10;
end;

begin
result:=-1;
pmb:=0;
sx:=getmaxx div 2;
sy:=3*getmaxy div 4;
borderx:=20;
bordery1:=40;
bg:=createimageWH(getimagewidth(prev_img),getimageheight(prev_img));
createscreenimg(bg,view.x,view.y,'V',false);
sx:=sx+2;sy:=sy+2;//for frame
scrollbarx:=15;
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

ssx:=sx-borderx*2;
ssy:=b[1]^.y-91+5;
page_size:=(ssy div (font.fontheight+1));
filename:='';
d_file:=0;
getdir(0,curfolder);
build_file_list(curfolder);

repeat
	begin
  fillimage(win_img,main_back_color);
  draw_bar(win_img,0,0,sx-1,sy-1,nil,true,true);
  mb:=mousebutton;
  mousecoords(mx,my);
  if (mb=0)and(pmb=1)and(mx>getmaxx div 2-sx div 2+borderx)and(mx<getmaxx div 2-sx div 2+borderx+ssx)
  	and(my>getmaxy div 2-sy div 2+bordery1)and(my<getmaxy div 2-sy div 2+bordery1+ssy)then
  	begin
    i:=(my-(getmaxy div 2-sy div 2+bordery1)-5)div(font.fontheight+1)+d_file;
    if i<folder_files then
  	if file_attr_list[i]<>faDirectory then filename:=file_list[i] else
    	begin
      if (file_list[i]<>'.')and(file_list[i]<>'..')then curfolder:=curfolder+file_list[i]
      	else curfolder:=prev_folder(curfolder);
      build_file_list(curfolder);
      filename:='';
    	end;
    end;
  composeimage(prev_img,bg,0,0);
  draw_bar(win_img,borderx,bordery1,borderx+ssx,bordery1+ssy,nil,false,false);
  for i:=0 to page_size-1 do
    if (i<max_files)and(i<folder_files) then
    begin
    if file_attr_list[i+d_file]=faDirectory then col:=rgbcolorrgb(230,230,230) else col:=rgbcolorrgb(15,15,15);
    font.outtext(borderx+5,bordery1+5+i*(font.fontheight+1),file_list[i+d_file],col);
    end;
  for i:=1 to 2 do
    begin
    if update_button(b[i],pmb,mb,mx-(getmaxx div 2-sx div 2),my-(getmaxy div 2-sy div 2))<>BTA_NOTHING then result:=i;
    draw_button(b[i]);
    end;
  key_pressed:=keypressed;
  if key_pressed then key:=readkey;
  if key_pressed then
    case key of
    	#27:result:=2;
      #13:result:=1;
      #0:case readkey of
      	#72:dec(d_file);
      	#80:inc(d_file);
      	#73:dec(d_file,page_size-1);
      	#81:inc(d_file,page_size-1);
      	#71:begin
          curfolder:=prev_folder(curfolder);
        	build_file_list(curfolder);
        	filename:='';
        	end;
        #83:filename:='';
        end;
      #8:filename:=copy(filename,1,length(filename)-1);
      #56..#90,#97..#122:filename:=filename+key;
      end;
  if d_file>folder_files-page_size then d_file:=folder_files-page_size;
  if d_file<0 then d_file:=0;
  pmb:=mb;
  draw_bar(win_img,sx-borderx-10-scrollbarx div 3,bordery1+5,sx-borderx-10,bordery1+ssy-5,nil,false,false);
  draw_bar(win_img,sx-borderx-10-2*scrollbarx div 3,bordery1+5+round((ssy-10)*(d_file/folder_files)),sx-borderx-10+scrollbarx div 3,bordery1+5+round((ssy-10)*(d_file/folder_files))+scrollbary,nil,false,true);
  font.outtext(25,25-font.textheight(filename)div 2,curfolder,rgbcolorrgb(15,15,15));
  font.outtext(b[1]^.x+b[1]^.w div 2-font.textlength(bt_text1)div 2,b[1]^.y+b[1]^.h div 2-font.textheight(bt_text1)div 2,bt_text1,rgbcolorrgb(15,15,15));
  font.outtext(b[2]^.x+b[2]^.w div 2-font.textlength(bt_text2)div 2,b[2]^.y+b[2]^.h div 2-font.textheight(bt_text2)div 2,bt_text2,rgbcolorrgb(15,15,15));
  font.outtext(sx div 2-font.textlength('File name:'+filename+'|')div 2,b[1]^.y-25-font.textheight('File name:'+filename+'|')div 2,'File name:'+filename+'|',rgbcolorrgb(15,15,15));
  composeimage(prev_img,win_img,getmaxx div 2-sx div 2,getmaxy div 2-sy div 2);
  composeimagec(prev_img,cursor[cur_cursor],mx,my);
  putimage(0,0,prev_img);
  key_pressed:=false;
  end
until result<>-1;

for i:=1 to 2 do destroy_button(b[i]);
destroyimage(win_img);
destroyimage(bg);
font.setimage(prev_img);
file_select:=result;
s^:=curfolder+filename;
end;

procedure save_file(a:integer);
var i,j:longint;
    f:text;
    fs:integer;
    s:ansistring;
begin
g_timer_stop(main_timer);
fs:=file_select(@s,'Save','Cancel',screenimg);
if pos('.2m',s)<>length(s)-2 then s:=s+'.2m';
assign(f,s);
{$i-}
rewrite(f);
{$i+}
if ioresult<>0 then
	begin
  if fs=1 then writeln('File saving error "'+s+'"');
  end
  else if fs=1 then
begin
for i:=0 to max_kol_objects-1 do
    if obj[i]<>nil then
    begin
    writeln(f,'obj',i);
    writeln(f,'{');
    writeln(f,'points'+'{');
    for j:=0 to max_obj_points-1 do
        if obj[i]^.pnt[j]<>nil then
        with obj[i]^.pnt[j]^ do
        begin
        writeln(f,#9+'"',x,',',y,'"');
        end;
    writeln(f,#9+'}');
    writeln(f,'triangles'+'{');
    for j:=0 to max_obj_triangles-1 do
        if obj[i]^.tr[j]<>nil then
        with obj[i]^.tr[j]^ do
        begin
        write(f,#9+'{');
        with p1^ do write(f,'<',x,',',y,'>');
        with p2^ do write(f,'<',x,',',y,'>');
        with p3^ do write(f,'<',x,',',y,'>');
        writeln(f,'}');
        end;
    writeln(f,#9+'}');
    writeln(f,'}');
    end;
close(f);
end else close(f);{saving}
g_timer_start(main_timer);
end;{procedure}

procedure load_file(append_:integer);
var s,path,tr_str,pnt_str:ansistring;
    depth,fs:integer;
  c:char;
  f:text;
  obj:Pobject;
function get(s:ansistring):ansistring;
var t:ansistring;
	i:longint;
begin
t:='';
i:=1;
while (i<length(s))and(s[i]<>'{')do inc(i);
if s[i]='{'then depth:=1 else depth:=0;
inc(i);
while (i<=length(s))and(depth>0)do
	begin
  if s[i]='{'then inc(depth);
  if s[i]='}'then dec(depth);
  if depth>0 then t:=t+s[i];
  inc(i);
  end;
get:=t;
end;
function str_wo(s:ansistring;c:char):ansistring;
var t:ansistring;
	i:longint;
begin
t:='';
for i:=1 to length(s)do if s[i]<>c then t:=t+s[i];
str_wo:=t;
end;

begin
g_timer_stop(main_timer);
fs:=file_select(@s,'Load','Cancel',screenimg);
assign(f,s);
{$i-}
reset(f);
{$i+}
if ioresult<>0 then
	begin
  if fs=1 then writeln('File loading error "'+path+'"');
  end
  else if fs=1 then
begin{loading}
if append_=0 then prepare_new_workplace(0);
while not eof(f)do
	begin
  s:='';
  repeat read(f,c)until (c='{')or(eof(f));
  if not eof(f)then depth:=1 else depth:=0;
  if depth=1 then
  	begin
  	repeat
  		begin
    	read(f,c);
    	if c='{'then inc(depth);
    	if c='}'then dec(depth);
    	if depth<>0 then s:=s+c;
    	end
    	until depth=0;
    tr_str:=copy(s,pos('triangles',s),length(s)-pos('triangles',s));
    pnt_str:=copy(s,pos('points',s),length(s)-pos('points',s));
    tr_str:=get(tr_str);
    tr_str:=str_wo(tr_str,' ');
    tr_str:=str_wo(tr_str,#9);
    pnt_str:=get(pnt_str);
    pnt_str:=str_wo(pnt_str,' ');
    pnt_str:=str_wo(pnt_str,#9);
  	obj:=new_object(-1);
  	obj_str_to_points(obj,pnt_str);
  	obj_str_to_triangles(obj,tr_str);
    end;
  end;
close(f);
end else close(f);{loading}
g_timer_start(main_timer);
end;{procedure}
