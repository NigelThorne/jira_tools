#https://gist.github.com/NigelThorne/3f7120d538dcd18a911a6c90d42d027f


require 'rubygems'
require 'jira-ruby'
require 'awesome_print'
require 'pit'

# SET EDITOR=Notepad.exe

config = Pit.get("jira", :require => 
    { "url" => "http://jira.vsl.com.au:80/",  
      "username" => "default value", 
      "password" => "default value",
      "project_id" => "TAISS" })

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
			_, indent, title, rest = l.match(/^(\*+)\s([^-]+)(-.*)?$/).to_a
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

@filename = ARGV[0]
@lines = File.readlines(@filename)
@tasks = parse_tasks_file(@lines)
@project_id = config["project_id"]
puts "Stories will be added to Project #{@project_id}"

@client = get_jira_client(config);

types = @client.Issuetype.all

@user_story_type = types.find{|t| t.name == "User Story"}
@task_type = types.find{|t| t.name == "Task"}
@project = @client.Project.find(@project_id)

puts "==== Project #{@project.key} ===="
puts @project.description
puts "==== Story Type ===="
puts @user_story_type.name

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

@story_fields = @tasks.map { |task| 
	story_fields(
		@project.id, 
		@user_story_type.id, 
		task[:title], 
		task[:notes],
		"CR9362", 
		"CR9362")
}

@force = ARGV.include?("--force")

if(!@force)
	puts "** No changes will be made **"
end

@story_fields.each{|story|
	if(@force)
		puts "Creating Story:"
		issue = @client.Issue.build
		ap issue.save(story) 
		ap story
		puts "--------story saved--------"
	else
		puts "...Skipping..."
		ap story
		puts "--------story skipped--------"
	end
}
