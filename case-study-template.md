# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на потребление памяти и быстродействие программы я придумал использовать такую метрику:
Объем потребляемой памяти
Делать замеры буду на ограниченном датасете и увеличивать его, когда программа будет становится быстрее

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за *время, которое у вас получилось*

Вот как я построил `feedback_loop`: *как вы построили feedback_loop*

## Вникаем в детали системы, чтобы найти главные точки роста
До того как оптимизировать программу
ее нужно было перевести на потоковый подход

я переписал ее вот так
```ruby
def add_user_stat(user, user_sessions, report)
  user = User.new(attributes: user, sessions: user_sessions)
  user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"

  report['usersStats'][user_key] ||= {}
  report['usersStats'][user_key] = report['usersStats'][user_key]
                                     .merge('sessionsCount' => user.sessions.count)
                                     .merge('totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.')
                                     .merge('longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.')
                                     .merge('browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '))
                                     .merge('usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ })
                                     .merge('alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ })
                                     .merge('dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 })
end

def work(file_name: 'data.txt')
  report = {}
  report[:totalUsers] = 0
  report['totalSessions'] = 0
  report['usersStats'] = {}
  all_browsers = []
  current_user = nil
  current_user_sessions = nil
  File.new(file_name).each_line do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      add_user_stat(current_user, current_user_sessions, report) if current_user
      current_user = parse_user(line)
      report[:totalUsers] += 1
      current_user_sessions = []
    when 'session'
      session = parse_session(line)
      current_user_sessions << session
      report['totalSessions'] += 1
      all_browsers << session['browser'].upcase
    end
  end
  add_user_stat(current_user, current_user_sessions, report)
  uniq_browsers = all_browsers.uniq
  report['uniqueBrowsersCount'] = uniq_browsers.count
  report['allBrowsers'] = uniq_browsers.uniq.sort.join(',')

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
```
Это не совсем потоковый подход т.к я все равно накапливаю usersStats, all_browsers в репорте
но рассчитываю на то, что это не сильно заафектит, т.к данных все равно сильно меньше
я старался по-максимум оставить все как есть
(но программа стала работать значительно быстрее)

также я решил выводить и время выполнения чтобы следить как оптимизации влияют и на память тоже
asymptotic_analysis
```
10000
MEMORY USAGE: 34 MB
TIME: 0.15319300000555813
-------------
20000
MEMORY USAGE: 38 MB
TIME: 0.30837699997937307
-------------
40000
MEMORY USAGE: 45 MB
TIME: 0.6265910000074655
-------------
80000
MEMORY USAGE: 57 MB
TIME: 1.3260580000351183
-------------
160000
MEMORY USAGE: 90 MB
TIME: 2.5768730000127107
-------------
320000
MEMORY USAGE: 148 MB
TIME: 5.138665000034962
-------------
640000
MEMORY USAGE: 264 MB
TIME: 11.27137999999104
-------------
```

### Инструменты
Для того, чтобы найти "точки роста" для оптимизации я воспользовался *инструментами, которыми вы воспользовались*
 
Вот какие проблемы удалось найти и решить


### Date.parse - allocates lots of memory
- я использовал memory_profiler и затем ruby_prof в graph моде
  на 200_000 строках
  оба профайлера показали главную точку роста
  ```ruby
  .merge('dates' => user.sessions.map{ |s| s['date'] }.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 })
  ```
- я оптимизировал ее
  ```ruby
  .merge('dates' => user.sessions.map{ |s| s['date'].chomp }.reverse)
  ```
- как изменилась метрика
  До
  ```
   MEMORY USAGE: 51 MB
   TIME: 2.8387410000432283
  ```
  После
  ```
    MEMORY USAGE: 48 MB
    TIME: 1.3741059999447316
  ```
  метрика изменилась не сильно
  Похоже GC хорошо работает
  но программа ускорилась вдвое
  
  с выключенным GC ситуация другая
  ```
    MEMORY USAGE: 713 MB
    TIME: 2.3015339999692515
  ```
  ```
    MEMORY USAGE: 477 MB
    TIME: 1.2134320000186563
  ```
- Судя по отчету профилировщика это место больше не является главной точкой роста

