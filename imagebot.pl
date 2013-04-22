#!/usr/bin/perl
package MyBot;
use POE::Kernel;
use POE::Component::IRC::Plugin::AutoJoin;
use POE::Component::IRC::Plugin::NickServID;
use Data::Validate::URI qw(is_http_uri is_uri);
use Bot::BasicBot;
use LWP::Simple;
use HTTP::Headers;
use LWP::UserAgent;
use DBI;
use base qw( Bot::BasicBot );
use warnings;
use strict;

#IRC Server Settings
my $server   =  "irc.freenode.net";
my $port     =  "6667";
my $channel  =  [ "#squixy", "#reddit", "#Ubuntu", "#perl", "##freebsd" ];
my $nick     =  "Squixy_"; 
my $name =  "Kyle-Work";

#Rejoin Settings;
my $rejoin = POE::Component::IRC::Plugin::AutoJoin->new(
  Channels => $channel,
  RejoinOnKick => 1,
  Rejoin_delay => 67,
);

#Nickserv Password
my $pass = POE::Component::IRC::Plugin::NickServID->new(
  Password => '**********'
);

#MySQL Database Settings
my $host = "localhost";
my $database = "dbi:mysql:ircz";
my $tablename = "images";
my $user = "****";
my $pw = "*********************";

#Connect to database
my $dbh = DBI->connect($database,$user,$pw) or die "Connection Error: $DBI::errstr\n";

#Setup Image Type Hashes
my %imagetypes = (
  "image/png" => "png",
  "image/jpeg" => "jpeg",
  "image/jpg" => "jpg",
  "image/gif" => "gif",
  "image/bmp" => "bmp"
);

#Detect URL's
sub said { 
  my ($speak, $message) = @_;
  my @text = split(' ',$message->{body});
  my $chan = $message->{channel};
  for my $string (@text) { 
    urlval($string, $chan);
  }
}

#Test if URL is valid
sub urlval {
  my ($url, $chan) = @_;
  if (length($url) < 200) {
    if(is_http_uri($url)){
      if ($url =~ /wiki/){
        return 0;
      }
      image_test($url, $chan);
    } 
  } 
}

#Test if URL is an image
sub image_test {
  my ($url, $chan) = @_;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  my $response = $ua->get($url);
  my $imgtype = $response ->header('Content-Type'); 
  if ($imgtype =~ m,image/,) {
    my $type = $imagetypes{$imgtype};
    if (!$type) {
      return 0;
    }
    my $size = $response ->header('Content-Length');
    if ($size > 5242880) {
      return 0;
    }
    database($url, $size, $type, $chan);
  } 
 
}

#Write image to database
sub database {
  my ($url, $size, $type, $chan) = @_;
  my $sql = "select URL from images where URL = \"$url\" or Size = \"$size\";";
  my $sth = $dbh->prepare($sql);
  $sth->execute or die "SQL Error: $DBI::errstr\n";
  if(!$sth->fetchrow_array) {
    my $sql = "insert into images (URL, FileType, Size, Channel) values (\"$url\", \"$type\", \"$size\", \"$chan\");";
    my $sth = $dbh->prepare($sql);
    $sth->execute or die "SQL Error: $DBI::errstr\n";
    download($url, $type);
  }
}

#CREATE TABLE images( ID INT NOT NULL AUTO_INCREMENT, 
#                      URL VARCHAR(200), 
#                      Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
#                      FileType VARCHAR(4), 
#                      Size VARCHAR(7), 
#                      Channel VARCHAR(30), 
#                      PRIMARY KEY(ID)
#);

sub download {
  my ($url, $type) = @_;
  my $sql = "select ID from images where URL = \"$url\";";
  my $sth = $dbh->prepare($sql);
  $sth->execute or die "SQL Error: $DBI::errstr\n";
  my $ID = $sth->fetchrow_array;
  my $file = "/var/www/images/$ID.$type";
  getstore($url,$file);
}

sub help { return 0; }

#Create bot and connect
my $bot = MyBot->new(
  server     => $server,
  port       => $port,
  channels   => $channel, 
  nick       => $nick,
  name       => $name,
  no_run     => 1
);

$bot->run();
$bot->pocoirc->plugin_add('AutoJoin', $rejoin);
$bot->pocoirc->plugin_add('NickServID', $pass);
POE::Kernel->run();
