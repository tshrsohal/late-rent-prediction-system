-- KPI 1: Late payment rate

SELECT
ROUND(AVG(is_late) * 100, 2) AS late_payment_rent_pct
FROM rent_payments;

-- tenants who are late most often
SELECT tenant_id,
COUNT(*) AS total_payments,
SUM(is_late) AS late_payments,
ROUND(SUM(is_late) * 100.0 / COUNT(*), 2) AS late_payment_pct,
ROUND(AVG(days_late), 2) AS avg_days_late
FROM rent_payments
GROUP BY tenant_id
HAVING COUNT(*) >= 6
ORDER BY late_payment_pct DESC, avg_days_late DESC;

-- which properties have highest late rate and largest delays
SELECT property_id, property_name,
COUNT(*) AS total_payments,
SUM(is_late) AS late_payments,
ROUND(SUM(is_late) * 100 / COUNT(*), 2) AS late_payment_pct,
ROUND(AVG(days_late), 2) AS avg_days_late
FROM rent_payments
GROUP BY property_id, property_name
ORDER BY late_payment_pct DESC, avg_days_late DESC;

-- analyze payment methods
SELECT payment_method,
COUNT(*) AS total_payments,
SUM(is_late) AS late_payments,
ROUND(SUM(is_late) * 100.0 / COUNT(*), 2) AS late_payment_pct,
ROUND(AVG(days_late), 2) AS  avg_days_date
FROM rent_payments
GROUP BY payment_method
ORDER BY late_payment_pct DESC;

-- analyze income-to-rent ratio

SELECT
	CASE
		WHEN income_to_rent_ratio < 2.5 THEN 'Below 2.5x'
        WHEN income_to_rent_ratio< 3.0 THEN 'Below 2.5x - 2.99x'
        WHEN income_to_rent_ratio < 4.0 THEN 'Below 3.0 - 3.99x'
        ELSE '4.0x+'
	END AS income_band,
    COUNT(*) AS total_payments,
    SUM(is_late) AS late_payments,
    ROUND(SUM(is_late) * 100.0 / COUNT(*), 2) AS late_payment_pct
FROM rent_payments
GROUP BY 1
ORDER BY 1;

-- Analyze credit band

SELECT credit_band,
COUNT(*) AS total_payments,
SUM(is_late) AS late_payments,
ROUND(SUM(is_late) * 100 / COUNT(*), 2) AS late_payment_pct,
ROUND(AVG(days_late), 2) AS avg_days_late
FROM rent_payments
GROUP BY credit_band
ORDER BY late_payment_pct DESC;

-- NSF flags

SELECT tenant_id,
SUM(nsf_flag) AS nsf_events,
SUM(is_late) AS late_payments,
ROUND(AVG(days_late), 2) AS avg_days_late
FROM rent_payments
GROUP BY tenant_id
HAVING SUM(nsf_flag) > 0
ORDER BY nsf_events, avg_days_late DESC;

-- categorization of tenants based on the risk levels (high, medium, low)

SELECT tenant_id,
ROUND(AVG(days_late), 2) AS avg_days_late,
ROUND(SUM(is_late) * 100 / COUNT(*), 2) AS late_payment_pct,
CASE
	WHEN ROUND(AVG(days_late), 2) >= 5 OR ROUND(SUM(is_late) * 100 / COUNT(*), 2) >= 40 THEN 'High Risk'
    WHEN ROUND(AVG(days_late), 2) >= 2 OR ROUND(SUM(is_late) * 100 / COUNT(*), 2) >= 20 THEN 'Medium Risk'
    ELSE 'Low Risk'
    END AS risk_segment
    FROM rent_payments
    GROUP BY tenant_id;
    
    