- Установить valgrind и massif-visualizer, если ранее не установлены:

    sudo apt-get install valgrind

    воспользоваться одним из вариантов установки massif-visualizer 1

- Запустить программу с профилировщиком:

    DATA_FILE=data_large.txt valgrind --tool=massif ruby work.rb

    or

    valgrind --tool=massif ruby 'task-2.rb'

- Запустить визуализатор:

    $ massif-visualizer

    из запущенной программы открыть файл вида massif.out.35370