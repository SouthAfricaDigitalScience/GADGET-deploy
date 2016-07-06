#!/bin/bash -e
# the GADGET build script
. /etc/profile.d/modules.sh

module add deploy
module add gsl/2.1
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add fftw/2.1.5-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add hdf5/1.6.10-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

# re-build with the right links
cd ${WORKSPACE}/Gadget-${VERSION}/Gadget2/
make clean
make -j2

# if it runs, install it.
mkdir -p ${SOFT_DIR}/bin
cp -v ${WORKSPACE}/Gadget-${VERSION}/Gadget2/Gadget2 ${SOFT_DIR}/bin
chmod 755 ${SOFT_DIR}/bin/Gadget2
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
module add gsl/2.1
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add fftw/2.1.5-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add hdf5/1.6.10-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

setenv       GADGET2_VERSION       $VERSION
setenv       GADGET2_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                  "$::env(GADGET2_DIR)/bin"
MODULE_FILE
) > modules/$VERSION

mkdir -vp ${ASTRO_MODULES}/${NAME}
cp -v modules/$VERSION ${ASTRO_MODULES}/${NAME}

module avail ${NAME}

# can we add the module ?
cd ${WORKSPACE}
module purge

module add deploy
module add ${NAME}

which Gadget2
