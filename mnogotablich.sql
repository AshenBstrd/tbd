*/Вывести все имена и фамилии студентов, и название хобби, которым занимается этот студент
SELECT 
  st.name, st.surname, h.name 
FROM students st, students_hobbies sth, hobby h 
WHERE 
  st.n_z = sth.n_z AND 
  sth.hobby_id = h.id AND 
  sth.date_finish IS NULL
*/Вывести информацию о студенте, занимающимся хобби самое продолжительное время
SELECT * FROM students st
WHERE st.n_z IN
  (SELECT t.n_z FROM
    (SELECT 
      sth.n_z, 
      sth.date_finish - sth.date_start do_time 
    FROM students_hobbies sth 
    WHERE 
      sth.date_finish - sth.date_start IS NOT NULL 
    ORDER BY do_time DESC 
    LIMIT 1) t
)  
*/Вывести имя, фамилию, номер зачетки и дату рождения для студентов, средний балл которых выше среднего, а сумма риска всех хобби, которыми он занимается в данный момент, больше 9.
SELECT st.n_z, st.name, st.surname, st.date_of_birth
FROM 
  students st,
  (SELECT sth.n_z, SUM(h.risk)
    FROM hobby h
    INNER JOIN students_hobbies sth
    ON h.id = sth.hobby_id
    GROUP BY sth.n_z
    HAVING SUM(h.risk) > 9) hrisk
WHERE 
  st.score > (SELECT ROUND(AVG(st.score),2) FROM students st) AND
  hrisk.n_z = st.n_z 
*/Вывести фамилию, имя, зачетку, дату рождения, название хобби и длительность в месяцах, для всех завершенных хобби
SELECT st.n_z, st.name, st.surname, st.date_of_birth, h.name, sth.do_time FROM students st 
INNER JOIN 
  (SELECT 
    sth.n_z, 
    sth.hobby_id,
    sth.date_finish - sth.date_start do_time 
  FROM students_hobbies sth 
  WHERE sth.date_finish - sth.date_start IS NOT NULL) sth 
ON st.n_z = sth.n_z 
INNER JOIN hobby h
ON sth.hobby_id = h.id
*/Вывести фамилию, имя, зачетку, дату рождения студентов, которым исполнилось N полных лет на текущую дату, и которые имеют более 1 действующего хобби.
SELECT st.n_z, st.name, st.surname, st.date_of_birth
FROM students st,
  (SELECT st.n_z
  FROM students st
  INNER JOIN
    (SELECT *
      FROM students_hobbies sth
      WHERE sth.date_finish IS NULL) sth
  ON st.n_z = sth.n_z
  GROUP BY st.n_z
  HAVING COUNT(st.n_z) > 1) multhobby
WHERE 
  EXTRACT(DAYS FROM NOW() - st.date_of_birth)/365 > 19 AND 
  st.n_z = multhobby.n_z
*/Найти средний балл в каждой группе, учитывая только баллы студентов, которые имеют хотя бы одно действующее хобби.
SELECT st.group_num, ROUND(AVG(st.score),2)
FROM students st
INNER JOIN
  (SELECT *
    FROM students_hobbies sth
    WHERE sth.date_finish IS NULL) curh
ON st.n_z = curh.n_z
GROUP BY st.group_num
*/Найти название, риск, длительность в месяцах самого продолжительного хобби из действующих, указав номер зачетки студента.
SELECT h.name, h.risk, EXTRACT(MONTH FROM age(NOW(),sth.date_start))
FROM students st
INNER JOIN 
  (SELECT * FROM students_hobbies sth
     WHERE sth.date_finish IS NULL) sth
ON st.n_z = sth.n_z
INNER JOIN hobby h
ON sth.hobby_id = h.id
WHERE st.n_z = 111
ORDER BY DATE_PART DESC
LIMIT 1
*/Найти все хобби, которыми увлекаются студенты, имеющие максимальный балл.
SELECT h.* FROM students st
INNER JOIN students_hobbies sth
ON sth.n_z = st.n_z
INNER JOIN hobby h
ON sth.hobby_id = h.id
WHERE 
  st.score = (SELECT st.score
  FROM students st
  GROUP BY st.score
  ORDER BY st.score DESC
  LIMIT 1)
