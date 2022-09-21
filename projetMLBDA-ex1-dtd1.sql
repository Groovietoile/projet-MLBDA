drop table lesaeroports;
drop table lesmontagnes;
drop table lesdeserts;
drop table lesiles;
drop table lescontinents;
drop table lesprovinces;
drop table lespays;
drop table mondial;

drop type t_aeroport force;
drop type t_montagne force;
drop type t_desert force;
drop type t_ile force;
drop type t_province force;
drop type t_continent force;
drop type t_pays force;
drop type t_mondial force;

-- CREATION DE TYPES ET TABLES

-- MONTAGNES 

create or replace  type T_Montagne as object (
   NAME_Montagne VARCHAR2(35 Byte),
   MOUNTAINS     VARCHAR2(35 Byte),
   HEIGHT        NUMBER,
   TYPE_Montagne VARCHAR2(10 Byte),
   CODEPAYS      VARCHAR2(4),
   PROVINCE		 VARCHAR2(35 Byte),
   -- COORDINATES  GEOCOORD,
   member function toXML return XMLType
)
/

create or replace type body T_Montagne as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<mountain name = "'||name_montagne||'"  height = "'||height||'" />');
      return output;
   end;
end;
/

create table LesMontagnes of T_Montagne;

-- DESERTS


create or replace  type T_Desert as object (
   name_desert	VARCHAR2(35 Byte),
   area_desert	NUMBER,
   country		VARCHAR2(4 Byte),
   province		VARCHAR2(35 Byte),
   
   member function toXML return XMLType
)
/

create or replace type body T_Desert as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<desert name = "'||name_desert||'"  area = "'||area_desert||'" />');
      return output;
   end;
end;
/

create table LesDeserts of T_Desert;

-- ILES


create or replace  type T_Ile as object (
   name_ile		VARCHAR2(35 Byte),
   latitude 	NUMBER,
   longitude	NUMBER,
   country		VARCHAR2(4 Byte),
   province		VARCHAR2(35 Byte),
   
   member function toXML return XMLType
)
/

create or replace type body T_Ile as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<island name = "'||name_ile||'" />');
      output := XMLType.appendchildxml(output,'island', XMLType('<coordinates latitude = "'||latitude||'"  longitude = "'||longitude||'"/>'));
      return output;
   end;
end;
/

create table LesIles of T_Ile;

--AEROPORTS

create or replace  type T_Aeroport as object (
   NAME_Aeroport        VARCHAR2(100 Byte),
   IATACODE    			VARCHAR2(3 Byte),
   COUNTRY     			VARCHAR2(4 Byte),
   PROVINCE    			VARCHAR2(50 Byte),
   CITY        			VARCHAR2(50 Byte),
   ISLAND  				VARCHAR2(50 Byte),
   member function toXML return XMLType
)
/


create or replace type body T_Aeroport as 
	member function toXML return XMLType is
	output XMLType;
	begin
		output := XMLType.createxml('<airport name = "'||name_aeroport||'"  nearCity = "'||city||'" />');
		return output;
   end;
end;
/


create table LesAeroports of T_Aeroport;


-- CONTINENT

create or replace  type T_Continent as object (
	country VARCHAR2(4 Byte),
	continent VARCHAR2(20 Byte),
	percentage NUMBER, 
    member function toXML return XMLType
)
/

create or replace type body T_Continent as 
	member function toXML return XMLType is
	output XMLType;
	begin
		output := XMLType.createxml('<continent name = "'||continent||'"  percent = "'||percentage||'" />');
		return output;
   end;
end;
/


create table LesContinents of T_Continent;


-- PROVINCE
create or replace type T_ensMontagne as table of T_Montagne;
/

create or replace type T_ensDesert as table of T_Desert;
/

create or replace type T_ensIle as table of T_Ile;
/

