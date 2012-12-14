#
class nx::pek-hostel {

  include nx::local_build
  nx::setup { 
    ['1','2']:
      notxylo_branch => '4.x';
  }
}
