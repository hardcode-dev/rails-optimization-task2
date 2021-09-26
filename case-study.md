# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику:

- объем используемой оперативной памяти при завершении работы программы 300 MB (на файле с 100_000 строками),

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за *время, которое у вас получилось*

Вот как я построил `feedback_loop`:

- запуск профилировщика
- анализ отчета профилировщика
- изменения в программе
- замер метрики
- запуск теста

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался

- memory_profiler
- ruby-prof
- stackprof

Вот какие проблемы удалось найти и решить

### Моя находка №1
- какой отчёт показал главную точку роста

	- memory_profiler + ruby_prof

		Total: 2.825751 sec.

		allocated memory by location
		-----------------------------------
		  62.92 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:117
		  43.38 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:56
		  14.21 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:35
		  12.94 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:50


		str 117: dates_iso8601 = dates.each { |d| dates_array << Date.iso8601(d) }

		allocated memory by class
		-----------------------------------
		  70.58 MB  String
		  40.32 MB  Hash
		  34.51 MB  Array
		  31.17 MB  MatchData
		   6.09 MB  Date

		allocated objects by location
		-----------------------------------
		    684569  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:56
		    591987  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:117
		    144699  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:123
		    100003  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:50
		     84569  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:35
		     66073  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:124
		     44684  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:126
		     30877  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:122
		     30862  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:97
		     30860  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:92

		allocated objects by class
		-----------------------------------
		   1311017  String
		    246292  Hash
		    235669  Array
		     96969  MatchData
		     84569  Date
		     15431  User

		Allocated String Report
		-----------------------------------
		     84569  "session"
		     84569  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:56

		- MEMORY USAGE: 997 MB

- как вы решили её оптимизировать

	- Вынес массив dates_array = [] за пределы хэша collect_stats_from_users

	- Заменил парсинг даты, а именно вот эту строчку:

		dates_iso8601 = dates.each { |d| dates_array << Date.iso8601(d) }

		...на эту...

		dates_iso8601 = dates.each { |d| dates_array << Date.strptime(d, '%Y-%m-%d').iso8601 }

- как изменилась метрика

	- MEMORY USAGE: 917 MB

- как изменился отчёт профилировщика

	Total: 2.632483 sec.

	allocated memory by location
	-----------------------------------
	  43.38 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:56
	  23.68 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:117
	  14.21 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:35
	  12.94 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:50

	(117-ая строка (с парсингом даты) перестала быть главной точкой роста, 62.92 MB --> 23.68 MB)


	allocated memory by class
	-----------------------------------
	  60.43 MB  String
	  40.32 MB  Hash
	  32.86 MB  Array
	   6.09 MB  Date

	(String: 70.58 MB --> 60.43 MB)

	allocated objects by location
	-----------------------------------
	    684569  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:56
	    253711  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:117
	    144699  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:123
	    100003  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:50
	     84569  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:35
	     65926  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:124
	     44684  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:126
	     30877  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:122

	(70.58 MB --> 60.43 MB)

	allocated objects by class
	-----------------------------------
	   1057311  String
	    246292  Hash
	    220239  Array
	     84569  Date
	     15431  User
	     12253  MatchData

	(String: 1311017 --> 1057311)

### Моя находка №2
- какой отчёт показал главную точку роста

	- На этот раз я решил оптимизировать программу с учетом новых знаний

- как вы решили её оптимизировать

	- Изменил все строковые ключи в хэшах на символьные
	- Использовал bang! методы вместо обычных (map!, upcase! ...)

- как изменилась метрика

	- MEMORY USAGE: 917 MB --> 904 MB

- как изменился отчёт профилировщика

### Моя находка №3
- какой отчёт показал главную точку роста

	- Решаю переписать программу построчно...

