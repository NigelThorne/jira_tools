# jira_tools
Various scripts to help working with Jira. Don't run the scripts without reading them and understanding them. 

If you muck up your Jira.. it's not my fault! :)


I find in the "planning game" it's better to rough out the stories in another tool (I'm using a markdown text file).
then I push those stories to Jira.

*gen_jiras.rb* : This creates Jira item for each bullet point in your document. Subtree items are added as comments. The code to add them as tasks is there too, but needs some work. (It's commented out).   

*print_jiras.rb*: I print off cards from Jira by generating them as an html page with this script.

# Instructions

* Clone this repo  `git clone ...`
* Install bundler if you don't have it.   `gem install bundler`
* bundle install the gems  `bundle install`
* Run it `bundle exec ` where xxx is your jql query.

# Now runs from Docker!

# build image
docker build . -t nwt/jira_tools:latest

# run image
docker run --name jira_tools --restart=always -p 5678:4567 nwt/jira_tools

# TODO

## MoonJS
	- Make the UI more responsive... validate fields etc.
	- make pretty
	- add silly comments when waiting for jira to respond.

## Handle Exceptions
	- Make authentication errors redirect you back to re-login. 

## Take Credit
	- Add "NigelThorne" and Blog address to submit form. 

## Multiple Requests At Once
	- Traefik? 
	- Angelo
		- I moved from Sinatra to Angelo, but I need to make calls to Jira async to get full benefit.

# Make urls (page of stories) sharable
	- Use sessions to prompt for login and remember Jira credentials 
	- Add "logout"
	- change form to GET so urls to include the query.. so sharable

