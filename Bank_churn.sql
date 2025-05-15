-- STEP 1: DDL COMMANDS

	SELECT *
	FROM bank_churn;

-- Step 1.1: Checking Datatypes by describing each columns
	SELECT column_name, data_type
	FROM information_schema.columns
	WHERE table_name = 'bank_churn';

-- step 1.2: creating new column for analysis- customer segment 
	ALTER TABLE bank_churn
	ADD COLUMN customer_segment TEXT;

	SELECT *
	FROM bank_churn;

-- STEP 2: DML COMMANDS (EXPLORATION & INSIGHTS)

-- Step 2.1: Count of customers who exited vs retained
	SELECT "Exited", 
			COUNT(*) as total_customers
	FROM bank_churn
	GROUP BY "Exited";

-- Step 2.2.1: Calculate overall Churn rate-- Approach 1
	SELECT 
		ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn;

-- Step 2.2.2: Calculate overall Churn rate- Approach 2
	SELECT 
		Round(100.0 * (select count(*)
	FROM bank_churn
	WHERE "Exited" = 1)/count(*),2) as churn_rate

-- Step 2.3: Churn by Age Group
    SELECT 
	CASE 
		WHEN "Age" < 30 THEN 'Under 30'
		WHEN "Age" BETWEEN 30 AND 50 THEN '30-50'
		ELSE 'Over 50'
	END AS age_group,
	COUNT(*) AS total_customers,
	SUM("Exited") AS churned,
	ROUND(100.0 * SUM("Exited") / COUNT(*), 2) AS churn_rate
	FROM bank_churn
	GROUP BY "age_group"
	ORDER BY "churn_rate" DESC;

-- Step 2.4: Churn rate by gender
	SELECT "Gender",
			COUNT(*) as total_customer,
			COUNT(*) FILTER (WHERE "Exited" = 0) AS retained_customer,
			COUNT(*) FILTER (WHERE "Exited" = 1) AS churned_customer,	
			ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn
	GROUP BY "Gender";

-- Step 2.5: Churned rate based on geography
	SELECT "Geography",
			COUNT(*) as total_customer,
			COUNT(*) FILTER (WHERE "Exited" = 0) AS retained_customer,
			COUNT(*) FILTER (WHERE "Exited" = 1) AS churned_customer,	
			ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn
	Group by "Geography"
	Order by churn_rate_percent desc;

-- Step 2.6: Churned rate based on Tenure
	SELECT "Tenure",
			COUNT(*) as total_customer,
			COUNT(*) FILTER (WHERE "Exited" = 0) AS retained_customer,
			COUNT(*) FILTER (WHERE "Exited" = 1) AS churned_customer,	
			ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn
	GROUP BY "Tenure"
	ORDER BY "churn_rate_percent" desc;

-- Step 2.7: Churned rate based on Number of Products
	SELECT "NumOfProducts",
			COUNT(*) as total_customer,
			COUNT(*) FILTER (WHERE "Exited" = 0) AS retained_customer,
			COUNT(*) FILTER (WHERE "Exited" = 1) AS churned_customer,	
			ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn
	GROUP BY "NumOfProducts"
	ORDER BY churn_rate_percent desc;

-- Step 2.8: Churned rate based on customer activeness
	SELECT "IsActiveMember",
			COUNT(*) as total_customer,
			COUNT(*) FILTER (WHERE "Exited" = 0) AS retained_customer,
			COUNT(*) FILTER (WHERE "Exited" = 1) AS churned_customer,	
			ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn
	GROUP BY "IsActiveMember"
	ORDER BY churn_rate_percent desc;
	
-- Step 2.9: Churned rate based on customer activeness with total products
	SELECT "IsActiveMember", 
		   "NumOfProducts",
	   	    COUNT(*) AS total,
	   		SUM("Exited") AS churned,
			ROUND(100.0 * SUM("Exited")::NUMERIC / COUNT(*), 2) AS churn_rate
	FROM bank_churn
	GROUP BY "IsActiveMember", "NumOfProducts"
	ORDER BY churn_rate DESC;
	
