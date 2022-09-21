--drop table lesrivieres;
drop table lessources;
drop table lesmontagnes;
drop table lesprovinces;
drop table lesorganisations;
drop table BordersBis;
drop table lespays;
drop table lescontinents;
drop table racine;

--drop type t_riviere force;
drop type t_source force;
drop type t_montagne force;
drop type t_province force;
drop type t_organisation force;
drop type t_pays force;
drop type t_continent force;
drop type t_racine force;

-- CREATION DE TYPES ET TABLES 

-- SOURCES (les rivières sources)

create or replace  type T_Source as object (
   riviere_s 	   VARCHAR2(35 Byte),
   country_s     VARCHAR2(4 Byte),
   member function toXML return XMLType
)
/

create or replace type body T_Source as
 member function toXML return XMLType is
   output XMLType;
   begin
        output := XMLType.createxml('<river name = "'||riviere_s||'"/>');
	    return output;
   end;
end;
/

create table LesSources of T_Source;

-- MONTAGNES 

create or replace  type T_Montagne as object (
   NAME_Montagne VARCHAR2(35 Byte),
   MOUNTAINS     VARCHAR2(35 Byte),
   HEIGHT        NUMBER,
   TYPE_Montagne VARCHAR2(10 Byte),
   CODEPAYS      VARCHAR2(4),
   PROVINCE		 VARCHAR2(35 Byte),
   latitude		 NUMBER,
   longitude	 NUMBER,
   member function toXML return XMLType
)
/

create or replace type body T_Montagne as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<mountain name = "'||name_montagne||'"  altitude = "'||height||'" latitude = "'||latitude||'" longitude = "'||longitude||'" />');
	  return output;
   end;
end;
/

create table LesMontagnes of T_Montagne;

-- PROVINCE

create or replace type T_ensMontagne as table of T_Montagne;
/


create or replace  type T_Province as object (
   name_province	VARCHAR2(35 Byte),
   country			VARCHAR2(4 Byte),
   member function toXML return XMLType
)
/

create or replace type body T_Province as 
	member function toXML return XMLType is
	output XMLType;
	tmpMontagne T_ensMontagne;

	begin
		output := XMLType.createxml('<province name = "'||name_province||'" />');
		
		--on prend la plus haute montagne de la province si elle existe
		select value(m) bulk collect into tmpMontagne
		from LesMontagnes m
		--double vérification country/province
		where name_province = m.province and country = m.codepays 
		and m.height = (select max(m2.height)
		from LesMontagnes m2
		where name_province = m2.province and country = m2.codepays);  
		for indx IN 1..tmpMontagne.COUNT
		loop
		 output := XMLType.appendchildxml(output,'province', tmpMontagne(indx).toXML());   
		end loop;	
		
		return output;
   end;
end;
/

create table LesProvinces of T_Province;



-- ORGANISATIONS

create or replace  type T_Organisation as object (
   abbreviation	    VARCHAR2(12 Byte),
   name_org			VARCHAR2(80 Byte),
   country_org		VARCHAR2(4 Byte),
   established		DATE,
   member function toXML return XMLType
)
/

create or replace type body T_Organisation as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<organization name = "'||name_org||'" establishedDate = "'||established||'"/>');

	  return output;
   end;
end;
/

create table LesOrganisations of T_Organisation;

-- PAYS

create or replace type T_ensOrg as table of T_Organisation;
/

create or replace type T_ensPro as table of T_Province;
/

create or replace type T_ensSource as table of T_Source;
/


create table BordersBis as select * from Mondial.BORDERS;

create or replace  type T_Pays as object (
   NAME_Pays    VARCHAR2(35 Byte),
   CODE_Pays    VARCHAR2(4 Byte),
   CAPITAL     	VARCHAR2(35 Byte),
   PROVINCE     VARCHAR2(35 Byte),
   AREA         NUMBER,
   POPULATION   NUMBER,
   orga_pays    VARCHAR2(12 Byte),
   continent_pays VARCHAR2(20 Byte),
   member function toXML return XMLType
)
/

