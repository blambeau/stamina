# This file is only used in the test, to check that some parsing method do not
# execute ruby code. If not the case, a SystemExit will be raised
+ Kernel.exit(-1)