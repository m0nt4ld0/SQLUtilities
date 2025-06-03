DEFINE owner = 'PORTALRRHH'

-- Truncar (vaciar contenido)

SELECT 'TRUNCATE TABLE ' || TABLE_NAME || ';'
FROM all_tables 
WHERE owner = '&owner';


-- Eliminar tabla (contenido y estructura)

SELECT 'DROP TABLE ' || TABLE_NAME || ';'
FROM all_tables 
WHERE owner = '&owner';


-- Contar registros en cada tabla (primero actualiza estadisticas de las tablas)
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('&owner');
DEFINE owner = 'MIOWNER'

SELECT 'CANTIDAD DE REGISTROS DE ' || table_name || ': ' || NVL(num_rows, 0) as resultado
FROM all_tables 
WHERE owner = '&owner'
AND table_name NOT LIKE 'BIN$%'; -- Excluir tablas de reciclaje


-- Sentencia MERGE - Si existe actualiza, de lo contrario, inserta
MERGE INTO tgt_orders  t
USING       src_orders s
ON          (t.order_id = s.order_id)
WHEN MATCHED THEN
    UPDATE
       SET t.amount = s.amount              -- mutate existing rows
WHEN NOT MATCHED THEN
    INSERT (order_id, customer_id, amount)  -- insert new rows
    VALUES (s.order_id, s.customer_id, s.amount);


-- Generacion de inserts en una tabla
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

-- ################################################################
-- Generacion de cuadros con estructura de la tabla en README file
-- ################################################################
SELECT
    CASE WHEN COLUMN_ID = 1 
        THEN chr(13)||chr(10)||'# <span style="color:#203D7C">' || 
             replace(TABLE_NAME, '_', '&#95;') -- Reemplazo los guiones bajos porque Wiki no los reconoce
             || chr(10) ||
             '|<span style="color:#26B4BD">**Campo**|<span style="color:#26B4BD">**Tipo**|' || chr(10) ||
             '|--|--|' || chr(10) ELSE '' 
     END || '|' || 
     COLUMN_NAME || '|' || 
     DATA_TYPE  || '(' || 
     COALESCE(DATA_PRECISION,DATA_LENGTH) || 
     CASE WHEN DATA_SCALE IS NOT NULL 
          THEN ',' || DATA_SCALE 
          ELSE '' 
     END || ')' WIKI
FROM ALL_TAB_COLS
WHERE OWNER = 'OWNER'
ORDER BY TABLE_NAME, COLUMN_ID
;
