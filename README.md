#  Zomato Data Analysis using PostgreSQL

---

##  Project Overview

This project is a comprehensive SQL-based analysis of a Zomato-like food delivery platform.

The objective was to solve **20 real-world business problems** using PostgreSQL and simulate how data analysts support product, operations, and growth teams in food delivery businesses.

The analysis transforms transactional data into actionable insights covering customer behavior, restaurant performance, and rider efficiency.

---

##  Key Business Insights

- Identified high-value customers using Customer Lifetime Value (CLV)
- Detected churned customers for re-engagement targeting
- Ranked top-performing restaurants city-wise
- Measured cancellation rate trends year-over-year
- Calculated rider average delivery time and efficiency scores
- Built month-over-month revenue growth reports
- Identified peak order time slots for operational planning
- Segmented customers into revenue-based tiers (Gold / Silver)

---

##  Database Schema

The relational schema includes:

- **Customers**
- **Restaurants**
- **Orders**
- **Deliveries**
- **Riders**

An Entity Relationship Diagram (ERD) is included in this repository.

---
![ERD](erd.png)


##  SQL Concepts & Techniques Applied

- INNER JOIN / LEFT JOIN
- Common Table Expressions (CTEs)
- Window Functions (RANK, DENSE_RANK, LAG)
- Aggregations (SUM, COUNT, AVG)
- Conditional Logic (CASE statements)
- Date & Time Functions
- Subqueries
- Revenue & KPI Reporting

---

##  Highlighted Analytical Solutions

### 1️ Customer Churn Analysis
Identified customers active in 2023 but inactive in 2024.

### 2️ Restaurant Revenue Ranking
Ranked restaurants by city based on total annual revenue.

### 3️ Rider Efficiency KPI
Calculated average delivery time per rider and categorized performance.

### 4️ Month-over-Month Growth
Used LAG() to measure revenue growth trends.

### 5️ Cancellation Rate Analysis
Compared yearly cancellation rates per restaurant.

---

##  Business Impact Simulation

This project demonstrates how SQL can be used to:

- Improve customer retention strategies
- Optimize restaurant partnerships
- Monitor delivery efficiency
- Identify operational bottlenecks
- Support product growth decisions

---

##  Tools Used

- PostgreSQL
- SQL
- Relational Database Modeling

---

##  Repository Structure

- `database_setup.sql` – Schema creation
- `20_business_problems_solution.sql` – All SQL solutions
- `data/` – CSV files
- `erd.png` – Database diagram

---

## 👤 Author

**Aamir Iqbal**  
Aspiring Data Analyst | SQL | PostgreSQL  

---

##  Disclaimer

All data used in this project is computer-generated for educational purposes.  
It does not represent real Zomato data.

---

If you found this project interesting, feel free to connect or provide feedback!
