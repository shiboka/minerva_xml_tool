require "redis"

module XMLTool
  class WebLogger
    def initialize(user_ip)
      @user_ip = user_ip
    end

    def print_msg(msg, color, indent = 0)
      begin
        message = "<span style='color:#{color}'>#{"  " * indent}#{msg}</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end
    end

    def print_areas(areas)
      begin
        message = "<span style='color:cyan;font-weight:bold'>#{areas.join("/")}</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end
    end

    def print_mode(source)
      begin
        message = "<span style='color:red;font-weight:bold'>#{source}</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end
    end

    def print_file(file, path = nil)
      begin
        message = "<span style='color:blue;font-weight:bold'>#{path ? File.join(path, file) : file}</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end    
    end

    def print_id_name_line(id, name, line)
      begin
        message = "<span style='color:magenta'>#{indent(1)}#{id}: #{name ? name : "???"}: </span><span style='color:lightblue'>Line: #{line}</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end
    end

    def print_class_race_gender_line(clazz, race, gender, line)
      begin
        message = "<span style='color:magenta'>#{indent(1)}#{clazz}: </span><span style='color:green'>#{race} </span><span style='color:red'>#{gender}</span>: <span style='color:lightblue'>Line: #{line}</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end
    end

    def print_attr(attr, value, mod = nil)
      begin
        message = "<span style='color:yellow'>#{indent(2)}- #{attr}=#{value} </span>"
        message += "<span style='color:grey'>#{mod}</span>" if mod
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end
    end

    def print_modified_files(file_count, attr_count)
      begin
        message = "<span style='color:red;font-weight:bold'>Modified #{attr_count} attributes in #{file_count} files</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
        puts "Finished command"
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
    end
    end

    def log_error_and_exit(message)
      begin
        message = "<span style='color:red'>#{message}</span>"
        $redis.multi { $redis.rpush(@user_ip, message) }
      rescue Sequel::Error => e
        puts "Failed to insert log: #{e.message}"
      end
    end

    private

    def indent(level)
      "  " * level
    end
  end
end