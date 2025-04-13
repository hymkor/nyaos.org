$main::inline_plugin{ruby} = sub{
    my (undef,$base,$ruby)=@_;
    "<ruby><rb>$base</rb><rp>(</rp><rt>$ruby</rt><rp>)</rp></ruby>";
};

( index($ENV{'HTTP_USER_AGENT'},'Firefox') >= 0 || 
  index($ENV{'HTTP_USER_AGENT'},'Opera'  ) >= 0
) and push( @main::html_header , 
<<HEREDOC
<style type="text/css"><!--
/* based upon
 *   http://www.akatsukinishisu.net/itazuragaki/2001_10.html#ruby_for_Mozilla_3
 * updated with
 *   http://www.akatsukinishisu.net/itazuragaki/css/use_ruby_style_as_user_stylesheet.html
 */

ruby {
  display:inline-table !important;
  text-align:center !important;
  white-space:nowrap !important;
  text-indent:0 !important;
  margin:0 !important;
  vertical-align:-21% !important;
  line-height:1 !important;
}

ruby>rb,ruby>rbc {
  display:table-row-group !important;
  line-height:1.0 !important;
}

ruby>rt,ruby>rbc+rtc {
  display:table-header-group !important;
  font-size:71% !important;
  line-height:1.0 !important;
  letter-spacing:0 !important;
}

ruby>rbc+rtc+rtc {
  display:table-footer-group !important;
  font-size:71% !important;
  line-height:1.0 !important;
  letter-spacing:0 !important;
}

rbc>rb,rtc>rt {
  display:table-cell !important;
  letter-spacing:0 !important;
}

rp {
  display:none !important;
}
-->
</style>
HEREDOC
);
