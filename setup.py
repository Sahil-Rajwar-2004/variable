from setuptools import setup, find_packages
import os

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name = "variable",
    version = "0.1",
    packages = find_packages(),
    include_package_data = True,
    package_data = {
        "variable": ["libvar.so"],
    },
    description = "A library for variable operations with CUDA support",
    long_description = read("README.md"),
    long_description_content_type = "text/markdown",
    url = "https://github.com/Sahil-Rajwar/variable",
    author = "Sahil Rajwar",
    license = "MIT",
    classifiers = [
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires = ">=3.6",
)

