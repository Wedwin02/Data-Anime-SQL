/*1. Cree las tablas para almacenar los set de datos. */
CREATE TABLE anime
(
    anime_id NUMERIC(10,0), 
    name VARCHAR(250), 
    genre VARCHAR(250),
    type VARCHAR(50), 
    episodes VARCHAR(1000), 
    rating NUMERIC(10,3), 
    members NUMERIC(10,0)
)
CREATE TABLE rating
(
    user_id NUMERIC(10,0), 
    anime_id NUMERIC(10,0),  
    rating NUMERIC(10,0)
)

/*IMPORTAR DATA */
COPY anime from 'C:\anime.csv' delimiter ',' CSV HEADER ENCODING 'UTF-8' ESCAPE '"'
COPY rating from 'C:\rating.csv' delimiter ',' CSV HEADER ENCODING 'UTF-8'
/*VALIDAR QUE LA INFORMACION SE GUARDO */
select * from anime;
select * from RATING;


/*2. Cual es el anime por cada type que posee más episodios*/
/*Describe el tipo , nombre , id y el numero de episodio*/
SELECT type, name, anime_id,episodes
FROM anime
WHERE (type,CASE 
			WHEN episodes = 'Unknown' THEN 0
			ELSE TO_NUMBER(episodes,'S9999')
		END) 
		IN (
			SELECT type, 
			MAX(
				CASE 
					WHEN episodes = 'Unknown' THEN 0
					ELSE TO_NUMBER(episodes,'S9999')
				END
			) AS capitulos
			FROM anime 
			GROUP BY type	
);
/*Total por tipo*/
SELECT 
		type,
		MAX(
		CASE 
			WHEN episodes = 'Unknown' THEN 0
			ELSE TO_NUMBER(episodes,'S9999')
		END 
			)AS miembros
	FROM anime a
GROUP BY type

/*3. Cual es el tipo de anime que tiene mayor cantidad de miembros.*/

SELECT  type,members FROM anime WHERE members IN (SELECT MAX(members) AS max_miembros
FROM anime
GROUP BY type
ORDER BY max_miembros DESC
LIMIT 1); 
/*Describe todos los campos*/
SELECT  * FROM anime WHERE members IN (SELECT MAX(members) AS max_miembros
FROM anime
GROUP BY type
ORDER BY max_miembros DESC
LIMIT 1); 

/*4. valide que el rating promedio del archivo anime, sea el mismo que el rating del archivo rating*/
/* creo una vista que contiene el avg de rating agrupado por el anime id*/
create view  rating_unificado as
SELECT anime_id,CAST(AVG(rating) AS DECIMAL(10,2))/*Para reducir decimales*/
FROM rating
WHERE rating >0 
GROUP BY anime_id 

/* Genero una consulta a mi vista que coincida el avg, anime_id con el de la tabla anime*/
select * from anime as a
inner join rating_unificado as b
on b.avg = a.rating and b.anime_id = a.anime_id
/*Conclusion el promedio rating del archivo anime es diferente al promedio agrupado por anime_id del archivo rating*/

/*5. Cual es el anime que posee mayor cantidad de calificaciones de los miembros*/
create view  anime_Count as
select user_id, count(rating) as cantidad
from rating 
WHERE rating > 0
group by user_id
order by cantidad desc

select *
	from Capitulos  where "Capitulos"  in(
	  select MAX("Capitulos") from Capitulos where anime_id /* atravez de lista de anime_id se lecciona cual de estos es el mayor*/ 
		in (
			SELECT anime_id FROM rating as a  right join public.anime_Count as b on a.user_id = b.user_id where a.rating > 0 /*Se une el top 10 con rating , rating no debe tener -1*/
		)
		
)
/*6. Del genero Sci-Fi, cual es el anime mayor calificado? cual es el que tiene el mayor raiting*/

SELECT  * FROM  anime 
WHERE genre LIKE '%Sci-Fi%' 
AND  rating IN (
	SELECT MAX (rating) FROM anime WHERE genre LIKE '%Sci-Fi%' 
);

/*7. Del top 10 de miembros que mas han valorado, cual es el anime que tiene mas capitulos*/ 
/*creo una vista del top 10*/
create view  top_10 as
select user_id, count(rating) as cantidad
from rating as c
WHERE rating > 0
group by user_id
order by cantidad desc
limit 10


create view  Capitulos as
select *, 
			CASE 
			WHEN episodes = 'Unknown' THEN 0
			ELSE TO_NUMBER(episodes,'S9999') 
			END AS "Capitulos"
from anime ORDER BY "Capitulos" DESC

/* "Capitulos" es una columna alternativa de tipo numeric*/
select *
	from Capitulos  where "Capitulos"  in(
	  select MAX("Capitulos") from Capitulos where anime_id /* atravez de lista de anime_id se lecciona cual de estos es el mayor*/ 
		in (
			SELECT anime_id FROM rating as a  right join public.top_10 as b on a.user_id = b.user_id where a.rating > 0 /*Se une el top 10 con rating , rating no debe tener -1*/
		)
) 
