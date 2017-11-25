![](https://img.shields.io/docker/stars/redwyvern/ubuntu-devenv-base.svg)
![](https://img.shields.io/docker/pulls/redwyvern/ubuntu-devenv-base.svg)
![](https://img.shields.io/docker/automated/redwyvern/ubuntu-devenv-base.svg)
[![](https://images.microbadger.com/badges/image/redwyvern/ubuntu-devenv-base.svg)](https://microbadger.com/images/redwyvern/ubuntu-devenv-base "Get your own image badge on microbadger.com")

Redwyvern C++ Development Environment Base Image 
================================================

This is the Docker base docker image that contains the development environment.

This image contains software to build the following type of projects:
* GCC 6.1 => C++ 11, C++ 14 and C++ 17 (experimental features)
* CMake 3.6.1
* Boost 6.0 - Built with GCC 6.1 (At the time of writing, Boost 6.1 has some portibility issues)
