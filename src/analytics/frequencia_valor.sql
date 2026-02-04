WITH tb_freq_valor AS (
    SELECT IdCliente,
            count(DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
            sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdPontosPositivos,
            sum(abs(QtdePontos)) AS qtdPontosAbs

    FROM transacoes

    WHERE DtCriacao < '2026-01-01'
    AND DtCriacao > DATE('2026-01-01', '-28 day') 

    GROUP BY 1

    ORDER BY qtdeFrequencia DESC
),

tb_cluster AS (
    SELECT *,

            CASE
                WHEN qtdeFrequencia <= 7 AND qtdPontosPositivos >= 1000 THEN '10-HYPERS'
                WHEN qtdeFrequencia > 7 AND qtdPontosPositivos >= 1400 THEN '22-EFICIENTES'
                WHEN qtdeFrequencia > 7 AND qtdPontosPositivos < 1400 THEN '21-ESFORÇADO'
                WHEN qtdeFrequencia < 3 THEN '00-LURKER'
                WHEN qtdeFrequencia <= 7 THEN '20-POTENCIAL'
            
            END AS cluster

    FROM tb_freq_valor
)

SELECT *

FROM tb_cluster
