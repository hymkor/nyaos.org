#!/usr/local/bin/ruby

REM="#"
MOVE="mv -i"
DEL="rm -f"
DELTREE="rm -r"
Q='\''

dir1 = ARGV.shift
dir2 = ARGV.shift

if dir2.nil? 
    $stderr.print "usage: #{$0} dir1 dir2\n"
    $stderr.print "  dir1's file will be moved to dir2.\n"
    exit 1
end

dir1.gsub!(/\\/,"/")
dir2.gsub!(/\\/,"/")

# 二つのファイルのスペックをコメント文として表示する.
def display(path1,path2)
    print "#{REM} src: #{path1}\n"
    print "#{REM}      #{File.stat(path1).size}\n"
    print "#{REM}      #{File.mtime(path1)}\n"
    print "#{REM} dst: #{path2}\n"
    print "#{REM}      #{File.stat(path2).size}\n"
    print "#{REM}      #{File.mtime(path2)}\n"
end

# 1も2もファイルのスペックが同じ時
#   ⇒ 重複しているので、1 の方を削除する.
def when_same(path1)
    print %Q|#{DEL} #{Q}#{path1}#{Q}\n|
end
# 2 のファイルが存在しない時
#   ⇒ 2 ののもう一方のディレクトリに移動させる.
def when_notexist(path1,dir2)
    if File.directory?(path1)
	print %Q|cp -r #{Q}#{path1}#{Q} #{Q}#{dir2}#{Q}/. && |
	print %Q|#{DELTREE} #{Q}#{path1}#{Q}\n|
    else
	print %Q|#{MOVE} #{Q}#{path1}#{Q} #{Q}#{dir2}#{Q}/. \n|
    end
end
# ファイルのスペックが異なる場合の処理
#   ⇒ 1 のファイル名に日付を足して、2 のディレクトリへ移動させる.
def when_diff(path1,path2)
    stamp = File.mtime(path1).strftime("%Y%m%d%H%M%S")
    print %Q|#{MOVE} #{Q}#{path1}#{Q} #{Q}#{path2}\@#{stamp}#{Q}\n|
end

def robot(dir1,dir2)
    Dir.open(dir1) do |d|
	while fn=d.read
	    if fn == '.' || fn == ".." then
		next
	    end
	    path1 = "#{dir1}/#{fn}"
	    path2 = "#{dir2}/#{fn}"
	    print "\n"
	    if File.exist?( path2 ) then
		# ファイルが存在する時

		if File.directory?( path1 ) && File.directory?( path2 )
		    robot( path1 , path2 );
		    next;
		end
		stat1=File.stat( path1 )
		stat2=File.stat( path2 )

		display(path1,path2)

		if  File.stat(path1).size != File.stat(path2).size ||
		    File.mtime(path1)     != File.mtime(path2) then

		    when_diff( path1 , path2 )

		else
		    # ファイルは変更されていない.
		    when_same( path1 )
		end
	    else
		# ファイルが存在しない時.
		when_notexist( path1 , dir2 );
	    end
	end
    end
end

robot(dir1,dir2)
