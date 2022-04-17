set echo on
set pagesize 100

SELECT c.FNAME, c.LNAME, c.TELNO, c.PREFTYPE, c.MAXRENT, c.EMAIL, RENT
FROM client c left join viewing v on c.clientno = v.clientno
     left join propertyforrent p on v.propertyno = p.propertyno
WHERE viewdate > '30-APR-2013' AND
p.staffno = (SELECT staffno
            FROM staff
            WHERE fname = 'Mary' AND lname = 'Howe');
            
            
SELECT staffno, fname, lname, count(staffno) AS rentedout, 
	RANK() OVER (ORDER BY count(staffno)DESC) as rank
FROM staff join propertyforrent USING(staffno)
GROUP BY staffno, fname, lname;



SELECT DISTINCT lname, fname
FROM staff join propertyforrent USING(staffno) join viewing USING(propertyno)
WHERE viewing.viewdate BETWEEN '01-MAY-13' AND '31-MAY-13'
ORDER BY lname, fname;


SELECT c_last, c_first, item_desc as product, inv_price
FROM customer join orders USING(c_id) 
	join order_line USING(o_id) 
	join inventory USING(inv_id)
	join item USING(item_id)
WHERE o_methpmt ='CC';


SELECT c_first, c_last, NVL2(sl_date_received, 'Shipped', 'Not yet arrived') as "Shipped_status"
FROM customer join orders USING(c_id)
    join order_line USING(o_id) 
	join inventory USING(inv_id)
    full outer join shipment_line USING(inv_id)
WHERE o_date >= '01-MAY-06' AND o_date <= '31-MAY-06';



SELECT cat_desc AS category, sum(ol_quantity) AS orders, sum(inv_qoh) as inventory
FROM orders join order_line USING(o_id)
            right join inventory USING(inv_id)
            join item USING(item_id)
            join category USING(cat_id)
GROUP BY cat_desc
ORDER BY sum(ol_quantity) DESC;



SELECT propertyno, street, city, postcode, type, rooms, ownerno, branchno, staffno, rent, 
    CASE WHEN (propertyno IN (SELECT propertyno
                                FROM viewing
                                GROUP BY propertyno
                                HAVING count(propertyno) > 1))
            THEN rent
         ELSE 0.95*rent
    END AS "Adjusted_rent"
FROM propertyforrent;



ALTER TABLE client ADD
(id number(7));


UPDATE client
SET id = ROWNUM
WHERE id IS NULL;


CREATE SEQUENCE client_id_seq
INCREMENT BY 1
START WITH 5
CACHE 5;


INSERT INTO client (clientno, lname, telno, id)
VALUES ('xxx', 'xxx', 'xxx', client_id_seq.NEXTVAL);

INSERT INTO client (clientno, lname, telno, id)
VALUES ('yyy', 'yyy', 'yyy', client_id_seq.NEXTVAL);

ALTER SEQUENCE client_id_seq 
INCREMENT BY 6;

INSERT INTO client (clientno, lname, telno, id)
VALUES ('zzz', 'zzz', 'zzz', client_id_seq.NEXTVAL);

SELECT *
FROM client;

SELECT propertyno, street, city, postcode,
    CASE WHEN (rent > (select avg(rent)
                        from propertyforrent))
            THEN 'LUX'
        ELSE 'STANDARD'
    END AS "CLASS"
FROM propertyforrent;


SELECT P || G || F || L AS NEW_ID, fname, lname
FROM staff join (SELECT staffno,
                           DECODE(position, 'Supervisor', 1,
                                         'Manager',2,
                                         3) "P",
                           DECODE(sex, 'M', 'M',
                                         'F') "G",
                           substr(fname, 1,1) AS "F",
                           substr(lname, 1,1) AS "L"
                    FROM staff) USING(staffno);
                    
                    
    
SELECT propertyno, type
FROM (
        select propertyno, type
        from propertyforrent
        where type = 'Flat'
        order by rent desc
                            )
WHERE ROWNUM <= 3

UNION

SELECT propertyno, type
FROM (
        select propertyno, type
        from propertyforrent
        where type = 'House'
        order by rent desc
                            )
WHERE ROWNUM <= 3
ORDER BY type;



SELECT propertyno
FROM propertyforrent
WHERE rent > (SELECT max(maxrent)
              FROM client);
              
              
