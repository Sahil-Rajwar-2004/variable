PKG="variable"

if pip show "$PKG" > /dev/null 2>&1; then
    exit 0
else
    python3 setup.py sdist bdist_wheel
    cd ./dist/
    pip install *.whl
    cd ..
    rm -rf dist build variable.egg-info
fi
