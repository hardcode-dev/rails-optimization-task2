# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику: программа не должна потреблять больше **70Мб** памяти при обработке файла `data_large.txt` в течение всей своей работы.
(Учел ошибку первой домашней работы и сделал объем данных больше, для того чтобы проблемы были более очевидны на частичных файлах от основного)
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

### Ваша находка №5
- Использую data_40000.txt, профайлеры показывают, что точки роста есть, но они незначительные. Скорее всего их исправление не поможет уложиться в 70 мБ для полного файла.
  К тому же на данном этапе мы сохраняем весь файл целиком в файл, только на чтение  `data_large.txt` и сохранение в `result.json` потребуется значительно больше памяти.
  Поэтому дальше попробую воспользоваться подсказкой из readme перепишу в "потоковом" стиле, то-есть чтение/запись по строкам. Это должно кратно сократить потребление памяти на больших объемах.

- Проблема в считывании всего файла и подготовки отчета, целиком. 
```
```
- как изменилась метрика
```
GC disabled MEMORY USAGE: 86 MB
GС enabled MEMORY USAGE: 36 MB
```
- как изменился отчёт профилировщика.
```
MEMORY USAGE: 199 MB
allocated memory by file
-----------------------------------
  75.94 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb
  15.42 kB  /home/alex/.asdf/installs/ruby/2.7.8/lib/ruby/2.7.0/set.rb
   40.00 B  memory-profiler.rb

allocated memory by location
-----------------------------------
  30.05 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:7
  12.89 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:9
   6.57 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:43
   4.74 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:58
   4.02 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:59
   3.10 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:64
   2.40 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:8
   2.11 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:39
   2.03 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:71
   1.79 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:42
   1.55 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:22
   1.40 MB  /home/alex/documents/studies/rails-optimization-task2/task-2.rb:19
```
- Пришлось переписать весть код, перейти на построчное считывание данных и их запись. Так же запустил тест на файле `data_large.txt`, в итоге уложился в метрику с двухкратным запасом. Файл потребляет ~38 мБ.

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с 131 MB при выполнении 20_000к строк и 226 MB при выполнении 40_000к строк в начале, до ~38 мБ на файле `data_large.txt` и уложиться в заданный бюджет.

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы был написан performance тест для полного объема файла `data_large.txt`
