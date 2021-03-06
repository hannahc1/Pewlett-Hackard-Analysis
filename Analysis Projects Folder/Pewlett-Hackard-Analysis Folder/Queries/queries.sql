-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL,
	dept_name VARCHAR(40) NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
);

CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)

);

CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)

);

CREATE TABLE dept_emp (
  emp_no INT NOT NULL,
  dept_no VARCHAR NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
  PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
  emp_no INT NOT NULL,
  title VARCHAR NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no,title, from_data)
);

SELECT * 
FROM departments;

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';


SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- Retirement eligibility
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Retirement eligibility
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM salaries
ORDER BY to_date DESC;

-- Joining departments and dept_manager tables
SELECT departments.dept_name
, dept_manager.emp_no
, dept_manager.from_date
, dept_manager.to_date
FROM departments
INNER JOIN dept_manager
ON departments.dept_no = dept_manager.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT retirement_info.emp_no
, retirement_info.first_name
, retirement_info.last_name
, dept_emp.to_date
FROM retirement_info
LEFT JOIN dept_emp
ON retirement_info.emp_no = dept_emp.emp_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no
, ri.first_name
, ri.last_name
, de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;

-- Joining departments and dept_manager tables
SELECT d.dept_name
, dm.emp_no
, dm.from_date
, dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

DROP TABLE current_emp

-- Joining retirement_info and dept_emp tables
SELECT re.emp_no
, re.first_name
, re.last_name
, de.to_date
INTO current_emp
FROM retirement_info as re
LEFT JOIN dept_emp as de
ON re.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO dept_employee_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT e.emp_no
, e.first_name
, e.last_name
, e.gender
	, s.salary
		, de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- the manager’s employee number, first name, last name, and their starting and ending employment dates.
SELECT dm.dept_no
		,d.dept_name
		,dm.emp_no
		,ce.first_name
		,ce.last_name
		,dm.from_date
		,dm.to_date
INTO manager_info
FROM dept_manager AS dm
	INNER JOIN departments AS d
		ON (dm.dept_no = d.dept_no)
	INNER JOIN current_emp AS ce
		ON (dm.emp_no = ce.emp_no);
		
SELECT * FROM retirement_info;
DROP TABLE manager_info;

-- Department Retirees
SELECT ce.emp_no
,ce.first_name
,ce.last_name
,d.dept_name
INTO dept_info
FROM current_emp AS ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);

-- Department Retirees - sales
SELECT ce.emp_no
,ce.first_name
,ce.last_name
,d.dept_name
-- INTO dept_info
FROM current_emp AS ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no)
WHERE (d.dept_name = 'Sales' OR d.dept_name = 'Development')

-- Department Retirees - sales
SELECT *
FROM dept_info
WHERE dept_name IN ('Sales','Development')

-- table of number of employees about to retired grouped by job title.
-- Deliverable 1 Step 1
SELECT ce.emp_no
, ce.first_name
, ce.last_name
, t.title
, t.from_date
, s.salary
INTO retiring_emp
FROM current_emp AS ce
INNER JOIN titles AS t
ON (ce.emp_no = t.emp_no)
INNER JOIN salaries AS s
on (ce.emp_no = s.emp_no)

-- Number of employees with each title (historical, including duplicates)
SELECT count(emp_no), title
INTO number_of_emp_by_title
FROM retiring_emp
GROUP BY title
ORDER BY title

-- Partition the data to show only most recent title per employee
SELECT emp_no
,first_name
,last_name
,title
,from_date
,salary
INTO retiring_emp1
FROM
 (SELECT emp_no
,first_name
,last_name
,title
,from_date
,salary, ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY from_date DESC) rn
 FROM retiring_emp
 ) tmp WHERE rn = 1
ORDER BY emp_no;

DROP TABLE number_of_retiring_by_title

-- Number of retiring employees with each title (no duplicates)
SELECT count(emp_no), title
INTO number_of_retiring_by_title
FROM retiring_emp1
GROUP BY title
ORDER BY count(emp_no) DESC

SELECT * FROM number_of_retiring_by_title 
order by count()

SELECT e.emp_no, e.first_name, e.last_name, t.title, t.from_date, t.to_date
INTO mentorship
FROM employees AS e
INNER JOIN titles AS t
ON (e.emp_no = t.emp_no)
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31') AND to_date = '9999-01-01';

SELECT count(emp_no) FROM mentorship
