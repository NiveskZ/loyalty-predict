DROP TABLE IF EXISTS abt_fiel;
CREATE TABLE abt_fiel AS

WITH tb_join AS (
    SELECT t1.dtRef,
            t1.IdCliente,
            t1.descLifeCycle,
            t2.descLifeCycle,
            CASE WHEN t2.descLifeCycle = '02-FIEL' THEN 1 ELSE 0 END AS flFiel,
            row_number() OVER (PARTITION BY t1.IdCliente ORDER BY random()) AS rnRow

    FROM life_cycle AS t1

    LEFT JOIN life_cycle AS t2 
    ON t1.IdCliente = t2.IdCliente
    AND date(t1.dtRef, '+28 day') = date(t2.dtRef)

    WHERE ((t1.dtRef >= '2024-03-01' AND t1.dtRef <= '2025-12-01')
            OR (t1.dtRef = '2026-01-01'))
    AND t1.descLifeCycle <> '05-ZUMBI'
),

tb_cohort AS (
    SELECT t1.dtRef,
            t1.IdCliente,
            t1.flFiel

    FROM tb_join AS t1

    WHERE rnRow <= 2

    ORDER BY IdCliente, dtRef
)

SELECT t1.*,
        t2.idadeDias,
        t2.qtdeAtivacaoVida,
        t2.qtdeAtivacaoD7,
        t2.qtdeAtivacaoD14, 
        t2.qtdeAtivacaoD28,
        t2.qtdeAtivacaoD56,
        t2.qtdeTransacaoVida,
        t2.qtdeTransacaoD7,
        t2.qtdeTransacaoD14,
        t2.qtdeTransacaoD28,
        t2.qtdeTransacaoD56,
        t2.saldoVida,
        t2.SaldoD7,
        t2.SaldoD14,
        t2.SaldoD28,
        t2.SaldoD56,
        t2.qtdePontosPosVida,
        t2.qtdePontosPosD7,
        t2.qtdePontosPosD14,
        t2.qtdePontosPosD28,
        t2.qtdePontosPosD56,
        t2.qtdePontosNegVida,
        t2.qtdePontosNegD7,
        t2.qtdePontosNegD14,
        t2.qtdePontosNegD28,
        t2.qtdePontosNegD56,
        t2.qtdeTransaocaoManha,
        t2.qtdeTransaocaoTarde,
        t2.qtdeTransaocaoNoite,
        t2.pctTransaocaoManha,
        t2.pctTransaocaoTarde,
        t2.pctTransaocaoNoite,
        t2.QtdeTransacaoDiaVida, 
        t2.QtdeTransacaoDiaD7,
        t2.QtdeTransacaoDiaD14,
        t2.QtdeTransacaoDiaD28,
        t2.QtdeTransacaoDiaD56,
        t2.pctAtivacaoMAU,
        t2.qtdeHorasVida,
        t2.qtdeHorasD7,
        t2.qtdeHorasD14,
        t2.qtdeHorasD28,
        t2.qtdeHorasD56,
        t2.avgIntervaloDiasVida,
        t2.avgIntervaloDiasD28,
        t2.qtdeChatMessage,
        t2.qtdeAirflowLover,
        t2.qtdeRLover,
        t2.qtdeResgatarPonei,
        t2.qtdeListadePresenca,
        t2.qtdePresencaStreak,
        t2.qtdeTrocadePontosStreamElements,
        t2.qtdeReembolsoTrocadePontosStreamElements,
        t2.qtdeAdaga,
        t2.qtdeAarmadura,
        t2.qtdeBotas,
        t2.qtdeCajado,
        t2.qtdeChapeu,
        t2.qtdeChurn_model,
        t2.qtdeEspada,
        t2.qtdeRPG,
        t3.qtdeFrequencia,
        t3.descLifeCycleAtual,
        t3.descLifeCycleD28,
        t3.pctZUMBI,
        t3.pctDESENCANTADA,
        t3.pctCURIOSO,
        t3.pctFIEL,
        t3.pctRECONQUISTADO,
        t3.pctTURISTA,
        t3.pctREBORN,
        t3.avgFreqGrupo,
        t3.ratioFreqGrupo,
        t4.qtdeCursosCompletos,
        t4.qtdeCursosIncompletos,
        t4.carreira,
        t4.coletadados2024,
        t4.dsdatabricks2024,
        t4.dspontos2024,
        t4.estatistica2024,
        t4.estatistica2025,
        t4.github2024,
        t4.github2025,
        t4.go2026,
        t4.iacanal2025,
        t4.lagomago2024,
        t4.loyaltypredict2025,
        t4.machinelearning2025,
        t4.matchmakingtrampardecasa2024,
        t4.ml2024,
        t4.mlflow2025,
        t4.nekt2025,
        t4.pandas2024,
        t4.pandas2025,
        t4.python2024,
        t4.python2025,
        t4.speedf1,
        t4.sql2020,
        t4.sql2025,
        t4.streamlit2025,
        t4.tramparlakehouse2024,
        t4.tseanalytics2024,
        t4.qtdDiasUltAtividade

FROM tb_cohort AS t1

LEFT JOIN fs_transacional AS t2
ON t1.IdCliente = t2.IdCliente
AND t1.dtRef = t2.dtRef

LEFT JOIN fs_life_cycle AS t3
ON t1.IdCliente = t3.IdCliente
AND t1.dtRef = t3.dtRef

LEFT JOIN fs_education AS t4
ON t1.IdCliente = t4.IdCliente
AND t1.dtRef = t4.dtRef

WHERE t3.dtRef IS NOT NULL;