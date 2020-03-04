  CREATE OR REPLACE PROCEDURE `CRG_INT_VENTAS_EXONERADOS`(VAR_SCHEMA varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL, VAR_EMPRESA varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL, VAR_FECHA_INICIO date NULL, VAR_FECHA_FIN date NULL, VAR_LINEA_NEGOCIO_1 varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL) RETURNS void AS
/***********************************************************************************************************************
  * Descripcion: Cargar Datos INT_VENTAS_EXONERADOS
  * Version: 1.0.0
  * Fecha Creacion: 24/07/2019
  * Autor: Byron Vinueza
  * Comentario : Para Ejecutar = CALL CRG_INT_VENTAS_EXONERADOS('SQUEMA', 'EMPRESA', 'FECHA_INICIO', 'FECHA_FIN','LINEA_NEGOCIO')
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

	
	INSERT INTO CTR.LOG_PROCESO (MODULO, ETAPA,DT_FECHA_INICIO) VALUES ('INTERMEDIA',CONCAT('INICIO ',VAR_SCHEMA,'.CRG_INT_VENTAS_EXONERADOS'),VAR_DT_INICIO);
	COMMIT;

	VAR_SQL=CONCAT('DROP TABLE IF EXISTS ',VAR_SCHEMA,'.INT_VENTAS_EXONERADOS');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;
	
	VAR_SQL=CONCAT('CREATE TABLE ',VAR_SCHEMA,'.INT_VENTAS_EXONERADOS (KEY (COD_FACTURA) USING CLUSTERED COLUMNSTORE)
	AS  
SELECT  
	FECHA AS FECHA_FACTURA,COD_EMPRESA, SERIE_FISICO as COD_LINEA_NEGOCIO,COD_AGENCIA,TIPO_DOC AS COD_TIPO_DOCUMENTO,
	NO_VENDEDOR AS COD_VENDEDOR, NO_FACTU AS COD_FACTURA,
	NO_FISICO AS COD_NO_FISICO, NO_PEDIDO AS COD_COTIZACION,COD_TIPO_FORMA_PAGO, CHASIS AS COD_CHASIS, VERSION_VEH AS COD_VERSION_VEHICULO,
	NO_CLIENTE AS COD_CLIENTE, CLASE_VEHICULOS AS COD_CLASE_CLIENTE	, LINEA AS COD_ENTIDAD, PORCENTAJE_DISCAPACIDAD ,COD_TIPO_EXONERADO ,
	SUM(COSTO_VEHICULO)COSTO_VEHICULO, SUM(DESCUENTO)DESCUENTO,  
	SUM(SALDO_FINANCIAR) AS SALDO_FINANCIAR, SUM(CUOTA_DE_ALCANCE) AS CUOTA_DE_ALCANCE
	, SUM(NETO_VEH) PRECIO ,  SUM(COSTOS_IMPORT ) COSTOS_IMPORT , SUM(COMISON_SIN_IVA) COMISON_SIN_IVA , SUM(COMISION_CON_IVA) COMISION_CON_IVA
	FROM
	(select DISTINCT  A.FECHA, A.NO_FACTU, A.NO_FISICO, A.TIPO_DOC, A.NO_VENDEDOR, A.NBR_CLIENTE, A.CEDULA, B.CHASIS, E.SVMADESCRI AS MODELO, 
	NVL(A.LINEA, G.ENTIDAD) LINEA, A.NO_PEDIDO, NVL(I.VERSION_VEH, C.VERSION_ACC) AS VERSION_VEH,  I.SALDO_FINANCIAR, I.CUOTA_DE_ALCANCE, 
	I.NETO_VEH, I.PORCENTAJE_DISCAPACIDAD , TEX.ID_TIPO_EXONERADO AS COD_TIPO_EXONERADO  ,
	  B.DESCUENTO,  C.SVINCOSTDO COSTO_VEHICULO, 
	 IM.TOTAL COSTOS_IMPORT ,  CO.SUB_TOTAL COMISON_SIN_IVA , CO.TOTAL COMISION_CON_IVA ,
	DECODE(A.CENTRO_ORIGEN, NULL, A.CENTROD, A.CENTRO_ORIGEN) AS COD_AGENCIA, A.NO_CIA COD_EMPRESA, D.NO_CLIENTE, D.CLASE_VEHICULOS, A.SERIE_FISICO,
	DECODE(A.SALDO_FACTURA,0,"CON","CRE") COD_TIPO_FORMA_PAGO
	from ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB A
	INNER JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_VEHICULOS B ON A.NO_CIA = B.NO_CIA AND A.RUTA = B.RUTA AND A.TIPO_DOC = B.TIPO_DOC AND A.NO_FACTU = B.NO_FACTU
	INNER JOIN ',VAR_SCHEMA,'.S3S_SVFINVEN C ON B.NO_CIA = C.NO_CIA AND B.CHASIS = C.SVINCODI
	INNER JOIN ',VAR_SCHEMA,'.S3S_ARCCMC D ON A.NO_CIA = D.NO_CIA AND A.GRUPO = D.GRUPO AND A.NO_CLIENTE = D.NO_CLIENTE
	INNER JOIN ',VAR_SCHEMA,'.S3S_SVFMASTER E ON C.NO_CIA = E.NO_CIA AND C.SVMAMASTER = E.SVMAMASTER AND C.SFX = E.SFX
	INNER JOIN ',VAR_SCHEMA,'.S3S_AGENCIAS F ON A.NO_CIA = F.NO_CIA AND A.CENTROD = F.CODIGO
	INNER JOIN ',VAR_SCHEMA,'.S3S_ARCCTF G ON A.NO_CIA = G.NO_CIA AND A.LINEA = G.TIPO
	INNER JOIN ',VAR_SCHEMA,'.S3S_SVFTRANSA H ON A.NO_CIA = H.NO_CIA AND A.TIPO_DOC = H.SVTITIPO AND CAST(A.NO_FISICO AS UNSIGNED) = H.SVTRNUME AND A.CEDULA = H.SVTRCLCODI AND 
	B.CHASIS = H.SVINCODI AND CAST(A.FECHA AS DATE) = CAST(H.SVTRFECHA AS DATE)
	LEFT JOIN ',VAR_SCHEMA,'.S3S_SVFCOTI I ON  A.CENTROD = I.CENTRO AND A.NO_PEDIDO = I.NUMERO_COTIZACION AND I.SVLICODI = ',VAR_LINEA_NEGOCIO_1,' AND A.NO_CIA = I.NO_CIA
	LEFT JOIN ',VAR_SCHEMA,'.S3S_CAT_TIPO_EXONERADO TEX ON  I.TIPO_EXONERADO = TEX.TIPO_EXONERADO
 	LEFT JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB IM ON  A.NO_CIA = IM.NO_CIA  AND A.RUTA = IM.RUTA  AND A.CHASIS= IM.CHASIS  AND A.NO_PEDIDO= IM.NO_PEDIDO 
 	LEFT JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB CO ON  A.NO_CIA = CO.NO_CIA  AND A.RUTA = CO.RUTA  AND A.CHASIS= CO.CHASIS  AND A.NO_PEDIDO= CO.NO_PEDIDO 
	WHERE  A.NO_CIA = ',VAR_EMPRESA,'  AND A.SERIE_FISICO = ',VAR_LINEA_NEGOCIO_1,' AND NVL(A.IND_ANU_DEV,"X")<>"A"	
	AND IM.NO_CIA = ',VAR_EMPRESA,' AND IM.TIPO_DOC = "FC" AND IM.IMPUESTO = 0  AND  IM.SERIE_FISICO = ',VAR_LINEA_NEGOCIO_1,'
	AND CO.NO_CIA = ',VAR_EMPRESA,' AND CO.TIPO_DOC = "FC" AND CO.IMPUESTO > 0  AND  CO.SERIE_FISICO = ',VAR_LINEA_NEGOCIO_1,'
	AND CAST(A.FECHA AS DATE) BETWEEN "',VAR_FECHA_INICIO,'"   AND "',VAR_FECHA_FIN,'"
	AND NOT EXISTS ( SELECT 1 FROM ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB NC WHERE NC.NO_CIA = A.NO_CIA AND NC.NO_FISICO = A.REFER AND NC.LINEA_NEGOCIO = A.LINEA_NEGOCIO
						AND NC.TIPO_DOC = DECODE(A.KM,"NC", "FD", "AA") AND NC.CENTROD = A.CENTROD 
						AND TO_CHAR(NC.FECHA,"MM/YYYY") = TO_CHAR(A.FECHA,"MM/YYYY") AND NC.NO_FACTU_REFE = A.NO_FACTU AND NC.LINEA_NEGOCIO <>"7")
	AND NOT EXISTS 	(SELECT 1 FROM ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB NC WHERE NC.NO_CIA = A.NO_CIA AND NC.LINEA_NEGOCIO = A.LINEA_NEGOCIO
						AND NC.CENTROD = A.CENTROD
						AND TO_CHAR(NC.FECHA,"MM/YYYY") = TO_CHAR(A.FECHA,"MM/YYYY")  AND NC.NO_FACTU_REFE = A.NO_FACTU AND NC.LINEA_NEGOCIO <>"7")									
	)A 
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 ' );

		EXECUTE IMMEDIATE VAR_SQL;
		COMMIT;
	
	VAR_SQL=CONCAT( ' INSERT INTO  ',VAR_SCHEMA,'.INT_VENTAS_EXONERADOS 
	SELECT 	FECHA AS FECHA_FACTURA,COD_EMPRESA, LINEA_NEGOCIO as COD_LINEA_NEGOCIO,COD_AGENCIA,TIPO_DOC AS COD_TIPO_DOCUMENTO,
    NO_VENDEDOR AS COD_VENDEDOR, NO_FACTU AS COD_FACTURA, 
	NO_FISICO AS COD_NO_FISICO, NO_PEDIDO AS COD_COTIZACION,COD_TIPO_FORMA_PAGO,CHASIS AS COD_CHASIS, VERSION_VEH AS COD_VERSION_VEHICULO,
	NO_CLIENTE AS COD_CLIENTE, CLASE_VEHICULOS AS COD_CLASE_CLIENTE	, LINEA AS COD_ENTIDAD, PORCENTAJE_DISCAPACIDAD ,COD_TIPO_EXONERADO ,
	SUM(COSTO_VEHICULO)COSTO_VEHICULO, SUM(DESCUENTO)DESCUENTO,  
	SUM(SALDO_FINANCIAR) AS SALDO_FINANCIAR, SUM(CUOTA_DE_ALCANCE) AS CUOTA_DE_ALCANCE
	, SUM(NETO_VEH) PRECIO ,  SUM(COSTOS_IMPORT ) COSTOS_IMPORT , SUM(COMISON_SIN_IVA) COMISON_SIN_IVA , SUM(COMISION_CON_IVA) COMISION_CON_IVA
	FROM
	(select DISTINCT  A.FECHA, A.NO_FACTU, A.NO_FISICO, A.TIPO_DOC, A.NO_VENDEDOR, A.NBR_CLIENTE, A.CEDULA, B.CHASIS, E.SVMADESCRI AS MODELO, 
	NVL(A.LINEA, G.ENTIDAD) LINEA,  A.NO_PEDIDO, NVL(I.VERSION_VEH, C.VERSION_ACC) AS VERSION_VEH,I.SALDO_FINANCIAR, I.CUOTA_DE_ALCANCE, 
	I.NETO_VEH, I.PORCENTAJE_DISCAPACIDAD , TEX.ID_TIPO_EXONERADO AS COD_TIPO_EXONERADO  ,
	A.TOTAL AS SUBTOTAL_MASIVO, B.PRECIO, B.DESCUENTO,  A.SUB_TOTAL NETO, C.SVINCOSTDO COSTO_VEHICULO,
	 IM.TOTAL COSTOS_IMPORT ,  CO.SUB_TOTAL COMISON_SIN_IVA , CO.TOTAL COMISION_CON_IVA ,
	DECODE(A.CENTRO_ORIGEN, NULL, A.CENTROD, A.CENTRO_ORIGEN) AS COD_AGENCIA, A.NO_CIA AS COD_EMPRESA, D.NO_CLIENTE, D.CLASE_VEHICULOS, A.LINEA_NEGOCIO,
	DECODE(A.SALDO_FACTURA,0,"CON","CRE") COD_TIPO_FORMA_PAGO
	from ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB A
	INNER JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_VEHICULOS B ON A.NO_CIA = B.NO_CIA AND A.RUTA = B.RUTA AND A.TIPO_DOC = B.TIPO_DOC AND A.NO_FACTU = B.NO_FACTU
	INNER JOIN ',VAR_SCHEMA,'.S3S_SVFINVEN C ON B.NO_CIA = C.NO_CIA AND B.CHASIS = C.SVINCODI
	INNER JOIN ',VAR_SCHEMA,'.S3S_ARCCMC D ON A.NO_CIA = D.NO_CIA AND A.GRUPO = D.GRUPO AND A.NO_CLIENTE = D.NO_CLIENTE
	INNER JOIN ',VAR_SCHEMA,'.S3S_SVFMASTER E ON C.NO_CIA = E.NO_CIA AND C.SVMAMASTER = E.SVMAMASTER AND C.SFX = E.SFX
	INNER JOIN ',VAR_SCHEMA,'.S3S_AGENCIAS F ON A.NO_CIA = F.NO_CIA AND A.CENTROD = F.CODIGO
	INNER JOIN ',VAR_SCHEMA,'.S3S_ARCCTF G ON A.NO_CIA = G.NO_CIA AND A.LINEA = G.TIPO
	INNER JOIN ',VAR_SCHEMA,'.S3S_SVFTRANSA H ON A.NO_CIA = H.NO_CIA AND A.TIPO_DOC = H.SVTITIPO AND CAST(A.NO_FISICO AS UNSIGNED) = H.SVTRNUME AND A.CEDULA = H.SVTRCLCODI AND 
	B.CHASIS = H.SVINCODI AND CAST(A.FECHA AS DATE) = CAST(H.SVTRFECHA AS DATE)
	LEFT JOIN ',VAR_SCHEMA,'.S3S_SVFCOTI I ON  A.CENTROD = I.CENTRO AND A.NO_PEDIDO = I.NUMERO_COTIZACION AND I.SVLICODI = ',VAR_LINEA_NEGOCIO_1,' AND A.NO_CIA = I.NO_CIA
	LEFT JOIN ',VAR_SCHEMA,'.S3S_CAT_TIPO_EXONERADO TEX ON  I.TIPO_EXONERADO = TEX.TIPO_EXONERADO
	LEFT JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB IM ON  A.NO_CIA = IM.NO_CIA  AND A.RUTA = IM.RUTA  AND A.CHASIS= IM.CHASIS  AND A.NO_PEDIDO= IM.NO_PEDIDO 
 	LEFT JOIN ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB CO ON  A.NO_CIA = CO.NO_CIA  AND A.RUTA = CO.RUTA  AND A.CHASIS= CO.CHASIS  AND A.NO_PEDIDO= CO.NO_PEDIDO 
	WHERE  A.NO_CIA = ',VAR_EMPRESA,'  AND A.LINEA_NEGOCIO = ',VAR_LINEA_NEGOCIO_1,' AND NVL(A.IND_ANU_DEV,"X")<>"A"
	AND IM.NO_CIA = ',VAR_EMPRESA,' AND IM.TIPO_DOC = "FD" AND IM.IMPUESTO = 0  AND  IM.LINEA_NEGOCIO = ',VAR_LINEA_NEGOCIO_1,'
	AND CO.NO_CIA = ',VAR_EMPRESA,' AND CO.TIPO_DOC = "FD" AND CO.IMPUESTO > 0  AND  CO.LINEA_NEGOCIO = ',VAR_LINEA_NEGOCIO_1,'
	AND CAST(A.FECHA AS DATE) BETWEEN "',VAR_FECHA_INICIO,'"   AND "',VAR_FECHA_FIN,'" AND A.TIPO_DOC = "NE"
	AND NOT EXISTS (SELECT 1 FROM ',VAR_SCHEMA,'.S3S_FAC_VENTAS_CAB NC WHERE NC.NO_CIA = A.NO_CIA AND NC.NO_FISICO = A.REFER AND NC.LINEA_NEGOCIO = A.LINEA_NEGOCIO
						AND NC.TIPO_DOC = A.KM AND NC.CENTROD = A.CENTROD 
						AND TO_CHAR(NC.FECHA,"MM/YYYY") = TO_CHAR(A.FECHA,"MM/YYYY"))		
			)A
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 '	) ;

		EXECUTE IMMEDIATE VAR_SQL;
		COMMIT;
	END;






