require "logger"
require "colorize"

module XMLTool
  class CLILogger
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end

    def print_msg(msg, color, indent = 0)
      @logger.info "#{"  " * indent}#{msg.colorize(color)}"
    end

    def print_areas(areas)
      @logger.info "\n#{areas.join("/").cyan.bold}:"
    end

    def print_mode(source)
      @logger.info "#{source.red.bold}:"
    end

    def print_file(file, path = nil)
      @logger.info "#{indent(1)}#{path ? File.join(path, file).blue.bold : file.blue.bold}:"
    end

    def print_id_name_line(id, name, line)
      @logger.info "#{indent(2)}#{id.magenta}: #{name ? name.green : "???".green}: " + "Line: #{line}".light_blue
    end

    def print_class_race_gender_line(clazz, race, gender, line)
      @logger.info "#{indent(2)}#{clazz.magenta}: #{race.green}: #{gender.red}: " + "Line #{line}".light_blue
    end

    def print_attr(attr, value, mod = nil)
      outstr = "#{indent(3)}- #{attr}=#{value} ".yellow
      outstr += mod.grey if mod
      @logger.info outstr
    end

    def print_modified_files(file_count, attr_count)
      @logger.info "\nModified #{attr_count} attributes in #{file_count} files".red.bold
    end

    def log_error_and_exit(message)
      @logger.error message.red
      exit(1)
    end

    private

    def indent(level)
      "  " * level
    end
  end
end
