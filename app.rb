require 'sinatra'
require 'sinatra/base'
require_relative './print_jiras'
require 'rqrcode'
require 'json'
require 'slim'


class App < Sinatra::Base
  def initialize()
    super 
    
    begin 
      @config = JSON.parse(File.read("server.config"))
    rescue 
      @config = {"URL" => ""}  
    end
  end


  def ensure_configured
    #condition do
      redirect( "/config" ) if(@config.try(:[], "URL").blank?) 
    #end
  end

  get '/' do
    ensure_configured

    defaults = Proj.new
    slim("form.slim",defaults)
  end

  post '/show' do
    ensure_configured

    config = { "url" => @config["URL"],  
        "username" => params['username'], 
        "password" => params['password'] }
    client = get_jira_client(config) 
    project = Proj.new
    project.cfrom = params['cfrom']
    project.cto = params['cto']
    project.issues = client.Issue.jql(params['query'], {:max_results  => 500})
    project.qrs = project.issues.each_with_object({}){|i,obj| 
      obj[i.key] = RQRCode::QRCode.new("http://jira.vsl.com.au/browse/#{i.key}", :size => 5)
        .as_svg()
        .gsub(/width="407" height="407"/, 'viewBox="0 0 407 407" width="80" height="80"')
    }
    slim("story_template.slim",project)
  end

  get '/qr' do 
    content_type "image/png"
    key = params['key']
    qrcode = RQRCode::QRCode.new("http://jira.vsl.com.au/browse/#{key}")
    # With default options specified explicitly
    png = qrcode.as_png(
              resize_gte_to: false,
              resize_exactly_to: false,
              fill: 'white',
              color: 'black',
              size: 100,
              border_modules: 0,
              module_px_size: 5,
              file: nil # path to write
              )
    png.to_s
  end


  get '/config' do
    slim :config_template, @config
  end

  post '/config' do
    @config["URL"] = params["URL"]
    File.write("server.config","o"){|f| f << @config.to_json}
    slim :config_template, @config
  end

end
