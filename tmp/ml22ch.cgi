#!/usr/bin/perl

if ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN, $query_string, $ENV{'CONTENT_LENGTH'});
} else {
    $query_string = $ENV{'QUERY_STRING'};
}
@a = split(/&/, $query_string);
foreach $a (@a) {
    ($name, $value) = split(/=/, $a);
    $value =~ tr/+/ /;
    $value =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;
    $form{$name} = $value;
}

my @body = ();
foreach ( split(/\n/,$form{'message'}) ){
    if( /^(\>+\s?)+/ ){
	$body[ length($&) ] .= $' 
    }else{
	$body[ 0 ] .= $_;
    }
}

my $counter=1;
my $html = "<dl style=\"color:black;background-color:white\">\n";
for( my $i=$#body ; $i >= 0 ; --$i ){
    next unless length($body[$i]) > 0 ;
    $body = $body[$i];

    $body =~ s/^\r+//g;
    $body =~ s/&/&amp;/g;
    $body =~ s/"/&quot;/g;
    $body =~ s/</&lt;/g;
    $body =~ s/>/&gt;/g;
    $body =~ s/\r/<br>/g;
    my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time() - $i*60 );

    $html .= sprintf "<dt style=\"font-weight:normal\"";
    $html .= sprintf ">%d 名前：<font color=\"forestgreen\"><b>",$counter++;
    $html .= sprintf "名無しさん＠お腹いっぱい。</b></font>";
    $html .= sprintf "[sage] 投稿日：%02d/%02d/%02d %02d:%02d</dt>\n" ,
	$year%100 , $mon+1 , $mday , $hour , $min ;
    $html .= sprintf "<dd>%s<br></dd>\n",$body;
__HERE__
}
$html .= "</dl>\n";

print "Content-type: text/html\n";
print "\n";
print "<html><body>\n";
print "${html}\n";

$html =~ s/&/&amp;/g;
$html =~ s/"/&quot;/g;
$html =~ s/</&lt;/g;
$html =~ s/>/&gt;/g;

print "<form><textarea cols=\"80\" rows=\"10\">${html}</textarea></form>\n";

print "</body></html>\n";
