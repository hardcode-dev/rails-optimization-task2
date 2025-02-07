


На sample до оптимизации split:

Total allocated: 179.51 MB (2546193 objects)
Total retained:  0 B (0 objects)

cols

----------

после передачи cols:

Total allocated: 131.29 MB (1761624 objects)
Total retained:  0 B (0 objects)



--------------------
Перепишу без массива (набор переменных):

anna@composaurus:~/apps/rails-optimization/rails-optimization-task2$ be ruby task-2.rb 
Total allocated: 51.71 MB (854936 objects)
Total retained:  0 B (0 objects)

О, круто!


-------------------------------
Из первого отчёта (по 100_000 строк)


Total allocated: 312.22 MB (2609218 objects)
Total retained:  6.58 kB (48 objects)


Вот хз, Array#each да readlines много занимают.

Io.open ещё.


allocated memory by gem
-----------------------------------
 312.10 MB  other
 121.74 kB  set
  295.00 B  bundled_gems

allocated memory by file
-----------------------------------
 312.10 MB  task-2.rb
 121.74 kB  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/set.rb
  295.00 B  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/bundled_gems.rb

allocated memory by location
-----------------------------------
 131.47 MB  task-2.rb:47
  48.22 MB  task-2.rb:79
  41.43 MB  task-2.rb:27
  13.53 MB  task-2.rb:28
   9.45 MB  task-2.rb:57
   9.32 MB  task-2.rb:49
   9.03 MB  task-2.rb:78
   7.89 MB  task-2.rb:87
   6.79 MB  task-2.rb:17
   5.52 MB  task-2.rb:43
   5.26 MB  task-2.rb:54
   4.22 MB  task-2.rb:94
   4.00 MB  task-2.rb:80
   3.38 MB  task-2.rb:89
   2.70 MB  task-2.rb:55
   2.47 MB  task-2.rb:18
   1.73 MB  task-2.rb:48
   1.30 MB  task-2.rb:42
   1.30 MB  task-2.rb:45
   1.03 MB  task-2.rb:56
 747.60 kB  task-2.rb:40
 617.24 kB  task-2.rb:52
 617.24 kB  task-2.rb:53
 100.15 kB  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/set.rb:0
  61.56 kB  task-2.rb:51
  10.00 kB  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/set.rb:512
   8.67 kB  task-2.rb:76
   8.63 kB  task-2.rb:100
   8.52 kB  task-2.rb:119
   7.33 kB  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/set.rb:244
   5.08 kB  task-2.rb:122
   3.86 kB  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/set.rb:218
  400.00 B  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/set.rb:852
  295.00 B  /home/anna/.rbenv/versions/3.3.6/lib/ruby/3.3.0/bundled_gems.rb:69
  192.00 B  task-2.rb:120
  120.00 B  task-2.rb:121
  120.00 B  task-2.rb:123
  112.00 B  task-2.rb:70
   80.00 B  task-2.rb:131
   72.00 B  task-2.rb:61
   40.00 B  task-2.rb:124
   40.00 B  task-2.rb:66

allocated memory by class
-----------------------------------
 130.28 MB  File
 102.99 MB  String
  53.61 MB  Array
  20.95 MB  Hash
   2.66 MB  MatchData
   1.11 MB  Thread::Mutex
 617.24 kB  User
   3.86 kB  Class
   40.00 B  Range
   40.00 B  Set
