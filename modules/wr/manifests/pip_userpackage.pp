#Install a python package using pip but install as user
define wr::pip_userpackage ( $owner ) {
  python::pip {
    $name:
      ensure       => present,
      owner        => $owner,
      environment  => "HOME=/home/${owner}",
      install_args => "--user --build=/home/${owner}/.pip/build";
  }
}