create or replace type body T_Pays as
   member function toXML return XMLType is
   output XMLType;
   blength1 number;
   blength2 number;
   blength number;
   tmpOrg T_ensOrg;
   tmpPro T_ensPro;
   tmpS T_ensSource;
   
   begin
		
		select sum(b.length) into blength1
		from BordersBis b
		where b.country1 = self.CODE_Pays;
		
		select sum(b.length) into blength2
		from BordersBis b
		where b.country2 = self.CODE_Pays;
		
		select blength1+blength2 into blength from dual;
		
		
		output := XMLType.createxml('<country name = "'||name_pays||'" population = "'||population||'" blength = "'||blength||'"/>');
		
		
		--les organisations triées par ordre de création
		select value(o) bulk collect into tmpOrg
		from LesOrganisations o
		where CODE_Pays = o.country_org
		order by o.established;  
		for indx IN 1..tmpOrg.COUNT
		loop
		 output := XMLType.appendchildxml(output,'country', tmpOrg(indx).toXML());   
		end loop;
		
		--province+
		select value(p) bulk collect into tmpPro
		from LesProvinces p
		where CODE_Pays = p.country;  
		for indx IN 1..tmpPro.COUNT
		loop
		 output := XMLType.appendchildxml(output,'country', tmpPro(indx).toXML());   
		end loop;
		
		
		--sources : river*
		select value(s) bulk collect into tmpS
		from LesSources s
		where CODE_Pays = s.country_s;  
		for indx IN 1..tmpS.COUNT
		loop
		 output := XMLType.appendchildxml(output,'country', tmpS(indx).toXML());   
		end loop;

	  
	  return output;
   end;
end;
/


create table LesPays of T_Pays;
/

-- CONTINENT
create or replace type T_ensPays as table of T_Pays;
/

create or replace  type T_Continent as object (
	continent VARCHAR2(20 Byte),
    member function toXML return XMLType
)
/

create or replace type body T_Continent as 
	member function toXML return XMLType is
	output XMLType;
    tmpP T_ensPays;
	begin
		output := XMLType.createxml('<continent name = "'||continent||'"/>');
		select value(p) bulk collect into tmpP
		from LesPays p
		where continent = p.continent_pays;
		for indx IN 1..tmpP.COUNT
		loop
			output := XMLType.appendchildxml(output,'continent', tmpP(indx).toXML());   
		end loop;
		
		return output;
   end;
end;
/


create table LesContinents of T_Continent;

-- racine
create or replace type T_ensCont as table of T_Continent;
/

create or replace type t_racine as object (
   noattribute			VARCHAR2(1 Byte),
   member function toXML return XMLType
)
/

create or replace type body t_racine as
   member function toXML return XMLType is
   output XMLType;
   tmpC T_ensCont;
   begin
		output := XMLType.createxml('<ex3/>');
			  
		select value(c) bulk collect into tmpC
		from LesContinents c;
		for indx IN 1..tmpC.COUNT
		loop
			output := XMLType.appendchildxml(output,'ex3', tmpC(indx).toXML());   
		end loop;
		
		return output;
   end;
end;
/


create table racine of t_racine;
/

-- INSERTIONS

insert into racine(noattribute)
values(' ');
	 
insert into LesSources
  select T_Source(s.river, s.country) 
         from GEO_SOURCE s;  
		 
insert into LesOrganisations
  select T_Organisation(o.abbreviation, o.name, o.country, o.established) 
         from ORGANIZATION o;  

insert into LesMontagnes
  select T_Montagne(m.name, m.mountains, m.height, 
         m.type, g.country, g.province, m.coordinates.latitude, m.coordinates.longitude) 
         from MOUNTAIN m, GEO_MOUNTAIN g
         where g.MOUNTAIN = m.NAME;
		 
insert into LesProvinces
  select T_Province(p.name, p.country) 
         from PROVINCE p; 
		 
insert into LesPays
  select T_Pays(c.name, c.code, c.capital, c.province, c.area, c.population, null, e.continent) 
         from COUNTRY c, ENCOMPASSES e	
		 where c.code = e.country; 		

insert into LesContinents
  select T_Continent(c.name) 
         from CONTINENT c;  
		 
 -- affichage du résultat
-- @WbOptimizeRowHeight lines=100
select exo.toXML().getClobVal() 
from racine exo;


-- exporter le résultat dans un fichier 
WbExport -type=text
         -file='projetMLBDA-ex3-HATTAB-Maria.xml'
         -createDir=true
         -encoding=UTF-8
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select exo.toXML().getClobVal() 
from racine exo;