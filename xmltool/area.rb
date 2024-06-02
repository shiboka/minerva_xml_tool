module XMLTool
  class Area
    def initialize(sources, area, mob)
      @sources = sources
      @area = area
      @mob = mob
    end

    def load_config(path)
      begin
        @config = Psych.load_file(path)
      rescue Psych::Exception => e
        puts "Error loading configuration: #{e.message}"
      end

      @area.each do |a|
        if @config.key?(a)
          @config = @config[a]
        else
          puts "Area not found: #{a}"
          return false
        end
      end

      @config = { @area.last => @config }
      true
    end

    def change_with(attrs)
      traverse_config(@config, 0)
    end

    private

    def traverse_config(cfg, i)
      cfg.each do |key, value|
        if key == "server"
          print "  " * i
          puts "Server:".red.bold
        elsif key == "client"
          print "  " * i
          puts "Client:".red.bold
        else
          print "  " * i
          puts "#{key.blue.bold}:"
        end

        if value.is_a?(Array)
          value.each do |v|
            print "  " * (i + 1)
            puts v
          end
        else
          traverse_config(value, i + 1)          
        end
      end
    end
  end
end