*/Найти все действующие хобби, которыми увлекаются троечники 2-го курса.
SELECT h.name FROM students st
INNER JOIN students_hobbies sth
ON sth.n_z = st.n_z
INNER JOIN hobby h
ON sth.hobby_id = h.id
WHERE 
  LEFT(st.group_num::VARCHAR, 1) = '2' AND 
  st.score >= 2.5 AND 
  st.score <= 3.8 AND
  sth.date_finish IS NULL
*/Найти номера курсов, на которых более 50% студентов имеют более одного действующего хобби.
SELECT *
FROM
  (SELECT LEFT(st.group_num::VARCHAR,1), COUNT(st.n_z) 
    FROM students st
    GROUP BY
      LEFT(st.group_num::VARCHAR,1)) total
INNER JOIN
  (SELECT LEFT(st.group_num::VARCHAR,1), COUNT(st.n_z)
    FROM
      students st,
      (SELECT st.n_z, COUNT(st.n_z) FROM students st
        INNER JOIN students_hobbies sth
        ON sth.n_z = st.n_z
        INNER JOIN hobby h
        ON sth.hobby_id = h.id
        WHERE sth.date_finish IS NULL
        GROUP BY st.n_z
        HAVING COUNT(st.n_z) > 1) morethanone
    WHERE
      st.n_z = morethanone.n_z
    GROUP BY
      LEFT(st.group_num::VARCHAR,1)) morethanone
ON total.left = morethanone.left
WHERE
  total.count / 2 < morethanone.count
*/Вывести номера групп, в которых не менее 60% студентов имеют балл не ниже 4.
SELECT sub.group_num
FROM
  (SELECT 
    st.group_num, 
    COUNT(st.n_z) total_count, 
    COUNT(st.score) FILTER (WHERE st.score > 4) above_score_count
  FROM students st
  GROUP BY st.group_num) sub
WHERE sub.total_count*0.6 < above_score_count
*/Для каждого курса подсчитать количество различных действующих хобби на курсе.
SELECT LEFT(st.group_num::VARCHAR,1) grade, COUNT(DISTINCT h.id)
FROM students st
INNER JOIN students_hobbies sth
ON sth.n_z = st.n_z
INNER JOIN hobby h
ON sth.hobby_id = h.id
GROUP BY LEFT(st.group_num::VARCHAR,1)
*/Вывести номер зачётки, фамилию и имя, дату рождения и номер курса для всех отличников, не имеющих хобби. Отсортировать данные по возрастанию в пределах курса по убыванию даты рождения.
SELECT 
  st.n_z, 
  st.name, 
  st.surname, 
  st.date_of_birth, 
  LEFT(st.group_num::VARCHAR,1) grade
FROM students st
WHERE 
  st.score >= 4.5 AND
  st.n_z IN
    (SELECT sth.n_z
    FROM students_hobbies sth
    GROUP BY sth.n_z
    HAVING COUNT(sth.date_finish) = COUNT(sth.date_start))
ORDER BY
  LEFT(st.group_num::VARCHAR,1),
  st.date_of_birth DESC
*/Создать представление, в котором отображается вся информация о студентах, которые продолжают заниматься хобби в данный момент и занимаются им как минимум 5 лет.
CREATE OR REPLACE VIEW st_hobby_5year AS
SELECT st.*
FROM students st
INNER JOIN students_hobbies sth
ON sth.n_z = st.n_z
WHERE
  sth.date_finish IS NULL AND
  EXTRACT(YEAR FROM AGE(NOW(),sth.date_start)) > 1
*/Для каждого хобби вывести количество людей, которые им занимаются.
SELECT h.name, COUNT(DISTINCT sth.n_z)
FROM hobby h
INNER JOIN students_hobbies sth
ON h.id = sth.hobby_id
GROUP BY h.name
*/Вывести ID самого популярного хобби.
SELECT sth.hobby_id
FROM students_hobbies sth
GROUP BY sth.hobby_id
ORDER BY COUNT(sth.n_z) DESC
LIMIT 1
*/Вывести всю информацию о студентах, занимающихся самым популярным хобби.
SELECT st.*
FROM students st
INNER JOIN students_hobbies sth
ON st.n_z = sth.n_z
WHERE
  sth.hobby_id = (SELECT sth.hobby_id
    FROM students_hobbies sth
    GROUP BY sth.hobby_id
    ORDER BY COUNT(sth.n_z) DESC
    LIMIT 1) AND
  sth.date_finish IS NULL
