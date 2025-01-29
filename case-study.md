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

При подготовке фидбек-лупа был учтен опыт предыдущего задания. В основу лег отчет `MemoryProfiler`, выводимый в консоль.
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
MEMORY USAGE: 135 MB
Total allocated: 118338189 bytes (223632 objects)
Total retained:  576151 bytes (8882 objects)

allocated memory by gem
-----------------------------------
 118338189  other

allocated memory by file
-----------------------------------
 118338149  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb
        40  benchmarks/memory_profiler_benchmark.rb

allocated memory by location
-----------------------------------
  71991240  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:54
  26198352  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:100
   3854988  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
   2661272  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:53
   2461272  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:102
   2369040  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
   2028480  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
    910224  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
    709968  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:28
    650160  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
    637352  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:46
    497910  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
    468638  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:142
    340560  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
    238984  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
    215168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
    215168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
    202888  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90
    176752  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:80
    160992  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:101
    144960  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:108
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:113
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:118
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:123
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:128
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:133
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:138
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:18
     61920  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
     33888  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:91
     33848  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:89
     28768  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
      2645  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93
      1640  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:92
       488  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143
       168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:48
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:49
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:77
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:96
        40  benchmarks/memory_profiler_benchmark.rb:5

allocated memory by class
-----------------------------------
 106163384  Array
   7185896  String
   3560680  Hash
   1079888  MatchData
    304272  Date
     30960  User
      8656  File
      4117  Regexp
       224  JSON::Ext::Generator::State
        72  Thread::Mutex
        40  Process::Status

allocated objects by gem
-----------------------------------
    223632  other

allocated objects by file
-----------------------------------
    223631  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb
         1  benchmarks/memory_profiler_benchmark.rb

allocated objects by location
-----------------------------------
     55289  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
     39226  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
     33808  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
     16254  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39
     13452  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:54
      8787  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
      6548  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:53
      5418  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
      5418  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
      5004  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:46
      4227  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:90
      4226  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:28
      3940  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:129
      3870  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
      3870  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
      2255  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:134
      1548  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:101
      1548  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:102
      1548  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:100
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:108
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:113
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:118
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:123
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:128
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:133
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:138
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:18
       400  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:80
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143
         8  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:142
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:91
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:48
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:49
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:77
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:89
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:92
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:96
         1  benchmarks/memory_profiler_benchmark.rb:5

allocated objects by class
-----------------------------------
    157242  String
     34950  Array
     21614  Hash
      4818  MatchData
      4226  Date
       774  User
         3  Regexp
         2  File
         1  JSON::Ext::Generator::State
         1  Process::Status
         1  Thread::Mutex

retained memory by gem
-----------------------------------
    576151  other

retained memory by file
-----------------------------------
    576151  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

retained memory by location
-----------------------------------
    234820  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
    130032  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
     86838  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
     30960  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
     30960  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
     30960  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
     28768  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
      2605  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93
       168  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143

retained memory by class
-----------------------------------
    351882  String
    158968  Hash
     61144  Array
      4117  Regexp
        40  Process::Status

retained objects by gem
-----------------------------------
      8882  other

retained objects by file
-----------------------------------
      8882  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

retained objects by location
-----------------------------------
      5008  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:40
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:41
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:105
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:143
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:72
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93

retained objects by class
-----------------------------------
      7328  String
       776  Hash
       774  Array
         3  Regexp
         1  Process::Status


