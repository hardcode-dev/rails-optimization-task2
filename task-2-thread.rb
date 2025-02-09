require 'thread'
require_relative 'task-2'

pid = Process.pid  # Получаем ID текущего процесса
memory_limit = 70_000  # Лимит памяти в KB (например, 15_000 = 15MB)

# Поток мониторинга памяти
memory_thread = Thread.new do
  loop do
    memory_usage = `ps -o rss= -p #{pid}`.strip.to_i  # Получаем память в КБ
    
    puts "Используемая память: #{memory_usage/1024} MB"

    if memory_usage > memory_limit
      puts "Превышен лимит памяти! Завершаем процесс..."
      Process.kill('TERM', pid)  # Отправляем сигнал завершения процесса
    end

    sleep 1  # Ожидание 1 секунду перед следующим измерением
  end
end

# Поток выполнения программы
work_thread = Thread.new do
  work(file_name: 'data_large.txt')
end

# Ожидаем завершения выполнения программы
work_thread.join
memory_thread.kill  # Завершаем поток мониторинга памяти после окончания работы
