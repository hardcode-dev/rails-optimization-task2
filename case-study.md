# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт таким образом, чтобы в процессе выполнения потребление памяти не превышало 70мб.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Например, обработка файла размеро 4 мб отнимала 151 мб оперативной памяти. 

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я создал бенчмарк с использованием гема `memory_profiler`.

Бенчмарк после выполнения отображал в консоли отчет `CallTree` `ruby_prof`, который позволял определить общий объем выделенной памяти, количество объектов с построчной детализацией, что позволило быстро определить точку роста и влияние вносимых изменений на ее рост.  

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.
Тем не менее, тест был переписан с `minitest` на `rspec` для личного удобства формирования фидбек-лупа.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за ~30 секунд, включающих запуск теста, прогон программы и изучения отчета в консоли.

За основу фидбек-лупа был взял опыт предыдущего задания. В основу лег отчет `MemoryProfiler`, выводимый в консоль.
Код первой версии профилировщика:
```ruby
require 'memory_profiler'
require_relative '../task-2'

report = MemoryProfiler.report do
  work
end

report.pretty_print
```

В дальнейшем в этом же бенчмарке формировались и другие виды отчетов, так что можно было сразу увидеть результат изменения с нескольких точек зрения.
Забегая вперед поделюсь, что `MemoryProfiler` настолько мощный, что вполне можно было обойтись им.

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался разработанным фидбек-лупом и `MemoryProfiler`.
Первым делом я произвел замеры неоптимизированного кода.

