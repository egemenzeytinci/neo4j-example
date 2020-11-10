// create constraint to customer id for all customer
CREATE CONSTRAINT ON (customer:Customer) ASSERT customer.customerID IS UNIQUE;

// create customer nodes
:auto 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM 'file:///data.csv'
AS line
WITH toInteger(line.CustomerID) AS CustomerID, line WHERE NOT line.CustomerID IS null
MERGE(customer:Customer {customerID: CustomerID})
ON CREATE SET customer.country = line.Country;

// create constraint to stock code for all product
CREATE CONSTRAINT ON (product:Product) ASSERT product.stockCode IS UNIQUE;

// create product nodes
:auto 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM 'file:///data.csv'
AS line
MERGE(product:Product {stockCode: line.StockCode})
ON CREATE SET product.description = line.Description;

// create constraint to transaction id for all transactions
CREATE CONSTRAINT ON (transaction:Transaction) ASSERT transaction.transactionID IS UNIQUE;

// create transaction nodes
:auto 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM 'file:///data.csv'
AS line
MERGE(transaction:Transaction {transactionID: line.InvoiceNo})
ON CREATE SET transaction.transactionDate = line.InvoiceDate;

// create made relationships
:auto 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM 'file:///data.csv'
AS line
WITH toInteger(line.CustomerID) AS CustomerID, line.InvoiceNo AS InvoiceNo
MATCH (customer:Customer {customerID: CustomerID})
MATCH (transaction:Transaction {transactionID: InvoiceNo})
MERGE (customer)-[:MADE]->(transaction);

// create contains relationships
:auto 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM 'file:///data.csv'
AS line
WITH toInteger(line.Quantity) AS Quantity, toFloat(line.UnitPrice) AS UnitPrice, line.InvoiceNo AS InvoiceNo, line.StockCode AS StockCode
MATCH (transaction:Transaction {transactionID: InvoiceNo})
MATCH (product:Product {stockCode: StockCode})
MERGE (transaction)-[r:CONTAINS]->(product)
	ON CREATE SET r.quantity = Quantity, r.price = UnitPrice * Quantity
	ON MATCH SET r.quantity = r.quantity + Quantity, r.price = r.price + UnitPrice * Quantity;