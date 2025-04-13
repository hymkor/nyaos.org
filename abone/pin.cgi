#!/usr/local/bin/python
# -*- coding:utf8 -*-

import os
import sys
import cgi
import re
import cgitb ; cgitb.enable()
import shelve
import urllib

def print_title(form):

    newurl = os.getenv('HTTP_REFERER','')
    if myurl in newurl  :
        newurl = None
    title  = form.getfirst('ttl',newurl)
    
    print 'Content-type: text/html'
    print ''
    print '<html>'
    if newurl != None :
        print '<head>'
        print '<script language="JavaScript"><!--'
        print "function settitle(){"
        print "  document.addform.url.value=unescape(document.hdnform.url.value);"
        print "  document.addform.ttl.value=unescape(document.hdnform.ttl.value);"
        print "}"
        print '// -->'
        print '</script></head>'
        print '<body onload="settitle()">'
        print '<form name="hdnform">'
        print '<input type="hidden" name="url" value="%s">' % cgi.escape(newurl)
        print '<input type="hidden" name="ttl" value="%s">' % cgi.escape(title)
        print '</form>'
    else:
        print '<body>'
    print '<h1 align="center"><a href="%s">Your Pin</a></h1>' % myurl
    print '<p align="center">To setup your browser, please bookmarking'
    print '''<a href="javascript:window.location='%s?ttl='+escape(document.title)+'&url='+escape(location.href);undefined">Pin</a> on your browser''' % ( myurl )
    print '</p>'

def no_operation(form,data,myurl) :
    return True

def append_url(form,data,myurl) :
    url = form.getfirst("url",None)
    ttl = form.getfirst("ttl",url)

    ### reject this script self ###
    if url == None or myurl in url :
        return True

    entry = data.get("entry",[])

    ### reject duplicate url ###
    if len(entry) > 0 and entry[-1][0] == url :
        return True

    entry.append( (url,ttl) )
    data["entry"] = entry

    data["trashbox"] = \
        [ e for e in data.get("trashbox",[]) if e[0] != url ]

    return True

def goto_url(form,data,myurl):
    url = form.getfirst("url",None)

    entry = data.get("entry",[])
    if not entry :
        return "Not found data['entry']"
    no = None
    for i,e in enumerate(entry):
        if e[0] == url :
            no = i
            break
    else:
        return "Not found %s in entry" % url
    trashbox = data.get("trashbox",[])
    trashbox.append( entry[no] )
    if len(trashbox) > 3 :
        del trashbox[0]
    data["trashbox"] = trashbox

    del entry[no]
    data["entry"] = entry

    if form.getfirst("a","") == "mov" :
        print 'Content-type: text/html'
        print ''
        print '<html><head>'
        print '<title>Moving...</title>'
        print '<meta http-equiv="refresh" content="0;URL=%s">' % url
        print '</head>'
        print '<body><a href="%s">Wait or Click Here</a></body>' % url
        print '</html>'
        return False
    else:
        return "Succeeded to remove %s" % url

form   = cgi.FieldStorage()
mypath = sys.argv[0]
myurl  = "http://" \
       + os.getenv("HTTP_HOST") \
       + os.getenv("SCRIPT_NAME","[SCRIPT_NAME]")

data = shelve.open(mypath + ".dat")

jumptable = {
    "add":append_url ,
    "mov":goto_url ,
    "del":goto_url ,
}

status = jumptable.get(form.getfirst("a",""),no_operation)( form,data,myurl )
if status :

    print_title(form)

    if status != True :
        print "<div>%s</div>" % cgi.escape(status)

    print '<h2>Add</h2>'
    print '<form name="addform" action="%s" method="POST">' % myurl
    print '<dl><dt compact="compact">URL:</dt>'
    print '<dd><input type="text" name="url" value="" size="80" /></dd>'
    print '<dt compact="compact">Title:</dt>'
    print '<dd><input type="text" name="ttl" value="" size="80" /></dd>'
    print '<dt><input type="submit" name="Submit" value="Pin!"></dt>'
    print '</dl>'
    print '<input type="hidden" name="a" value="add" />'
    print '</form>'

    print '<h2>Stack</h2>'
    print '<ul>'
    for e in reversed(data.get("entry",[])) :
        print '<li><a href="%s?a=mov&amp;url=%s">%s</a>' % (
            myurl ,
            urllib.quote_plus( e[0] ) ,
            cgi.escape( e[1] ) ,
        )
        print '(<a href="%s?a=del&amp;url=%s">DEL</a>)</li>' % (
            myurl ,
            urllib.quote_plus( e[0] ) ,
        )
    print '</ul>'


    print '<h2>Trashbox</h2>'
    print '<ul>'
    for e,color in zip(data.get("trashbox",[]),("000","444","777")) :
        print '<li><a href="%s" style="color:#%s">%s</a>' % (
            cgi.escape( e[0] ) ,
            color ,
            cgi.escape( e[1] ) ,
        )
        print '<a href="%s?a=add&amp;ttl=%s;url=%s" style="color:#%s">(ADD)</a>' % (
            myurl ,
            urllib.quote_plus( e[1] ) ,
            urllib.quote_plus( e[0] ) ,
            color ,
        )
    print '</ul>'

    print '</body></html>'
data.close()
# vim:set k=T K=T:
