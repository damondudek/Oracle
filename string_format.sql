create or replace function Fu_String_Format(p_String in varchar2
                                           ,p_Format in varchar2) return varchar2 is

  v_Retorno varchar2(32767) := p_String;
begin

  for c_Cursor in (select Regexp_Substr(p_String, '{\d{1,}}', 1, level) as Identificador
                         ,level as Posicao
                     from Dual
                   connect by level <= Length(Regexp_Replace((Regexp_Replace(p_String, '{\d{1,}}', '§')), '[^§]'))
                    order by 1)
  loop
    v_Retorno := replace(v_Retorno, c_Cursor.Identificador, trim(Substr(Regexp_Substr(',' || p_Format, ',[^,]*', 1, c_Cursor.Posicao), 2)));
  end loop;

  return v_Retorno;
end;
