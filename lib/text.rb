require 'json'


# File.write('result.json', '')
# f = File.open('result.json', 'w')
# f.write('{"usersStats":{')
# data = File.open('fixtures/data_mikro.txt', 'r')
# user_storage = {}
# current_user_id = nil
# process = true
# delimetr = ','
# while process
#   line = data.gets
#   delimetr = nil unless line
#   if (line && current_user_id && line =~ /user/) || !line
#     pp current_user_id
#     user_data = user_storage[current_user_id]
#     pp user_data
#     key = "#{user_data[:first_name]} #{user_data[:last_name]}"
#     f.write("\"#{key}\":")
#     f.write("#{user_data.to_json}#{delimetr}")
#     user_storage.delete(current_user_id)      
#   end
  
#   break unless line
#   if line =~ /user/
#     _, id, first_name, last_name, age  = line.split(',')
#     current_user_id = id
#     user_storage[id] = { first_name:, last_name:, age: }
#   else
#       _, user_id, session_id, browser, time, date = line.split(',')
#       user = user_storage[user_id]
      
#       if user
#         user.merge!({sesions: [session_id, browser, time, date]})
#       end
#   end
# end

# f.write('}}')
# f.close
# puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

f = JSON.parse(File.read('result.json'))
pp f