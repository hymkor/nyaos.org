#!/usr/bin/env python

import sys
import urllib
import urllib2
import cookielib

def mixi(email,passwd,mixiid):
    cj = cookielib.CookieJar()
    opener = urllib2.build_opener( urllib2.HTTPCookieProcessor(cj))

    urlobj = opener.open(
            "http://mixi.jp/login.pl" ,
            urllib.urlencode( 
                { "next_url":"/home.pl" , 
                  "email":email ,
                  "password":passwd 
                }
            )
    )
    urlobj.close()

    urlobj = opener.open("http://mixi.jp/atom/updates/r=1/member_id=%d"%mixiid)
    body = urlobj.read()
    info = urlobj.info()
    urlobj.close()
    return info,body

info,body = mixi("iyahaya@nifty.com","drivethr",6905)
sys.stdout.write(str(info)+"\n"+body)
