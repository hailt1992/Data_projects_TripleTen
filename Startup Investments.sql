ALTER TABLE "TripleTen_project".acquisition 
ALTER COLUMN price_amount TYPE BIGINT;

ALTER TABLE acquisition 
ADD CONSTRAINT pk_a_id PRIMARY KEY (id);

ALTER TABLE company 
ADD CONSTRAINT pk_c_id PRIMARY KEY (id);

ALTER TABLE education 
ADD CONSTRAINT pk_e_id PRIMARY KEY (id);

ALTER TABLE fund 
ADD CONSTRAINT pk_f_id PRIMARY KEY (id);

ALTER TABLE funding_round  
ADD CONSTRAINT pk_fr_id PRIMARY KEY (id);

ALTER TABLE investment
ADD CONSTRAINT pk_i_id PRIMARY KEY (id);

ALTER TABLE people 
ADD CONSTRAINT pk_p_id PRIMARY KEY (id);

/* Calculate how many companies were closed down.*/

SELECT COUNT(status)
FROM company
WHERE status = 'closed';

/*the amount of money news-related companies from the USA raised.*/

SELECT funding_total
FROM company 
WHERE country_code = 'USA'
    AND category_code = 'news'
ORDER BY funding_total DESC;