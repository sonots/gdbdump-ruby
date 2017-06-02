puts Process.pid

th1 = Thread.new do
  loop do
    puts 'thread 1'
    sleep 1
  end
end

th2 = Thread.new do
  loop do
    puts 'thread 2'
    sleep 1
  end
end

th1.join
th2.join
