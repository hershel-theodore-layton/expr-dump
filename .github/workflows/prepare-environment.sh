#!/bin/sh
rm vendor/autoload.php vendor/composer/*.php

# Processes the `requires:4.128` comments in .hhconfig.

HHVM_VERSION_MAJOR=`hhvm --php -r "echo HHVM_VERSION_MAJOR;"`
if [ "$HHVM_VERSION_MAJOR" -ne "4" ]; then exit; fi

# Some .hhconfig settings only work on hhvm version 4.128 and above.
# This script will scan the hhconfig file for directives that look like this:
# requires:4.128
# Where 128 can be any hhvm minor version.
# If the current hhvm version is less than the required version,
# the hhconfig file stops at this directive, ignoring all settings below.

HHVM_VERSION_MINOR=`hhvm --php -r "echo HHVM_VERSION_MINOR;"`
NEXT=$(($HHVM_VERSION_MINOR + 1))

# On hhvm 4.102, this would create the pattern:
# "requires:4.103|requires:4.104|...|requires:4.128|...|requires:4.172"
# Since `requires:4.128` is part of the regex, the hhconfig file stops there.
# On hhvm 4.128, the expression would be "requires:4.129|...|requires:4.172".
# Since `requires:4.128` is not part of the regex, the requires directive is ignored.

FUTURE_VERSIONS=`for i in $(seq $NEXT 172); do echo "requires:4.$i"; done`
FUTURE_VERSIONS=`echo $FUTURE_VERSIONS | sed "s/ /|/g"`

# Edit the file in place, sorry Mac users, your sed requires a `-i ''` here.
sed -i -E "/$FUTURE_VERSIONS/q0" .hhconfig
