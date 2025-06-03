--======================================================================
-- Función primaria:
--  Script de generación de comentarios en tablas y columnas
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
accept p_owner prompt 'Nombre del owner de la base - Ejemplo: SYS' default 'SYS';

-- Comentarios en tablas
SELECT
    distinct 'COMMENT ON TABLE ' || table_name || ' IS ' ||''''|| 'Tabla de '||table_name||' de '||owner||''''|| ';' consultas
FROM all_tab_cols
where owner='&p_owner'
    and (column_name LIKE '%_NOMBRE' OR column_name LIKE '%_ID')
    and table_name not like 'VW_%'
;

-- Comentarios en columnas
SELECT
    'COMMENT ON COLUMN ' || owner || '.' || table_name || '.' || column_name || ' IS ' ||''''||
        CASE 
            WHEN column_name LIKE '%_NOMBRE'
                then 'Nombre de ' || SUBSTR(lower(column_name),1,INSTR(column_name,'_')-1)
            WHEN column_name LIKE '%_ID' AND IDENTITY_COLUMN='NO'
                THEN 'Referencia a tabla de ' || SUBSTR(column_name,1,INSTR(column_name,'_')-1)
            WHEN IDENTITY_COLUMN='YES'
                THEN 'Clave primaria de ' || table_name
            ELSE ''
        END || ''';' consultas
FROM all_tab_cols
where owner='&p_owner'
and (column_name LIKE '%_NOMBRE' OR column_name LIKE '%_ID')
and table_name not like 'VW_%'
order by table_name, column_id
;
