/* 
I was able to get this February pageview data out of our web analytics tool. 
Would you be able to help me load  it into the database so we can tie it to all fo your other great data?
*/

CREATE TABLE website_pageviews (
	website_pageview_id BIGINT,
    created_at DATETIME,
    website_session_id BIGINT, 
    pageview_url VARCHAR(50),
    PRIMARY KEY (website_pageview_id)
    );
