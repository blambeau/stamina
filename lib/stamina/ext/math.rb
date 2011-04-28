if RUBY_VERSION < "1.9"

  def Math.log2( x )
    Math.log( x ) / Math.log( 2 )
  end
 
  def Math.logn( x, n )
    Math.log( x ) / Math.log( n )
  end

end
