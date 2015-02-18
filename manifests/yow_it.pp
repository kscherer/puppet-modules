
node 'yow-lbreports.wrs.com' {
  include wr::yow_lbreports
}
node 'yow-build48-lx.wrs.com' {
	include wr::yow_eng_vm
}
node 'yow-ssp3-lx.wrs.com' {
	include wr::yow_ssp_ub
}
node 'yow-samba3test.wrs.com' {
	include wr::yow_samba3test
}
node 'yow-ssp4-lx.wrs.com' {
	include wr::yow_ssp_ub
}
node 'yow-lab-simics6' {
	include wr::yow_simics
}
node 'yow-lab-simics5' {
	include wr::yow_simics
}