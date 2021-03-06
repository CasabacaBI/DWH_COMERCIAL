CREATE PROCEDURE `CRG_DIM_CONTACTO`(VAR_SCHEMA varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL) RETURNS void AS
/***********************************************************************************************************************
  * Descripcion: Cargar Datos DIM_CONTACTO
  * Version: 1.0.0
  * Fecha Creacion: 23/01/2020
  * Autor: Ivan Suasnavas
  * Comentario : Para Ejecutar = CALL CRG_DIM_CONTACTO('SQUEMA')
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
	INSERT INTO CTR.LOG_PROCESO (MODULO, ETAPA,DT_FECHA_INICIO) VALUES ('DIMENSION',CONCAT('INICIO ',VAR_SCHEMA,'.CRG_DIM_CONTACTO'),VAR_DT_INICIO);
	COMMIT;

	VAR_SQL=CONCAT('DROP TABLE IF EXISTS DSA.TMP_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;	

	VAR_SQL=CONCAT('DROP TABLE IF EXISTS DSA.TMP_DM_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;	

	VAR_SQL=CONCAT('CREATE TABLE DSA.TMP_DM_CONTACTO
					SELECT DISTINCT
				CC.id_cliente_c AS COD_CLIENTE
				, MAX(T.DATE_ENTERED) DATE_ENTERED
 				, "01" AS COD_EMPRESA
 				, CONCAT_WS(" ",C.first_name, C.last_name) AS NOMBRE
 				, CONCAT_WS(" ",CC.calle_principal_c, CC.calle_secundaria_c) DIRECCION
 				, C.phone_home AS TELEFONO
 				, C.phone_mobile AS TELEFONO2
				, T.email AS EMAIL1
 				, CC.numero_identificacion_c AS CEDULA
 				, CC.nacionalidad_c AS PAIS
 				, CC.provincia_c AS PROVINCIA
				from 
				DSA.CRM_CB_TRAFICOCONTROL T
				LEFT JOIN DSA.CRM_CB_TRAFICOCONTROL_CONTACTS_C TC ON T.id = TC.cb_traficocontrol_contactscb_traficocontrol_ida
				LEFT JOIN DSA.CRM_CONTACTS C ON TC.cb_traficocontrol_contactscontacts_idb = C.id
				LEFT JOIN DSA.CRM_CONTACTS_CSTM CC ON TC.cb_traficocontrol_contactscontacts_idb = CC.id_c 
				WHERE CC.id_cliente_c > 0 AND (TC.id IS NOT NULL AND C.id IS NOT NULL AND CC.id_c IS NOT NULL)
				GROUP BY CC.numero_identificacion_c');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

-- GUARDA EN UNA TABLA TEMPORAL LOS REGISTROS ACTUALIZADOS
	VAR_SQL=CONCAT('CREATE TABLE DSA.TMP_CONTACTO  
	SELECT  R.SK_CONTACTO,R.COD_EMPRESA
	,IF(NVL(P.COD_CLIENTE,R.COD_CLIENTE)=R.COD_CLIENTE,R.COD_CLIENTE,P.COD_CLIENTE) COD_CLIENTE
	,IF(NVL(P.NOMBRE,R.NOMBRE)=R.NOMBRE,R.NOMBRE,P.NOMBRE) NOMBRE
	,IF(NVL(P.DIRECCION,R.DIRECCION)=R.DIRECCION,R.DIRECCION,P.DIRECCION) DIRECCION
	,IF(NVL(P.TELEFONO,R.TELEFONO)=R.TELEFONO,R.TELEFONO,P.TELEFONO) TELEFONO
	,IF(NVL(P.TELEFONO2,R.TELEFONO2)=R.TELEFONO2,R.TELEFONO2,P.TELEFONO2) TELEFONO2
	,IF(NVL(P.EMAIL1,R.EMAIL1)=R.EMAIL1,R.EMAIL1,P.EMAIL1) EMAIL1
	,IF(NVL(P.CEDULA,R.CEDULA)=R.CEDULA,R.CEDULA,P.CEDULA) CEDULA
	,IF(NVL(P.PAIS,R.PAIS)=R.PAIS,R.PAIS,P.PAIS) PAIS
	,IF(NVL(P.PROVINCIA,R.PROVINCIA)=R.PROVINCIA,R.PROVINCIA,P.PROVINCIA) PROVINCIA
	,IF(NVL(P.NOMBRE,R.NOMBRE)=R.NOMBRE,R.FECHA_CARGA,CURRENT_TIMESTAMP) FECHA_CARGA
	FROM DWH.DIM_CONTACTO R
	LEFT JOIN DSA.TMP_DM_CONTACTO P 
	ON R.COD_EMPRESA = P.COD_EMPRESA AND R.CEDULA = P.CEDULA			
	');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;
	
	-- ELIMINA LOS DATOS DE LA DIM
	VAR_SQL=CONCAT('TRUNCATE TABLE DWH.DIM_CONTACTO');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;
	
	-- INSERTA LOS DATOS DE LA TMP A LA DIM
	VAR_SQL=CONCAT('INSERT INTO DWH.DIM_CONTACTO
	  (SK_CONTACTO,COD_CLIENTE,COD_EMPRESA,NOMBRE,DIRECCION,TELEFONO,TELEFONO2,EMAIL1,CEDULA,PAIS,PROVINCIA,FECHA_CARGA)
          SELECT  A.SK_CONTACTO,A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA,A.FECHA_CARGA
	  FROM DSA.TMP_CONTACTO A');
	  EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('TRUNCATE TABLE DSA.TMP_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

VAR_SQL=CONCAT('CREATE TABLE DSA.TMP_DM_CONTACTO1
				SELECT DISTINCT
				CC.id_cliente_c AS COD_CLIENTE
				, MAX(T.DATE_ENTERED) DATE_ENTERED
 				, "01" AS COD_EMPRESA
 				, CONCAT_WS(" ",C.first_name, C.last_name) AS NOMBRE
 				, CONCAT_WS(" ",CC.calle_principal_c, CC.calle_secundaria_c) DIRECCION
 				, C.phone_home AS TELEFONO
 				, C.phone_mobile AS TELEFONO2
				, T.email AS EMAIL1
 				, CC.numero_identificacion_c AS CEDULA
 				, CC.nacionalidad_c AS PAIS
 				, CC.provincia_c AS PROVINCIA
				from 
				CRM_CB_TRAFICOCONTROL T
	LEFT JOIN CRM_CB_NEGOCIACION_CB_TRAFICOCONTROL_C NT ON T.id = NT.cb_negociacion_cb_traficocontrolcb_traficocontrol_idb
	LEFT JOIN CRM_CB_NEGOCIACION N ON NT.cb_negociacion_cb_traficocontrolcb_negociacion_ida = N.id
	LEFT JOIN CRM_CB_NEGOCIACION_CONTACTS_C NC ON N.id = NC.cb_negociacion_contactscb_negociacion_idb
	LEFT JOIN CRM_CONTACTS C ON NC.cb_negociacion_contactscontacts_ida = C.id
	LEFT JOIN CRM_CONTACTS_CSTM CC ON C.id = CC.id_c 
	WHERE CC.id_cliente_c > 0 AND (N.id IS NOT NULL AND NC.id IS NOT NULL AND C.id IS NOT NULL AND CC.id_c IS NOT NULL)
	GROUP BY CC.numero_identificacion_c');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;
	
VAR_SQL=CONCAT('INSERT INTO DSA.TMP_CONTACTO  
	SELECT R.SK_CONTACTO,R.COD_EMPRESA
	,IF(NVL(P.COD_CLIENTE,R.COD_CLIENTE)=R.COD_CLIENTE,R.COD_CLIENTE,P.COD_CLIENTE) COD_CLIENTE
	,IF(NVL(P.NOMBRE,R.NOMBRE)=R.NOMBRE,R.NOMBRE,P.NOMBRE) NOMBRE
	,IF(NVL(P.DIRECCION,R.DIRECCION)=R.DIRECCION,R.DIRECCION,P.DIRECCION) DIRECCION
	,IF(NVL(P.TELEFONO,R.TELEFONO)=R.TELEFONO,R.TELEFONO,P.TELEFONO) TELEFONO
	,IF(NVL(P.TELEFONO2,R.TELEFONO2)=R.TELEFONO2,R.TELEFONO2,P.TELEFONO2) TELEFONO2
	,IF(NVL(P.EMAIL1,R.EMAIL1)=R.EMAIL1,R.EMAIL1,P.EMAIL1) EMAIL1
	,IF(NVL(P.CEDULA,R.CEDULA)=R.CEDULA,R.CEDULA,P.CEDULA) CEDULA
	,IF(NVL(P.PAIS,R.PAIS)=R.PAIS,R.PAIS,P.PAIS) PAIS
	,IF(NVL(P.PROVINCIA,R.PROVINCIA)=R.PROVINCIA,R.PROVINCIA,P.PROVINCIA) PROVINCIA
	,IF(NVL(P.NOMBRE,R.NOMBRE)=R.NOMBRE,R.FECHA_CARGA,CURRENT_TIMESTAMP) FECHA_CARGA
	FROM DWH.DIM_CONTACTO R
	LEFT JOIN DSA.TMP_DM_CONTACTO1 P 
	ON R.COD_EMPRESA = P.COD_EMPRESA AND R.CEDULA = P.CEDULA			
	');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- ELIMINA LOS DATOS DE LA DIM
	VAR_SQL=CONCAT('TRUNCATE TABLE DWH.DIM_CONTACTO');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA LOS DATOS DE LA TMP A LA DIM
	VAR_SQL=CONCAT('INSERT INTO DWH.DIM_CONTACTO
	  (SK_CONTACTO,COD_CLIENTE,COD_EMPRESA,NOMBRE,DIRECCION,TELEFONO,TELEFONO2,EMAIL1,CEDULA,PAIS,PROVINCIA,FECHA_CARGA)
          SELECT  A.SK_CONTACTO,A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA,A.FECHA_CARGA
	  FROM DSA.TMP_CONTACTO A');
	  EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('DROP TABLE IF EXISTS DSA.TMP_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA TMP 
	VAR_SQL=CONCAT('CREATE TABLE DSA.TMP_CONTACTO
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA
			FROM DSA.TMP_DM_CONTACTO A
     ');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA DIM 
	VAR_SQL=CONCAT('INSERT INTO DWH.DIM_CONTACTO
		(COD_CLIENTE,COD_EMPRESA,NOMBRE,DIRECCION,TELEFONO,TELEFONO2,EMAIL1,CEDULA,PAIS,PROVINCIA)
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA 
		FROM DSA.TMP_CONTACTO A
		LEFT JOIN DWH.DIM_CONTACTO B ON A.COD_EMPRESA = B.COD_EMPRESA AND A.CEDULA = B.CEDULA
		WHERE B.NOMBRE IS NULL 
		');
	 	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('TRUNCATE TABLE DSA.TMP_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA TMP 
	VAR_SQL=CONCAT('INSERT INTO DSA.TMP_CONTACTO
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA
			FROM DSA.TMP_DM_CONTACTO1 A
     ');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA DIM 
	VAR_SQL=CONCAT('INSERT INTO DWH.DIM_CONTACTO
		(COD_CLIENTE,COD_EMPRESA,NOMBRE,DIRECCION,TELEFONO,TELEFONO2,EMAIL1,CEDULA,PAIS,PROVINCIA)
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA 
		FROM DSA.TMP_CONTACTO A
		LEFT JOIN DWH.DIM_CONTACTO B ON A.COD_EMPRESA = B.COD_EMPRESA AND A.CEDULA = B.CEDULA
		WHERE B.NOMBRE IS NULL 
		');
	 	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('TRUNCATE TABLE DSA.TMP_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA TMP 
	VAR_SQL=CONCAT('INSERT INTO DSA.TMP_CONTACTO
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA
			FROM DSA.TMP_DM_CONTACTO A
     ');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA DIM 
	VAR_SQL=CONCAT('INSERT INTO DWH.DIM_CONTACTO
		(COD_CLIENTE,COD_EMPRESA,NOMBRE,DIRECCION,TELEFONO,TELEFONO2,EMAIL1,CEDULA,PAIS,PROVINCIA)
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA 
		FROM DSA.TMP_CONTACTO A
		LEFT JOIN DWH.DIM_CONTACTO B ON A.COD_EMPRESA = B.COD_EMPRESA AND A.CEDULA = B.CEDULA
		WHERE B.NOMBRE IS NULL 
		');
	 	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('TRUNCATE TABLE DSA.TMP_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA TMP 
	VAR_SQL=CONCAT('INSERT INTO DSA.TMP_CONTACTO
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA
			FROM DSA.TMP_DM_CONTACTO1 A
     ');
	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	-- INSERTA NUEVOS REGISTROS A LA DIM 
	VAR_SQL=CONCAT('INSERT INTO DWH.DIM_CONTACTO
		(COD_CLIENTE,COD_EMPRESA,NOMBRE,DIRECCION,TELEFONO,TELEFONO2,EMAIL1,CEDULA,PAIS,PROVINCIA)
		SELECT A.COD_CLIENTE,A.COD_EMPRESA,A.NOMBRE,A.DIRECCION,A.TELEFONO,A.TELEFONO2,A.EMAIL1,A.CEDULA,A.PAIS,A.PROVINCIA 
		FROM DSA.TMP_CONTACTO A
		LEFT JOIN DWH.DIM_CONTACTO B ON A.COD_EMPRESA = B.COD_EMPRESA AND A.CEDULA = B.CEDULA
		WHERE B.NOMBRE IS NULL 
		');
	 	EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('DROP TABLE IF EXISTS DSA.TMP_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('DROP TABLE IF EXISTS DSA.TMP_DM_CONTACTO');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

	VAR_SQL=CONCAT('DROP TABLE IF EXISTS DSA.TMP_DM_CONTACTO1');
	 EXECUTE IMMEDIATE VAR_SQL;
	COMMIT;

END;
	