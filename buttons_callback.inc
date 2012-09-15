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
begin
if (mode=EDIT_MODE)and(kol_sel_pnt=3)and(ed_obj<>nil)then
obj_set_triangle(ed_obj,get_first_obj_tr_nil(ed_obj),sel_pnt[0],sel_pnt[1],sel_pnt[2]);
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