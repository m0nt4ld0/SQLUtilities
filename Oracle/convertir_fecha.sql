
-- =================================================================
-- Author:      Mariela Montaldo
-- Create date: 
-- Description: CONVERSION DE FECHAS EXPRESADAS EN PALABRAS A DATE
-- =================================================================

CREATE OR REPLACE FUNCTION convertir_fecha(p_fecha_str IN VARCHAR2)
RETURN DATE
IS
    v_fecha_str VARCHAR2(100);
    v_fecha DATE;
    v_mes VARCHAR2(20);
BEGIN
     -- Verificar si la cadena está en formato dd/mm/yyyy
    IF REGEXP_LIKE(p_fecha_str, '^\d{1,2}/\d{1,2}/\d{4}$') THEN
        -- Convertir directamente si es formato dd/mm/yyyy
        v_fecha := TO_DATE(p_fecha_str, 'DD/MM/YYYY');
    ELSE
        -- Reemplazar 'de ' con un espacio
        v_fecha_str := REGEXP_REPLACE(p_fecha_str, ' (de|del mes de|del año|del) ', ' ');
        
        -- Obtener el nombre del mes en la cadena
        v_mes := REGEXP_SUBSTR(v_fecha_str, '[A-Za-z]+', 2, 1, NULL, 1);
        
        -- Reemplazar el nombre del mes en español por su abreviatura en inglés
        v_fecha_str := REPLACE(v_fecha_str, v_mes, 
                               CASE v_mes
                                   WHEN 'Enero' THEN 'JAN'
                                   WHEN 'Febrero' THEN 'FEB'
                                   WHEN 'Marzo' THEN 'MAR'
                                   WHEN 'Abril' THEN 'APR'
                                   WHEN 'Mayo' THEN 'MAY'
                                   WHEN 'Junio' THEN 'JUN'
                                   WHEN 'Julio' THEN 'JUL'
                                   WHEN 'Agosto' THEN 'AUG'
                                   WHEN 'Septiembre' THEN 'SEP'
                                   WHEN 'Octubre' THEN 'OCT'
                                   WHEN 'Noviembre' THEN 'NOV'
                                   WHEN 'Diciembre' THEN 'DEC'
                                   ELSE 'UNKNOWN'
                               END);
        -- Convertir la cadena a tipo DATE
        v_fecha := TO_DATE(v_fecha_str, 'DD MON YYYY');
    end if;
    RETURN v_fecha;
EXCEPTION
    WHEN OTHERS THEN
        -- Manejo de errores si la conversión falla
        DBMS_OUTPUT.PUT_LINE('Error al convertir la fecha: ' || SQLERRM);
        RETURN NULL;
END;
/
