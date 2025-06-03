--======================================================================
-- Función primaria:
--  Script de generación de pruebas unitarias
--
-- Parámetros:
--  p_tablahechos: Nombre de la fact (Staging)
--
-- Ejemplo de invocación: 
-- p_tablahechos: SF_FACTURASDETALLES
-- 
--======================================================================
-- Autor...........:   Mariela Montaldo
-- Creado el.......:   14/05/2021
-- Documentación...:
-- Cambios.........:
-- Día _____ Quien_____ Descripción_________________________________
--
--======================================================================

accept p_tablahechos prompt 'Nombre de la fact (Staging) - Ejemplo: SF_FACTURASDETALLES' default 'SF_FACTURASDETALLES';
--------------------------------------------------------
--  Generar consulta aplanada desde la fact
--------------------------------------------------------
-- Genera un select tomando como tabla principal la tabla de hechos de la estrella
-- y haciendo left join a todas las tablas de dimensión (staging).
-- De esta manera, al ejecutar esta selección se puede tener una idea aproximada de
-- cómo se van a visualizar los datos y detectar si existe algún problema con los
-- mismos (problemas en el join, problemas en los datos de origen al traer demasiados
-- valores nulos, etc).
-- 

SELECT CONSULTA
FROM(
    SELECT -1 COLUMN_ID, 'SELECT ' CONSULTA
    FROM DUAL
    
    UNION
    
    SELECT COLUMN_ID, CONSULTA
    FROM(
        SELECT column_id,
            'A.'||column_name
            || ',' as CONSULTA
        FROM all_tab_cols
        where 1=1
        and column_name not like 'AUD_%'
        and column_name <> 'HS_REGISTRO'
        and table_name = '&p_tablahechos'
        order by column_id
    )
    
    union
    
    SELECT  atc.column_id*10 column_id,
            CHR(64 + atc.column_id) ||'.'|| 
            replace(atc.column_name,'ID_','DS_') 
            || CASE WHEN (MAX(atc.COLUMN_ID) OVER (ORDER BY atc.TABLE_NAME)) <> atc.COLUMN_ID THEN ',' ELSE ' FROM ' || atc.table_name || ' A ' END CONSULTA
    FROM all_tab_cols atc
    inner join (
        select table_name, column_name, column_id
        from all_tab_cols
        where 1=1
        and owner = 'BI_STG'
        and table_name <> '&p_tablahechos'
        and table_name like 'SD_%'
    ) src
        on src.column_name = atc.column_name
    where 1=1
    and atc.column_name LIKE 'ID_%_%'
    and atc.column_id <> 1
    and atc.table_name = '&p_tablahechos'
    and src.column_id = 1
    
    union
    
    -- JOINS
    SELECT  atc.column_id * 100 column_id,
            'LEFT JOIN ' || 
            src.table_name || ' ' || 
            CHR(64 + atc.column_id) || ' ON ' || 'A.' || 
            atc.column_name || ' = ' || 
            CHR(64 + atc.column_id) ||'.'|| 
            atc.column_name CONSULTA
    FROM all_tab_cols atc
    inner join (
        select table_name, column_name, column_id
        from all_tab_cols
        where 1=1
        and owner = 'BI_STG'
        and table_name <> '&p_tablahechos'
        and table_name like 'SD_%'
    ) src
        on src.column_name = atc.column_name
    where 1=1
    and atc.column_name LIKE 'ID_%_%'
    and atc.column_id <> 1
    and atc.table_name = '&p_tablahechos'
    and src.column_id = 1
    
    order by column_id
)
ORDER BY COLUMN_ID
;
