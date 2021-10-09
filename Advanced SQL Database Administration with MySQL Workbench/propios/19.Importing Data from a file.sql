CREATE SCHEMA survey;

USE survey;

CREATE TABLE salary_survey(
	country VARCHAR(120),
    year_experience BIGINT,
    employment_status VARCHAR(120),
    job_title VARCHAR(120),
    is_manager VARCHAR(5),
    education_level VARCHAR(120)
);

SELECT * FROM salary_survey;