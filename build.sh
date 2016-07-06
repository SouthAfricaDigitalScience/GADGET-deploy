#!/bin/bash -e
# the GADGET build script
. /etc/profile.d/modules.sh
module add  ci
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module add gsl/2.1
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add fftw/2.1.5-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add hdf5/1.6.10-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

echo "REPO_DIR is "
echo ${REPO_DIR}
echo "SRC_DIR is "
echo ${SRC_DIR}
echo "WORKSPACE is "
echo ${WORKSPACE}
echo "SOFT_DIR is"
echo ${SOFT_DIR}

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  mkdir -p ${SRC_DIR}
  wget http://wwwmpa.mpa-garching.mpg.de/gadget/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
# copy the correct Makefile to the buildS
cp Makefile-${SITE}-${ARCH}-${OS} ${WORKSPACE}/Gadget-${VERSION}/Gadget2/Makefile
cd ${WORKSPACE}/Gadget-${VERSION}/Gadget2
make
