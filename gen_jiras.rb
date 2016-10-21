#https://gist.github.com/NigelThorne/3f7120d538dcd18a911a6c90d42d027f

require 'rubygems'
require 'jira-ruby'
require 'awesome_print'

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


# def add_task(scope, task)
# 	return [task] if scope == []
# 	prev = scope[-1]
# 	return scope << task if task[:indent] == prev[:indent]
# 	prev[:tasks] = add_task(prev[:tasks], task)
# 	return scope
# end


def parse_tasks_file(lines)
	lines
		.reject{|l| /^[^\*]/ =~ l} #ignore titles (or anything that doesn't start with a *)
		.map{|l| l.gsub(/\n$/,"")}
		.map{|l|
			_, indent, title, rest = l.match(/^(\*+)\s([^-]+)(\s-.*)?$/).to_a
			{indent:indent.length, title:title.strip, rest:rest}
		}		
		.inject([]){ |arr, task|
			new = add_task(task, arr[-1])
			new ? (arr + [new]) : arr
		}
end

def add_task(task, prev)
	if(prev && (prev[:indent] < task[:indent]))
		prev[:notes] += "\n" + task[:title]
		prev[:notes] += "\n\t"+task[:rest] if task[:rest]
		nil
	else
		{indent:task[:indent], title:task[:title], notes:(task[:rest]||"")}
	end
end

def story_fields(project_id, type_id, name, notes, label, fixversion)
	{"fields"=>
		{
			"summary"=>name,
			"description"=>notes,
			"project"=>{"id"=>project_id},
			"labels"=>[label],
			#"subtasks" => [], # TODO : add subtasks (need issuelinks)
			"issuetype"=>{"id"=>type_id},
#			"fixversions"=>[fixversion],
		}
	}
end

def get_project_from_client(client, project_key)
	project = client.Project.find( project_id )
	puts "==== Project #{project.key} ===="
	puts project.description
	puts ("=" * (project.key.length + 18))
	return project
end

def run(force, filename, config, project_key)

	if(!force)
		puts "** No changes will be made **"
	end

	client = get_jira_client(config);
	project_id = get_project_from_client(client, project_key)

	types = client.Issuetype.all
	user_story_type = types.find{|t| t.name == "User Story"}
	## TODO @task_type = types.find{|t| t.name == "Task"}

	parse_tasks_file(File.readlines(filename))
	.map { |task| 
		story_fields( 
			project_id: project_id, 
			type_id: user_story_type.id, 
			name: task[:title], 
			notes: task[:notes], 
			label: "CR9362", 
			fixversion: "CR9362")}
	.each {|story|
		if(force)
			puts "Creating Story:"
			issue = @client.Issue.build
			ap issue.save(story) 
			ap story
			puts "-- issue --"
			ap issue
			puts "--------story saved--------"
		else
			puts "...Skipping Story..."
			ap story
			puts "--------story skipped--------"
		end
	}
end

#################################### RUN ################################
if __FILE__ == $0


	unless ENV["EDITOR"]
	  puts "You need to set environment variable EDITOR to something."
	  puts "eg. SET EDITOR=Notepad.exe"
	  exit -1
	end

	# SET EDITOR=Notepad.exe

	require 'pit'
	@config = Pit.get("jira", :require => 
	    { "url" => "http://jira.vsl.com.au:80/",  
	      "username" => "default value", 
	      "password" => "default value",
	      "project_id" => "TAISS" }) #Project ID should probably be a command line parameter

	@filename = ARGV[0]
	@force = ARGV.include?("--force")
	@project_id = config["project_id"]

	run(@force, @filename, @config, @project_id)
end