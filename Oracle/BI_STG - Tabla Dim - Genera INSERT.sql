--======================================================================
-- Función primaria:
--  Script de generación de pruebas unitarias
--
-- Parámetros:
--  p_tabladim: Nombre de la tabla de dimensión (Staging)
--
-- Ejemplo de invocación:
-- p_tabladim: SD_GEO_LOCALIDADES
-- 
--======================================================================
-- Autor...........:   Mariela Montaldo
-- Creado el.......:   14/05/2021
-- Documentación...:
-- Cambios.........:
-- Día _____ Quien_____ Descripción_________________________________
--
--======================================================================

accept p_tabladim prompt 'Nombre de la tabla de dimensión (Staging) - Ejemplo: SD_GEO_LOCALIDADES' default 'SD_GEO_LOCALIDADES';

-------------------------------------------------------------------------------------------
--  Generar inserción de registro en Staging para pruebas de escenario de inserción en ETLs
-------------------------------------------------------------------------------------------
-- La siguiente consulta genera un registro de pruebas con el ID -1, con la finalidad de 
-- insertarlo en la tabla de staging a probar. Al ejecutar el ETL de carga de la tabla de 
-- dimensión correspondiente, primero se van a insertar los registros default, con lo cual
-- uno de los registros va a tener ya ID -1. Ese registro se va a modificar en el data flow
-- detectando el cambio e insertando todo el resto de registros en la tabla de staging.
-- Con lo cual, la finalidad de generar este registro de pruebas es probar los dos escenarios
-- (insert y update) con un solo registro.


SELECT COLUMN_ID, CONSULTA
FROM(
    SELECT -1 AS COLUMN_ID, 'INSERT INTO ' || '&p_tabladim' || '(' AS CONSULTA
    FROM DUAL
    
    UNION
    
    SELECT COLUMN_ID,
        '  ' || CONSULTA || CASE WHEN AUX = COLUMN_ID THEN ') VALUES (' ELSE ',' END AS CONSULTA
    FROM (SELECT COLUMN_ID,
                 COLUMN_NAME AS CONSULTA,
                 MAX (COLUMN_ID) OVER (ORDER BY TABLE_NAME) AUX
        FROM ALL_TAB_COLS
        WHERE TABLE_NAME = '&p_tabladim'
        AND COLUMN_NAME NOT LIKE 'AUD_%'
        GROUP BY TABLE_NAME, COLUMN_ID,COLUMN_NAME
    )
    
    union
    -- Columnas
    SELECT COLUMN_ID,
        '  ' || CONSULTA || CASE WHEN AUX=COLUMN_ID THEN ') VALUES (' ELSE ',' END AS CONSULTA
    FROM (SELECT COLUMN_ID,
                 COLUMN_NAME AS CONSULTA,
                 MAX (COLUMN_ID) OVER (ORDER BY TABLE_NAME) AUX
        FROM ALL_TAB_COLS
        WHERE TABLE_NAME = '&p_tabladim'
        AND COLUMN_NAME NOT LIKE 'AUD_%'
        GROUP BY TABLE_NAME, COLUMN_ID,COLUMN_NAME
    )
    order by column_id
)

union
-- Valores
SELECT COLUMN_ID, CONSULTA
FROM(
    SELECT   COLUMN_ID*10 COLUMN_ID,
             CASE DATA_TYPE
                WHEN 'NUMBER' THEN '  -1'
                WHEN 'VARCHAR2' THEN 
                    CASE WHEN SUBSTR(COLUMN_NAME,1,2) = 'ID' 
                         THEN '  ''<S/D>'''
                         ELSE '  ''' || SUBSTR(COLUMN_NAME,1,DATA_LENGTH) || ' TEST''' 
                    END
             ELSE ''
             END || CASE WHEN (MAX(COLUMN_ID) OVER (ORDER BY TABLE_NAME)) = COLUMN_ID THEN ');' ELSE ',' END 
            AS CONSULTA
    FROM ALL_TAB_COLS
    WHERE TABLE_NAME = '&p_tabladim'
    AND COLUMN_NAME NOT LIKE 'AUD_%'
    ORDER BY COLUMN_ID
)
;