### Split
- с помощью memory_profiler нашел главную точку роста
  но как ее оптимизировать было не очень понятно
  ```ruby
    cols = line.split(',')
  ```
  я сгенерил отчеты ruby_prof и в graph и flat моде увидел,
  что метод split потребляет 43% памяти
  stack_prof показал, что parse_session аллоцирует 26% памяти
- я понял - нужно пробрасывать в parse_session и parse_user результат `line.split(',')`
  (проводил тесты на 400_000 строк)
- как изменилась метрика
  до оптимизации
  ```
    MEMORY USAGE: 195 MB
    TIME: 3.8313899999920977
  ```
  после
  ```
    MEMORY USAGE: 176 MB
    TIME: 3.074631000010413
  ```
- Но `cols = line.split(',')` - все еще главная точка роста

### Lots calls of Upcase
- memory_profiler показал что след самой проблемной после `cols = line.split(',')` - является строка
`.merge('browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '))`
 а ruby_prof в flat моде показал, что upcase находится на 3-м месте
- session['browser'] - везде нужен в upcase, так что я сделаю это на этапе session_parse 
  и заменю upcase на upcase!
- метрика не изменилась
  разница заметна только с выключенным GC
  ```
  MEMORY USAGE: 777 MB
  TIME: 2.2718319999985397
  ```
  ```
  MEMORY USAGE: 727 MB
  TIME: 2.0187589999986812
  ```
  Судя по GC.stat - число вызовов GC уменьшилось на ~ 10%

### replace split with split {}
- я решил посмотреть могу ли я оптимизировать `cols = line.split(',')` так как это по-прежнему самое ухкое место
- я по хардкору переписал parse_user и parse_session
  ```ruby
    def parse_user(line)
      index = -1
      result = {}
    
      line.split(',') do |value|
        index += 1
        next if index == 0
    
        result[USER_COLUMNS[index]] = value
      end
      result
    end
    
    def parse_session(line)
      index = -1
      result = {}
      line.split(',') do |value|
        index += 1
        next if index == 0
    
        # upcase for browser field
        if index == 3
          result[SESSION_COLUMNS[index]] = value.upcase!
          next
        end
    
        result[SESSION_COLUMNS[index]] = value
      end
      result
    end
  ```
но мне удалось уменьшить потребление памяти только на 6%
я понял что с такими темпами мне не удастся уложиться в заданный бюджет

основная проблема в расбухании программы по мере увеличения датасета
я решил искать место где объекты не высвобождаются

я написал методы чтобы посмотреть как меняется число объектов
на протяжении работы программы

просто добавляю где-нибудь в основном цикле и смотрю как меняется стата каждые 50_000 итераций
но в целом бесполезный т.к с помощью него не понятно как локализовать проблему
```ruby
@throttling = 0
def space_objects_stat
  @throttling += 1
  @curr_stat ||= ObjectSpace.count_objects
  if @throttling == 50_000
    GC.start(full_mark: true, immediate_sweep: true)
    ObjectSpace.count_objects.each { |k, v| puts "#{k}: #{v - @curr_stat[k]}" }
    puts '------------'
    @curr_stat = ObjectSpace.count_objects
    @throttling = 0
  end
end
```

обарачиваю вызов метода и смотрю разницу в стате
```ruby
def with_objects_space_stat(&block)
  GC.start(full_mark: true, immediate_sweep: true)
  start_stat = ObjectSpace.count_objects
  res = block.call
  GC.start(full_mark: true, immediate_sweep: true)
  ObjectSpace.count_objects.each { |k, v| puts "#{k}: #{v - start_stat[k]}" } rescue nil
  puts '------------'
  res
end
```
я обернул вызов add_user_stat
`with_objects_space_stat{add_user_stat(current_user, current_user_sessions, report) if current_user}`
и посмотрел как меняется статистика
когда я закомментил присвоение результата работы в report['usersStats'] - статистика практически перестала меняться
т.е GC ожидаемо начал освобождать память
т.е в этом месте нужно писать в файл а не накапливать в report

(Наверное и до этого было понятно в чем дело, но было интересно поиграться)

я подсмотрел, что другие ребята используют Oj::StreamWriter
и решил тоже его заюзать
(интересно а в природе существует дока с примерами использования? :))

