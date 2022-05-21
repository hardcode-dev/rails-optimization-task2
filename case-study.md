# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику: *тут ваша метрика*

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался гемом 'memory-profiler'

Вот какие проблемы удалось найти и решить

### Ваша находка №1
файл data_32509.txt (1% от файла data_large.txt) показал следующие данные
MEMORY USAGE: 3499 MB
Total allocated: 4.44 GB (1657221 objects)
Total retained:  4.29 kB (9 objects)

Точкой роста была 

    users = users + [parse_user(line)] if cols[0] == 'user'
    sessions = sessions + [parse_session(line)] if cols[0] == 'session'

    allocated memory by location
    -----------------------------------
    3.03 GB  /Users/farid/projects/rails-optimization-task2/task-2.rb:56

как мне кажется проблема в конкатенации массивов users и session, изменил на добавление parse_user(line)
в массив users без создания нового массива, тоже самое проделано с parse_session(line) при добавлении в sessions и
получился следующий результат

    MEMORY USAGE: 460 MB
    Total allocated: 1.31 GB (1592203 objects)
    Total retained:  4.29 kB (9 objects)

как видно по результатам, использование памяти уменьшилось почти в 8 раз

### Ваша находка №2

Следующей точкой роста была строка 102

    MEMORY USAGE: 460 MB
    Total allocated: 1.31 GB (1592203 objects)
    Total retained:  4.29 kB (9 objects)

    allocated memory by location
    -----------------------------------
    1.10 GB  /Users/farid/projects/rails-optimization-task2/task-2.rb:102
    
    user_sessions = sessions.select { |session| session['user_id'] == user['id'] }

после изменения select на group_by по user_id (групировку по user_id)

    MEMORY USAGE: 443 MB
    Total allocated: 216.08 MB (1597184 objects)
    Total retained:  4.29 kB (9 objects)

MEMORY USAGE не сильно изменился, но Total allocated как видно изменился

### Ваша находка №3

Следующей точкой роста была строка 106

    MEMORY USAGE: 443 MB
    Total allocated: 216.08 MB (1597184 objects)
    Total retained:  4.29 kB (9 objects)
    
    99.70 MB  /Users/farid/projects/rails-optimization-task2/task-2.rb:106

    users_objects = users_objects + [user_object]

проблема такая же как находка №1, то есть конкантенация с использованием нового массива
результат после внесения правки

    MEMORY USAGE: 348 MB
    Total allocated: 116.44 MB (1587220 objects)
    Total retained:  4.29 kB (9 objects)
