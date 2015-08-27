
node 'yow-lbreports.wrs.com' {
  include wr::yow_lbreports
}

#
## Build Cluster Machines
#

node 'yow-build48-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build51-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build47-lx.wrs.com' {
    include wr::yow_build
}

node 'yow-build53-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build54-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build55-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build16-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build11-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build12-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build13-lx.wrs.com' {
    include wr::yow_build
}

node 'yow-build56-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build57-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build58-lx.wrs.com' {
    include wr::yow_build
}
node 'yow-build59-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build60-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build61-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build62-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build63-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build64-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build65-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build66-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-build67-lx.wrs.com' {
    include wr::yow_ssp_ub
}
node 'yow-iotbuild1.wrs.com' {
  include wr::yow_build
}
node 'yow-iotbuild4.wrs.com' {
    include wr::yow_build
}
node 'yow-iotbuild5.wrs.com' {
    include wr::yow_build
}
node 'yow-iotbuild6.wrs.com' {
    include wr::yow_build
}


#
##   SSP Cluster machines
#

node 'yow-ssp2-lx.wrs.com' {
  include wr::yow_ovp_ub
}

node 'yow-ssp3-lx.wrs.com' {
    include wr::yow_ssp_ub
}

node 'yow-ssp4-lx.wrs.com' {
    include wr::yow_ssp_ub
}

node 'yow-ssp5-lx.wrs.com' {
    include wr::yow_ssp_ub
}

###   Others:

node 'yow-lab-simics7.wrs.com' {
  include wr::yow_simics
}

node 'yow-lab-simics6' {
    include wr::yow_simics
}
node 'yow-lab-simics5' {
    include wr::yow_simics
}

node 'yow-samba3test.wrs.com' {
    include wr::yow_samba3test
}

node 'yow-cgts3-lx.wrs.com' {
  include wr::cgts
}

##	Test Machines

node 'yow-puppetsamba-tst.wrs.com' {
  include wr::yow_samba3test
}
