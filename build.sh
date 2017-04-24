#!/bin/bash

PACKAGE=${1}
VERSION=${2}
RUNTIME=${3}

TMP_DIR="${RUNTIME}_${PACKAGE}_${VERSION}"

mkdir ${TMP_DIR}
cd  ${TMP_DIR}
echo "Packaging ${PACKAGE}"

echo "do update"
sudo yum update -y

sudo yum groupinstall -y "Development Tools"

echo "do dependcy install"

sudo yum install -y openssl openssl-devel cyrus-sasl-devel

ENV="env-${RUNTIME}-${PACKAGE}-${VERSION}"

echo "make ${ENV}"
virtualenv -p ${RUNTIME} "${ENV}"

echo "activate env in $(pwd)"
source "${ENV}/bin/activate"

# https://github.com/pypa/pip/issues/3056
echo '[install]' > ./setup.cfg
echo 'install-purelib=$base/lib64/python' >> ./setup.cfg


TARGET_DIR=${ENV}/packaged
echo "install pips"
${RUNTIME} -m pip install --verbose --use-wheel --no-dependencies --target ${TARGET_DIR} "${PACKAGE}==${VERSION}"
deactivate

find ${TARGET_DIR} -type f -name '*.py[co]' -exec rm -f {} \;
find ${TARGET_DIR} -type d -name '__pycache__' -exec rm -rf {} \;

cd ${TARGET_DIR} && tar -zcvf ../../../${RUNTIME}-${PACKAGE}-${VERSION}.tar.gz * && cd ../../..
rm -rf ${TMP_DIR}
