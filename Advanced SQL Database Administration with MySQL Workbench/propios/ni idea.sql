USE survey;

SELECT * FROM salary_survey;

CREATE VIEW country_averages AS
SELECT 
	country,
    COUNT(*) AS respondents,
    AVG(year_experience) as yrs_experience,
    AVG(CASE WHEN is_manager = "Yes" THEN 1 ELSE 0 END) pct_mgrs,
    AVG(CASE WHEN education_level = "Masters" THEN 1 ELSE 0 END) pct_masters
FROM salary_survey
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM country_averages;
