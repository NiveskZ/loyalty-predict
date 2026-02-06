WITH tb_usuario_cursos AS (
    SELECT idUsuario,
            descSlugCurso,
            count(descSlugCursoEpisodio) AS qtdeEps
    FROM cursos_episodios_completos

    WHERE dtCriacao < '2026-02-05'

    GROUP BY idUsuario, descSlugCurso
),

tb_cursos_total_eps AS (
    SELECT descSlugCurso,
            COUNT(descEpisodio) AS qtdeTotalEps

    FROM cursos_episodios

    GROUP BY descSlugCurso
),

tb_pct_cursos AS (
    SELECT t1.idUsuario,
            t1.descSlugCurso,
            1. * t1.qtdeEps / t2.qtdeTotalEps AS pctCursoCompleto

    FROM tb_usuario_cursos AS t1

    LEFT JOIN tb_cursos_total_eps AS t2
    ON t1.descSlugCurso = t2.descSlugCurso
),

tb_pct_cursos_pivot AS (

    SELECT idUsuario,

            sum(CASE WHEN pctCursoCompleto = 1 THEN 1 ELSE 0 END) AS qtdeCursosCompletos,
            sum(CASE WHEN pctCursoCompleto > 0 AND pctCursoCompleto < 1 THEN 1 ELSE 0 END) AS qtdeCursosIncompletos,
            sum(CASE WHEN descSlugCurso = 'carreira' THEN pctCursoCompleto ELSE 0 END) AS carreira,
            sum(CASE WHEN descSlugCurso = 'coleta-dados-2024' THEN pctCursoCompleto ELSE 0 END) AS coletadados2024,
            sum(CASE WHEN descSlugCurso = 'ds-databricks-2024' THEN pctCursoCompleto ELSE 0 END) AS dsdatabricks2024,
            sum(CASE WHEN descSlugCurso = 'ds-pontos-2024' THEN pctCursoCompleto ELSE 0 END) AS dspontos2024,
            sum(CASE WHEN descSlugCurso = 'estatistica-2024' THEN pctCursoCompleto ELSE 0 END) AS estatistica2024,
            sum(CASE WHEN descSlugCurso = 'estatistica-2025' THEN pctCursoCompleto ELSE 0 END) AS estatistica2025,
            sum(CASE WHEN descSlugCurso = 'github-2024' THEN pctCursoCompleto ELSE 0 END) AS github2024,
            sum(CASE WHEN descSlugCurso = 'github-2025' THEN pctCursoCompleto ELSE 0 END) AS github2025,
            sum(CASE WHEN descSlugCurso = 'go-2026' THEN pctCursoCompleto ELSE 0 END) AS go2026,
            sum(CASE WHEN descSlugCurso = 'ia-canal-2025' THEN pctCursoCompleto ELSE 0 END) AS iacanal2025,
            sum(CASE WHEN descSlugCurso = 'lago-mago-2024' THEN pctCursoCompleto ELSE 0 END) AS lagomago2024,
            sum(CASE WHEN descSlugCurso = 'loyalty-predict-2025' THEN pctCursoCompleto ELSE 0 END) AS loyaltypredict2025,
            sum(CASE WHEN descSlugCurso = 'machine-learning-2025' THEN pctCursoCompleto ELSE 0 END) AS machinelearning2025,
            sum(CASE WHEN descSlugCurso = 'matchmaking-trampar-de-casa-2024' THEN pctCursoCompleto ELSE 0 END) AS matchmakingtrampardecasa2024,
            sum(CASE WHEN descSlugCurso = 'ml-2024' THEN pctCursoCompleto ELSE 0 END) AS ml2024,
            sum(CASE WHEN descSlugCurso = 'mlflow-2025' THEN pctCursoCompleto ELSE 0 END) AS mlflow2025,
            sum(CASE WHEN descSlugCurso = 'nekt-2025' THEN pctCursoCompleto ELSE 0 END) AS nekt2025,
            sum(CASE WHEN descSlugCurso = 'pandas-2024' THEN pctCursoCompleto ELSE 0 END) AS pandas2024,
            sum(CASE WHEN descSlugCurso = 'pandas-2025' THEN pctCursoCompleto ELSE 0 END) AS pandas2025,
            sum(CASE WHEN descSlugCurso = 'python-2024' THEN pctCursoCompleto ELSE 0 END) AS python2024,
            sum(CASE WHEN descSlugCurso = 'python-2025' THEN pctCursoCompleto ELSE 0 END) AS python2025,
            sum(CASE WHEN descSlugCurso = 'speed-f1' THEN pctCursoCompleto ELSE 0 END) AS speedf1,
            sum(CASE WHEN descSlugCurso = 'sql-2020' THEN pctCursoCompleto ELSE 0 END) AS sql2020,
            sum(CASE WHEN descSlugCurso = 'sql-2025' THEN pctCursoCompleto ELSE 0 END) AS sql2025,
            sum(CASE WHEN descSlugCurso = 'streamlit-2025' THEN pctCursoCompleto ELSE 0 END) AS streamlit2025,
            sum(CASE WHEN descSlugCurso = 'trampar-lakehouse-2024' THEN pctCursoCompleto ELSE 0 END) AS tramparlakehouse2024,
            sum(CASE WHEN descSlugCurso = 'tse-analytics-2024' THEN pctCursoCompleto ELSE 0 END) AS tseanalytics2024

    FROM tb_pct_cursos

    GROUP BY idUsuario
),

