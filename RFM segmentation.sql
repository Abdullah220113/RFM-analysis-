with  customer_aggregated_data as
(
select CUSTOMERNAME,
max(customer_date) as last_order_date,
datediff((select max(customer_date) from sales_data), max(customer_date)) as recency_value,
count(distinct ordernumber) as frequency_value,
round(sum(SALES),0) as monetary_value
from sales_data
group by CUSTOMERNAME)
,rfm_score as ( select c.* ,
ntile(4) over (order by recency_value desc) as R_score,
ntile(4) over (order by frequency_value desc) as F_score,
ntile(4) over (order by monetary_value desc) as M_score
from customer_aggregated_data as c)
select
customername,
recency_value,
R_score,
frequency_value,
F_score,
monetary_value,
M_score,
(R_score+F_score+M_score) as total_rf_score,
concat_ws('',R_score,F_score,M_score) as rfm_score_combination
from rfm_score as r;

SELECT 
    CUSTOMERNAME,
    CASE
        WHEN rfm_score_combination IN (111 , 112, 121, 132, 211, 211, 212, 114, 141) THEN 'CHURNED CUSTOMER'
        WHEN rfm_score_combination IN (133 , 134, 143, 24, 334, 343, 344, 144) THEN 'SLIPPING AWAY, CANNOT LOSE'
        WHEN rfm_score_combination IN (311 , 411, 331) THEN 'NEW CUSTOMERS'
        WHEN rfm_score_combination IN (222 , 231, 221, 223, 233, 322) THEN 'POTENTIAL CHURNERS'
        WHEN rfm_score_combination IN (323 , 333, 321, 341, 422, 332, 432) THEN 'ACTIVE'
        WHEN rfm_score_combination IN (433 , 434, 443, 444) THEN 'LOYAL'
        ELSE 'CANNOT BE DEFINED'
    END AS CUSTOMER_SEGMENT
FROM
    RFM_customer_Analysis;
