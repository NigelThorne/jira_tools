#https://gist.github.com/NigelThorne/3f7120d538dcd18a911a6c90d42d027f


require 'rubygems'
require 'jira-ruby'
require 'awesome_print'

# SET EDITOR=Notepad.exe

config = Pit.get("jira", :require => 
    { "url" => "http://jira.vsl.com.au:80/",  
      "username" => "default value", 
      "password" => "default value" })



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
		.reject{|l| /^[^\*]/ =~ l} #ignore titles
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

@lines = File.readlines(ARGV[0])
@tasks = parse_tasks_file(@lines)
@client = get_jira_client();

types = @client.Issuetype.all

@user_story_type = types.find{|t| t.name == "User Story"}
@task_type = types.find{|t| t.name == "Task"}
@project = @client.Project.find('LAACM')

ap @project
ap @user_story_type


def story_fields(project_id, type_id, name, notes)
	{"fields"=>
		{
			"summary"=>"2016_1 Patch: "+ name,
			"description"=>notes,
			"project"=>{"id"=>project_id},
			"labels"=>["2016_1Patch"],
			#"subtasks" => [], # TODO : add subtasks (need issuelinks)
			"issuetype"=>{"id"=>type_id}
		}
	}
end

@story_fields = @tasks.map {|task| story_fields(@project.id, @user_story_type.id, task[:title], task[:notes])}

puts "I'll stop here cos you were just about to change jira!!"
exit

@force = ARGV.contains("--force")

@story_fields.each{|story|
	puts "Creating Story:"
	ap story

	issue = @client.Issue.build
	if(force)
		ap issue.save(story) 
		puts "--------story saved--------"
	else
		puts "skipped..."
	end
}
