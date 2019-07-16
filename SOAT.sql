-------------------------------------------------BUSCAR POLIZA POR PLACA-------------------------------------------------
SELECT (CHR(39) || pol.ideacuerdo || CHR(39)||','||CHR(39)||acuc.ideacuerdo || CHR(39)) CADENA, pol.refexterna, case when a.placavehiculo is not null then a.placavehiculo else ftec.valortxt end PLACA, coti.ideacuerdo as ACU_COT, case when coti.stsacuerdo=2 then 'Ct-CERR' when coti.stsacuerdo=1 then 'Ct-GEN' else 'Ct-ACT' end  AS EST      , coti.usucreacion, case when pol.stsacuerdo=5  then 'POL-ACT' when pol.stsacuerdo=1  then 'Pol-GEN' when pol.stsacuerdo=4  then 'POL-ANU' else 'POL-ON' end  AS EST, pol.ideacuerdo ACU_POL, pol.numero, case when acuc.stsacuerdo=5 then 'CER-ACT' when acuc.stsacuerdo=1 then 'Cer-GEN' when acuc.stsacuerdo=4 then 'POL-ANU' else 'CER-ON' end  AS EST, acuc.ideacuerdo ACU_CERT, acuc.numero, pol.fecemision, a.idptipdocumento AS TDOC, a.numdocumento, t.codexterno, a.corcontacto, t.nomcompleto, case when pp.idpformapago='SFP' then 'SFP' when pp.idpformapago='TAR' and pp.idecargo is not null then 'CUL' when pp.idpformapago='CON' then 'CON' when pp.idpformapago='TAR' then 'PAS' else '000' end AS PAGO, case when pp.idpformapago='SFP' then tn.estado when pp.idpformapago='TAR' and pp.idecargo is not null then c.stscargo when pp.idpformapago='CON' then 'ACT' when pp.idpformapago='TAR' then tsx.estadoproceso else '000' end AS STSPAGO,
    c.numeropedido, pp.fecha, c.idecargo, modelo.valortxt TIPO, pp.montocuota, c.numtarjeta
FROM app_iaa_acuerdo.acu_acuerdo acuc
    RIGHT JOIN app_iaa_acuerdo.acu_acuerdo coti ON acuc.idecotizacion=coti.ideacuerdo and coti.ideprod=acuc.ideprod and coti.idptipoacuseg='COT'
    LEFT JOIN app_iaa_acuerdo.acu_acuerdo pol ON pol.ideacuerdo=acuc.idemaestro left join app_iaa_comunes.cfg_insfictec  ftec on coti.ideacuerdo=ftec.codigo1 and ideatributo=169
    LEFT JOIN app_iaa_acuerdo.acu_rolacuerdo ra ON coti.ideacuerdo=ra.ideacuerdo inner join app_iaa_tercero.ter_roltercero rt ON ra.iderolter=rt.iderolter and rt.iderol = 10
    LEFT JOIN app_iaa_tercero.ter_tercero t ON rt.idetercero=t.idetercero and t.stster='ACT'
    LEFT JOIN app_iaa_interfaz.int_transaccion_ci_mtcapeseg  a on pol.refexterna=a.idepoliza left join app_iaa_acuerdo.acu_primerpago pp on pp.ideacuerdo = coti.ideacuerdo left join app_iaa_cobranza.clq_cargo  c on c.idecargo = pp.idecargo
    LEFT JOIN app_iaa_finanzas.trs_transaccion_negocio     tn on coti.ideacuerdo=tn.codigo1 left join app_iaa_finanzas.trs_transaccion_trx         tsx on pp.tokentrx=tsx.tokentrx
    LEFT JOIN app_iaa_comunes.cfg_insfictec modelo on modelo.codigo1=coti.ideacuerdo and modelo.ideatributo=110
WHERE coti.ideprod=3844 and coti.idptipoacuseg='COT'
    AND ftec.valortxt in ('D8D201');-->Placa
-- Columna EST_1 => indica el estado los cuales pueden ser [POL-{ACT|ANU|ON|GEN}] Donde=> GEN= GENERADO,ON=MODIFICADO O GENERADO, ACT = Activo

--Cuando no se ha efecuado correctamente una cotizacion, se debe seguir lo siguiente

-- 1-. Verificar el estado del pago y regularizar 2.- Enlazar el pago con la cotizacion 3.- Activar la Poliza
--Buscar transaccion
--Verificacion del estado del pago
SELECT *
FROM app_iaa_finanzas.trs_transaccion_trx trx
where trx.numtarjeta in('54529547')--> ideacuerdo cotizacion
;


--2.- En caso de que no exista el pago se debe enlazar el pago con la cotizacion
INSERT INTO app_iaa_acuerdo.acu_primerpago
    (IDEACUERDO, IDPMONEDACUOTA, MONTOCUOTA, NROVOUCHER, FECHA, IDPMONEDAVOUCHER, MONTOVOUCHER, TIPOCAMBIO, STSVOUCHER, USUCREACION, FECCREACION, USUMODIF, FECMODIF, IDPFORMAPAGO, IDPMARCATARJETA, IDEBANCO, TOKENTRX, IDECARGO)
values
    (54358545, 'SOL', 79.0000, ' ', sysdate, 'SOL', 79.0000, 3.4000, 'ACT', 'DS_ASESOR_PD', sysdate, 'DS_ASESOR_PD', sysdate, 'SFP', 'SFP', null, '09ffa98e-af9a-462c-a2cb-af14f0c81b47', null);

--3.-Verificar Pago (OPCIONAL)
select *
from app_iaa_acuerdo.acu_primerpago
where ideacuerdo = 54358545;--> ideacuerdo cotizacion

 --4.- Enviar a la URL http://soatdigital.rimac.com.pe/SOATDIGITAL/servicesSD/soatFlujoCompleto.do el siguiente cuerpo para
 -- la activacion de la poliza
 -- activacion ingresando los datos correspondientes (Revisar el documento CASOS SOAT)
 /*
{
  "ideacuerdo":"54358545",//
  "usuario":"CR1IQUICHED"
}
 */