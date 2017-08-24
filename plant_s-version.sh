#!/bin/bash
set -e
# set -x

. common.sh

# extract worker prefix, e.g. m12
wwid=${1%%-*}
# extract number, e.g. 12
wid=${wwid:1:100}

port=$((4606+$wid))
port1=$((14606+$wid))

workdir=$(find . -maxdepth 1 -type d -name "$wwid*" | head -1)

# if folder exists - it must be empty or have only two empry directories (they may be mapped by parent farm for docker image)
if [[ -d $workdir ]]; then
  [[ $workdir =~ ($wwid-)([1-9][0-9]?)(\.)([0-9])(\.)([1-9][0-9]?) ]] || ((>&2 echo "Couldn't parse format of $workdir, expected $wwid-version") ; exit 1)
  version=${BASH_REMATCH[2]}.${BASH_REMATCH[4]}.${BASH_REMATCH[6]}
fi

tar=${2-$version}

[[ $tar =~ ([1-9])(\.)([0-9])(\.)([1-9][0-9]?) ]] || { (>&2 echo "Invalid second parameter ($tar), expected version, e.g. 2.1.2 ") ; exit 1; }

[[ -z $version ]] || [[ $version == $tar ]] || { (>&2 echo "Scond parameter must match version in pre-created folder") ; exit 1; }
version=$tar

workdir=$(pwd)/$wwid-$version
[[ -d $workdir ]] || mkdir $workdir


# now we add the same for oracle-mysql specific
for plugin in $ERN_PLUGINS ; do
  [ -d ./_plugin/$plugin/s-version/ ] && for filename in ./_plugin/$plugin/s-version/* ; do
    MSYS2_ARG_CONV_EXCL="*" m4 -D__wid=$wid -D__workdir=$workdir -D__srcdir=$src -D__blddir=$bld -D__port=$port -D__port1=$port1 -D__bldtype=$bldtype -D__dll=$dll -D__version=$version -D__wwid=$wwid -D__datadir=$workdir/dt $filename > $workdir/$(basename $filename)
    [ "${filename##*.}" = "cnf" ] ||  chmod +x $workdir/$(basename $filename)
  done

#  [ -d ./_plugin/$plugin/o-all/ ] && for filename in ./_plugin/$plugin/o-all/* ; do
#    MSYS2_ARG_CONV_EXCL="*" m4 -D__wid=$wid -D__workdir=$workdir -D__srcdir=$src -D__blddir=$bld -D__port=$port -D__port1=$port1 -D__bldtype=$bldtype -D__dll=$dll -D__version=$version -D__wwid=$wwid -D__datadir=$workdir/dt $filename > $workdir/$(basename $filename)
#    chmod +x $workdir/$(basename $filename)
#  done

done

:
