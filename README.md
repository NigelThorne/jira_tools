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
* Run it `bundle exec ruby print_jiras  xxxx`  where xxx is your jql query.

# Now runs from Docker!

# build image
docker build . -t nwt/jira_tools:latest

# run image
docker run --name jira_tools --restart=always -p 5678:8888 nwt/jira_tools

# TODO

## Config page: To set Jira URL
	- Set your jira server url: Then I can push the docker image to docker hub

## MoonJS
	- Make the UI more responsive... validate fields etc.
	- make pretty
	- add silly comments when waiting for jira to respond.

## Handle Exceptions
	- Make authentication errors redirect you back to re-login. 

## TakeCredit
	- Add "NigelThorne" and Blog address to submit form. 

## Traefik 
	- do something to allow multiple requests at once. 
	
