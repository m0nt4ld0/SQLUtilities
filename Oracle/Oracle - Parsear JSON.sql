-- Ejemplo de parseo de JSON con Oracle (Oracle 12 en adelante)
-- Estructura del JSON del ejemplo: 
-- {"stamped":true,"stamps":[{"whostamped":"0x08328a39f3c90C2f748610d0988a709E20Da5988","blocknumber":"23167711","blocktimestamp":1654716135}]}

SELECT json_value(response, '$.stamped' RETURNING VARCHAR2(32))
	,jt.*
	,response
FROM ax_cin_hashes
	,json_table(response, '$.stamps[*]' 
	    COLUMNS (whostamped  VARCHAR2(100) PATH '$.whostamped'
	,            blocknumber VARCHAR2(100) PATH '$.blocknumber' )) jt
;

