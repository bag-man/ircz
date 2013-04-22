# ircz

A clone of http://ircz.de. 

## Introduction
This script was written in an attempt to clone [ircz.de](http://ircz.de/random), the idea was to copy the idea (with permission of the creator), and then hopefully create a nicer interface and integrate new features such as the ability to select and add new channels to the feed. Unfortunately I got side tracked once the project was working, so all I have is a very basic clone!

[You can view the site in action here.](http://squixy.co.uk/ircz/)

# Requirements
This script uses a perl bot to listen in on the user defined channels. The perl script uses the following modules:

- POE::Kernel
- POE::Component::IRC::Plugin::AutoJoin
- POE::Component::IRC::Plugin::NickServID
- Data::Validate::URI 
- Bot::BasicBot
- LWP::Simple
- HTTP::Headers
- LWP::UserAgent
- DBI

The web front end is just a very small PHP script that selects the data at random from the MySQL database that the IRC bot logs to. 
