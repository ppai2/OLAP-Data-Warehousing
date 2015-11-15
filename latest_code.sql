
------ 2.1
select count(P_ID) TUMOR_COUNT 
from DIAGNOSIS1 
where DS_ID IN 
  (select DS_ID from DISEASE where DESCRIPTION='tumor');

select count(P_ID) LEUKEMIA_COUNT 
from DIAGNOSIS1 
where DS_ID IN 
  (select DS_ID from DISEASE where TYPE='leukemia');

select count(P_ID) ALL_COUNT 
from DIAGNOSIS1 
where DS_ID IN 
  (select DS_ID from DISEASE where NAME='ALL');


------ 2.2
select distinct TYPE DRUG_TYPES 
from DRUG1 
where DR_ID IN 
(select DR_ID from DRUGUSE1 where P_ID IN 
  (select P_ID from DIAGNOSIS1 where DS_ID IN 
    (select DS_ID from DISEASE1 where DESCRIPTION='tumor')
  )
) order by TYPE;

------ 2.3
select distinct TYPE 
from DRUG1 
where DR_ID in 
(select DR_ID from DRUGUSE1 where P_ID in 
  (select P_ID from DIAGNOSIS1 where DS_ID in 
    (select DS_ID from DISEASE1 where DESCRIPTION = 'tumor')
  )
);


