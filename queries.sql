-- *******************************************
-- Drop any previous tables

DROP TABLE IF EXISTS article;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS title;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS tag_article_mapping;

-- ***********************************
-- Let's create some tables

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT
);

CREATE TABLE article (
    user_id INT NOT NULL,
    text VARCHAR(256),
    date TIMESTAMP
);

CREATE TABLE tag (
    text VARCHAR(25)
);

CREATE TABLE title (
    id SERIAL PRIMARY KEY,
    text VARCHAR(100),
    article_id INT NOT NULL
);

-- will throw ERROR
CREATE TABLE tag_article_mapping (
    tag_id INT PRIMARY KEY,
    article_id INT PRIMARY KEY
); -- will throw ERROR

CREATE TABLE tag_article_mapping (
    tag_id INT NOT NULL,
    article_id INT NOT NULL,
    PRIMARY KEY (tag_id, article_id)
);

-- ******************************************
-- oops, we forgot to mention primary keys in 
-- some of the tables. Let's fix that.

ALTER TABLE article ADD id SERIAL PRIMARY KEY;
ALTER TABLE tag ADD id SERIAL PRIMARY KEY;

-- We have a change in spec. Article table needs
-- a new column "location", as in where the article
-- was written.

ALTER TABLE article ADD COLUMN location VARCHAR(50);


-- Let's add some users

INSERT INTO users (first_name, last_name, age) 
VALUES 
    ('Pranjal', 'Chakraborty', 99),
    ('Karl', 'Grantham', 88),
    ('Amirmahdi Khosravi', 'Tabrizi', 77);

SELECT * FROM users;
SELECT first_name FROM users;
SELECT first_name FROM users WHERE age > 90;

-- ************************
-- Let's create some tags
INSERT INTO tag (text)
VALUES
    ('Canada'), 
    ('USA'), 
    ('Travel');

-- ************************
-- Okay, first article
INSERT INTO article (user_id, text, location, date)
VALUES (
    1,
    'Alberta is beautiful around this time of the year.',
    'Toronto, ON',
    now()
);

SELECT * FROM article;

INSERT INTO title (text, article_id)
VALUES ('Best places to visit in Alberta', 1);

INSERT INTO tag_article_mapping (article_id, tag_id)
VALUES
    (1, 1), (1, 3);


-- Second article
INSERT INTO article (user_id, text, location, date)
VALUES (
    3,
    'Violence is spreading across NEw York',
    'Buffalo, NY',
    now()
);

SELECT * FROM article;

INSERT INTO title (text, article_id)
VALUES ('NY is not what it used to be', 2);

SELECT * FROM tag;

INSERT INTO tag_article_mapping (article_id, tag_id)
VALUES (2, 2);

-- Third article
INSERT INTO article (user_id, text, location, date)
VALUES (
    2,
    'This might be the perfect time to visit this side of the world...',
    'Toronto, ON',
    now()
);

SELECT * FROM article;

INSERT INTO title (text, article_id)
VALUES ('North American travel destinations', 3);

INSERT INTO tag_article_mapping (article_id, tag_id)
VALUES
    (3, 1), (3, 2), (3, 3);

-- *******************************************
-- Now let's explore how many ways we can 
-- see data

SELECT * FROM article;

-- with Author name

SELECT * FROM article a
JOIN users u ON a.user_id = u.id;

-- what if there were more users in the table
INSERT INTO users (first_name, last_name, age) 
VALUES 
    ('Naser', 'Ezzati-Jivan', 66),
    ('Earl', 'Foxwell', 55);

SELECT * FROM article a
JOIN users u ON a.user_id = u.id;

-- No problem! Let's only see what we want to see.

SELECT a.text, a.location, u.first_name 
FROM article a
JOIN users u ON a.user_id = u.id;

-- let's see the tags too
SELECT a.text, a.location, u.first_name, tam.tag_id 
FROM article a
JOIN users u ON a.user_id = u.id
JOIN tag_article_mapping tam ON a.id = tam.article_id;

-- But those are just id. Tag texts are in a different table.
-- Let's join that too.
SELECT a.text, a.location, u.first_name, t.text 
FROM article a
JOIN users u ON a.user_id = u.id
JOIN tag_article_mapping tam ON a.id = tam.article_id
JOIN tag t ON t.id = tam.tag_id;

-- Let's get rid of the repeatation, and add the tags in one column.
SELECT a.text, a.location, u.first_name, string_agg(t.text, ' ,') 
FROM article a
JOIN users u ON a.user_id = u.id
JOIN tag_article_mapping tam ON a.id = tam.article_id
JOIN tag t ON t.id = tam.tag_id
GROUP BY a.text, a.location, u.first_name; -- all columns in the select, except for the column we are trying to aggregate

-- Let's add the title in there too.
SELECT ti.text, a.text, a.location, u.first_name, string_agg(t.text, ' ,') 
FROM article a
JOIN users u ON a.user_id = u.id
JOIN tag_article_mapping tam ON a.id = tam.article_id
JOIN tag t ON t.id = tam.tag_id
JOIN title ti ON ti.article_id = a.id
GROUP BY ti.text, a.text, a.location, u.first_name;

-- Change the column names to make it pretty.
SELECT 
    ti.text AS title,
    a.text AS text, 
    a.location AS location, 
    u.first_name AS author, 
    string_agg(t.text, ' ,') AS tags 
FROM article a
JOIN users u ON a.user_id = u.id
JOIN tag_article_mapping tam ON a.id = tam.article_id
JOIN tag t ON t.id = tam.tag_id
JOIN title ti ON ti.article_id = a.id
GROUP BY ti.text, a.text, a.location, u.first_name;

-- Now WHERE clause to filter different things.


-- **************************
-- Maybe we want to see how many articles were posted by each author.

SELECT u.first_name 
FROM users u
JOIN article a ON a.user_id = u.id;

-- Now let's list article ids with the user.
SELECT u.first_name, a.id
FROM users u
JOIN article a ON a.user_id = u.id;

-- Maybe let's add another article to Karl
INSERT INTO article (user_id, text, location, date)
VALUES (
    2,
    E'Who doesn\'t love to travel?', -- E is there to deal with escape character
    'Niagara Falls, ON',
    now()
);

SELECT * FROM article;

INSERT INTO title (text, article_id)
VALUES ('Traveling might help you live longer', 4);

INSERT INTO tag_article_mapping (article_id, tag_id)
VALUES
    (4, 3);


-- Okay... NOW let's list article ids with the user.
SELECT u.first_name, a.id
FROM users u
JOIN article a ON a.user_id = u.id;

-- Let's count

-- Now let's list article ids with the user.
SELECT u.first_name, COUNT(a.id)
FROM users u
JOIN article a ON a.user_id = u.id
GROUP BY u.first_name;

-- But we want to see users without article too
SELECT u.first_name, a.id
FROM users u
LEFT JOIN article a ON a.user_id = u.id;

-- Nice! Now let's add count.
SELECT u.first_name, COUNT(a.id)
FROM users u
LEFT JOIN article a ON a.user_id = u.id
GROUP BY u.first_name;

-- Let's sort by the count
SELECT 
    u.first_name AS name, 
    COUNT(a.id) AS article_count
FROM users u
LEFT JOIN article a ON a.user_id = u.id
GROUP BY u.first_name
ORDER BY article_count DESC;