-- Step 2.10: Average credit score and balance of retained vs churned
	SELECT "Exited",
		   ROUND(AVG("CreditScore"), 2) AS avg_credit_score,
		   ROUND(AVG("Balance"), 2) AS avg_balance
	FROM bank_churn
	GROUP BY "Exited";

-- Step 2.11: Churned rate based on Geography and Gender
	SELECT "Gender",
		   "Geography",
			COUNT(*) as total_customer,
			COUNT(*) FILTER (WHERE "Exited" = 0) AS retained_customer,
			COUNT(*) FILTER (WHERE "Exited" = 1) AS churned_customer,	
			ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn
	GROUP BY "Gender","Geography"
	ORDER BY churn_rate_percent desc;

-- Step 2.13: Churned rate based on Geography,Gender & Financial behavior
	SELECT "Geography","Gender",
		   ROUND(AVG("CreditScore"), 2) AS avg_credit_score,
		   ROUND(AVG("Balance"), 2) AS avg_balance,
		   ROUND(100.0 * COUNT(*) FILTER (WHERE "Exited" = 1) / COUNT(*),2) AS churn_rate_percent
	FROM bank_churn
	GROUP BY "Geography","Gender"
	ORDER BY churn_rate_percent desc;
	
-- 2.14: Mark high-value customers (balance > 100K) as "High", others as "Standard"
	UPDATE bank_churn
		SET customer_segment = CASE 
		WHEN "Balance" > 100000 THEN 'High'
		ELSE 'Standard'
	END;

	SELECT customer_segment,Count(*) as Total_customer
	FROM bank_churn
	GROUP BY customer_segment;
	

--STEP 3: SUMMARY STATISTICS

--Step 3.1: Summary statistics of CreditScore and Balance
	SELECT
		ROUND(AVG("CreditScore"), 2) AS avg_credit_score,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "CreditScore") AS median_credit_score,
		MIN("CreditScore") AS min_credit_score,
		MAX("CreditScore") AS max_credit_score,
		ROUND(STDDEV("CreditScore"), 2) AS stddev_credit_score,
	
		ROUND(AVG("Balance"), 2) AS avg_balance,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Balance") AS median_balance,
		MIN("Balance") AS min_balance,
		MAX("Balance") AS max_balance,
		ROUND(STDDEV("Balance"), 2) AS stddev_balance
	FROM bank_churn;
	
-- STEP 4: COHORTING THE CUSTOMERS

-- STEP 4.1: To Identify the Churned/Non-churned Customers by Cohorting
	SELECT 
    	"CustomerId","Surname",
    	"Geography","Gender",
	    "Age","CreditScore",
	    "Balance","NumOfProducts",
	    "HasCrCard","IsActiveMember",
	    "EstimatedSalary","Exited",
		"customer_segment",
   		 CASE 
        	WHEN "Exited" = 1 THEN 'Churned'
        	ELSE 'Active'
    	END AS ChurnStatus,
    	RANK() OVER (
        ORDER BY "Balance" DESC, "CreditScore" DESC
    ) AS BalanceRank
	FROM bank_churn

-- STEP 4.2: TOP 5 HIGH-VALUE ACTIVE CUSTOMERS FOR RETENTION OFFER

	SELECT *
	FROM(
		SELECT 
    	"CustomerId",
		-- "Surname",
    	"Geography",
	    "Gender",
	    "Age",
	    "CreditScore",
	    "Balance",
	    "NumOfProducts",
	    "HasCrCard",
	    "IsActiveMember",
	    "EstimatedSalary",
	    -- "Exited",
		"customer_segment",
   		 CASE 
        	WHEN "Exited" = 1 THEN 'Churned'
        	ELSE 'Active'
    	END AS ChurnStatus,
    	RANK() OVER (
        ORDER BY "Balance" DESC, "CreditScore" DESC
    ) AS BalanceRank
	FROM bank_churn
	WHERE "Exited" = 0 and "IsActiveMember" = 1
	) AS customer_ranking
	WHERE BalanceRank <=5;