в итоге программа стала выглядеть так
```ruby
def initialize_stream_writer
  @file = File.open('result.json', 'w')
  @stream_writer = Oj::StreamWriter.new(@file)
  @stream_writer.push_object
end

def add_user_stat(user, user_sessions, report)
  user = User.new(attributes: user, sessions: user_sessions)
  user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"

  @stream_writer.push_key(user_key)
  @stream_writer.push_value(
    'sessionsCount' => user.sessions.count,
    'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
    'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
    'browsers' => user.sessions.map {|s| s['browser'] }.sort.join(', '),
    'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b =~ /CHROME/ },
    'dates' => user.sessions.map{ |s| s['date'].chomp }.sort.reverse
  )
end

def work(file_name: 'data.txt')
  initialize_stream_writer
  report = {}
  report[:totalUsers] = 0
  report[:totalSessions] = 0
  all_browsers = []
  current_user = nil
  current_user_sessions = nil

  @stream_writer.push_key('usersStats')
  @stream_writer.push_object
  File.new(file_name).each_line do |line|
    case line[0]
    when 'u'
      add_user_stat(current_user, current_user_sessions, report) if current_user
      current_user = parse_user(line)
      report[:totalUsers] += 1
      current_user_sessions = []
    when 's'
      session = parse_session(line)
      current_user_sessions << session
      report[:totalSessions] += 1
      all_browsers << session['browser']
    end
  end
  add_user_stat(current_user, current_user_sessions, report)
  @stream_writer.pop

  uniq_browsers = all_browsers.uniq
  report['uniqueBrowsersCount'] = uniq_browsers.count
  report['allBrowsers'] = uniq_browsers.uniq.sort.join(',')

  report.each do |k, v|
    @stream_writer.push_key(k.to_s)
    @stream_writer.push_value(v)
  end
  @stream_writer.pop_all

  # File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
ensure
  @file.close
end
```
анализ асимптотики показал что программа стала намного медленнее разбухать

```
10000
MEMORY USAGE: 31 MB
TIME: 0.07240299999830313
-------------
20000
MEMORY USAGE: 30 MB
TIME: 0.13285399999585934
-------------
40000
MEMORY USAGE: 33 MB
TIME: 0.24913500000548083
-------------
80000
MEMORY USAGE: 37 MB
TIME: 0.49505900000804104
-------------
160000
MEMORY USAGE: 42 MB
TIME: 1.0326339999883203
-------------
320000
MEMORY USAGE: 59 MB
TIME: 2.1196790000103647
-------------
640000
MEMORY USAGE: 90 MB
TIME: 4.415775000001304
-------------
1280000
MEMORY USAGE: 147 MB
TIME: 9.276582000005874
-------------
2560000
MEMORY USAGE: 261 MB
TIME: 19.737781999996514
-------------
5120000
MEMORY USAGE: 333 MB
TIME: 27.48570999999356
-------------
```

### `all_browsers << session['browser']`
судя по профилировщикам самым узким местом остается сплит
но программа разбухает в другом месте
`all_browsers << session['browser']`
[] заменил на SortedSet

программа перестала разбухать и потребляемая память стала константой
```
10000
MEMORY USAGE: 28 MB
TIME: 0.07622000000264961
-------------
20000
MEMORY USAGE: 29 MB
TIME: 0.1322199999995064
-------------
40000
MEMORY USAGE: 29 MB
TIME: 0.2555829999910202
-------------
80000
MEMORY USAGE: 29 MB
TIME: 0.4904649999953108
-------------
160000
MEMORY USAGE: 29 MB
TIME: 0.9653669999970589
-------------
320000
MEMORY USAGE: 29 MB
TIME: 1.9302030000108061
-------------
640000
MEMORY USAGE: 30 MB
TIME: 3.6661999999923864
-------------
1280000
MEMORY USAGE: 30 MB
TIME: 7.570767999990494
-------------
2560000
MEMORY USAGE: 31 MB
TIME: 18.08916699999827
-------------
5120000
MEMORY USAGE: 29 MB
TIME: 20.696947000004002
-------------
```

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с *того, что у вас было в начале, до того, что получилось в конце* и уложиться в заданный бюджет.

*Какими ещё результами можете поделиться*
память тяжело дебажить
не хватает инструмента который показываем где накапливаются объекты

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*