create or replace  type T_Province as object (
   name_province	VARCHAR2(35 Byte),
   country			VARCHAR2(4 Byte),
   population		NUMBER,
   area        		NUMBER,
   capital   		VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

create or replace type body T_Province as 
	member function toXML return XMLType is
	output XMLType;
	tmpMontagne T_ensMontagne;
	tmpDesert T_ensDesert;
	tmpIle T_ensIle;
	begin
		output := XMLType.createxml('<province name = "'||name_province||'"  capital = "'||capital||'" />');
		
		-- geo_mountain + mountain
		select value(m) bulk collect into tmpMontagne
		from LesMontagnes m
		--double vérification country/province
		where name_province = m.province and country = m.codepays;  
		for indx IN 1..tmpMontagne.COUNT
		loop
		 output := XMLType.appendchildxml(output,'province', tmpMontagne(indx).toXML());   
		end loop;
		
		-- geo_desert + desert
		select value(d) bulk collect into tmpDesert
		from LesDeserts d
		--double vérification country/province
		where name_province = d.province and country = d.country;  
		for indx IN 1..tmpDesert.COUNT
		loop
		 output := XMLType.appendchildxml(output,'province', tmpDesert(indx).toXML());   
		end loop;
		
		-- geo_island + island(geocoordinates)
		select value(i) bulk collect into tmpIle
		from LesIles i
		--double vérification country/province
		where name_province = i.province and country = i.country;  
		for indx IN 1..tmpIle.COUNT
		loop
		 output := XMLType.appendchildxml(output,'province', tmpIle(indx).toXML());   
		end loop;
		
		
		return output;
   end;
end;
/

create table LesProvinces of T_Province;

-- PAYS

create or replace  type T_Pays as object (
   NAME_Pays    VARCHAR2(35 Byte),
   CODE     	VARCHAR2(4 Byte),
   CAPITAL     	VARCHAR2(35 Byte),
   PROVINCE     VARCHAR2(35 Byte),
   AREA         NUMBER,
   POPULATION   NUMBER,
   member function toXML return XMLType
)
/

create or replace type T_ensAeroport as table of T_Aeroport;
/

create or replace type T_ensContinent as table of T_Continent;
/

create or replace type T_ensProvince as table of T_Province;
/


create or replace type body T_Pays as
   member function toXML return XMLType is
   output XMLType;
   tmpAeroport T_ensAeroport;
   tmpContinent T_ensContinent;
   tmpProvince T_ensProvince;
   begin
      output := XMLType.createxml('<country idcountry = "'||code||'" nom = "'||NAME_Pays||'" />');

	  select value(c) bulk collect into tmpContinent
      from LesContinents c
      where code = c.country ;  
      for indx IN 1..tmpContinent.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpContinent(indx).toXML());   
      end loop;
	  
	  select value(p) bulk collect into tmpProvince
      from LesProvinces p
      where code = p.country ;  
      for indx IN 1..tmpProvince.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpProvince(indx).toXML());   
      end loop;
	  
	  select value(a) bulk collect into tmpAeroport
      from LesAeroports a
      where code = a.country ;  
      for indx IN 1..tmpAeroport.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpAeroport(indx).toXML());   
      end loop;
	  
      return output;
   end;
end;
/


create table LesPays of T_Pays;
/

create or replace type T_ensPays as table of T_Pays;
/


-- MONDIAL (racine)

create or replace type t_mondial as object (
   noattribute			VARCHAR2(1 Byte),
   member function toXML return XMLType
)
/

create or replace type body t_mondial as
   member function toXML return XMLType is
   output XMLType;
   tmpPays T_ensPays;
   begin
		output := XMLType.createxml('<mondial/>');
			  
		select value(p) bulk collect into tmpPays
		from LesPays p;
		for indx IN 1..tmpPays.COUNT
		loop
			output := XMLType.appendchildxml(output,'mondial', tmpPays(indx).toXML());   
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

insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population) 
         from COUNTRY c;       
		 
insert into LesContinents
  select T_Continent(e.country, e.continent, e.percentage) 
         from ENCOMPASSES e;    

insert into LesProvinces
  select T_Province(p.name, p.country, p.population, p.area, p.capital) 
         from PROVINCE p;     		 
		 
insert into LesMontagnes
  select T_Montagne(m.name, m.mountains, m.height, 
         m.type, g.country, g.province) 
         from MOUNTAIN m, GEO_MOUNTAIN g
         where g.MOUNTAIN = m.NAME;

insert into LesDeserts
  select T_Desert(d.name, d.area, g.country, g.province)
         from DESERT d, GEO_DESERT g
         where d.name = g.desert;
		 
insert into LesIles
  select T_Ile(i.name, i.coordinates.latitude, i.coordinates.longitude, g.country, g.province)
         from ISLAND i, GEO_ISLAND g
         where i.name = g.island;
		 
insert into LesAeroports
  select T_Aeroport(a.name, a.iatacode, a.country, a.province, a.city, a.island) 
         from AIRPORT a;

       
-- affichage du résultat
-- @WbOptimizeRowHeight lines=100
select m.toXML().getClobVal() 
from mondial m;


-- exporter le résultat dans un fichier 
WbExport -type=text
         -file='projetMLBDA-ex1-dtd1-HATTAB-Maria.xml'
         -createDir=true
         -encoding=UTF-8
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from mondial m;

