USE mavenbearbuilders;

/*
Email: March 07, 2014
Subject: Tying website activity to sales
I have this website session data that I would love to tie into that order data so we can better understand where sales are coming from.
Can you creat a website_sessions table and help me import the attached files 
*/

CREATE TABLE website_sessions (
	website_sessions BIGINT,
    created_at DATETIME,
    user_id BIGINT,
    is_repeat_session BIGINT,
    utm_source VARCHAR(50),
    utm_campaign VARCHAR(50),
	utm_content VARCHAR(50),
    device_type VARCHAR(50),
    http_referer VARCHAR(120),
    PRIMARY KEY (website_sessions)
);

SELECT COUNT(*) AS Total_Records FROM website_sessions;

/*
Email: March 09,2014
Would you be able to create a view summarizing performance for january and february? I would like to see the number of sessions sliced by year,
month, utm_source, and utm_campaign if possible. 
*/

SELECT * FROM 	monthly_sessions;

CREATE VIEW montly_sessions AS 
SELECT 
	year(created_at) as year,
    month(created_at) as month,
    utm_source,
    utm_campaign,
    count(website_sessions) as number_of_sessions
FROM website_sessions
GROUP BY 
	1,
    2, 
    3,
    4;
    

