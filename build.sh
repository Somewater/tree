MXMLC=mxmlc
CLASSNAME=TreeLoader
COMMAND=compile


if [ -o $USE_MXMLC  ] && [ `which fcshctl-mxmlc` ]; then
	MXMLC=fcshctl-mxmlc
fi

if [ -o $DEBUG ]; then
	DEBUG=true
fi

if [ ! -o $1 ]; then
	COMMAND=$1
fi

compile()
{
	rm bin-debug/$CLASSNAME.swf
	$MXMLC \
	-warnings=false \
	-static-link-runtime-shared-libraries \
	-default-background-color=#FFFFFF \
	-default-frame-rate=30 \
	-default-size 800 600 \
	-target-player=10.1.0 \
	-compiler.debug=$DEBUG \
	-use-network=true \
	-define+=CONFIG::debug,$DEBUG \
	-benchmark=true \
	-optimize=true \
	-source-path+=src \
	-source-path+=signals \
	-library-path+=libs \
	-output=bin-debug/$CLASSNAME.swf src/$CLASSNAME.as
}

clean()
{
	cn=`fcshctl id $CLASSNAME`	
	fcshctl clear ${cn:${#cn}-1:1}
}

case $COMMAND in
	clean|clear|clr)
  	echo "clean..."
  	clean
  	;;
  compile|c)
  	echo "compile..."
  	compile
  	;;
  release)
  	echo "release compile..."
  	DEBUG=false
  	compile
  	;;
  *)
  	echo "undefined command..."
  	;;
esac
