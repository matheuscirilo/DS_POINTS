SELECT t1.NameCustomer,
t1.PointsCustomer,
t1.flEmail,
t2.idTransaction,
t2.pointsTransaction,
t3.NameProduct,
t3.QuantityProduct

FROM customers AS t1

LEFT JOIN transactions AS t2
ON T1.idCustomer = T2.idCustomer

LEFT JOIN transactions_product AS t3
ON T2.idTransaction = T3.idTransaction