*/Вывести ID 3х хобби с максимальным риском.
SELECT h.id
FROM hobby h
ORDER BY h.risk DESC
LIMIT 3
*/Вывести 10 студентов, которые занимаются одним (или несколькими) хобби самое продолжительно время.
SELECT *, AGE(COALESCE(date_finish,NOW()),date_start) do_time
FROM students st
INNER JOIN students_hobbies sth
ON st.n_z = sth.n_z
ORDER BY do_time DESC
LIMIT 10
*/Вывести номера групп (без повторений), в которых учатся студенты из предыдущего запроса.
SELECT DISTINCT sub.group_num
FROM
  (SELECT *, AGE(COALESCE(date_finish,NOW()),date_start) do_time
  FROM students st
  INNER JOIN students_hobbies sth
  ON st.n_z = sth.n_z
  ORDER BY do_time DESC
  LIMIT 10) sub
*/Создать представление, которое выводит номер зачетки, имя и фамилию студентов, отсортированных по убыванию среднего балла.
CREATE OR REPLACE VIEW st_score AS
SELECT st.n_z, st.name, st.surname
FROM students st
ORDER BY st.score DESC
*/Представление: найти каждое популярное хобби на каждом курсе.
CREATE  VIEW mpopular_h AS
SELECT DISTINCT ON (1) LEFT(st.group_num::VARCHAR,1) grade, h.id
FROM students st
INNER JOIN students_hobbies sth
ON st.n_z = sth.n_z
INNER JOIN hobby h
ON sth.hobby_id = h.id
GROUP BY LEFT(st.group_num::VARCHAR,1), h.id
ORDER BY LEFT(st.group_num::VARCHAR,1), COUNT(h.id) DESC
*/Представление: найти хобби с максимальным риском среди самых популярных хобби на 2 курсе.


*/Представление: для каждого курса подсчитать количество студентов на курсе и количество отличников.
CREATE VIEW bestscore_st AS
SELECT 
  LEFT(st.group_num::VARCHAR,1) grade, 
  COUNT(st.n_z) total, 
  COUNT(st.n_z) FILTER (WHERE st.score >= 4.5) goodcount
FROM students st
GROUP BY LEFT(st.group_num::VARCHAR,1)
*/Представление: самое популярное хобби среди всех студентов.
CREATE VIEW h_popular AS
SELECT *
FROM hobby h
WHERE 
  h.id = 
    (SELECT h.id
    FROM students st
    INNER JOIN students_hobbies sth
    ON st.n_z = sth.n_z
    INNER JOIN hobby h
    ON sth.hobby_id = h.id
    GROUP BY h.id
    ORDER BY COUNT(h.id) DESC
    LIMIT 1)