Allocated String Report
-----------------------------------
     22322  " "
     16904  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
      5418  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:39

     13452  "session"
      5000  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:54
      4226  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
      4226  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

     10001  ","
      5000  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
      4226  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:93

      6548  "user"
      5000  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:53
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52

      1652  "0"
       825  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       818  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

      1579  "2017"
      1579  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

      1548  " min."
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

      1524  "2018"
      1524  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

      1468  "1"
       734  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       730  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

      1352  "2"
       675  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       665  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

      1206  "3"
       603  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       590  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        13  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       988  "4"
       494  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       488  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       943  "2016"
       943  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       858  "5"
       429  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       417  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        12  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       774  ", "
       774  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:124

       718  "6"
       358  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       351  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       618  "10"
       508  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        55  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        44  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        11  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       609  "12"
       506  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        48  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        41  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       603  "11"
       519  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        41  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        35  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       588  "7"
       294  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       285  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       577  "08"
       577  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       543  "07"
       543  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       521  "01"
       521  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       499  "06"
       499  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       492  "05"
       492  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       472  "09"
       472  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       449  "02"
       449  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       417  "04"
       417  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       405  "03"
       405  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

       404  "8"
       201  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       191  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       272  "13"
       155  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        57  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        49  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         8  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

       271  "27"
       135  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        67  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        55  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        12  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       264  "18"
       140  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        62  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        52  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       259  "19"
       145  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        57  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        52  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         5  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       253  "28"
       141  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        55  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        38  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        17  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       252  "14"
       127  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        60  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        50  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

       242  "21"
       133  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        53  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        42  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        11  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

       239  "17"
       133  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        53  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        43  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       239  "24"
       152  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        42  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        37  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         5  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

       239  "25"
       149  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        45  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         5  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       239  "29"
       124  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        55  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        48  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

       238  "20"
       147  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        44  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        34  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

       235  "9"
       116  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
       110  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

       228  "23"
       135  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        44  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        34  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       225  "16"
       123  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        51  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        32  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
        19  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       225  "26"
       129  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        48  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        39  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17

       223  "15"
       127  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        47  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         7  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       223  "30"
       121  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        48  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        39  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       212  "31"
       106  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        51  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        45  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

       203  "22"
       122  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139
        40  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:52
        34  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:27
         6  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:17
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119


Retained String Report
-----------------------------------
        35  "114 min."
        33  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        32  "117 min."
        30  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        31  "118 min."
        31  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

        30  "116 min."
        29  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        29  "119 min."
        28  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        28  "113 min."
        28  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

        27  "108 min."
        26  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        27  "111 min."
        24  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         3  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        24  "103 min."
        22  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        24  "115 min."
        23  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        23  "107 min."
        22  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        23  "110 min."
        23  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

        23  "112 min."
        22  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        21  "109 min."
        20  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        21  "98 min."
        20  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        20  "95 min."
        16  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        17  "100 min."
        16  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        17  "105 min."
        16  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        16  "101 min."
        16  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

        16  "96 min."
        14  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        15  "106 min."
        14  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        15  "88 min."
        11  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        14  "92 min."
        13  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        14  "94 min."
        12  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        13  "104 min."
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        13  "2016-08-03"
        13  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        13  "2018-05-27"
        13  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        13  "86 min."
        12  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        13  "87 min."
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         4  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        12  "99 min."
        12  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

        10  "2016-08-10"
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        10  "2016-09-18"
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        10  "2017-12-14"
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        10  "2018-03-03"
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        10  "2018-10-14"
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        10  "2018-10-31"
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        10  "2019-02-04"
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

        10  "81 min."
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        10  "89 min."
        10  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119

        10  "90 min."
         8  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         2  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

        10  "91 min."
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:119
         1  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:114

         9  "2016-05-30"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2016-07-29"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2016-08-20"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2017-01-29"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2017-02-06"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2017-02-11"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2017-02-19"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2017-03-29"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

         9  "2017-05-30"
         9  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:139

```

Он показался наиболее интересным, так как отрабатывает довольно быстро, но уже показывает проблемы, возникающие при большом объеме данных.

Вот какие проблемы удалось найти и решить:

### Ваша находка №1
- После добавления `frozen string literal = true` количество объектов-строк сократилось:
- ни `fasterer`, ни `rubocop-performance` не оказались особо полезными в данном случае
-  157242 -123304 = 33938. Однако в целом это не исправило ситуацию, хотя для "бесплатной" оптимизации, я считаю, не так уж и плохо.

### Ваша находка №2
- `MemoryProfiler` показал основную точку роста:
```bash
allocated memory by location
-----------------------------------
  71791240  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:56
  26198352  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:102
```
Это строка:
```ruby
sessions += [parse_session(line)] if cols[0] == 'session'
```
- меняем на 
```ruby
sessions << parse_session(line) if cols[0] == 'session'
```
- результат:
```bash
MEMORY USAGE: 60 MB
Total allocated: 45229277 bytes (181242 objects)
Total retained:  4676 bytes (9 objects)

allocated memory by gem
-----------------------------------
  45229277  other

allocated memory by file
-----------------------------------
  45229277  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

allocated memory by location
-----------------------------------
  26198352  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:102
   3854988  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:141
