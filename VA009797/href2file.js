function href2file(){
    if( window.location.protocol == "file:" ){
	var hdr='http://homepage2.nifty.com/hayamatta/';
	var vec='http://hp.vector.co.jp/authors/VA009797/';
	for(var i=0; i<document.links.length ; ++i ){ // ƒŠƒ“ƒN.
	    var tmp = document.links[i].href
	    if( document.links[i].href.substring(0,hdr.length) == hdr ){
		document.links[i].href
		    = '../nnn/' + document.links[i].href.substring(hdr.length);
	    }
	    if( document.links[i].href.substring(0,vec.length) == vec ){
		document.links[i].href
		    = '../www/' + document.links[i].href.substring(vec.length);
	    }
	}
	for(var i=0; i<document.images.length ; ++i ){ // ‰æ‘œ.
	    if( document.images[i].src.substring(0,hdr.length) == hdr ){
		document.images[i].src
		    = '../nnn/' + document.images[i].src.substring(hdr.length);
	    }
	}
    }
}
