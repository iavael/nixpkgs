{ stdenv, lib, buildPythonPackage, fetchPypi, pythonOlder, astroid, installShellFiles,
  isort, mccabe, pytestCheckHook, pytest-benchmark, pytestrunner, toml }:

buildPythonPackage rec {
  pname = "pylint";
  version = "2.6.2";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-cYt0eG6n7QeqDFi/VyFU1Geflg0m6WQcwd4gSjC4f8k=";
  };

  nativeBuildInputs = [ pytestrunner installShellFiles ];

  checkInputs = [ pytestCheckHook pytest-benchmark ];

  propagatedBuildInputs = [ astroid isort mccabe toml ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    # Remove broken darwin test
    rm -vf pylint/test/test_functional.py
  '';

  disabledTests = [
    # https://github.com/PyCQA/pylint/issues/3198
    "test_by_module_statement_value"
    # has issues with local directories
    "test_version"
   ] ++ lib.optionals stdenv.isDarwin [
      "test_parallel_execution"
      "test_py3k_jobs_option"
   ];

  # calls executable in one of the tests
  preCheck = ''
    export PATH=$PATH:$out/bin
  '';

  dontUseSetuptoolsCheck = true;

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp
    cp "elisp/"*.el $out/share/emacs/site-lisp/
    installManPage man/*.1
  '';

  meta = with lib; {
    homepage = "https://pylint.pycqa.org/";
    description = "A bug and style checker for Python";
    license = licenses.gpl1Plus;
    maintainers = with maintainers; [ nand0p ];
  };
}
