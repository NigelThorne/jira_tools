require 'rack'
require 'tilt'

require 'angelo'

require_relative './print_jiras'
require 'rqrcode'
require 'json'
require 'slim'


class AngeloServer < Angelo::Base
 def content_type type
  case type
   when :png
    headers 'Content-Type' => 'image/png'
   when :css
    headers 'Content-Type' => 'text/css'
   when Symbol
    super
   else
    headers 'Content-Type' => type
  end
 end
 def transfer_encoding encoding           # just because you ought to have this as well
  headers 'Transfer-Encoding' => encoding
 end
end


class App < AngeloServer

  addr '0.0.0.0'

  Temple::Templates::Tilt(Slim::Engine, register_as: :slim)

  def load_config
    begin 
      @config = JSON.parse(File.read("server.config"))
    rescue 
      @config = {"URL" => ENV['JIRA_URL'] || ""}  
    end
  end

  def slim( file, scope )
    file = file.to_s + ".slim" if file.is_a? Symbol
    Tilt.new("views/"+file).render(scope)
  end

  def ensure_configured
    load_config
    #condition do
    redirect( "/config" ) if(@config.nil? || @config["URL"].blank?) 
    #end
  end

  get '/' do
    ensure_configured

    defaults = Proj.new
    slim("index.slim",defaults)
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
    content_type :png
    key = params['key']
    qrcode = RQRCode::QRCode.new("http://jira.vsl.com.au/browse/#{key}")
    # With default options specified explicitly
    png = qrcode.as_png(
              resize_gte_to: false,
              resize_exactly_to: false,
              fill: 'white',
              color: 'black',
              size: 100,
              border_modules: 1,
              module_px_size: 5,
              file: nil # path to write
              )
    png.to_s
  end

  get '/config' do
    load_config
    slim :config_template, @config
  end

  post '/config' do
    load_config
    @config["URL"] = params["URL"]
    File.write("server.config",@config.to_json)
    redirect( "/" )
  end

  # BELOW follows an example of using non blocking IO to make a web call and return the result... we should do this with the JIRA calls.

  # get '/c' do
  #   future(:jira).value.to_s + "\n"
  # end

  # task :jira do

  #   body = ''

  #   sock = Celluloid::IO::TCPSocket.new 'example.com', 80
  #   begin
  #     sock.write "GET /big_file.tgz HTTP/1.1\n" +
  #                "Host: example.com\n" +
  #                "Connection: close\n\n"
  #     while data = sock.readpartial(4096)
  #       body << data
  #     end
  #   rescue EOFError
  #   ensure
  #     sock.close
  #   end

  #   body.length

  # end

end
