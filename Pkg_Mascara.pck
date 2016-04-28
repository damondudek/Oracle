create or replace package Pkg_Mascara is

  -- Author  : DKOJO
  -- Created : 23/02/2016 10:45:33
  -- Purpose : tratar mascara

  -- +55 (11) 98877-6655
  function Fu_Telefone(p_Numero in number) return varchar2;
  function Fu_Telefone(p_Numero in varchar2) return varchar2;

  -- 410.420.430-40
  function Fu_Cpf(p_Cpf in number) return varchar2;
  function Fu_Cpf(p_Cpf in varchar2) return varchar2;

  -- 04.918.584/0028-50
  function Fu_Cnpj(p_Cnpj in number) return varchar2;
  function Fu_Cnpj(p_Cnpj in varchar2) return varchar2;

  -- 06665-012
  function Fu_Cep(p_Cep in number) return varchar2;
  function Fu_Cep(p_Cep in varchar2) return varchar2;

  -- Damon H D Kojo
  function Fu_Nome(p_Nome   in varchar2
                  ,p_Limite in number default 0) return varchar2;

end Pkg_Mascara;
/
create or replace package body Pkg_Mascara is

  function Fu_Telefone(p_Numero in number) return varchar2 is
    v_Numero varchar2(15) := To_Char(Regexp_Replace(p_Numero, '\D'));
  begin
    return Fu_Telefone(v_Numero);
  end Fu_Telefone;

  function Fu_Telefone(p_Numero in varchar2) return varchar2 is
    v_Numero varchar2(15) := To_Char(To_Number(Regexp_Replace(p_Numero, '\D')));
  begin
    /*
      55 011 96354 8450 = 14
      55  11 96354 8450 = 13
      55  11  6354 8450 = 12
          11 96354 8450 = 11
          11  6354 8450 = 10
             96354 8450 = 9
              6354 8450 = 8
    */
    return case Length(v_Numero)
             when 14 then Regexp_Replace(v_Numero, '([0-9]{2})([0-9]{3})([0-9]{5})([0-9]{4})', '+\1 (\2) \3-\4')
             when 13 then Regexp_Replace(v_Numero, '([0-9]{2})([0-9]{2})([0-9]{5})([0-9]{4})', '+\1 (\2) \3-\4')
             when 12 then Regexp_Replace(v_Numero, '([0-9]{2})([0-9]{2})([0-9]{4})([0-9]{4})', '+\1 (\2) \3-\4')
             when 11 then Regexp_Replace(v_Numero, '([0-9]{2})([0-9]{5})([0-9]{4})', '(\1) \2-\3')
             when 10 then Regexp_Replace(v_Numero, '([0-9]{2})([0-9]{4})([0-9]{4})', '(\1) \2-\3')
             when 09 then Regexp_Replace(v_Numero, '([0-9]{5})([0-9]{4})', '\1-\2')
             when 08 then Regexp_Replace(v_Numero, '([0-9]{4})([0-9]{4})', '\1-\2')
             else v_Numero end;
  end Fu_Telefone;

  function Fu_Cpf(p_Cpf in number) return varchar2 is
  begin
    return Fu_Cpf(To_Char(p_Cpf));
  end Fu_Cpf;

  function Fu_Cpf(p_Cpf in varchar2) return varchar2 is
  begin
    return Regexp_Replace(To_Char(Regexp_Replace(p_Cpf, '[^[:digit:]]'), 'FM00000000000')
                         ,'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})'
                         ,'\1.\2.\3-\4');
  end Fu_Cpf;

  function Fu_Cnpj(p_Cnpj in number) return varchar2 is
  begin
    return Fu_Cnpj(To_Char(p_Cnpj));
  end Fu_Cnpj;

  function Fu_Cnpj(p_Cnpj in varchar2) return varchar2 is
  begin
    return Regexp_Replace(To_Char(Regexp_Replace(p_Cnpj, '[^[:digit:]]'), 'FM00000000000000')
                         ,'([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})'
                         ,'\1.\2.\3/\4-\5');
  end Fu_Cnpj;

  function Fu_Cep(p_Cep in number) return varchar2 is
  begin
    return Fu_Cep(To_Char(p_Cep));
  end Fu_Cep;

  function Fu_Cep(p_Cep in varchar2) return varchar2 is
  begin
    return Regexp_Replace(To_Char(Regexp_Replace(p_Cep, '[^[:digit:]]'), 'FM00000000'), '([0-9]{5})([0-9]{3})', '\1-\2');
  end Fu_Cep;

  function Fu_Nome(p_Nome   in varchar2
                  ,p_Limite in number default 0) return varchar2 is
  
    v_Nome    varchar2(100) := Upper(trim(Regexp_Replace(Regexp_Replace(p_Nome, '[^[:alnum:][:space:]''-]', ''), ' +', ' ')));
    v_Espacos pls_integer   := Length(Regexp_Replace(v_Nome, '\S', '')) + 1;
  begin
    if (Length(v_Nome) <= p_Limite)
    then
      return v_Nome;
    end if;
  
    select To_Char(Regexp_Replace(Wmsys.Wm_Concat(Nome), ',', ' '))
      into v_Nome
      from (select case
                     when level = 1 then
                      Regexp_Substr(v_Nome, '\S+', 1, level)
                     when level = v_Espacos then
                      Regexp_Substr(v_Nome, '\S+', 1, level)
                     when Regexp_Substr(v_Nome, '\S+', 1, level) not in ('DA', 'DE', 'DI', 'DO', 'DU', 'DAS', 'DOS') then
                      Substr(Regexp_Substr(v_Nome, '\S+', 1, level), 1, 1)
                     else
                      Regexp_Substr(v_Nome, '\S+', 1, level)
                   end as Nome
              from Dual
            connect by level <= v_Espacos);
  
    if (p_Limite != 0 and Length(v_Nome) > p_Limite)
    then
      v_Nome := Substr(v_Nome, 1, p_Limite);
    end if;
  
    return v_Nome;
  end Fu_Nome;

end Pkg_Mascara;
/
