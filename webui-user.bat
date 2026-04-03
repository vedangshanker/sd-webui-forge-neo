@echo off

set "PYTHON=C:\Users\vedang\AppData\Local\Programs\Python\Python312\python.exe"
:: set GIT=
:: set VENV_DIR=

set "A1111_HOME=D:\AI tools\automatic 1111"
set "COMMANDLINE_ARGS=--skip-python-version-check --forge-ref-a1111-home \"%A1111_HOME%\""

:: --xformers --sage --uv
:: --pin-shared-memory --cuda-malloc --cuda-stream
:: --skip-python-version-check --skip-torch-cuda-test --skip-version-check --skip-prepare-environment --skip-install

call webui.bat