------ 2.4
create table TTESTTEMP1 
(
  DS_TYPE VARCHAR2(20 BYTE), 
  EXPR NUMBER,
  G_UID NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

-- ALL
insert into TTESTTEMP1 (
select 'ALL', EXPRESSIONS.EXP, PROBES.UID1
from (select PB_ID, UID1 from PROBE1 where UID1 IN (select UID1 from GENEANNOTATION1 where GO_ID = 0012502)) PROBES,
  (select EXP, PB_ID from MICROARRAY_FACT1 where S_ID IN 
    (select S_ID from SAMPLE1 where P_ID IN 
      (select P_ID from DIAGNOSIS1 where DS_ID IN 
        (select DS_ID from DISEASE1 where NAME = 'ALL')
      )
    )
  ) EXPRESSIONS
where PROBES.PB_ID = EXPRESSIONS.PB_ID);

-- NOT ALL
insert into TTESTTEMP1 (
select 'NOTALL', EXPRESSIONS.EXP, PROBES.UID1
from (select PB_ID, UID1 from PROBE1 where UID1 IN (select UID1 from GENEANNOTATION1 where GO_ID = 0012502)) PROBES,
  (select EXP, PB_ID from MICROARRAY_FACT1 where S_ID IN 
    (select S_ID from SAMPLE1 where P_ID IN 
      (select P_ID from DIAGNOSIS1 where DS_ID IN 
        (select DS_ID from DISEASE1 where NAME != 'ALL')
      )
    )
  ) EXPRESSIONS
where PROBES.PB_ID = EXPRESSIONS.PB_ID);

-- T statistics
select AVG(DECODE(DS_TYPE, 'ALL', EXPR, null)) ALL_AVERAGE,
     AVG(DECODE(DS_TYPE, 'NOTALL', EXPR, null)) NOTALL_AVERAGE,
     STATS_T_TEST_INDEP(DS_TYPE, EXPR, 'STATISTIC', 'ALL') t_observed,
     STATS_T_TEST_INDEP(DS_TYPE, EXPR) two_sided_p_value
from TTESTTEMP1;


------ 2.5
create table ANOVA_TEMP 
(
  DIS_NAME VARCHAR2(20 BYTE),
  EXP VARCHAR2(20 BYTE)
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

-- ALL
insert into ANOVA_TEMP 
select 'ALL', EXP 
from MICROARRAY_FACT1 
where PB_ID in 
(select PB_ID from PROBE1 where UID1 in 
  (select UID1 from GENEANNOTATION1 where GO_ID = 7154)
) 
and S_ID in 
(select S_ID from SAMPLE1 where P_ID in 
  (select P_ID from DIAGNOSIS1 where DS_ID in 
    (select DS_ID from DISEASE1 where NAME = 'ALL')
  )
);

-- AML
insert into ANOVA_TEMP 
select 'AML', EXP 
from MICROARRAY_FACT1
where PB_ID in 
(select PB_ID from PROBE1 where UID1 in 
  (select UID1 from GENEANNOTATION1 where GO_ID = 7154)
) 
and S_ID in 
(select S_ID from SAMPLE1 where P_ID in 
  (select P_ID from DIAGNOSIS1 where DS_ID in 
    (select DS_ID from DISEASE1 where NAME = 'AML')
  )
);

-- Colon Tumor
insert into ANOVA_TEMP 
select 'Colon tumor', EXP 
from MICROARRAY_FACT1 
where PB_ID in 
(select PB_ID from PROBE1 where UID1 in 
  (select UID1 from GENEANNOTATION1 where GO_ID = 7154)
) 
and S_ID in 
(select S_ID from SAMPLE1 where P_ID in 
  (select P_ID from DIAGNOSIS1 where DS_ID in 
    (select DS_ID from DISEASE1 where NAME = 'Colon tumor')
  )
);

-- Breast Tumor
insert into ANOVA_TEMP 
select 'Breast tumor', EXP 
from MICROARRAY_FACT1 
where PB_ID in 
(select PB_ID from PROBE1 where UID1 in 
  (select UID1 from GENEANNOTATION1 where GO_ID = 7154)
) 
and S_ID in 
(select S_ID from SAMPLE1 where P_ID in 
  (select P_ID from DIAGNOSIS1 where DS_ID in 
    (select DS_ID from DISEASE1 where NAME = 'Breast tumor')
  )
);

-- F statistics
select STATS_ONE_WAY_ANOVA(DIS_NAME,EXP,'F_RATIO') f_observed,
  STATS_ONE_WAY_ANOVA(DIS_NAME,EXP,'SIG') two_sided_p_value
from ANOVA_TEMP;


------ 2.6
create table CORRELATION_TEMP1 
(
  P_ID NUMBER, 
  PB_ID NUMBER,
  EXP NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

create table CORRELATION_TEMP2 
(
  P_ID NUMBER, 
  PB_ID NUMBER,
  EXP NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

-- ALL
insert into CORRELATION_TEMP1 
select SAMPLE1.P_ID, MICROARRAY.PB_ID, MICROARRAY.EXP 
from (select S_ID, PB_ID, EXP from MICROARRAY_FACT1 where PB_ID in 
  (select PB_ID from PROBE1 where UID1 in (select UID1 from GENEANNOTATION1 where GO_ID = 7154))
  ) MICROARRAY,
  (select S_ID, P_ID from SAMPLE1 where P_ID in 
    (select P_ID from DIAGNOSIS1 where DS_ID in 
      (select DS_ID from DISEASE1 where NAME = 'ALL')
    )
  ) SAMPLE1 
where SAMPLE1.S_ID = MICROARRAY.S_ID;

-- AML
insert into CORRELATION_TEMP2 
select SAMPLE1.P_ID, MICROARRAY.PB_ID, MICROARRAY.EXP 
from (select S_ID, PB_ID, EXP from MICROARRAY_FACT1 where PB_ID in 
  (select PB_ID from PROBE1 where UID1 in (select UID1 from GENEANNOTATION1 where GO_ID = 7154))
  ) MICROARRAY,
  (select S_ID, P_ID from SAMPLE1 where P_ID in 
    (select P_ID from DIAGNOSIS1 where DS_ID in 
      (select DS_ID from DISEASE1 where NAME = 'AML')
    )
  ) SAMPLE1 
where SAMPLE1.S_ID = MICROARRAY.S_ID;

-- Correlation between 'ALL' and 'ALL'
select AVG(CORR(P1.EXP,P2.EXP)) CORRELATION 
from (select P_ID,PB_ID, EXP from CORRELATION_TEMP1) P1,
  (select P_ID, PB_ID, EXP from CORRELATION_TEMP1) P2 
where P1.PB_ID = P2.PB_ID
group by P1.P_ID, P2.P_ID;

-- Correlation between 'ALL' and 'AML'
select AVG(CORR(P1.EXP,P2.EXP)) CORRELATION 
from (select P_ID,PB_ID, EXP from TRIAL6) P1,
(select P_ID, PB_ID, EXP from TRIAL7) P2 
where P1.PB_ID = P2.PB_ID
group by P1.P_ID, P2.P_ID;


------ 3.1
create table INFO_TEMP 
(
  DS_TYPE VARCHAR2(20 BYTE), 
  EXPR NUMBER,
  G_UID NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

create table INFORMATIVE_GENES1 
(
  GENE_UID NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

-- ALL
insert into INFO_TEMP (
select 'ALL', EXPRESSIONS.EXP, PROBES.UID1
from (select PB_ID, UID1 from PROBE1) PROBES,
  (select EXP, PB_ID from MICROARRAY_FACT1 where S_ID in 
    (select S_ID from SAMPLE1 where P_ID in 
      (select P_ID from DIAGNOSIS1 where DS_ID in 
        (select DS_ID from DISEASE1 where NAME = 'ALL')
      )
    )
  ) EXPRESSIONS
WHERE PROBES.PB_ID = EXPRESSIONS.PB_ID);

-- NOTALL
insert into INFO_TEMP (
select 'NOTALL', EXPRESSIONS.EXP, PROBES.UID1
from (select PB_ID, UID1 from PROBE1) PROBES,
  (select EXP, PB_ID from MICROARRAY_FACT1 where S_ID in 
    (select S_ID from SAMPLE1 where P_ID in 
      (select P_ID from DIAGNOSIS1 where DS_ID in 
        (select DS_ID from DISEASE1 where NAME != 'ALL')
      )
    )
  ) EXPRESSIONS
WHERE PROBES.PB_ID = EXPRESSIONS.PB_ID);

-- Informative Genes
insert into INFORMATIVE_GENES1 
select GENE_UID
from (select G_UID GENE_UID, 
     AVG(DECODE(DS_TYPE, 'ALL', EXPR, null)) ALL_AVERAGE,
     AVG(DECODE(DS_TYPE, 'NOTALL', EXPR, null)) NOTALL_AVERAGE,
     STATS_T_TEST_INDEP(DS_TYPE, EXPR, 'STATISTIC', 'ALL') t_observed,
     STATS_T_TEST_INDEP(DS_TYPE, EXPR) two_sided_p_value
 FROM INFO_TEMP
 GROUP BY ROLLUP (G_UID)
 ORDER BY G_UID, t_observed) INF
 WHERE INF.two_sided_p_value < 0.01;
 
 
------ 3.2
create table P_NEW 
(
  GENE_UID NUMBER, 
  EXP NUMBER, 
  P_ID NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

create table P_ALL 
(
  GENE_UID NUMBER, 
  EXP NUMBER, 
  P_ID NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

create table P_NOTALL 
(
  GENE_UID NUMBER, 
  EXP NUMBER, 
  P_ID NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

create table CLASSIFY_TTEST 
(
  R_TYPE VARCHAR2(30 BYTE), 
  R_VALUE NUMBER 
) 
logging 
tablespace CSE601 
pctfree 10 
initrans 1 
storage 
( 
  initial 65536 
  next 1048576 
  minextents 1 
  maxextents unlimited 
  buffer_pool default 
) 
nocompress 
noparallel;

-- Pn data (new patient test1)
insert into P_NEW 
select G_UID, EXP, P_ID 
from PATIENT_NEW 
where P_ID = 1;

-- Pa data ('ALL' patients - Group A)
insert into P_ALL
select PROBE1.UID1, EXP, P_ID
from PROBE1,
  (select P_ID, ALLSAMPLES.S_ID, PB_ID, EXP
  from MICROARRAY_FACT1,
    (select P_ID, S_ID from SAMPLE1 where P_ID in 
      (select P_ID from DIAGNOSIS1 where DS_ID in 
        (select DS_ID from DISEASE1 where NAME = 'ALL')
      )
    ) ALLSAMPLES
  where MICROARRAY_FACT1.S_ID = ALLSAMPLES.S_ID
  ) TMP
where PROBE1.PB_ID = TMP.PB_ID;

-- Pb data (NOT 'ALL' patients - Group B)
insert into P_NOTALL
select PROBE1.UID1, EXP, P_ID
from PROBE1,
  (select P_ID, ALLSAMPLES.S_ID, PB_ID, EXP
  from MICROARRAY_FACT1,
    (select P_ID, S_ID from SAMPLE1 where P_ID in 
      (select P_ID from DIAGNOSIS1 where DS_ID in 
        (select DS_ID from DISEASE1 where NAME != 'ALL')
      )
    ) ALLSAMPLES
  where MICROARRAY_FACT1.S_ID = ALLSAMPLES.S_ID) TMP
where PROBE1.PB_ID = TMP.PB_ID;

-- Ra
insert into CLASSIFY_TTEST
select 'ALL', CORR(P1.EXP,P2.EXP) CORRA 
from (select GENE_UID, EXP, P_ID from P_ALL where GENE_UID in 
    (select GENE_UID from INFORMATIVE_GENES1)
  ) P1,
  (select GENE_UID, EXP, P_ID from P_NEW where GENE_UID in 
    (select GENE_UID from INFORMATIVE_GENES1)
  ) P2
where P1.GENE_UID = P2.GENE_UID
group by P1.P_ID, P2.P_ID;

-- Rb
insert into CLASSIFY_TTEST
select 'NOTALL', CORR(P1.EXP,P2.EXP) CORRB 
from (select GENE_UID, EXP, P_ID from P_NOTALL where GENE_UID in 
    (select GENE_UID from INFORMATIVE_GENES1)
  ) P1,
  (select GENE_UID, EXP, P_ID from P_NEW where GENE_UID in 
    (select GENE_UID from INFORMATIVE_GENES1)
  ) P2
where P1.GENE_UID = P2.GENE_UID
group by P1.P_ID, P2.P_ID;

-- T statistics between Ra and Rb
select AVG(DECODE(R_TYPE, 'ALL', R_VALUE, null)) ALL_AVERAGE,
     AVG(DECODE(R_TYPE, 'NOTALL', R_VALUE, null)) NOTALL_AVERAGE,
     STATS_T_TEST_INDEP(R_TYPE, R_VALUE, 'STATISTIC', 'ALL') t_observed,
     STATS_T_TEST_INDEP(R_TYPE, R_VALUE) two_sided_p_value
from CLASSIFY_TTEST;

