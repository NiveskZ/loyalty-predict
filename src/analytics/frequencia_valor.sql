SELECT IdCliente,
        count(DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
        sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdPontosPositivos,
        sum(abs(QtdePontos)) AS qtdPontosAbs

FROM transacoes

WHERE DtCriacao < '2026-01-01'
AND DtCriacao > DATE('2026-01-01', '-28 day') 

GROUP BY 1

ORDER BY qtdeFrequencia DESC