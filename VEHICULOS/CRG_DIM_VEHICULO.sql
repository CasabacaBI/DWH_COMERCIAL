CREATE OR REPLACE  PROCEDURE `CRG_DIM_VEHICULO`(VAR_SCHEMA varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL) RETURNS void AS
/***********************************************************************************************************************
  * Descripcion: Cargar Datos DIM_CLIENTE
  * Version: 1.0.0
  * Fecha Creacion: 29/07/2019
  * Autor: Marco Palacios
  * Comentario : Para Ejecutar = CALL CRG_DIM_CLIENTE('SQUEMA')
  -------------------------------------------------------------------------
  * Fecha Modificacion:
  * Modificado:
*************************************************************************************************************************/
DECLARE
	VAR_SQL VARCHAR(4000);
	VAR_ERROR VARCHAR(4000);
	VAR_DT_INICIO TIMESTAMP = CURRENT_TIMESTAMP;
BEGIN
START TRANSACTION;
	INSERT INTO CTR.LOG_PROCESO (MODULO, ETAPA,DT_FECHA_INICIO) VALUES ('DIMENSION',CONCAT('INICIO ',VAR_SCHEMA,'.CRG_DIM_VEHICULO'),VAR_DT_INICIO);
	COMMIT;
	
	VAR_SQL=CONCAT('DROP TABLE IF EXISTS ',VAR_SCHEMA,'.TMP1_VEHICULO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- GUARDA EN UNA TABLA TEMPORAL LOS REGISTROS ACTUALIZADOS
	VAR_SQL=CONCAT('CREATE TABLE ',VAR_SCHEMA,'.TMP1_VEHICULO
	SELECT  R.SK_VEHICULO,R.COD_VEHICULO, R.COD_EMPRESA, R.COD_LINEA_NEGOCIO, R.CHASIS
	,IF(NVL(P.PLACA,R.PLACA)=R.PLACA,R.PLACA,P.PLACA) PLACA 
	,IF(NVL(P.MARCA,R.MARCA)=R.MARCA,R.MARCA,P.MARCA) MARCA 
	,IF(NVL(P.ANIO_VEHICULO,R.ANIO_VEHICULO)=R.ANIO_VEHICULO,R.ANIO_VEHICULO,P.ANIO_VEHICULO) ANIO_VEHICULO 
	,IF(NVL(P.SVMAMASTER,R.SVMAMASTER)=R.SVMAMASTER,R.SVMAMASTER,P.SVMAMASTER) SVMAMASTER
	,IF(NVL(P.SFX,R.SFX)=R.SFX,R.SFX,P.SFX) SFX
    ,IF(NVL(P.MODELO,R.MODELO)=R.MODELO,R.MODELO,P.MODELO) MODELO 
	,IF(NVL(P.PLACA,R.PLACA)=R.PLACA,R.FECHA_CARGA,CURRENT_TIMESTAMP) FECHA_CARGA
	FROM DWH.DIM_VEHICULO R
	LEFT JOIN ',VAR_SCHEMA,'.S3S_CAT_VEHICULO P ON R.COD_EMPRESA = P.COD_EMPRESA AND R.COD_LINEA_NEGOCIO = P.COD_LINEA_NEGOCIO AND R.CHASIS = P.CHASIS				
	');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- ELIMINA LOS DATOS DE LA DIM
	VAR_SQL=CONCAT('TRUNCATE TABLE DWH.DIM_VEHICULO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA LOS DATOS DE LA TMP1 A LA DIM
	VAR_SQL=CONCAT('	INSERT INTO DWH.DIM_VEHICULO
	(SK_VEHICULO, COD_VEHICULO, COD_EMPRESA, COD_LINEA_NEGOCIO, CHASIS, PLACA, MARCA,ANIO_VEHICULO ,SVMAMASTER ,SFX, MODELO)
	SELECT A.SK_VEHICULO, A.COD_VEHICULO, A.COD_EMPRESA, A.COD_LINEA_NEGOCIO, A.CHASIS, NVL(A.PLACA,"NO DEFINIDO"), NVL(A.MARCA,"NO DEFINIDO"),
	NVL(A.ANIO_VEHICULO,"NO DEFINIDO") , NVL(A.SVMAMASTER,"NO DEFINIDO"), NVL(A.SFX,"NO DEFINIDO"), NVL(A.MODELO,"NO DEFINIDO")
	FROM ',VAR_SCHEMA,'.TMP1_VEHICULO A	
	');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;
	
	VAR_SQL=CONCAT('DROP TABLE IF EXISTS ',VAR_SCHEMA,'.TMP1_VEHICULO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

		-- INSERTA NUEVOS REGISTROS A LA DIM 
	VAR_SQL=CONCAT('INSERT INTO DWH.DIM_VEHICULO
		(COD_VEHICULO, COD_EMPRESA, COD_LINEA_NEGOCIO, CHASIS, PLACA, MARCA,ANIO_VEHICULO,SVMAMASTER ,SFX, MODELO)
		SELECT A.COD_VEHICULO, A.COD_EMPRESA, A.COD_LINEA_NEGOCIO, A.CHASIS, NVL(A.PLACA,"NO DEFINIDO"), NVL(A.MARCA,"NO DEFINIDO"), 
		NVL(A.ANIO_VEHICULO,"NO DEFINIDO"), NVL(A.SVMAMASTER,"NO DEFINIDO"),NVL(A.SFX,"NO DEFINIDO"), NVL(A.MODELO, "NO DEFINIDO")
		FROM ',VAR_SCHEMA,'.S3S_CAT_VEHICULO A
		LEFT JOIN DWH.DIM_VEHICULO B ON A.COD_LINEA_NEGOCIO = B.COD_LINEA_NEGOCIO AND A.COD_EMPRESA = B.COD_EMPRESA AND A.CHASIS = B.CHASIS
		WHERE B.COD_EMPRESA IS NULL
		');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;


END;