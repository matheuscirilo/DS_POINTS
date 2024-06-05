with tb_transactions_hour AS (
    SELECT idCustomer,
        pointsTransaction,
        CAST(
            strftime('%H', datetime(dtTransaction, '-3 hour')) AS INTEGER
        ) AS hour
    FROM transactions
    WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
),
tb_share AS (
    SELECT idCustomer,
        SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN abs(pointsTransaction)
                ELSE 0
            END
        ) AS qtdPointsManha,
        SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN abs(pointsTransaction)
                ELSE 0
            END
        ) AS qtdPointsTarde,
        SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN abs(pointsTransaction)
                ELSE 0
            END
        ) AS qtdPointsNoite,
        1.0 * SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN abs(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctPointsManha,
        1.0 * SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN abs(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctPointsTarde,
        1.0 * SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN abs(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctPointsNoite,
        SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN 1
                ELSE 0
            END
        ) AS qtdTransactionsManha,
        SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN 1
                ELSE 0
            END
        ) AS qtdTransactionsTarde,
        SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN 1
                ELSE 0
            END
        ) AS qtdTransactionsNoite,
        1.0 * SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN 1
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctTransactionsManha,
        1.0 * SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN 1
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctTransactionsTarde,
        1.0 * SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN 1
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctTransactionsNoite
    FROM tb_transactions_hour
    GROUP BY idCustomer
)
SELECT '{date}' AS dtRef,
    *
FROM tb_share