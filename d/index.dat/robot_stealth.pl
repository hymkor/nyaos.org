my $ua=$ENV{HTTP_USER_AGENT};

$main::preferences{'Robot Stealth'} = [ 
    { name => 'robot_stealth' ,
      desc => 'user agent names not to show your pages',
      type => 'textarea'
    }
];

unless( $ua =~ /Mozilla/ 
    && ($main::form{a} eq 'tools' || $main::form{a} eq 'preferences' ) )
{
    foreach my $p ( split(/\s*\n\s*/,$main::config{robot_stealth}) ){
	$p && index($ua,$p) >= 0 and die('!Robots can not read this page.!');
    }
}
