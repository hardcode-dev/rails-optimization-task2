# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику: программа не должна потреблять больше нескольких мегабайт памяти при обработке файлов `data_2000.txt` затем `data_4000.txt`.
(Учел ошибку первой домашней работы и сделал объем данных больше, для того чтобы проблемы были более очевидны)
Первичные измерения:
1. `data_20000.txt`
```
GC enabled: MEMORY USAGE: 131 MB
GC disabled MEMORY USAGE: 1287 MB
```
2. `data_40000.txt`
```
GC enabled: MEMORY USAGE: 226 MB
GC disabled MEMORY USAGE: 4856 MB
```

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за 15-20 секунд.

Вот как я построил `feedback_loop`:
- Собрал в одну команду выполнение всех профилировщиков, для удобства

Следующие шаги выполняются в цикле
- Зафиксировал бюджет метрики, которую определили выше.
  То-есть выбрать объем данных, который выполняется за адекватное время, на первой итерации например 5 сек. (20_000 строк кода на моей машине) и посмотреть на потребляемую память, которая равна 146 мб.
  Когда потребляемая память сильно сократиться, для удобства перейти на файлы размером 40_000 и затем 60_000.
- Защитить метрику от дальнейшей деградации, написать тест
- С помощью профилировщика найти главную точку роста
- Внести оптимизационные правки
- С помощью профилировщика проверить есть ли улучшения
- Запустить тест, проверить, если улучшения с включенным GC есть тогда закоммитить.

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался ruby-prof, memory-profiler и qcachegrind

Вот какие проблемы удалось найти и решить

### Ваша находка №1
- Использую data_20000.txt, memory-profiler указал на главную точку роста, а именно:
```
MEMORY USAGE: 1371 MB
allocated memory by location
-----------------------------------
   1.15 GB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:57
   
   Строка 57:
   sessions = sessions + [parse_session(line)] if cols[0] == 'session'
```
Проблема в создании новой переменной на каждой итерации. Заодно исправил этот момент во всем коде.
- Строка 57:
```
sessions << parse_session(line) if cols[0] == 'session'
```
- Строка 56
```
users << parse_user(line) if cols[0] == 'user'
```
- Строка 83:
```
uniqueBrowsers << browser if uniqueBrowsers.all? { |b| b != browser }
```
- Строка 105:
```
users_objects << user_object
```
- как изменилась метрика
```
GC disabled MEMORY USAGE: 198 MB
GС enabled MEMORY USAGE: 117 MB
```
- как изменился отчёт профилировщика
```
MEMORY USAGE: 198 MB
allocated memory by location
-----------------------------------
    800.00 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:57
    800.00 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:56
```
- В целом, кажется что главная точка роста исправлена со 146 мб удалось получить 117 мб. Коммит и переход к следующей.

### Ваша находка №2
- Использую data_20000.txt, memory-profiler указал на главную точку роста, а именно:
```
MEMORY USAGE: 197 MB
allocated memory by location
-----------------------------------
   413.26 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:103

   
   Строка 103:
   user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
```
- Как и в первой домашней работе заменил перебор всех сессий на хэш с группированные данных по user_id. В данном конкретном месте алгоритмическая сложность с O(n) изменилась на O(1).
```
  user_sessions = sessions.group_by { |session| session['user_id'] }
  users_objects = users.map do |user|
    User.new(attributes: user, sessions: user_sessions[user['id']] || [])
  end
```
-- как изменилась метрика
```
GC disabled MEMORY USAGE: 105 MB
GС enabled MEMORY USAGE: 62 MB
```
- как изменился отчёт профилировщика
```
MEMORY USAGE: 186 MB
allocated memory by location
-----------------------------------
    700.74 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:100
    536.14 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:101
    121.88 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:102
```
- В целом, кажется что главная точка роста исправлена со 117 мб удалось получить 62 мб. Коммит и переход к следующей.


### Ваша находка №3
- Использую data_20000.txt, memory-profiler указал на главную точку роста, а именно:
```
MEMORY USAGE: 186 MB
allocated memory by location
-----------------------------------
   15.44 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:139

   
   Строка 139:
   collect_stats_from_users(report, users_objects) do |user|
     { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
   end
```
- Тут видется проблема неоптимального использования метода collect_stats_from_users.
  Оптимизировал, а именно избавился от collect_stats_from_users и начал подготавливать данные для отчета за один проход.
```
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

    # Подготовим данные для сессий
    sessions = user.sessions
    times = sessions.map { |s| s['time'].to_i }
    browsers = sessions.map { |s| s['browser'].upcase }

    report['usersStats'][user_key] = {
      # Количество сессий
      'sessionsCount' => sessions.count,
      # Общее время
      'totalTime' => "#{times.sum} min.",
      # Самая длинная сессия
      'longestSession' => "#{times.max} min.",
      # Браузеры через запятую
      'browsers' => browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => browsers.any? { |b| b.include?('INTERNET EXPLORER') },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => browsers.all? { |b| b.include?('CHROME') },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map { |s| s['date'] }.sort.reverse
    }
  end
```
- как изменилась метрика
```
GC disabled MEMORY USAGE: 75 MB
GС enabled MEMORY USAGE: 59 MB
```
- как изменился отчёт профилировщика
```
MEMORY USAGE: 116 MB
allocated memory by location
-----------------------------------
    121.84 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:108
    242.98 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:112
     921.14 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:113
     633.57 kB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:115
```
- Главная точка роста исправлена со 62 мб удалось получить 59 мб. Коммит и переход к следующей.

### Ваша находка №4
- Перешел на использование data_40000.txt, профайлеры указал на главную точку роста, а именно:
```
MEMORY USAGE: 206 MB
allocated memory by file
-----------------------------------
    18.95 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:55
    16.25 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:28

    Строка 28:
    fields = session.split(',')

    Строка 55:
    cols = line.split(',')
```
Так же удалось поставить kcachegrind на ubuntu. Были проблемы с зависимостями.

- Тут проблема неоптимального использования метода split.
  Оптимизировал, а именно избавился от избыточного использования split. Перешел на использование переменных.
```
def parse_session(user_id, session_id, browser, time, date)
  {
    'user_id' => user_id,
    'session_id' => session_id,
    'browser' => browser,
    'time' => time,
    'date' => date,
  }
end
```
- как изменилась метрика
```
GC disabled MEMORY USAGE: 66 MB
GС enabled MEMORY USAGE: 58 MB
```
- как изменился отчёт профилировщика
```
MEMORY USAGE: 156 MB
allocated memory by file
-----------------------------------
    18.95 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:53
    1.03 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:24
```
- Главная точка роста исправлена со 59 мб удалось получить 58 мб. Коммит и переход к следующей.

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с *того, что у вас было в начале, до того, что получилось в конце* и уложиться в заданный бюджет.

*Какими ещё результами можете поделиться*

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*
