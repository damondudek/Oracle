create or replace procedure Pr_Download_File is
  v_Clob       clob;
  v_Blob       blob;
  v_Mime_Type  varchar2(100) := 'application/xml';
  v_File_Name  varchar2(100) := 'file.xml';
  Dest_Offset  pls_integer := 1;
  Src_Offset   pls_integer := 1;
  Lang_Context pls_integer := 0;
  Warning      pls_integer;
  v_Content    clob;

begin
  /* set the mime type of header for the same type of the file */
  Owa_Util.Mime_Header(v_Mime_Type, false);
  Htp.p('Content-Disposition: attachment; filename="' || v_File_Name || '"');
  Owa_Util.Http_Header_Close;

  /* create temporary variable to need not define the variable */
  Dbms_Lob.Createtemporary(v_Clob, true);
  Dbms_Lob.Createtemporary(v_Blob, true);

  /* open the variable for the read and write */
  Dbms_Lob.open(v_Clob, Dbms_Lob.Lob_Readwrite);

  /* generate content */
  select Xmlelement("Person", Xmlelement("Name", 'Damon Hil Dudek Kojo')) .Getclobval() into v_Content from Dual;

  /* append content inside variable */
  Dbms_Lob.Append(v_Clob, v_Content);

  /* close variable */
  Dbms_Lob.close(v_Clob);

  /* open the variable for the read and write */
  Dbms_Lob.open(v_Blob, Dbms_Lob.Lob_Readwrite);

  /* convert clob to blob for download */
  Dbms_Lob.Converttoblob(v_Blob, v_Clob, Dbms_Lob.Lobmaxsize, Dest_Offset, Src_Offset, Dbms_Lob.Default_Csid, Lang_Context, Warning);

  /* close variable */
  Dbms_Lob.close(v_Blob);

  /* download content inside blob */
  Wpg_Docload.Download_File(v_Blob);

  /* clean free content temporary */
  Dbms_Lob.Freetemporary(v_Clob);
  Dbms_Lob.Freetemporary(v_Blob);

end;
/
