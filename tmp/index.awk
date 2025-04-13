#!/usr/bin/nawk -f

function init(  pid,fn,n){
    me = "index.awk"

    for(i=0;i<256;i++){
	ascii[ sprintf("%c",i) ] = i
	hex[ sprintf("%02X",i) ] = i
	hex[ sprintf("%02x",i) ] = i
    }

    fn = "/proc/" PROCINFO["pid"] "/cmdline"
    if( (getline cmdline < fn ) <= 0 ){
	return -1
    }
    close(fn)
    n=split(cmdline,args,/\0/ )
    while( n >= 0 && length(args[n]) <= 0 ){
	--n
    }
    workdir=args[n]
    gsub(/.[a-z][a-z]*$/,".d",workdir)
    indexes = workdir "/index.txt"
    return 0
}

function fname2title(fname   ,title){
    title=""
    for(i=0 ; i*2 < length(fname) ; ++i ){
	title=sprintf("%s%c" ,title , hex[ substr(fname,i*2+1,2) ] )
    }
    return title
}

function title2fname(title   ,fname,i){
    fname=""
    for(i=1 ; i <= length(title) ; ++i ){
	fname=sprintf("%s%02X",fname,ascii[ substr(title,i,1) ] )
    }
    return fname
}

function read_dir(  rc){
    while( (getline < indexes) > 0 ){
	pages[ $0 ] = 1
	++rc
    }
    close(indexes)
    if( rc <= 0 ){ system("mkdir " workdir " 2>/dev/null" ) }
}

function write_dir(){
    printf "" > indexes
    for(p in pages ){
	print p > indexes
    }
    close(indexes)
}

function read_text(title   ,text){
    text=""
    fn = workdir "/" title2fname(title)
    while( (getline < fn) > 0 ){
	text = text "\n" $0
    }
    return text = substr(text,2)
}

function write_text(title,text   ,fn){
    fn1 = title2fname(title)
    fn = workdir "/" fn1
    read_dir()
    if( text != "" ){
	pages[ fn1 ] = 1
	printf "%s",text > fn
	close(fn)
    }else{
	delete pages[ fn1 ]
	system( "rm " fn )
    }
    write_dir()
}

function read_form(     query_string,pairs,p,x){
    if( ENVIRON["REQUEST_METHOD"] == "POST" ){
	query_string=""
	while( (getline) > 0 ){
	    query_string = query_string "\n" $0
	}
	query_string = substr(query_string,2)
    }else{
	query_string = ENVIRON["QUERY_STRING"]
    }
    split(query_string,pairs,/&/)
    for( i in pairs ){
	split(pairs[i],p,/=/)
	while( match(p[2],/%[0-9a-zA-Z][0-9a-zA-Z]/) > 0 ){
	    p[2] = sprintf("%s%c%s" ,
		    RSTART > 1 ? substr(p[2],1,RSTART-1) : "",
		    hex[ substr(p[2],RSTART+1,2) ] ,
		    substr(p[2],RSTART+RLENGTH) )
	}
	gsub(/\+/," ",p[2])
	form[ p[1] ] = p[2]
    }
}

function enc(s   ,rc){
    rc=s
    gsub(/&/,"\\&amp;",rc)
    gsub(/</,"\\&lt;",rc)
    gsub(/>/,"\\&gt;",rc)
    return rc
}

function percent(s  ,rv,c,i){
    rv=""
    for(i=1 ; i <= length(s) ; ++i ){
	c = substr(s,i,1)
	rv = rv ( c ~ /0-9a-zA-Z/ ? c : sprintf("%%%02X",ascii[c]) )
    }
    return rv
}

BEGIN{
    init()
    read_form()
    printf "Content-Type: text/html; charset=EUC-JP'\n\n"
    printf "\n"
    printf "<html>\n" 

    if( form["a"] == "e" ){
	printf "<body>\n"
	printf "<h1>Edit: %s</h1>\n",form["p"]
	printf "<form action=\"%s\" method=\"post\">\n",me
	printf "<input type=\"hidden\" name=\"p\" value=\"%s\">\n",
		    percent(form["p"])
	printf "<input type=\"hidden\" name=\"a\" value=\"post\">\n"
	printf "<textarea name=\"text\" cols="80" rows="15">%s</textarea>\n",
		enc( read_text(form["p"]) )
	printf "<br><input type=\"submit\" name=\"Commit\" value=\"Commit\">\n"
    }else if( form["a"] == "post" && "p" in form ){
	write_text( form["p"] , form["text"] )
	print "<head>"
	printf "<meta http-equiv=\"refresh\" content=\"1;URL=%s\">\n",me
	print "</head>"
	print "<body>"
	printf "<a href=\"%s\">Wait or Click Here</a>\n",me
    }else if( "p" in form ){
	printf "<body>\n"
	printf "<h1>%s</h1>\n",enc(form["p"])
	printf "<p><a href=\"%s?a=e&amp;p=%s\">Edit</a> ",
		    me,percent(form["p"])
	printf "<a href=\"%s\">Index</a></p>\n",me
	printf "<pre>%s</pre>\n",enc( read_text(form["p"]) )
    }else{
	read_dir()
	print "<body>"
	print "<h1>IndexPage</h1>"
	print "<ol>"
	for( fn in pages ){
	    printf "<li><a href=\"%s?p=%s\">%s</a></li>\n" ,
		me , enc(fname2title(fn)) , enc(fname2title(fn))
	}
	print "</ol>"
	print "<form action=\"index.awk\" method=\"post\">New page:"
	print "<input type=\"text\" name=\"p\">"
	print "<input type=\"hidden\" name=\"a\" value=\"e\">"
	print "<input type=\"submit\" name=\"Commit\" value=\"Commit\">"
	print "</form>"
    }
    printf "</body></html>\n"
}
