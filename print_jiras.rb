#https://gist.github.com/NigelThorne/db54fccb979cecf4229ee662e4dc2e74

require 'rubygems'
require 'jira-ruby'
require 'awesome_print'
require 'slim'
require "pit"
require 'digest'

# SET EDITOR=Notepad.exe

# Amount should be a decimal between 0 and 1. Lower means darker
def darken_color(hex_color, amount=0.5)
  rgb = hex_to_rbg hex_color
  rgb[0] = (rgb[0].to_i * amount).round
  rgb[1] = (rgb[1].to_i * amount).round
  rgb[2] = (rgb[2].to_i * amount).round
  "#%02x%02x%02x" % rgb
end
  
# Amount should be a decimal between 0 and 1. Higher means lighter
def lighten_color(hex_color, amount=0.6)
  rgb = hex_to_rbg hex_color
  rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
  rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
  rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
  "#%02x%02x%02x" % rgb
end

def highlight_color(hex_color, amount=0.6)
  rgb = hex_to_rbg hex_color
  if ((rgb[0].to_i + rgb[1].to_i + rgb[2].to_i ) > ((255+255+255)/2) )
    darken_color(hex_color, amount)
  else
    lighten_color(hex_color, amount)
  end
end

def hex_to_rbg(hex_color)
  hex_color = hex_color.gsub('#','')
  hex_color.scan(/../).map {|color| color.hex.to_i}
end

def gradiate_color(start_hex_color, destination_hex_color, amount=0.5)
  s_rgb = hex_to_rbg(start_hex_color)
  d_rgb = hex_to_rbg(destination_hex_color)
  rgb = []
  rgb[0] = s_rgb[0] + ((d_rgb[0] - s_rgb[0]) * amount).round
  rgb[1] = s_rgb[1] + ((d_rgb[1] - s_rgb[1]) * amount).round
  rgb[2] = s_rgb[2] + ((d_rgb[2] - s_rgb[2]) * amount).round
  "#%02x%02x%02x" % rgb
end

config = Pit.get("jira", :require => 
    { "url" => "http://jira.vsl.com.au:80/",  
      "username" => "default value", 
      "password" => "default value" })

#args0 = jql

def get_jira_client(config)
    options = {
      :username     => config["username"],
      :password     => config["password"],
      :site         => config["url"],#'http://mydomain.atlassian.net:443/',
      :context_path => '',
      :auth_type    => :basic,
      :use_ssl      => false,
    }

    JIRA::Client.new(options)
end


class Proj
    attr_accessor :issues, :qrs
    attr_accessor :cfrom, :cto

    def initialize
      @cfrom = '#8fff96'
      @cto = '#968fff'
    end
end

if __FILE__ == $0
  @template =Slim::Template.new(){File.read("story_template.slim")}
  client = get_jira_client(config) 
  project = Proj.new
  project.issues = client.Issue.jql(ARGV[0])
  puts @template.render(project)
end