*/Создать обновляемое представление.
CREATE OR REPLACE VIEW students_short AS
SELECT st.n_z, st.name, st.surname, st.group_num
FROM students st
*/Для каждой буквы алфавита из имени найти максимальный, средний и минимальный балл. (Т.е. среди всех студентов, чьё имя начинается на А (Алексей, Алина, Артур, Анджела) найти то, что указано в задании. Вывести на экран тех, максимальный балл которых больше 3.6
SELECT LEFT(st.name::VARCHAR,1), MIN(st.score), MAX(st.score), ROUND(AVG(st.score),2)
FROM students st
GROUP BY LEFT(st.name::VARCHAR,1)
HAVING MAX(st.score) > 3.6
*/Для каждой фамилии на курсе вывести максимальный и минимальный средний балл. (Например, в университете учатся 4 Иванова (1-2-3-4). 1-2-3 учатся на 2 курсе и имеют средний балл 4.1, 4, 3.8 соответственно, а 4 Иванов учится на 3 курсе и имеет балл 4.5. На экране должно быть следующее: 2 Иванов 4.1 3.8 3 Иванов 4.5 4.5
SELECT 
  LEFT(st.group_num::VARCHAR,1), 
  st.surname,
  MIN(st.score),
  MAX(st.score)
FROM students st
GROUP BY
  LEFT(st.group_num::VARCHAR,1),
  st.surname
*/Для каждого года рождения подсчитать количество хобби, которыми занимаются или занимались студенты.
SELECT EXTRACT(YEAR FROM st.date_of_birth), COUNT(*)
FROM students st
INNER JOIN student_hobby sth
ON st.n_z = sth.n_z
GROUP BY EXTRACT(YEAR FROM st.date_of_birth)
*/Для каждой буквы алфавита в имени найти максимальный и минимальный риск хобби.


*/Для каждого месяца из даты рождения вывести средний балл студентов, которые занимаются хобби с названием «Футбол»
SELECT EXTRACT(MONTH FROM st.date_of_birth), COUNT(st.n_z)
FROM students st
INNER JOIN student_hobby sth
ON sth.n_z = st.n_z
INNER JOIN hobby h
ON sth.id_hobby = h.id
GROUP BY EXTRACT(MONTH FROM st.date_of_birth), h.name
HAVING h.name = 'Футбол'
*/Вывести информацию о студентах, которые занимались или занимаются хотя бы 1 хобби в следующем формате: Имя: Иван, фамилия: Иванов, группа: 1234
SELECT st.name, st.surname, st.group_num
FROM students st
WHERE
  st.n_z IN 
    (SELECT st.n_z
    FROM students st
    INNER JOIN students_hobbies sth
    ON sth.n_z = st.n_z
    INNER JOIN hobby h
    ON sth.hobby_id = h.id
    GROUP BY st.n_z)
*/Найдите в фамилии в каком по счёту символа встречается «ов». Если 0 (т.е. не встречается, то выведите на экран «не найдено».
SELECT 
  st.surname,
  CASE
    WHEN POSITION('ов' IN st.surname) = 0
    THEN 'Не найдено'
  ELSE POSITION('ов' IN st.surname)::VARCHAR
  END
FROM students st
*/Дополните фамилию справа символом # до 10 символов.
SELECT OVERLAY('##########' placing st.surname FROM 1)
FROM students st
*/При помощи функции удалите все символы # из предыдущего запроса.
SELECT TRIM(TRAILING '#' FROM OVERLAY('##########' placing st.surname FROM 1))
FROM students st
*/Выведите на экран сколько дней в апреле 2018 года.
SELECT EXTRACT(DAY FROM '2018-05-01'::TIMESTAMP-'2018-04-01'::TIMESTAMP)
*/Выведите на экран какого числа будет ближайшая суббота.
SELECT NOW()::DATE + (6-EXTRACT(DOW FROM NOW()))::INT
*/Выведите на экран век, а также какая сейчас неделя года и день года.
SELECT 
  EXTRACT(CENTURY FROM NOW()) cent, 
  EXTRACT(WEEK FROM NOW()) week,
  EXTRACT(DOY FROM NOW()) days
*/Выведите всех студентов, которые занимались или занимаются хотя бы 1 хобби. Выведите на экран Имя, Фамилию, Названию хобби, а также надпись «занимается», если студент продолжает заниматься хобби в данный момент или «закончил», если уже не занимает.
SELECT 
  st.name, 
  st.surname,
  h.name,
  CASE
    WHEN (sth.date_finish IS NULL) THEN 'Занимается'
    WHEN (sth.date_finish IS NOT NULL) THEN 'Закончил'
  END status
FROM students st
INNER JOIN students_hobbies sth
ON sth.n_z = st.n_z
INNER JOIN hobby h
ON sth.hobby_id = h.id
*/Для каждой группы вывести сколько студентов учится на 5,4,3,2. Использовать обычное математическое округление.
SELECT 
  st.group_num, 
  COUNT(st.score) FILTER (WHERE ROUND(st.score) = 5) five,
  COUNT(st.score) FILTER (WHERE ROUND(st.score) = 4) four,
  COUNT(st.score) FILTER (WHERE ROUND(st.score) = 3) three,
  COUNT(st.score) FILTER (WHERE ROUND(st.score) = 2) two
FROM students st
GROUP BY
  st.group_num