# Задание 2. Case Study.

## Checklist
- [x] Построить и проанализировать отчёт гемом `memory_profiler`
- [x] Построить и проанализировать отчёт `ruby-prof` в режиме `Flat`;
- [x] Построить и проанализировать отчёт `ruby-prof` в режиме `Graph`;
- [x] Построить и проанализировать отчёт `ruby-prof` в режиме `CallStack`;
- [x] Построить и проанализировать отчёт `ruby-prof` в режиме `CallTree` c визуализацией в `QCachegrind`;
- [x] Построить и проанализировать текстовый отчёт `stackprof`;
- [x] Построить и проанализировать отчёт `flamegraph` с помощью `stackprof` и визуализировать его в `speedscope.app`;
- [x] Построить график потребления памяти в `valgrind massif visualier` и включить скриншот в описание вашего `PR`;
- [x] Написать тест, на то что программа укладывается в бюджет по памяти

## Начальные метрики в полном файле
* Время выполнения: **21 сек.** 
* Память: **2296 Мб**


## Feedback Loop

В начале будем использовать лимит во 20 000 строк.

### Итерация 1
#### какой отчёт показал главную точку роста
memory_profiler показал 1.68 Гб массивов и большое выделение объектов в `File.read ... .split`:
```
allocated memory by class
-----------------------------------
   1.68 GB  Array

allocated objects by location
-----------------------------------
   3250943  /home/dave/dev/rails-optimization-task2/src/work.rb:43
   
```
#### как вы решили её оптимизировать
Перейти к построчному чтению файла.
#### как изменилась метрика
`492 MB` => `110 MB`
#### как изменился отчёт профилировщика
Потребление перенеслось в другую строку, теперь это наполнение массива `sessions`. Однако, массивов все еще много:
```
allocated objects by location
-----------------------------------
    221432  /home/dave/dev/rails-optimization-task2/src/work.rb:138

 => { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }

allocated memory by class
-----------------------------------
   1.65 GB  Array
```

### Итерация 2
#### какой отчёт показал главную точку роста
Call Tree ruby-prof показывает много аллокаций в `map` и `Date#parse` 
```
100.00% (100.00%) Object#ruby_prof [1 calls, 1 total]
  100.00% (100.00%) Object#do_work [1 calls, 1 total]
    100.00% (100.00%) Object#work [1 calls, 1 total]
53.01% (53.01%) Object#collect_stats_from_users [7 calls, 7 total]
      53.01% (100.00%) Array#each [7 calls, 9 total]
        30.87% (58.23%) Array#map [33506 calls, 33508 total]
          22.67% (73.45%) <Class::Date>#parse [16954 calls, 16954 total]
          
 => { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
```
#### как вы решили её оптимизировать
Как уже было понятно, парсинг дат тут не нужен, даты изначально в ISO 8601. Избавляемся от парсинга дат и последовательных вызовов `#map`.
#### как изменилась метрика
`110 MB` => `108 MB`. 
#### как изменился отчёт профилировщика
Несмотря на то, что потребление памяти изменилось незначительно, проблема ушла из отчета. 
```
100.00% (100.00%) Object#ruby_prof [1 calls, 1 total]
  100.00% (100.00%) Object#do_work [1 calls, 1 total]
    100.00% (100.00%) Object#work [1 calls, 1 total]
      58.31% (58.31%) Enumerator#with_index [1 calls, 1 total]
        58.31% (100.00%) IO#each_line [1 calls, 2 total]
          22.56% (38.70%) String#split [20000 calls, 40000 total]
          22.35% (38.32%) Object#parse_session [16954 calls, 16954 total]
            19.55% (87.50%) String#split [16954 calls, 40000 total]
          3.51% (6.02%) Object#parse_user [3046 calls, 3046 total]
```
Будем теперь смотреть потребление памяти, а не аллокации.

### Итерация 3

> TODO