- как вы решили её оптимизировать

	- Использовал построчную читку файла с помощью метода File.foreach, этот метод позволяет обрабатывать большие файлы (вместо File.read? который обрабатывает маленькие файлы)

	- Переписал программу, используя класс User и Session, изначально хотел использовать только один класс User, а сессию сделать хэшом, но в этом случае на программу выделялось больше памяти (на 8MB больше, поэтому решено было сделать сессию как класс, все же здесь мы занимаемся оптимизацией...)

	- Так как браузеры по заданию должны быть уникальны, использовал Set (all_browsers = Set.new), но честно говоря не увидел разницы между Set и [], кол-во используемой памяти не поменялось

- как изменилась метрика

	- MEMORY USAGE: 904 MB --> 696 MB. Кол-во памяти, выделяемой на программу снизилось на 200 MB, или на 23 %
	- Тест 'Memory test' теперь проходит. Для файла в 100_000 строк выделенная память составляет 35 MB

- как изменился отчёт профилировщика

	allocated memory by location
	-----------------------------------
	  43.38 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:82
	   8.36 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:102
	   8.07 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:81
	   6.77 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:91
	   3.38 MB  /home/den/rails-optimization-tasks/rails-optimization-task2/task_2.rb:61

	Осталась всего одна точка роста на 82-ой строчке: cols = line.chomp!.split(',')


	allocated memory by class
	-----------------------------------
	  40.37 MB  String
	  24.80 MB  Array
	   6.77 MB  Session
	   3.46 MB  JSON::Ext::Generator::State
	   2.60 MB  Hash
	   1.11 MB  User

	С предыдущего отчета профилировщика многие показатели выделенной памяти понизились:
	String 60.43 MB --> 40.37 MB
	Array 32.86 MB --> 24.80 MB
	Hash 40.32 MB --> 2.60 MB
	Date 6.09 MB --> N/A


	allocated objects by class
	-----------------------------------
	  800209  String
	  130864  Array
	   84569  Session
	   15434  Hash
	   15432  JSON::Ext::Generator::State
	   15431  User

	С предыдущего отчета профилировщика многие показатели выделенной памяти понизились:
	String 1057311 --> 800209
	Array 220239 --> 130864
	Hash 246292 --> 15434
	Date 84569 --> N/A

### Моя находка №4
- какой отчёт показал главную точку роста


- как вы решили её оптимизировать

	- Убрал ненужную локальную переменную total_users
	- Убрал ненужные поля у User (id), а у Session (user_id, session_id)
	- Использовал bang!-методы (@browser = browser.upcase!)
	- Установил переменную среды MALLOC_ARENA_MAX="2" с помощью гема dotenv (прописал переменную в файле .env), но никаких изменений по памяти нет((

- как изменилась метрика

	- MEMORY USAGE: 696 MB --> 528 MB. Кол-во памяти, выделяемой на программу снизилось на 168 MB, или на 25 %
	- Тест 'Memory test' для файла в 100_000 строк выделенная память составляет 32 MB (было 35 MB)

- как изменился отчёт профилировщика

	allocated memory by class
	-----------------------------------
	  36.98 MB  String
	  24.80 MB  Array
	   3.46 MB  JSON::Ext::Generator::State
	   3.38 MB  Session

	String 40.37 MB --> 36.98 MB


	allocated objects by class
	-----------------------------------
	  715640  String
	  130864  Array
	   84569  Session
	   15434  Hash

	String 800209 --> 715640

### Моя находка №5
- какой отчёт показал главную точку роста

	- Были найдены баги в программе, из-за того что менял тесты.
	- А именно не отсортировал даты в порядке убывания, браузеры не выстроил в алфавитном порядке...
	- Поправил код, тесты. Память обработки программы теперь увеличилась с 528 MB до 608 MB.
	- Скорость обработки Memory test не сильно изменилась. Файл в 100_000 строк обрабатывается за 34 MB

- как вы решили её оптимизировать
- как изменилась метрика

	- MEMORY USAGE: 608 MB. 
	- Тест 'Memory test' для файла в 100_000 строк выделенная память составляет 34 MB

- как изменился отчёт профилировщика



## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с *того, что у вас было в начале, до того, что получилось в конце* и уложиться в заданный бюджет.

*Какими ещё результами можете поделиться*

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*
