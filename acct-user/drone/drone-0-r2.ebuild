# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for dev-util/drone"

ACCT_USER_ID=112
ACCT_USER_GROUPS=( drone )
ACCT_USER_HOME=/var/lib/drone

acct-user_add_deps
