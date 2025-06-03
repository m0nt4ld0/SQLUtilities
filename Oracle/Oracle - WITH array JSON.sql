--WITH datos AS(
SELECT
  JSON_OBJECT( 'HASHES' VALUE b.hashes ) AS json
FROM(
  SELECT
     JSON_ARRAYAGG( a.cseti_hash ) AS hashes
  FROM(
     SELECT
        cseti_hash,
        FLOOR( RANK() OVER( ORDER BY cseti_hash ) / 40 ) AS grupo
     FROM
        ax_cin_hashes ) a
  GROUP BY a.grupo ) b
/*)
SELECT
   *
FROM
   datos
;*/