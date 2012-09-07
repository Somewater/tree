run Rack::URLMap.new( {
  "/" => Rack::Directory.new( "bin-debug" )
} )
