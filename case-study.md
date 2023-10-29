За основу взял оптимизированный по CPU код из первого задания

Первый отчет memory profiler
```
MEMORY USAGE: 122 MB
Total allocated: 40.17 MB (511366 objects)
Total retained:  40.00 B (1 objects)
allocated memory by location
-----------------------------------
  15.40 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:39
   4.62 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:26
   2.96 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:106
```

Самое проблемное на строке
```
columns = line.split(',')
```
Начнем с фриза
```
MEMORY USAGE: 112 MB
Total allocated: 37.37 MB (441381 objects)
Total retained:  40.00 B (1 objects)

allocated memory by location
-----------------------------------
  14.10 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:39
   4.62 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:26
   2.96 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:106
```
Пока не вижу смысла разбора отчетов, программа даже на небольшом объеме данных занимает много места, перепишу на потоковую обработку и заполнение файла

После переписания замерил потребление на 1кк данных
```
MEMORY USAGE: 2047 MB
Total allocated: 777.78 MB (10839411 objects)
Total retained:  19.17 kB (206 objects)

allocated memory by gem
-----------------------------------
 777.76 MB  other
  15.34 kB  set

allocated memory by file
-----------------------------------
 777.76 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb
  15.34 kB  /home/peplum/.rbenv/versions/3.1.3/lib/ruby/3.1.0/set.rb
   40.00 B  profile.rb

allocated memory by location
-----------------------------------
 233.85 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:21
 142.17 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:30
  80.66 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:18
  63.25 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:81
  57.31 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:73
  49.20 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:25
  35.15 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:78
  23.36 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:62
  23.36 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:63
  23.36 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:64
  22.91 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:79
  10.36 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:80
```
Наибольшее место занимает split и хэш session, программа выглядит так, что оптимизировать больше нечего, кроме замены all? и any?

Замеры после замены методов, удаления regex:
```
MEMORY USAGE: 1954 MB
Total allocated: 732.33 MB (10365779 objects)
Total retained:  19.17 kB (206 objects)

allocated memory by gem
-----------------------------------
 732.32 MB  other
  15.34 kB  set

allocated memory by file
-----------------------------------
 732.32 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb
  15.34 kB  /home/peplum/.rbenv/versions/3.1.3/lib/ruby/3.1.0/set.rb
   40.00 B  profile.rb

allocated memory by location
-----------------------------------
 233.85 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:21
 142.17 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:30
  80.66 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:18
  63.25 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:85
  57.31 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:77
  49.20 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:25
  23.36 MB  /home/peplum/dev/rails-optimization-task2/task-2.rb:62
```
Снижение с 777мб до 732мб

Больше точек оптимизации найти не могу, попробовал замерить потребление в valgrind massif, результат такой
![Alt text](<images/Screenshot from 2023-10-29 19-00-19.png>)
Пик потребления не достигает даже 1мб, пробовал по разному запускать, результат не меняется, всегда пик 3.1kb, то же самое происходит и с heaptrack
![Alt text](<images/Screenshot from 2023-10-29 19-02-30.png>)
Но простой прогон с puts в конце показывает
```
MEMORY USAGE: 30 MB
```
Программа теперь выполняется примерно за 9.6 секунд
