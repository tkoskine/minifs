
# calls an optional function(s)
function optional() {
	for f in $*; do
		if declare -F $f >/dev/null; then
			$f
		fi
	done
}

function optional-one-of () {
	for f in $*; do
		if declare -F $f >/dev/null; then
			#echo optional-one-of running $f
			$f
			return
		fi
	done
}

hput() {
	local k="${2/-}"
	eval "$1""$k"='$3'
}

hget() {
	local k="${2/-}"
	eval echo '${'"$1$k"'#hash}'
}

function package() {
	PACKAGE="$1"
	#echo "#### Building $PACKAGE"
	pushd "$BUILD/$PACKAGE" >/dev/null
}
function end_package() {
	#echo "#### Building $PACKAGE DONE"
	PACKAGE=""
	LOGFILE="&1"
	popd  >/dev/null
}

function configure() {
	local turd="._conf_$PACKAGE"
	if [ ! -f $turd ]; then
		echo "     Configuring $PACKAGE"
		rm -f $turd
		LOGFILE="$turd.log"
		echo "$@" >$turd.log
		if "$@" >>$turd.log 2>&1 ; then
			touch $turd
		else
			echo "#### ** ERROR ** Configuring $PACKAGE"
			echo "     Check $LOGFILE"
			return 1
		fi
	fi
}

function compile() {
	local turd="._compile_$PACKAGE"
	if [ ! -f $turd -o "._conf_$PACKAGE" -nt $turd ]; then
		echo "     Compiling $PACKAGE"
		rm -f $turd
		LOGFILE="$turd.log"
		echo "$@" >$turd.log
		if "$@" >>$turd.log 2>&1 ; then
			touch $turd
		else
			echo "#### ** ERROR ** Compiling $PACKAGE"
			echo "     Check $LOGFILE"
			return 1
		fi
	fi
}

function install() {
	local turd="._install_$PACKAGE"
	if [ -f "._compile_$PACKAGE" ]; then
		echo "     Installing $PACKAGE"
		rm -f $turd
		LOGFILE="$turd.log"
		echo "$@" >$turd.log
		if "$@" >>$turd.log 2>&1 ; then
			touch $turd
		else
			echo "#### ** ERROR ** Installing $PACKAGE"
			echo "     Check $LOGFILE"
			return 1
		fi
	fi
}