![unoptimized_valgrind](https://github.com/theendcomplete/rails-optimization-task2/blob/task-2/case_study_media/valgrind_unoptimized.png?raw=true)

Первый отчет `MemoryProfiler` обработки файла в 5000 строк:

```bash
(base) theendcomplete@N10L:~/Documents/projects/my/rails-optimization-task2$ ruby benchmarks/memory_profiler_benchmark.rb 
MEMORY USAGE: 21 MB
Total allocated: 80240 bytes (948 objects)
Total retained:  7263 bytes (45 objects)

allocated memory by gem
-----------------------------------
     80240  other

allocated memory by file
-----------------------------------
     80240  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

allocated memory by location
-----------------------------------
     19396  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
     11282  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:142
      8520  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
      7200  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
      4200  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
      4088  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
      2832  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:54
      2567  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:46
      2520  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:28
      1912  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:80
      1891  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
      1320  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
      1096  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
       960  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:53
       840  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
       840  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
       760  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90
       624  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:101
       608  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:108
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:113
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:118
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:123
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:128
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:133
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:138
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:18
       488  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143
       480  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:100
       256  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93
       240  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:102
       240  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
       200  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:91
       168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
       168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
       160  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:89
       152  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:92
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:45
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:48
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:49
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:77
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:96

allocated memory by class
-----------------------------------
     30675  String
     16816  Array
     13896  Hash
      8656  File
      4117  Regexp
      3984  MatchData
      1080  Date
       560  Proc
       224  JSON::Ext::Generator::State
       120  User
        72  Thread::Mutex
        40  Process::Status

allocated objects by gem
-----------------------------------
       948  other

allocated objects by file
-----------------------------------
       948  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

allocated objects by location
-----------------------------------
       214  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
       141  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       120  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
       105  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
        48  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:54
        33  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
        28  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
        28  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:80
        24  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:53
        23  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:46
        21  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
        18  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
        16  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90
        15  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
        15  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
        15  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:28
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143
         8  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:142
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:101
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:102
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:100
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:108
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:113
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:118
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:123
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:128
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:133
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:138
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:18
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:91
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:45
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:48
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:49
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:77
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:89
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:92
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:96

allocated objects by class
-----------------------------------
       645  String
       167  Array
        85  Hash
        18  MatchData
        15  Date
         7  Proc
         3  Regexp
         3  User
         2  File
         1  JSON::Ext::Generator::State
         1  Process::Status
         1  Thread::Mutex

retained memory by gem
-----------------------------------
      7263  other

retained memory by file
-----------------------------------
      7263  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

retained memory by location
-----------------------------------
      5476  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
       504  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
       331  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
       216  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93
       168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
       168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
       120  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
       120  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
       120  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143

retained memory by class
-----------------------------------
      4117  Regexp
      2026  String
       840  Hash
       240  Array
        40  Process::Status

retained objects by gem
-----------------------------------
        45  other

retained objects by file
-----------------------------------
        45  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

retained objects by location
-----------------------------------
        26  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93

retained objects by class
-----------------------------------
        33  String
         5  Hash
         3  Array
         3  Regexp
         1  Process::Status


Allocated String Report
-----------------------------------
        81  " "
        60  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        21  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39

        48  "session"
        18  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:54
        15  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        15  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

        37  ","
        18  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        15  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93

        24  "user"
        18  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:53
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

        22  "0"
        11  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

        18  "1"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
         8  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

        16  "2"
         8  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

         9  "Cira"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         9  "Gregory"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         9  "Katrina"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         9  "Leida"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         9  "Palmer"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         9  "Santos"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         8  "2016"
         8  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         8  "3"
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         8  "Gregory Santos"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40

         8  "Leida Cira"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40

         8  "Palmer Katrina"
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40

         7  "Gregory "
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39

         7  "Leida "
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39

         7  "Palmer "
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39

         6  " min."
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

         6  "INTERNET EXPLORER 28"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90

         5  "2017"
         5  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         5  "CHROME 35"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90

         4  "09"
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         4  "12"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-09-01"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-09-15"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-10-21"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-10-23"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-11-11"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-11-25"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-12-20"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2016-12-28"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2017-02-27"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2017-03-28"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2017-04-29"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2017-05-22"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2017-09-27"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2018-02-02"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "2018-09-21"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "28"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "4"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "6"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "INTERNET EXPLORER 10"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90

         4  "Internet Explorer 28"
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

         4  "SAFARI 17"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90

         4  "SAFARI 29"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90

         4  "SAFARI 49"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90


Retained String Report
-----------------------------------
         1  "('?[-+]?\\d+)-(\\d+)-('?-?\\d+)"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "((?:\\d+\\s*:\\s*\\d+(?:\\s*:\\s*\\d+(?:[,.]\\d*)?)?|\\d+\\s*h(?:\\s*\\d+m?(?:\\s*\\d+s?)?)?)(?:\\s*[ap](?:m\\b|\\.m\\.))?|\\d+\\s*[ap](?:m\\b|\\.m\\.))(?:\\s*((?:gmt|utc?)?[-+]\\d+(?:[,.:]\\d+(?::\\d+)?)?|(?-i:[[:alpha:].\\s]+)"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "116 min."
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

         1  "118 min."
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

         1  "192 min."
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

         1  "2016-09-01"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2016-09-15"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2016-10-21"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2016-10-23"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2016-11-11"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2016-11-25"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2016-12-20"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2016-12-28"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2017-02-27"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2017-03-28"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2017-04-29"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2017-05-22"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2017-09-27"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2018-02-02"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "2018-09-21"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "218 min."
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

         1  "455 min."
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

         1  "85 min."
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

         1  "CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124

         1  "CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93

         1  "CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124

         1  "FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124

         1  "Gregory Santos"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40

         1  "Leida Cira"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40

         1  "Palmer Katrina"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40

         1  "[^-+',./:@[:alnum:]\\[\\]]+"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "_bc"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         1  "_comp"
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
```

Он показался наиболее интересным, так как отрабатывает довольно быстро, но уже показывает проблемы, возникающие при большом объеме данных.

Вот какие проблемы удалось найти и решить:

### Ваша находка №1
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика

### Ваша находка №2
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика

### Ваша находка №X
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с *того, что у вас было в начале, до того, что получилось в конце* и уложиться в заданный бюджет.

*Какими ещё результами можете поделиться*

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*
