WITH tb_transactions AS (
    SELECT *
    FROM transactions
    WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
),
tb_freq AS (
    SELECT idCustomer,
        count(DISTINCT DATE(dtTransaction)) AS qtdeDiasD21,
        count(
            DISTINCT CASE
                WHEN dtTransaction > DATE('{date}', '-14 day') THEN DATE(dtTransaction)
            END
        ) AS qtdeDiasD14,
        count(
            DISTINCT CASE
                WHEN dtTransaction > DATE('{date}', '-7 day') THEN DATE(dtTransaction)
            END
        ) AS qtdeDiasD7
    FROM tb_transactions
    GROUP BY idCustomer
),
tb_live_minutes AS (
    SELECT idCustomer,
        DATE(dtTransaction, '-3 hOUR') AS dtTransactionDate,
        MAX(DATETIME(dtTransaction, '-3 hOUR')) AS dtFim,
        MIN(DATETIME(dtTransaction, '-3 hOUR')) AS dtInicio,
        (
            JULIANDAY(MAX(DATETIME(dtTransaction, '-3 hOUR'))) - JULIANDAY(MIN(DATETIME(dtTransaction, '-3 hOUR')))
        ) * 24 * 60 AS liveMinutes
    FROM tb_transactions
    GROUP BY 1,
        2
),
tb_hours AS(
    SELECT idCustomer,
        AVG(liveMinutes) AS avgLiveMinutes,
        SUM(liveMinutes) AS sumLiveMinutes,
        MIN(liveMinutes) AS minLiveMinutes,
        MAX(liveMinutes) AS maxLiveMinutes
    FROM tb_live_minutes
    GROUP BY idCustomer
),
tb_vida AS (
    SELECT idCustomer,
        COUNT(DISTINCT idTransaction) AS qtdeTransactionVida,
        COUNT(DISTINCT idTransaction) / (
            MAX(
                julianday('{date}') - julianday(dtTransaction)
            )
        ) AS avgTransactionVida
    FROM transactions
    WHERE dtTransaction < '{date}'
    GROUP BY idCustomer
),
tb_join AS (
    SELECT t1.*,
        t2.avgLiveMinutes,
        t2.sumLiveMinutes,
        t2.minLiveMinutes,
        t2.maxLiveMinutes,
        t3.qtdeTransactionVida,
        t3.avgTransactionVida
    FROM tb_freq AS t1
        LEFT JOIN tb_hours as t2 ON t1.idCustomer = t2.idCustomer
        LEFT JOIN tb_vida as t3 ON t3.idCustomer = t1.idCustomer
)
SELECT '{date}' AS dtRef,
    *
FROM tb_join