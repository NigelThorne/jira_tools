#https://gist.github.com/NigelThorne/db54fccb979cecf4229ee662e4dc2e74

require 'rubygems'
require 'jira-ruby'
require 'awesome_print'
require 'slim'
require "pit"

# SET EDITOR=Notepad.exe

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
      :use_ssl      => false
    }

    JIRA::Client.new(options)
end

@template =Slim::Template.new(){File.read("story_template.slim")}

class Proj
    attr_accessor :issues
end

client = get_jira_client(config) 
project = Proj.new
project.issues = client.Issue.jql(ARGV[0])
puts @template.render(project)
