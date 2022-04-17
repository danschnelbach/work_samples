set echo on;
spool "C:\Users\danie\Documents\Studies by subject\Advanced Relational Database\Assignments\3-PLSQL\HW3_Q5.lst"

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE get_gpa
    AS
    stu student.s_id%TYPE;
    stu2 student.s_id%TYPE;
    frst student.s_first%TYPE;
    lst student.s_last%TYPE;
    gpa NUMBER(4,2);
    
    CURSOR c1
        IS
            SELECT DISTINCT s.s_id, s.s_first, s.s_last
                FROM student s left join enrollment e ON s.s_id = e.s_id
                WHERE s.s_id IN 
                    (SELECT distinct e.s_id
                    FROM enrollment e
                    WHERE e.grade IS NOT NULL)
                    AND e.grade IS NOT NULL;
    
    CURSOR c2 
        IS
        WITH g AS (
            SELECT s.s_id, c.credits,
                CASE WHEN e.grade = 'A' THEN 4
                    WHEN e.grade = 'B' THEN 3
                    WHEN e.grade = 'C' THEN 2
                    WHEN e.grade = 'D' THEN 1
                    ELSE 0
                END AS grade_pt
                    FROM student s left join enrollment e ON s.s_id = e.s_id
                        left join course_section cs ON e.c_sec_id = cs.c_sec_id
                        left join course c ON c.course_no = cs.course_no
                    WHERE s.s_id IN 
                        (SELECT distinct e.s_id
                        FROM enrollment e
                        WHERE e.grade IS NOT NULL)
                        AND e.grade IS NOT NULL
                        )
            SELECT s_id, sum(credits * grade_pt)/sum(credits) AS gpa
            FROM g
            WHERE --s_id IN 
                    --(SELECT distinct e.s_id
                    --FROM enrollment e
                    --WHERE e.grade IS NOT NULL)
                    --AND e.grade IS NOT NULL
                    s_id = stu
            GROUP BY s_id;

BEGIN
    OPEN c1;
    LOOP
        FETCH c1 INTO stu, frst, lst;
        EXIT WHEN c1%NOTFOUND;
        
        OPEN c2;
        LOOP
            FETCH c2 into stu2, gpa;
            EXIT WHEN c2%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE('+                                             +');
                DBMS_OUTPUT.PUT_LINE('Student: ' || frst || ' ' || lst);
                DBMS_OUTPUT.PUT_LINE('s_id: ' || stu2 );
                DBMS_OUTPUT.PUT_LINE('gpa: ' || gpa );
        END LOOP;
        CLOSE c2;
    END LOOP;
    CLOSE c1;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Program attempted to divide a number by zero.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('A SELECT INTO statement returned no rows, or the program referenced a deleted element');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('A SELECT INTO statement returned more than one row.');
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('The PLSQL procedure failed due to an error');
END;
/
   
execute get_gpa;  

spool off  
        
        
           