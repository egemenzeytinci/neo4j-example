MATCH (c:Customer)-[r1:MADE]->(t:Transaction)-[r2:CONTAINS]->(:Product)
WITH SUM(r2.price) AS monetary,
	 COUNT(t) AS frequency,
     c.customerID AS customer,
     MIN(
     	duration.inDays(
			date(datetime({epochmillis: apoc.date.parse(t.transactionDate, 'ms', 'MM/dd/yyyy')})), 
			date()
		).days
	) AS recency
RETURN customer, recency, frequency, monetary