tb_atividade AS (
    SELECT
        idUsuario,
        max(dtRecompensa) AS dtCriacao
    FROM recompensas_usuarios
    WHERE dtRecompensa < '2026-02-05'
    GROUP BY idUsuario

UNION ALL

    SELECT 
        idUsuario,
        max(dtCriacao) AS dtCriacao

    FROM habilidades_usuarios
    WHERE dtCriacao < '2026-02-05'
    GROUP BY idUsuario

UNION ALL

    SELECT
        idUsuario,
        max(dtCriacao) AS dtCriacao

    FROM cursos_episodios_completos
    WHERE dtCriacao < '2026-02-05'
    GROUP BY idUsuario
),

tb_ultima_atividade AS (
    SELECT idUsuario,
            min(julianday('2026-02-05') - julianday(dtCriacao)) AS qtdDiasUltAtividade
    FROM tb_atividade
    GROUP BY idUsuario
),

tb_join AS (
    SELECT t3.idTMWCliente AS IdCliente,
            t1.qtdeCursosCompletos,
            t1.qtdeCursosIncompletos,
            t1.carreira,
            t1.coletadados2024,
            t1.dsdatabricks2024,
            t1.dspontos2024,
            t1.estatistica2024,
            t1.estatistica2025,
            t1.github2024,
            t1.github2025,
            t1.go2026,
            t1.iacanal2025,
            t1.lagomago2024,
            t1.loyaltypredict2025,
            t1.machinelearning2025,
            t1.matchmakingtrampardecasa2024,
            t1.ml2024,
            t1.mlflow2025,
            t1.nekt2025,
            t1.pandas2024,
            t1.pandas2025,
            t1.python2024,
            t1.python2025,
            t1.speedf1,
            t1.sql2020,
            t1.sql2025,
            t1.streamlit2025,
            t1.tramparlakehouse2024,
            t1.tseanalytics2024,
            t2.qtdDiasUltAtividade
    FROM tb_pct_cursos_pivot AS t1

    LEFT JOIN tb_ultima_atividade AS t2
    ON t1.idUsuario = t2.idUsuario

    INNER JOIN usuarios_tmw AS t3
    ON t1.idUsuario = t3.idUsuario
)

SELECT date('2026-02-05','-1 day') AS dtRef,
        *
FROM tb_join