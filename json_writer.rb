require 'oj'

class JsonWriter
  attr_reader :file_writer

  def initialize(file_name)
    @file_writer = Oj::StreamWriter.new(file_name)
  end

  def prepare_user_stats
    @file_writer.push_object
    @file_writer.push_key('usersStats')
    @file_writer.push_object
  end

  def write_user_stats(user_key, user_data)
    @file_writer.push_key(user_key)
    @file_writer.push_value(user_data)
  end

  def write_common_stats(users_count, unique_browsers, sessions_count)
    @file_writer.pop

    @file_writer.push_key('totalUsers')
    @file_writer.push_value(users_count)

    @file_writer.push_key('uniqueBrowsersCount')
    @file_writer.push_value(unique_browsers.count)

    @file_writer.push_key('totalSessions')
    @file_writer.push_value(sessions_count)

    @file_writer.push_key('allBrowsers')
    @file_writer.push_value(unique_browsers.sort.join(','))

    @file_writer.pop

    @file_writer.flush
  end
end
