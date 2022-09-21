drop table lesmontagnes;
drop table lesdeserts;
drop table lesiles;
drop table lesgeo;
drop table lespeak;
drop table lesbordures;
drop table leborders;
drop table EncompBis;
drop table lespays;
drop table racine;

drop type t_montagne force;
drop type t_desert force;
drop type t_ile force;
drop type t_geo force;
drop type t_peak force;
drop type t_bordure force;
drop type t_borders force;
drop type t_pays force;
drop type t_racine force;

-- CREATION DE TYPES ET TABLES

-- MONTAGNES 

create or replace  type T_Montagne as object (
   NAME_Montagne VARCHAR2(35 Byte),
   MOUNTAINS     VARCHAR2(35 Byte),
   HEIGHT        NUMBER,
   TYPE_Montagne VARCHAR2(10 Byte),
   CODEPAYS      VARCHAR2(4),
   PROVINCE		 VARCHAR2(35 Byte),
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
   country_d	VARCHAR2(4 Byte),
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
   country_i	VARCHAR2(4 Byte),
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


-- GEO

create or replace type T_ensMontagne as table of T_Montagne;
/

create or replace type T_ensDesert as table of T_Desert;
/

create or replace type T_ensIle as table of T_Ile;
/

create or replace  type T_Geo as object (
   noattribute_g	varchar2(1 Byte),
   member function toXML(pays varchar2) return XMLType
)
/

create or replace type body T_Geo as
   member function toXML(pays varchar2) return XMLType is
   output XMLType;
   tmpMontagne T_ensMontagne;
   tmpDesert T_ensDesert;
   tmpIle T_ensIle;

   begin
      output := XMLType.createxml('<geo/>');


	  select value(m) bulk collect into tmpMontagne
      from LesMontagnes m
      where m.codepays = pays;  
      for indx IN 1..tmpMontagne.COUNT
      loop
         output := XMLType.appendchildxml(output,'geo', tmpMontagne(indx).toXML());   
      end loop;

	  select value(d) bulk collect into tmpDesert
      from LesDeserts d
      where d.country_d = pays;  
      for indx IN 1..tmpDesert.COUNT
      loop
         output := XMLType.appendchildxml(output,'geo', tmpDesert(indx).toXML());   
      end loop;
  
	  select value(e) bulk collect into tmpIle
      from LesIles e
      where e.country_i = pays;  
      for indx IN 1..tmpIle.COUNT
      loop
         output := XMLType.appendchildxml(output,'geo', tmpIle(indx).toXML());   
      end loop;
  
      return output;
   end;
end;
/

create table LesGeo of T_Geo;
/

-- PEAK

create or replace  type T_Peak as object (
   noattribute_p varchar2(1 Byte),
   member function getHeight(pays varchar2) return number,
   member function toXML(pays varchar2) return XMLType
)
/

create or replace type body T_Peak as
   member function getHeight(pays varchar2) return number is
	res number;
	tmpMontagne T_ensMontagne;
	begin
	
		select max(m.height) into res
		from LesMontagnes m
		where m.codepays = pays;

		if (res is null)then return 0;
		end if;
		return res;
	end;
   
   member function toXML(pays varchar2) return XMLType is
   output XMLType;
   tmpMontagne T_ensMontagne;
   height number;
   begin
	  select self.getHeight(pays) into height from dual;
	  if height != 0 then
      output := XMLType.createxml('<peak height = "'||self.getHeight(pays)||'" />');
	  end if;
      return output;
   end;
end;
/

create table LesPeak of T_Peak;
/


-- BORDURES

--<border>

create or replace type T_Bordure as object (
   country1_b   VARCHAR2(4 Byte),
   country2_b   VARCHAR2(4 Byte),
   continent2   VARCHAR2(20 Byte),
   taille   	NUMBER,
   member function toXML(continent1 varchar2) return XMLType
)
/

create or replace type body T_Bordure as
   member function toXML(continent1 varchar2) return XMLType is
   output XMLType;
   begin
	  --on vérifie si le pays est sur le même continent que le pays courant
	  if(continent1 = continent2) then
      output := XMLType.createxml('<border countryCode = "'||country2_b||'" length = "'||taille||'"  />');
      end if;
	  return output;
   end;
end;
/

create table LesBordures of T_Bordure;
/

--<contCountries>

create or replace type T_ensBordure as table of T_Bordure;
/

create or replace type t_borders as object (
   country_bs			VARCHAR2(4 Byte),
   member function toXML(continent varchar2) return XMLType
)
/

create or replace type body t_borders as
   member function toXML(continent varchar2) return XMLType is
   output XMLType;
   tmpB T_ensBordure;
   begin
		output := XMLType.createxml('<contCountries/>');
			  
		select value(o) bulk collect into tmpB
		from LesBordures o
		where country_bs = o.country1_b;
		for indx IN 1..tmpB.COUNT
		loop
			output := XMLType.appendchildxml(output,'contCountries', tmpB(indx).toXML(continent));   
		end loop;
		
		return output;
   end;
end;
/


create table leborders of t_borders;
/

-- PAYS

create table EncompBis as select * from Mondial.ENCOMPASSES;

create or replace type T_ensBorders as table of t_borders;
/
create or replace type T_ensGeo as table of T_Geo;
/
create or replace type T_ensPeak as table of T_Peak;
/

create or replace  type T_Pays as object (
   NAME_Pays    VARCHAR2(35 Byte),
   CODE     	VARCHAR2(4 Byte),
   CAPITAL     	VARCHAR2(35 Byte),
   PROVINCE     VARCHAR2(35 Byte),
   AREA         NUMBER,
   POPULATION   NUMBER,
   continent    VARCHAR2(20 Byte),
   percentage   NUMBER,
   member function toXML return XMLType
)
/


create or replace type body T_Pays as
   member function toXML return XMLType is
   output XMLType;
   tmpGeo T_ensGeo;
   tmpPeak T_ensPeak;
   tmpBorders T_ensBorders;
   blength1 number;
   blength2 number;
   blength number;
   continentprincipal varchar2(20 Byte);
   begin
		select sum(b.taille) into blength1
		from LesBordures b
		where b.country1_b = self.code;
		
		select sum(b.taille) into blength2
		from LesBordures b
		where b.country1_b = self.code;
		
		select blength1+blength2 into blength from dual;

		--le continent principal uniquement
		select a.continent into continentprincipal
		from EncompBis a
		where a.country = self.code and a.percentage = (select max(b.percentage) from EncompBis b where b.country = a.country);
		
		if (continentprincipal = self.continent) then
        output := XMLType.createxml('<country name = "'||NAME_Pays||'" continent = "'||continent||'" blength = "'||blength||'" />'); 
		
		--<geo>
		select value(g) bulk collect into tmpGeo
		from LesGeo g;
		for indx IN 1..tmpGeo.COUNT
		loop
			output := XMLType.appendchildxml(output,'country', tmpGeo(indx).toXML(self.code));   
		end loop;
		
		--<peak>
		select value(p) bulk collect into tmpPeak
		from LesPeak p;
		for indx IN 1..tmpPeak.COUNT
		loop
			output := XMLType.appendchildxml(output,'country', tmpPeak(indx).toXML(self.code));   
		end loop;
		
		--<contCountries>
		select value(b) bulk collect into tmpBorders
        from leborders b
        where code = b.country_bs;  
        for indx IN 1..tmpBorders.COUNT
        loop
           output := XMLType.appendchildxml(output,'country', tmpBorders(indx).toXML(self.continent));   
        end loop;

	  end if;
      return output;
   end;
end;
/


create table LesPays of T_Pays;
/

create or replace type T_ensPays as table of T_Pays;
/


-- racine

create or replace type t_racine as object (
   noattribute			VARCHAR2(1 Byte),
   member function toXML return XMLType
)
/

create or replace type body t_racine as
   member function toXML return XMLType is
   output XMLType;
   tmpPays T_ensPays;
   begin
		output := XMLType.createxml('<ex2/>');
			  
		select value(p) bulk collect into tmpPays
		from LesPays p;
		for indx IN 1..tmpPays.COUNT
		loop
			output := XMLType.appendchildxml(output,'ex2', tmpPays(indx).toXML());   
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

insert into LesGeo(noattribute_g)
values(' ');

insert into LesPeak(noattribute_p)
values(' ');

insert into leborders
  select t_borders(c.code) 
         from COUNTRY c; 	
		 
insert into LesBordures
  select T_Bordure(b.country1, b.country2, e.continent, b.length) 
         from BORDERS b, ENCOMPASSES e
		 where e.country = b.country2; 

insert into LesBordures
  select T_Bordure(b.country2, b.country1, e.continent, b.length) 
         from BORDERS b, ENCOMPASSES e
		 where e.country = b.country1; 	 
		 
insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population, e.continent, e.percentage) 
         from COUNTRY c, ENCOMPASSES e
		 where e.country = c.code;        		 
		 
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

       
-- affichage du résultat
-- @WbOptimizeRowHeight lines=100
select m.toXML().getClobVal() 
from racine m;


-- exporter le résultat dans un fichier 
WbExport -type=text
         -file='projetMLBDA-ex2-HATTAB-Maria.xml'
         -createDir=true
         -encoding=UTF-8
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from racine m;

