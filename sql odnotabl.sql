/*Однотабличные запросы по созданным мной базам данных на ресурсе pgAdmin

/*Вывести всеми возможными способами имена и фамилии студентов, средний балл которых от 4 до 4.5
SELECT name,surname FROM students WHERE score >= 4.0 AND score <= 4.5

/*Познакомиться с функцией CAST. Вывести при помощи неё студентов заданного курса (использовать Like)
SELECT * FROM students st WHERE CAST(st.group_num AS VARCHAR) LIKE '2%'

/*Вывести всех студентов, отсортировать по убыванию номера группы и имени от А до Я
SELECT * FROM students st ORDER BY st.group_num DESC, st.name

/*Вывести студентов, средний балл которых больше 4, и отсортировать по баллу от большего к меньшему
SELECT * FROM students st WHERE st.score >= 4.0 ORDER BY st.score DESC

/*Вывести на экран название и риск футбола и хоккея
SELECT h.name, h.risk FROM hobby h WHERE h.name = 'Футбол' OR h.name = 'Хоккей'

/*Вывести ID хобби и ID студента, которые начали заниматься хобби между двумя заданными датами (выбрать самим) и студенты должны до сих пор заниматься хобби
SELECT st_h.n_z, st_h.hobby_id FROM students_hobbies st_h WHERE st_h.date_start > '2007-01-01' AND st_h.date_start < '2009-01-01' AND st_h.date_finish IS NULL

/*Вывести студентов, средний балл которых больше 4.5 и отсортировать по баллу от большего к меньшему
SELECT * FROM students st WHERE st.score >= 4.5 ORDER BY st.score DESC

/*Из предыдущего запроса вывести несколькими способами на экран только 5 студентов с максимальным баллом
SELECT * FROM students st WHERE st.score >= 4.5 ORDER BY st.score DESC LIMIT 5

SELECT * FROM students st WHERE st.score >= 4.5 ORDER BY st.score DESC FETCH FIRST 5 ROWS ONLY

/*Выведите хобби и с использованием условного оператора сделайте риск словами
SELECT h.name,
CASE 
WHEN h.risk < 2 THEN 'Очень низкий'
WHEN h.risk >= 2 AND h.risk < 4 THEN 'Низкий'
WHEN h.risk >= 4 AND h.risk < 6 THEN 'Средний'
WHEN h.risk >= 6 AND h.risk < 8 THEN 'Высокий'
WHEN h.risk >= 8 THEN 'Очень высокий'
END risk
FROM hobby h 
/*Вывести 3 хобби с максимальным риском
SELECT * FROM hobby h ORDER BY h.risk DESC LIMIT 3