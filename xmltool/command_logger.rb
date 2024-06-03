require "logger"

module XMLTool
  class CommandLogger
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end

    def print_areas(areas)
      @logger.info "\n#{areas.join("/").cyan.bold}:"
    end

    def print_source(source)
      @logger.info "#{source.red.bold}:"
    end

    def print_file(file, path = nil)
      @logger.info "#{indent(1)}#{path ? File.join(path, file).blue.bold : file.blue.bold}:"
    end

    def print_id_name_line(id, name, line)
      @logger.info "#{indent(2)}#{id.magenta}: #{name ? name.green : "???".green}: " + "Line: #{line}".light_blue
    end

    def print_area_attr(attr, value, line)
      @logger.info "#{indent(3)}- #{attr}=#{value}".yellow
    end

    def print_skill_attr(attr, value, config_value)
      outstr = "#{indent(3)}- #{attr}=#{value} ".yellow
      outstr += config_value.grey if config_value
      @logger.info outstr
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