#!/bin/bash

# Pre-requirement:
# This test script is based on OpenSSL's unit test utilities.
# Make sure, in a openssl git repository, `make test` has been run with success.
OPENSSL_GIT_ROOTDIR=/home/parallels/working/openssl.git
TEST_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
UADK_PROVIDER_FULLPATH="$TEST_SCRIPT_DIR/../src/.libs/uadk_provider.so"

# Check the OpenSSL has been built for 'make test'
if [ ! -f "$OPENSSL_GIT_ROOTDIR/test/evp_test" ]; then
    echo "evp_test doesn't exist. Please run 'make test' in OpenSSL."
    exit 1
fi

# create a uadk_provider config file
UADK_PROVIDER_CONF=uadk_provider.conf
cat <<EOF > $UADK_PROVIDER_CONF
# Configuration OpenSSL for uadk_provider
#
# Format of this file please refer to:
#     https://www.openssl.org/docs/man3.0/man5/config.html
#

# These must be in the default section
config_diagnostics = 1
openssl_conf = openssl_init

[openssl_init]
providers = providers

#
# Note: provider path needs to set in OPENSSL_MODULES, if it is not given as full path in
#       the 'module=...' para of each provider's conf section.
# Eg. OPENSSL_MODULES can be set either as part of the commandline, or as the environment:
#     OPENSSL_MODULES=/home/guodong/osslinstall/lib/ossl-modules
#

[providers]
uadk_provider = uadk_provider_conf
# default = default_conf

[default_conf]
activate = yes

[uadk_provider_conf]
module = $UADK_PROVIDER_FULLPATH
activate = yes
UADK_CMD_ENABLE_RSA_ENV = 1
UADK_CMD_ENABLE_DH_ENV = 1
UADK_CMD_ENABLE_CIPHER_ENV = 1
UADK_CMD_ENABLE_DIGEST_ENV = 1
UADK_CMD_ENABLE_ECC_ENV = 1
EOF

cp $UADK_PROVIDER_CONF $OPENSSL_GIT_ROOTDIR/test

cd $OPENSSL_GIT_ROOTDIR/test

LD_LIBRARY_PATH=.. \
  ./evp_test -config ../test/$UADK_PROVIDER_CONF \
  ./recipes/30-test_evp_data/evpciph_sm4.txt