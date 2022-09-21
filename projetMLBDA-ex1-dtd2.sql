drop table leslangues;
drop table lesbordures;
drop table leborders;
drop table lespays;
drop table lessieges;
drop table lesorganisations;
drop table mondial;

drop type t_langue force;
drop type t_bordure force;
drop type t_borders force;
drop type t_pays force;
drop type t_siege force;
drop type t_organisation force;
drop type t_mondial force;

-- CREATION DE TYPES ET TABLES

-- LANGUES

create or replace  type T_Langue as object (
   country_lang  	VARCHAR2(4 Byte),
   name_lang     	VARCHAR2(50 Byte),
   percentage_lang  NUMBER,
   member function toXML return XMLType
)
/

create or replace type body T_Langue as
   member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<language language = "'||name_lang||'" percent = "'||percentage_lang||'" />');

      return output;
   end;
end;
/

create table LesLangues of T_Langue;
/


-- BORDURES

--<border>

create or replace type T_Bordure as object (
   country1_b   VARCHAR2(4 Byte),
   country2_b   VARCHAR2(4 Byte),
   taille   	NUMBER,
   member function toXML return XMLType
)
/

create or replace type body T_Bordure as
   member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<border countryCode = "'||country2_b||'" length = "'||taille||'"  />');
      return output;
   end;
end;
/

create table LesBordures of T_Bordure;
/

--<borders>

create or replace type T_ensBordure as table of T_Bordure;
/

create or replace type t_borders as object (
   country_bs			VARCHAR2(4 Byte),
   member function toXML return XMLType
)
/

create or replace type body t_borders as
   member function toXML return XMLType is
   output XMLType;
   tmpB T_ensBordure;
   begin
		output := XMLType.createxml('<borders/>');
			  
		select value(o) bulk collect into tmpB
		from LesBordures o
		where country_bs = o.country1_b;
		for indx IN 1..tmpB.COUNT
		loop
			output := XMLType.appendchildxml(output,'borders', tmpB(indx).toXML());   
		end loop;
		
		return output;
   end;
end;
/


create table leborders of t_borders;
/

-- PAYS

create or replace  type T_Pays as object (
   NAME_Pays    VARCHAR2(35 Byte),
   CODE_Pays    VARCHAR2(4 Byte),
   CAPITAL     	VARCHAR2(35 Byte),
   PROVINCE     VARCHAR2(35 Byte),
   AREA         NUMBER,
   POPULATION   NUMBER,
   orga_pays    VARCHAR2(12 Byte),
   member function toXML return XMLType
)
/


create or replace type T_ensLangue as table of T_Langue;
/


create or replace type T_ensBorders as table of t_borders;
/


create or replace type body T_Pays as
   member function toXML return XMLType is
   output XMLType;
   tmpLangue T_ensLangue;
   tmpBorders T_ensBorders;
   begin
      output := XMLType.createxml('<country code = "'||CODE_Pays||'" name = "'||name_pays||'" population = "'||population||'" />');

      select value(a) bulk collect into tmpLangue
      from LesLangues a
      where CODE_Pays = a.country_lang ;  
      for indx IN 1..tmpLangue.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpLangue(indx).toXML());   
      end loop;
	  

      select value(b) bulk collect into tmpBorders
      from leborders b
      where CODE_Pays = b.country_bs;  
      for indx IN 1..tmpBorders.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpBorders(indx).toXML());   
      end loop;

	  
	  return output;
   end;
end;
/


create table LesPays of T_Pays;
/

-- <headquarter>


create or replace  type T_Siege as object (
   orga			VARCHAR2(12 Byte),
   name_hq		VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

create or replace type body T_Siege as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<headquarter name = "'||name_hq||'"/>');	  
	  return output;
   end;
end;
/

create table LesSieges of T_Siege;


-- ORGANISATIONS

create or replace type T_ensPays as table of T_Pays;
/

create or replace type T_ensSiege as table of T_Siege;
/

create or replace  type T_Organisation as object (
   abbreviation	VARCHAR2(12 Byte),
   name_org			VARCHAR2(80 Byte),
   country_org		VARCHAR2(4 Byte),
   member function toXML return XMLType
)
/

create or replace type body T_Organisation as
 member function toXML return XMLType is
   output XMLType;
   tmpPays T_ensPays;
   tmpSiege T_ensSiege;
   begin
      output := XMLType.createxml('<organization/>');
     
	  select value(p) bulk collect into tmpPays
      from LesPays p
      where abbreviation = p.orga_pays ;  
      for indx IN 1..tmpPays.COUNT
      loop
         output := XMLType.appendchildxml(output,'organization', tmpPays(indx).toXML());   
      end loop;
	  
	  select value(s) bulk collect into tmpSiege
      from LesSieges s
      where abbreviation = s.orga;  
      for indx IN 1..tmpSiege.COUNT
      loop
         output := XMLType.appendchildxml(output,'organization', tmpSiege(indx).toXML());   
      end loop;
	  
	  return output;
   end;
end;
/

create table LesOrganisations of T_Organisation;

-- MONDIAL (racine)


create or replace type T_ensOrg as table of T_Organisation;
/


create or replace type t_mondial as object (
   noattribute			VARCHAR2(1 Byte),
   member function toXML return XMLType
)
/

create or replace type body t_mondial as
   member function toXML return XMLType is
   output XMLType;
   tmpOrg T_ensOrg;
   begin
		output := XMLType.createxml('<mondial/>');
			  
		select value(o) bulk collect into tmpOrg
		from LesOrganisations o;
		for indx IN 1..tmpOrg.COUNT
		loop
			output := XMLType.appendchildxml(output,'mondial', tmpOrg(indx).toXML());   
		end loop;
		
		return output;
   end;
end;
/


create table mondial of t_mondial;
/

-- INSERTIONS

insert into mondial(noattribute)
values(' ');

insert into leborders
  select t_borders(c.code) 
         from COUNTRY c; 	

insert into LesOrganisations
  select T_Organisation(o.abbreviation, o.name, o.country) 
         from ORGANIZATION o;  

insert into LesSieges
  select T_Siege(o.abbreviation, o.city) 
         from ORGANIZATION o;  

insert into LesLangues
  select T_Langue(a.country, a.name, a.percentage) 
         from LANGUAGE a;  
		 
insert into LesBordures
  select T_Bordure(b.country1, b.country2, b.length) 
         from BORDERS b;  

insert into LesBordures
  select T_Bordure(b.country2, b.country1, b.length) 
         from BORDERS b;  
		 		 
insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population, m.organization) 
         from COUNTRY c, ISMEMBER m
		 where c.code = m.country; 		 

-- affichage du résultat
-- @WbOptimizeRowHeight lines=100
select m.toXML().getClobVal() 
from mondial m;


-- exporter le résultat dans un fichier 
WbExport -type=text
         -file='projetMLBDA-ex1-dtd2-HATTAB-Maria.xml'
         -createDir=true
         -encoding=UTF-8
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from mondial m;