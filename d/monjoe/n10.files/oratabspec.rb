#!/usr/local/bin/ruby

require 'oci8'

class OracleTableSpec
    class OracleColumnSpec
	def initialize( *spec )
	    @spec = spec
	end
	def no ;   @spec[0] ; end
	def name ; @spec[1] ; end
	def nameL; @spec[1].downcase ; end
	def nameU; @spec[1].upcase ; end
	def type ; @spec[2] ; end
	def len ;  @spec[3] ; end
	def nullable? ; @spec[4]=='Y' ; end
	def key? ; @spec[5]; end
	def spec ; @spec ; end
    end
    def initialize(conn,name)
	@name  = name
	@nameU = name.upcase
	@nameL = name.downcase
	@prmkeys = Hash.new
	@columns = []

	conn.exec(" 
	    select column_name from user_ind_columns
	     where index_name = (
	    select index_name from user_constraints
	     where constraint_type = 'P'
	       and table_name = '#{nameU}' )
	") do |rs| 
	    @prmkeys[ rs[0] ] = true
	end

	conn.exec("
	    select  column_id , column_name , data_type , data_length , nullable
	      from  user_tab_columns 
	     where  table_name = '#{nameU}'
	     order  by column_id
	" ) do |rs| 
	    if rs[2] == 'DATE' then
		rs[3] = 14
	    end
	    @columns << 
		OracleColumnSpec.new( 
		    rs[0] , rs[1] , rs[2] , rs[3] , rs[4] ,@prmkeys[ rs[1] ] )
	end
    end
    def name      ; @name       ; end
    def nameU     ; @nameU      ; end
    def nameL     ; @nameL      ; end
    def column(n) ; @columns[n] ; end
    def columns   ; @columns    ; end
    def prmkeys   ; @prmkeys    ; end
end

if $0 == __FILE__ then
    conn = OCI8.new('scott','tiger')
    table = OracleTableSpec.new(conn,'emp');

    table.columns.each do |col|
	case col.type
	when /DATE/
	    printf "%-20s %s %s %s\n", col.name , col.type ,
		( if col.nullable? then "NOT NULL" else "" end ) ,
		( if col.key? then "/* PRMKEY */" else "" end );
	else
	    printf "%-20s %s(%d) %s %s\n", col.name , col.type , col.len ,
		( if col.nullable? then "" else "NOT NULL" end ) ,
		( if col.key? then "/* PRMKEY */" else "" end );
	end
    end

    conn.logoff
end
