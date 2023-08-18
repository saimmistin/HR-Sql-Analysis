USE employees_mod;

# breakdown between the male and female employees working in the company each year, starting from 1990. 

select emp_no, from_date, to_date
FROM t_dept_emp;
SELECT DISTINCT
	emp_no, from_date, to_date
FROM
	t_dept_emp;
SELECT
	YEAR(d.from_date) AS calender_year,
    e.gender,
    COUNT(e.emp_no) as num_of_employees
FROM t_employees employees
	JOIN
    t_dept_emp d on d.emp_no = e.emp_no
GROUP BY calender_year
HAVING calender_year >= 1990
ORDER BY calender_year;


# compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.

SELECT
    d.dept_name,
    ee.gender,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
    CROSS JOIN
    t_dept_manager dm
    JOIN
    t_departments d ON dm.dept_no = d.dept_no
    JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;



#compare the average salary of female versus male employees in the entire company until year 2002, 
#and add a filter allowing you to see that per each department.

SELECT
	e.gender,
    d.dept_name,
    ROUND(AVG(s.salary),2) as avg_salary,
    YEAR(s.from_date) as calendar_year
FROM
	t_salaries s
		JOIN
	t_employees e ON s.emp_no = e.emp_no
		JOIN
	t_dept_emp de ON de.emp_no = e.emp_no
		JOIN
	t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no

#create a stored procedure that will allow you to fetch the average
# male and female salary per department within a certain salary range. 
#Let this range be defined by two values the user can insert.


SELECT MIN(salary) FROM t_salaries;
SELECT MAX(salary) FROM t_salaries;
DROP PROCEDURE IF EXISTS filter_salary;
DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT
	e.gender, d.dept_name, AVG(s.salary) as avg_salary
FROM
	t_salaries s
		JOIN
    t_employees e ON s.emp_no = e.emp_no
		JOIN
	t_dept_emp de ON de.emp_no = e.emp_no
		JOIN
	t_departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END$$
DELIMITER ;
CALL filter_salary(50000, 90000);