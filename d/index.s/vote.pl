package vote;
$main::action_plugin{vote} = sub {
    my @result = &load_vote;
    $main::form{pp} =~ /^\d\d?$/ or die('Bad form on pp');
    ++$result[ $main::form{pp}-1 ];
    &main::write_object($main::form{p} , 'vote.csv', join(',',@result) );
    &main::transfer_page();
};

$main::inline_plugin{vote} = sub {
    my $session = shift;
    my $cont = 1;
    if( $_[0] eq '-f' ){
	shift;
	$cont = 0;
    }
    my @title  = @_;
    my @result = &load_vote;
    $#result = $#title;

    my $buf=sprintf('<div class="vote"
	><form action="%s" method="post"
	><input type="hidden" name="p" value="%s"
	><input type="hidden" name="a" value="vote"
	><table class="vote"><tr><th>Plan</th
	><th colspan="2">Points</th>'
	    , $main::me
	    , $main::form{p} );
    $cont and $buf .= '<th>vote</th>';
    for(my $i=0 ; $i <= $#title ; ++$i ){
	defined($result[$i]) or $result[$i] = 0;
	$buf .= sprintf('</tr><tr><td>%s</td><td align="right">%d</td
			    ><td>%s</td>'
	    , &main::enc($title[$i])
	    , $result[$i]
	    , 'o'x $result[$i] );
	$cont and $buf .= sprintf('<td align="center"><input type="submit"
	    			name="pp" value="%d"></td>' , 1+$i );
    }
    $buf .= '</tr></table></form></div>';
    $buf;
};

sub load_vote{
    my $result = (&main::read_object($main::form{p},'vote.csv') || '');
    my @result = split(/,/,$result);
    @result;
}

sub save_vote{
    $result = join(',',@result);
    &main::write_object($main::form{p},'vote.csv',$result);
}
