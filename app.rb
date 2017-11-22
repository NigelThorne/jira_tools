require 'sinatra'
require 'sinatra/base'
require_relative './print_jiras'

class App < Sinatra::Base
  get '/' do
  	@template = Slim::Template.new(){File.read("form.slim")}
    defaults = Proj.new
  	@template.render(defaults)
  end

  get '/show' do
config = Pit.get("jira", :require => 
{ "url" => "http://jira.vsl.com.au:80/",  
"username" => "default value", 
"password" => "default value" })
@template =Slim::Template.new(){File.read("story_template.slim")}
client = get_jira_client(config) 
project = Proj.new
project.cfrom = params['cfrom']
project.cto = params['cto']
project.issues = client.Issue.jql(params['query'])
return @template.render(project)
  end
end
