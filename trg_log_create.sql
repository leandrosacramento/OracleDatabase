--TABELA DE LOG
CREATE TABLE tb_log_create
(
    dt_execucao      DATE
   ,nm_database      VARCHAR2(30)
   ,nm_schema        VARCHAR2(30)
   ,nm_objeto        VARCHAR2(30)
   ,tp_objeto        VARCHAR2(30)
   ,tp_evento        VARCHAR2(30)  
   ,nm_usuario_rede  VARCHAR2(80)
   ,nm_equipamento   VARCHAR2(80)
)
NOLOGGING;

--TRIGGER
CREATE OR REPLACE TRIGGER trg_log_create
  AFTER CREATE
  OR DROP
  --OR ALTER
  --OR TRUNCATE
  ON SCHEMA
DECLARE
  v_linha hr.tb_log_create%ROWTYPE;
  v_dummy INTEGER;
BEGIN
  -- DATA DO EVENTO
  v_linha.dt_execucao := SYSDATE;
  -- BANCO DE DADOS
  v_linha.nm_database := upper(sys_context('userenv', 'DB_NAME'));
  -- SCHEMA
  v_linha.nm_schema := sys_context('userenv', 'CURRENT_USER');
  -- NOME DO OBJETO
  v_linha.nm_objeto := ora_dict_obj_name;
  -- TIPO DE OBJETO
  v_linha.tp_objeto := ora_dict_obj_type;
  -- TIPO DE EVENTO
  v_linha.tp_evento := ora_sysevent;
  -- USUARIO DE REDE QUE EXECUTOU O COMANDO
  v_linha.nm_usuario_rede := upper(sys_context('userenv', 'OS_USER'));
  -- HOSTNAME
  v_linha.nm_equipamento := sys_context('userenv', 'HOST');

  SELECT COUNT(1)
  INTO v_dummy
  FROM tb_log_create l
  WHERE TRUNC(dt_execucao,'MONTH') = TRUNC(SYSDATE, 'MONTH')
    AND l.nm_objeto = v_linha.nm_objeto
    AND l.nm_usuario_rede = v_linha.nm_usuario_rede
    AND l.tp_objeto = v_linha.tp_evento;
  IF v_dummy = 0 THEN
    INSERT INTO tb_log_create
    VALUES
    (
       v_linha.dt_execucao
      ,v_linha.nm_database
      ,v_linha.nm_schema
      ,v_linha.nm_objeto
      ,v_linha.tp_objeto
      ,v_linha.tp_evento
      ,v_linha.nm_usuario_rede
      ,v_linha.nm_equipamento
    );

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END trg_log_create;