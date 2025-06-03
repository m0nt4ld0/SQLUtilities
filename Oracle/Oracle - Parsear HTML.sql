SELECT * FROM ax_xxx_htmls order by 1;

SELECT
    TRIM( REGEXP_REPLACE( a.id_banco, '[[:alpha:]<>/]', '' ) ) AS codigo,
    TRIM( REGEXP_REPLACE( a.desc_banco, '[<>/(td)]', '' ) ) AS denominacion
FROM(
    SELECT
        ROW_NUMBER() OVER( ORDER BY nro_linea ) AS nro_linea,
        linea AS id_banco,
        LEAD( linea ) OVER( ORDER BY nro_linea ) AS desc_banco
    FROM
        ax_xxx_htmls
    WHERE
        origen = 'ENTIDADES BANCARIAS'
        AND ( REGEXP_LIKE( linea, '.<td.>.[[:digit:]]', 'i' )
        OR REGEXP_LIKE( linea, '.<td.>.[[:alpha:]]', 'i' ) )
    ORDER BY nro_linea 
) a
WHERE MOD( nro_linea, 2 ) = 1
;