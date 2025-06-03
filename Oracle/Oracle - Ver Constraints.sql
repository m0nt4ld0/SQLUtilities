-- Ver constraints en un esquema Oracle
SELECT
    a.owner,
    a.constraint_name,
    a.table_name,
    a.CONSTRAINT_TYPE,
    a.STATUS
FROM
    user_constraints a
WHERE
    a.constraint_type = 'R'
    AND a.r_constraint_name IN (
        SELECT constraint_name
        FROM user_constraints
        WHERE OWNER = upper('&owner')
    );
