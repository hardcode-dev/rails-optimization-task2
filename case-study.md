# Case-study оптимизации

## Case 1
Метрика на 50 тысячах строков
~ 35 секунд

### Бюжет
Оптимизировать и снизить время выполнянения до 1 секунд

### Пишу спеку для фиксации текущей метрики
spec/work_performance_spec.rb:13

### Профилировщик:
1. Воспользовался memory profiler (ruby profiling/memory_profiler.rb)
   Total allocated: 10.37 GB (1847402 objects)

Первая точка роста:
**allocated memory by location**
`7.16 GB  /Users/bs/Documents/My_projects/Optimization/rails-optimization-task2/task-2.rb:54`

`sessions = sessions + [parse_session(line)] if cols[0] == 'session'`

**allocated objects by location**
`134610  /Users/bs/Documents/My_projects/Optimization/rails-optimization-task2/task-2.rb:54`

### В результате
``users << parse_user(line) if cols[0] == 'user'
sessions << parse_session(line) if cols[0] == 'session'
``

После оптимизации:
Total allocated: 2.97 GB (1747402 objects)
Total retained:  5.81 MB (88478 objects)

~ В 2.4 раза уменьшилось общее потребление памяти

### Обновил тест на производительность
Метрика не изменилась

### feedback loop
**Iteration 1:**

Дописал хелпер(**rails-optimization-task2/profiling/profiling_helpers.rb**) в котором снимается метрика:
Общее количество объектов выделенных во время работы программы(с каждой успешной оптимизацией ожидаю что метрика будет снижаться),
время работы программы и количество памяти затраченой при работе программы   
отработки программы)
* Вызов методов из хелпера
  `ruby rails-optimization-task2/call_task2.rb` # название поменял на call_report_processor.rb

_Total allocated objects during execution program: 1747431
Time taken: 21.5 seconds
Memory usage: 249 MB_

* Применил memory profile:
  Точка роста:

allocated memory by location
2.60 GB  rails-optimization-task2/task-2.rb:100

`user_sessions = sessions.select { |session| session['user_id'] == user['id'] }`

**Решение**

`grouped_sessions = sessions.group_by { |session| session['user_id'] }`

Один раз сгрупировать сессии по юзерам вне цикла
Далее внутри цикла использовать вытаскивать сессии для конкретного пользователя по хешу (O(1))

Результат после оптимизации:
`ruby rails-optimization-task2/call_task2.rb` # далее переменовал этот файл в call_report_processor.rb

_Total allocated objects during execution program: 1739737
Time taken: 0.38 seconds
Memory usage: 113 MB_

Вижу что время работы сильно сократилось ~ в 56 раз
Общее количество объектов выделенных во время работы программы сократилось на 7694
Количество памяти затраченой при работе программы сократилось в 2.2 раза

**Обновил тест на производительность**
`rspec rails-optimization-task2/spec/work_performance_spec.rb`

**Iteration 2:**
* Применил memory profile:
  Total allocated: 129.93 MB (1739706 objects)
  Total retained:  5.81 MB (88478 objects)


## Case 2
(Привожу задачу к ранее оптимизированному решению сделанному в taks-1)
И начинаю оптимизировать по памяти.

Метрика на 500 тысячах строк:

Total allocated: 832.13 MB (9897696 objects)
Total retained:  59.88 MB (882639 objects)

allocated objects by location

### Бюжет
Хочу снизить потребление памяти до 50 мб

### Применяю профилировщик

281.15 MB  /rails-optimization-task2/task-2.rb:49
Указывает на split.

Вот тут начались трудности, я пытался не делать это через сплит, парсил посимвольно, даже написал что-то.
Сначала я добавил построчное чтение с foreach, результат особо не изменился видимо потому что файл слишком маленького размера и проблема скорее не в загрузки фала в память а в агригировании данных в памяти создания дополнительных объектов. Тут я пока не понял как они по какой формуле можно посчитать заранее какое количество объектов того или иного класса будет на большем объеме данных(нужно заново смотреть ваши ведео)
Потратил очень много времени, минус моральнулся потому, что от сплита избаивался кое как, а осталось понимание что есть куча мест с агригированием данных которые делаются в памяти(я это помнил но уделил внимание на точку росту которая показывалась memory profile-ром.

Весь feadback loop поехал.

### Решение
Погряз в ошибках реализации.
Начал думать и читать как писать данные сразу в файл на диск минуя память.

### В результате (на файле data_large.txt 3_250_940 строк):
`ruby call_report_processor.rb`

MEMORY USAGE: 13 MB
Total allocated objects during execution program: 60875597
Time taken: 7.52 seconds
Memory usage: 17 MB

В бюджет уложился. Время обработки снизилось в ~3.26 раз от значений полученых после оптимизации в задании 1.
Больше всего из инструментов помог показатель объма памяти выделенного процессу в настоящее время.

### Обновил тест на производительность

`rspec spec/services/report_processor_performance_spec.rb`
`rspec spec/services/report_processor_spec.rb`

------

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.
