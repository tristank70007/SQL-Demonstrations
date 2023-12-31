--1. What is the total amount each customer spent at the restaurant?

SELECT s.CUSTOMER_ID, SUM(m.PRICE) AS TOTAL_SALES
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
INNER JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
GROUP BY s.CUSTOMER_ID;


--2. How many days has each customer visited the restaurant?

SELECT CUSTOMER_ID, COUNT(DISTINCT ORDER_DATE) AS DAYS_VISITED
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES"
GROUP BY CUSTOMER_ID;


--3. What was the first item from the menu purchased by each customer?
--(Note: you can choose to return all items for their first order or pick 1 of the items from their first order, I'll accept either)

SELECT s.CUSTOMER_ID, m.PRODUCT_NAME
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
INNER JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
WHERE ORDER_DATE = (
    SELECT MIN(ORDER_DATE) AS MIN_DATE
    FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES"
);


--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.PRODUCT_NAME, COUNT(s.CUSTOMER_ID) AS PURCHASE_COUNT
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
INNER JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
GROUP BY m.PRODUCT_NAME
ORDER BY PURCHASE_COUNT DESC
LIMIT 1;


--5. Which item was the most popular for each customer?

SELECT RANKED_SALES.CUSTOMER_ID, RANKED_SALES.PRODUCT_NAME
FROM (
    SELECT s.CUSTOMER_ID, m.PRODUCT_NAME, ROW_NUMBER() OVER (PARTITION BY s.CUSTOMER_ID ORDER BY COUNT(*) DESC) AS rank
    FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
    INNER JOIN
        "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
    GROUP BY s.CUSTOMER_ID, m.PRODUCT_NAME
) AS RANKED_SALES
WHERE rank = 1
ORDER BY RANKED_SALES.CUSTOMER_ID ASC; 


--6. Which item was purchased first by the customer after they became a member?

SELECT s.CUSTOMER_ID, m.PRODUCT_NAME AS ITEM, s.ORDER_DATE AS DATE, ROW_NUMBER() OVER (PARTITION BY s.CUSTOMER_ID ORDER BY DATE DESC) AS RANK
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MEMBERS" ON s.CUSTOMER_ID = MEMBERS.CUSTOMER_ID
WHERE DATE > JOIN_DATE
QUALIFY RANK = 1
ORDER BY s.CUSTOMER_ID ASC;


--7. Which item was purchased just before the customer became a member?

SELECT s.CUSTOMER_ID, m.PRODUCT_NAME AS ITEM, s.ORDER_DATE AS DATE, ROW_NUMBER() OVER (PARTITION BY s.CUSTOMER_ID ORDER BY DATE DESC) AS RANK
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MEMBERS" ON s.CUSTOMER_ID = MEMBERS.CUSTOMER_ID
WHERE DATE < JOIN_DATE
QUALIFY RANK = 1
ORDER BY s.CUSTOMER_ID ASC;

--8. What is the total items and amount spent for each member before they became a member?

SELECT s.CUSTOMER_ID, SUM(m.PRICE) AS TOTAL_AMOUNT, COUNT(m.PRODUCT_ID) AS TOTAL_ITEMS
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
    JOIN
        "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
    JOIN
        "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MEMBERS" ON s.CUSTOMER_ID = MEMBERS.CUSTOMER_ID
WHERE s.ORDER_DATE < JOIN_DATE
GROUP BY s.CUSTOMER_ID
ORDER BY s.CUSTOMER_ID ASC;


--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.CUSTOMER_ID, SUM(m.POINTS) AS TOTAL_POINTS
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
JOIN
    (
    SELECT PRODUCT_NAME, PRICE, PRODUCT_ID, (CASE WHEN PRODUCT_NAME = 'sushi' THEN 20 ELSE 10 END) AS POINTS
    FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU"
    )
    AS m
    ON s.PRODUCT_ID = m.PRODUCT_ID
JOIN
    "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MEMBERS" ON s.CUSTOMER_ID = MEMBERS.CUSTOMER_ID
WHERE ORDER_DATE >= JOIN_DATE
GROUP BY s.CUSTOMER_ID 
ORDER BY s.CUSTOMER_ID ASC;


--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customers A and B have at the end of January?

SELECT s.CUSTOMER_ID, SUM((CASE WHEN DATEDIFF('day',JOIN_DATE,ORDER_DATE) <= 7 OR PRODUCT_NAME = 'sushi' THEN 20 ELSE 10 END)) AS POINTS
FROM "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."SALES" s
    JOIN
        "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MENU" m ON s.PRODUCT_ID = m.PRODUCT_ID
    JOIN
        "TIL_PLAYGROUND"."CS1_DANNYS_DINER"."MEMBERS" ON s.CUSTOMER_ID = MEMBERS.CUSTOMER_ID
WHERE ORDER_DATE >= JOIN_DATE
GROUP BY s.CUSTOMER_ID
ORDER BY s.CUSTOMER_ID ASC;
