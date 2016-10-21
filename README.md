# jira_tools
Various scripts to help working with Jira

I find in the "planning game" it's better to rough out the stories in another tool (I'm using a markdown text file).
then I push those stories to Jira.

*print_jiras.rb*
I print off cards from Jira by generating them as an html page with this script.

#Instructions

* Clone this repo
* Install bundler if you don't have it. 
* bundle install the gems
* run it 
> bundle exec ruby print_jiras  xxxx
where xxx is your jql query.

Note: I use the gem "pit" to store user credentials for Jira in a file. 
You need an environment variable "EDITOR" set to something  (like Notepad.exe in windows) so you get prompted to fill in the credentials. 
they are stored on your local machine in your user's .pit folder.