```
- Отчет показал следующую точку роста:
```ruby
  users.each do |user|
    attributes = user
    user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects += [user_object]
  end
  ```
- меняем на 
```ruby
  users.each do |user|
    attributes = user
    user_object = User.new(attributes: attributes, sessions: sessions.select { |session| session['user_id'] == user['id'] })
    users_objects += [user_object]
  end
```          
- Результат не впечатляет:
```bash
MEMORY USAGE: 60 MB
Total allocated: 45229277 bytes (181242 objects)
Total retained:  4676 bytes (9 objects)

allocated memory by gem
-----------------------------------
  45229277  other

allocated memory by file
-----------------------------------
  45229277  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb

allocated memory by location
-----------------------------------
  26359344  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:102
   3854988  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:140
```
В отчете видно, что основные потребители памяти - массивы. 
Решил перейти на файл 10_000 строк (так как 5000 строк уже уложились в бюджет).
Выиграл 10 мб, переписав строку  55
```ruby
users += [parse_user(line)] if cols[0] == 'user'
# на
users << parse_user(line) if cols[0] == 'user'
```
        
Следуя подсказке переписываем на процедурный стиль и избавляемся от массивов для хранения данных. Тут помог оверинжиниринг из первого задания. Вместо сохранения в массив сессий писал сразу в файл `result.json`. Ушло некоторое время, чтобы JSON стал валидным. Обработанного пользователя удалял из хэша сразу же, как сохранял его данные в отчет.

Переписал чтение данных из файла таким образом:

```ruby
File.readlines(file_path).each do |line|
    line.chomp!
    cols = line.split(',')
    users << parse_user(line) if cols[0] == 'user'
    sessions << parse_session(line) if cols[0] == 'session'
  end
```
Выигрыш - порядка 19 мб. Основной потребитель - все тот же класс Array.

Замена `File.readlines` на `CSV` помогла выиграть еще 9 мегабайт:
```bash
MEMORY USAGE: 71 MB
Total allocated: 131956234 bytes (208840 objects)
Total retained:  112 bytes (2 objects)

allocated memory by gem
-----------------------------------
 124833472  other
   7122762  csv-3.1.7

allocated memory by file
-----------------------------------
 124833472  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb
   7109522  /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/csv-3.1.7/lib/csv/parser.rb
     13160  /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/csv-3.1.7/lib/csv.rb
        80  /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/csv-3.1.7/lib/csv/fields_converter.rb

allocated memory by location
-----------------------------------
 104386560  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:99
   9566160  /home/theendcomplete/Documents/projects/my/rails-optimization-task2/task-2.rb:100
```         
Далее осталось дело техники - добавил обход файла с данными через `foreach`.

### Ваша находка №X
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными, уложившись в ограничение по памяти.
Удалось улучшить потребление памяти и уложиться в заданный бюджет <70мб на всем протяжении работы программы.
Ранее потребление памяти росло с количеством обработанных строк, теперь же не зависит от размера файла.

До:
![unoptimized_valgrind](https://github.com/theendcomplete/rails-optimization-task2/blob/task-2/case_study_media/valgrind_unoptimized.png?raw=true)
После:
![optimized_valgrind](https://github.com/theendcomplete/rails-optimization-task2/blob/task-2/case_study_media/valgrind_optimized.png?raw=true)


- `jemalloc` оптимизированную программу еще больше оптимизировать не смог - потребление то же самое
- в ходе оптимизации также заменил все строковые ключи на символы - это не сильно, но улучшило производительность (не стал включать в отчет)
- волшебный коммент `frozen string literal = true` работает и дает бесплатную производительность. Нужно пользоваться.
- самое сложное в оптимизации - вести записи и логи работы.

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы был написан соответствующая performance-спецификация:

```ruby
# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'execution time' do
    before { GC.disable }
    after { GC.enable }

    it 'performs large file in less than 30 seconds' do
      expect do
        work('spec/fixtures/data_100000.txt')
      end.to perform_under(30).sec
    end
  end

  describe 'memory usage' do
    before { GC.compact }

    it 'performs data_500 file in less than 700 kylobytes' do
      expect do
        work('spec/fixtures/data_500.txt')
      end.to perform_allocation(700_000).bytes
    end
  end
end
```
700 kylobytes в спеке выбрано как компромиссное ко времени прогона
