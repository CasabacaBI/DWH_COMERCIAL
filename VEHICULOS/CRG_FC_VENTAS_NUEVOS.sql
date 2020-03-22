SHOW CREATE PROCEDURE CRG_FC_VENTAS_NUEVOS;
CREATE OR REPLACE PROCEDURE `CRG_FC_VENTAS_NUEVOS`(VAR_SCHEMA varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL, VAR_EMPRESA varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL, VAR_FECHA_INICIO date NULL, VAR_FECHA_FIN date NULL) RETURNS void AS
/***********************************************************************************************************************
  * Descripcion: Cargar Datos FC_TALLERES
  * Version: 1.0.0
  * Fecha Creacion: 24/07/2019
  * Autor: Viviana Herrera
  * Comentario : Para Ejecutar = CALL CRG_FC_VENTAS_NUEVOS(DSA,'01','FI','FF )
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
	INSERT INTO CTR.LOG_PROCESO (MODULO, ETAPA,DT_FECHA_INICIO) VALUES ('TABLA DE HECHOS',CONCAT('INICIO ',VAR_SCHEMA,'.CRG_FC_VENTAS_NUEVOS'),VAR_DT_INICIO);
	COMMIT;

	VAR_SQL=CONCAT('DELETE FROM DWH.FC_VENTAS_NUEVOS A 
					WHERE A.SK_EMPRESA = (SELECT SK_EMPRESA FROM DWH.DIM_EMPRESA WHERE COD_EMPRESA = ',VAR_EMPRESA,')
					AND SK_FECHA_FACTURA >= (SELECT SK_FECHA FROM DWH.DIM_FECHA WHERE FECHA = "',VAR_FECHA_INICIO,'") 
					AND SK_FECHA_FACTURA <= (SELECT SK_FECHA FROM DWH.DIM_FECHA WHERE FECHA = "',VAR_FECHA_FIN,'") ') ;
	EXECUTE IMMEDIATE VAR_SQL;			
	COMMIT;

		VAR_SQL=CONCAT('INSERT INTO DWH.FC_VENTAS_NUEVOS
		SELECT NVL(M.SK_FECHA,"19700101") AS SK_FECHA_FACTURA, NVL(B.SK_EMPRESA,1)SK_EMPRESA, NVL(C.SK_LINEA_NEGOCIO,1)SK_LINEA_NEGOCIO, NVL(D.SK_AGENCIA,1)SK_AGENCIA,  
		NVL(E.SK_TIPO_DOCUMENTO,1)SK_TIPO_DOCUMENTO, NVL(F.SK_VENDEDOR,1)SK_VENDEDOR, NVL(G.SK_VERSION_VEHICULO,1)SK_VERSION_VEHICULO, NVL(H.SK_FORMA_PAGO, 1)SK_FORMA_PAGO,
		NVL(I.SK_VEHICULO,1)SK_VEHICULO, NVL(N.SK_VEHICULO_INTERES,1) SK_VEHICULO_INTERES ,NVL(J.SK_CLIENTE, 1)SK_CLIENTE, NVL(K.SK_CLASE_CLIENTE,1)SK_CLASE_CLIENTE, NVL(L.SK_TIPO_FINANCIACION,1)SK_TIPO_FINANCIACION,
		NVL(A.COD_COTIZACION,"NO DFINIDO") AS SK_COTIZACION, NVL(A.COD_NO_FISICO,"NO DEFINIDO") AS SK_NO_FISICO, NVL(A.COD_FACTURA,"NO DEFINIDO") AS SK_FACTURA, 
		NVL(A.COSTO_VEHICULO,0)COSTO_VEHICULO, NVL(A.DESCUENTO,0)DESCUENTO, NVL(A.PRECIO,0)PRECIO, NVL(A.SUBTOTAL_MASIVO,0)SUBTOTAL_MASIVO,
		NVL(A.UTILIDAD,0) UTILIDAD, NVL(A.VALOR_NETO,0) VALOR_NETO, NVL(SALDO_FINANCIAR,0) AS SALDO_FINANCIAR, NVL(COUTA_DE_ALCANCE,0) AS COUTA_DE_ALCANCE
		FROM DSA.INT_VENTAS_NUEVOS A
		LEFT JOIN DWH.DIM_EMPRESA B ON A.COD_EMPRESA = B.COD_EMPRESA
		LEFT JOIN DWH.DIM_LINEA_NEGOCIO C ON A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_LINEA_NEGOCIO = C.COD_LINEA_NEGOCIO
		LEFT JOIN DWH.DIM_AGENCIA D ON A.COD_EMPRESA = D.COD_EMPRESA AND A.COD_AGENCIA = D.COD_AGENCIA
		LEFT JOIN DWH.DIM_TIPO_DOCUMENTO E ON A.COD_EMPRESA = E.COD_EMPRESA AND A.COD_TIPO_DOCUMENTO = E.COD_TIPO_DOCUMENTO 
		LEFT JOIN DWH.DIM_VENDEDOR F ON A.COD_EMPRESA = F.COD_EMPRESA AND A.COD_VENDEDOR = F.COD_VENDEDOR
		LEFT JOIN DWH.DIM_VERSION_VEHICULO G ON A.COD_EMPRESA = G.COD_EMPRESA AND A.COD_VERSION_VEHICULO = G.COD_VERSION_VEHICULO
		LEFT JOIN DWH.DIM_FORMA_PAGO H ON A.COD_TIPO_FORMA_PAGO = H.COD_FORMA_PAGO
		LEFT JOIN DWH.DIM_VEHICULO I ON A.COD_EMPRESA = I.COD_EMPRESA AND A.COD_CHASIS = I.CHASIS AND A.COD_LINEA_NEGOCIO = I.COD_LINEA_NEGOCIO
		LEFT JOIN DWH.DIM_CLIENTE J ON A.COD_EMPRESA = J.COD_EMPRESA AND A.COD_CLIENTE = J.COD_CLIENTE
		LEFT JOIN DWH.DIM_CLASE_CLIENTE K ON A.COD_EMPRESA = K.COD_EMPRESA AND A.COD_CLASE_CLIENTE = K.COD_CLASE_CLIENTE AND K.COD_LINEA_NEGOCIO = "VEH" 
		LEFT JOIN DWH.DIM_TIPO_FINANCIACION L ON A.COD_EMPRESA = L.COD_EMPRESA AND A.COD_ENTIDAD = L.COD_TIPO_FINANCIACION 
		LEFT JOIN DWH.DIM_FECHA M ON CAST(A.FECHA_FACTURA AS DATE) = M.FECHA
	 	LEFT join DWH.DIM_VEHICULOS_INTERES N ON A.COD_VEHICULO_INTERES = N.COD_VEHICULO_INTERES		
		WHERE 
				CAST(A.FECHA_FACTURA AS DATE) >= "',VAR_FECHA_INICIO,'" AND
				CAST(A.FECHA_FACTURA AS DATE) <= "',VAR_FECHA_FIN,'"  AND
				A.COD_EMPRESA = ',VAR_EMPRESA,'
		') ;
	EXECUTE IMMEDIATE VAR_SQL;	
	COMMIT;



END;





