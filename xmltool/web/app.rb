require "sinatra/base"
require "redis"
require "json"

require_relative "logger"
require_relative "serialize"
require_relative "../utils/attr_utils"
require_relative "../cmd/skill"
require_relative "../shared/sources"
require_relative "../config/config_loader"
require_relative "../cli/app"
require_relative "../shared/game_data"

module XMLTool
  $redis = Redis.new
end

module XMLTool
  class WebApp < Sinatra::Base
    set :bind, "0.0.0.0"
    set :public_folder, File.join(File.dirname(__FILE__), "frontend/build")

    get "/" do
      send_file File.join(settings.public_folder, "index.html")
    end

    post "/command" do
      user_ip = request.ip
      $redis.multi { $redis.del(user_ip) }
      logger = WebLogger.new(user_ip)
      
      request_body = request.body.read
      json_data = JSON.parse(request_body)

      command = json_data["command"]
      puts command

      case command
      when "skill"
        clazz = json_data["class"]
        id = json_data["id"]
        chain = json_data["skill_chain"]
        attrs = AttrUtils.parse_attrs(json_data["attrs"].split(" "))
        skill_cmd = SkillCommand.new(clazz, id, chain ? "y" : "n", logger)
        skill_cmd.run(attrs)
      when "area"
        area = json_data["area"]
        id = json_data["id"]
        attrs = AttrUtils.parse_attrs(json_data["attrs"].split(" "))
        area_cmd = AreaCommand.new(area, id, logger)
        area_cmd.run(attrs)
      when "stats"
        clazz = json_data["class"]
        race = json_data["race"]
        attrs = AttrUtils.parse_attrs(json_data["attrs"].split(" "))
        stats_cmd = StatsCommand.new(clazz, race, logger)
        stats_cmd.run(attrs)
      when "direct"
        CLIApp.logger = logger
        CLIApp.start(json_data["command_input"].split(" "))
      end

      content_type "text/plain"
      "Command finished"
    end

    get "/logs" do
      user_ip = request.ip
      logs = nil
      logs = $redis.lrange(user_ip, 0, -1)
      content_type "text/html"
      logs ? logs.join("<br>") + "<br>" : "<br>"
    end

    post "/clear" do
      $redis.del(request.ip)
    end

    get "/areas" do
      puts "getting areas..."
      unless $redis.exists("areas") == 1
        puts "loading areas..."
        config = ConfigLoader.load_config(File.join(XMLToolSources.sources["config"], "areas.yml"))
        serialized_areas = serialize_areas(config)
        areas_json = serialized_areas.to_json
        $redis.set("areas", areas_json)
        return areas_json
      end

      $redis.get("areas")
    end

    get "/classes" do
      puts "getting classes..."
      unless $redis.exists("classes") == 1
        puts "loading classes..."
        classes = GameData.classes
        serialized_classes = serialize_classes(classes)
        classes_json = serialized_classes.to_json
        $redis.set("classes", classes_json)
        return classes_json
      end

      $redis.get("classes")
    end

    get "/races" do
      puts "getting races..."
      unless $redis.exists("races") == 1
        puts "loading races..."
        races = GameData.races
        serialized_races = serialize_races(races)
        races_json = serialized_races.to_json
        $redis.set("races", races_json)
        return races_json
      end

      $redis.get("races")
    end

    # start the server if ruby file executed directly
    run! if app_file == $0
  end
end