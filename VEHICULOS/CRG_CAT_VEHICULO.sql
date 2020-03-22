
CREATE OR REPLACE PROCEDURE `CRG_CAT_VEHICULO`(VAR_SCHEMA varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL) RETURNS void AS
/***********************************************************************************************************************
  * Descripcion: Cargar Datos DIM_AGENCIA
  * Version: 1.0.0
  * Fecha Creacion: 24/07/2019
  * Autor: Viviana Herrera
  * Comentario : Para Ejecutar = CALL CRG_DIM_AGENCIA('SQUEMA')
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
	INSERT INTO CTR.LOG_PROCESO (MODULO, ETAPA,DT_FECHA_INICIO) VALUES ('CATALOGO',CONCAT('INICIO ',VAR_SCHEMA,'.CRG_CAT_VEHICULO'),VAR_DT_INICIO);
	COMMIT;
	

	-- GUARDA EN UNA TABLA TEMPORAL LOS REGISTROS ACTUALIZADOS
	VAR_SQL=CONCAT('TRUNCATE TABLE ',VAR_SCHEMA,'.S3S_CAT_VEHICULO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;


	-- INSERTA LOS DATOS DE LA TMP1 A LA DIM
	VAR_SQL=CONCAT('	INSERT INTO ',VAR_SCHEMA,'.S3S_CAT_VEHICULO (COD_EMPRESA,COD_LINEA_NEGOCIO, CHASIS, PLACA, MARCA, ANIO_VEHICULO, SVMAMASTER, SFX, MODELO)
						SELECT * FROM 
							(	SELECT A.COD_EMPRESA,A.COD_LINEA_NEGOCIO ,A.CHASIS, B.PLACA, B.MARCA, B.ANIO_VEHICULO,B.SVMAMASTER,B.SFX, B.MODELO
								FROM
								(select MAX(B.FECHA) AS FECHA, A.NO_CIA AS COD_EMPRESA, A.CHASIS, B.LINEA_NEGOCIO AS COD_LINEA_NEGOCIO
										FROM ',VAR_SCHEMA,'.S3S_FAC_VENTAS_VEHICULOS A
										INNER JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB B ON A.NO_CIA = B.NO_CIA AND A.NO_FACTU = B.NO_FACTU  
										GROUP BY A.NO_CIA, B.LINEA_NEGOCIO, A.CHASIS)A
								LEFT JOIN		
								(select DISTINCT A.NO_CIA AS COD_EMPRESA, B.LINEA_NEGOCIO COD_LINEA_NEGOCIO, A.CHASIS, D.SVINPLACA AS PLACA, A.MARCA, A.ANOFABRI AS ANIO_VEHICULO, 
											A.SFX, NVL(A.SVMAMASTER, D.SVMAMASTER ) SVMAMASTER, NVL(C.SVMADESCRI ,D.SVMRMODE )  AS MODELO , B.FECHA
										FROM ',VAR_SCHEMA,'.S3S_FAC_VENTAS_VEHICULOS A
										LEFT JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB B ON A.NO_CIA = B.NO_CIA AND A.NO_FACTU = B.NO_FACTU 
										LEFT JOIN ',VAR_SCHEMA,'.S3S_SVFMASTER C ON A.NO_CIA = C.NO_CIA AND A.SVMAMASTER = C.SVMAMASTER AND A.SFX = C.SFX
										LEFT JOIN ',VAR_SCHEMA,'.S3S_SVFINVEN D ON A.NO_CIA = D.NO_CIA AND A.CHASIS = D.SVINCODI 
										 )B ON  A.FECHA = B.FECHA AND A.COD_EMPRESA = B.COD_EMPRESA AND A.CHASIS = B.CHASIS AND A.COD_LINEA_NEGOCIO = B.COD_LINEA_NEGOCIO
							UNION		
								SELECT A.COD_EMPRESA, "30" AS COD_LINEA_NEGOCIO, A.CHASIS, B.PLACA, B.MARCA, B.ANIO_VEHICULO,NULL SVMAMASTER , NULL SFX, B.MODELO
								FROM
									(SELECT A.NO_CIA AS COD_EMPRESA, CHASIS_NO AS CHASIS , MAX(C.FECHA_CREA) AS FECHA
									FROM ',VAR_SCHEMA,'.S3S_SE_VEHICULOS A
												INNER JOIN ',VAR_SCHEMA,'.S3S_SE_ORDENREP C ON A.NO_CIA = C.NO_CIA AND A.NUMCBS = C.NUMCBS 
												GROUP BY A.NO_CIA, A.CHASIS_NO )A
								LEFT JOIN						
									(SELECT DISTINCT A.NO_CIA AS COD_EMPRESA, CHASIS_NO AS CHASIS, B.DESCRIPCION AS MODELO, PLACA_ID AS PLACA, A.MARCA_ID AS MARCA, ANIO_VEHICULO AS ANIO_VEHICULO, C.FECHA_CREA AS FECHA
												FROM ',VAR_SCHEMA,'.S3S_SE_VEHICULOS A
												LEFT JOIN ',VAR_SCHEMA,'.S3S_SE_MODELOS B ON A.NO_CIA = B.NO_CIA AND A.MODELO_ID = B.MODELO_ID 
												INNER JOIN ',VAR_SCHEMA,'.S3S_SE_ORDENREP C ON A.NO_CIA = C.NO_CIA AND A.NUMCBS = C.NUMCBS)B
								ON A.COD_EMPRESA = B.COD_EMPRESA AND A.CHASIS = B.CHASIS AND A.FECHA = B.FECHA 
								UNION
								SELECT DISTINCT D.NO_CIA AS COD_EMPRESA ,D.SVLICODI AS COD_LINEA_NEGOCIO, D.SVINCODI  AS CHASIS, 
								D.SVINPLACA AS PLACA, D.SVMRCODI MARCA , D.SVINAFABR AS ANIO_VEHICULO, NVL(A.SVMAMASTER, D.SVMAMASTER ) SVMAMASTER , D.SFX, 
								NVL(C.SVMADESCRI , D.SVMRMODE ) AS MODELO 
								FROM ',VAR_SCHEMA,'.S3S_SVFINVEN D 
								LEFT JOIN  ',VAR_SCHEMA,'.S3S_FAC_VENTAS_VEHICULOS A ON A.NO_CIA = D.NO_CIA AND A.CHASIS = D.SVINCODI  
								LEFT JOIN ',VAR_SCHEMA,'.S3S_SVFMASTER C ON D.NO_CIA = C.NO_CIA AND D.SVMAMASTER = C.SVMAMASTER AND D.SFX = C.SFX
								WHERE A.CHASIS IS NULL AND D.SVINSTOCK = 1  )A	');
							
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

END;


