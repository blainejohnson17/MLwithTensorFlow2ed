FROM tensorflow/tensorflow:1.15.2-gpu-py3-jupyter

ENV CONTAINER_USER_ID="mltf2" \
    CONTAINER_GROUP_ID="mltf2"

WORKDIR /usr/src/mltf2
COPY download-libs.sh .
COPY download-data.sh .

RUN apt-get update\
    && apt-get full-upgrade -y\
    && apt-get autoremove -y\
    && apt-get install --no-install-recommends -y\
        cmake\
        gcc\
        g++\
        mpi-default-bin\
        pkg-config\
        libpng-dev\
        libfreetype6-dev\
        libsndfile1-dev\
        libsm6\
        curl\
        zlib1g-dev\
        zlib1g\
        libssl-dev\
        libffi-dev\
        zip\
        unzip\
        openjdk-11-jdk-headless\
        lbzip2\
        ffmpeg\
    && apt-get clean all\
    && useradd -U -d /home/mltf2 -s /bin/sh ${CONTAINER_USER_ID}\
    && mkdir /home/mltf2\
    && chown -R mltf2:mltf2 /home/mltf2\
    && mkdir -p /usr/src/mltf2/\
    && cd /usr/src/mltf2/\
    && mkdir -p data/cache data/logs models libs\
    && ./download-libs.sh\
    && cd /usr/src/mltf2\
    && ./download-data.sh

# Python 3 dependencies
COPY requirements.txt /tmp
# Python 2 dependencies
COPY requirements-py2.txt /tmp

# Install deps and bulid custom Python2 for Bregman Toolkit and VGG16.py
RUN pip install -r /tmp/requirements.txt\
    && mkdir -p /usr/src/python27\
    && cd /usr/src/python27\
    && curl -O https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz\
    && tar xvf Python-2.7.18.tar.xz\
    && cd /usr/src/python27/Python-2.7.18\
    && sh ./configure --enable-shared --prefix=/usr/install/python27 --enable-unicode=ucs4\
    && make -j4 && make install\
    && cd .. && rm -rf Python-2.7.18.tar.xz Python-2.7.18\
    && echo "/usr/install/python27/lib/" >> /etc/ld.so.conf\
    && ldconfig\
    && cd /usr/install/python27/bin\
    && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py\
    && /usr/install/python27/bin/python2.7 get-pip.py\
    && /usr/install/python27/bin/pip2.7 install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp27-none-linux_x86_64.whl\
    && /usr/install/python27/bin/pip2.7 install -r /tmp/requirements-py2.txt\
    && /usr/install/python27/bin/python2.7 -m pip install ipykernel\
    && cd /usr/src/mltf2/libs/BregmanToolkit\
    && /usr/install/python27/bin/python setup.py install\
    && rm -rf /root/.cache


WORKDIR /usr/src/mltf2

COPY ch02 /usr/src/mltf2/ch02
COPY ch03 /usr/src/mltf2/ch03
COPY ch04 /usr/src/mltf2/ch04
COPY ch05 /usr/src/mltf2/ch05
COPY ch06 /usr/src/mltf2/ch06
COPY ch07 /usr/src/mltf2/ch07
COPY ch08 /usr/src/mltf2/ch08
COPY ch09 /usr/src/mltf2/ch09
COPY ch10 /usr/src/mltf2/ch10
COPY ch11 /usr/src/mltf2/ch11
COPY ch12 /usr/src/mltf2/ch12
COPY ch13 /usr/src/mltf2/ch13
COPY ch14 /usr/src/mltf2/ch14
COPY ch15 /usr/src/mltf2/ch15
COPY ch16 /usr/src/mltf2/ch16
COPY ch17 /usr/src/mltf2/ch17
COPY ch18 /usr/src/mltf2/ch18
COPY ch19 /usr/src/mltf2/ch19

COPY figs /usr/src/mltf2/figs

RUN chown -R mltf2:mltf2 ch* models data/cache data/logs
COPY mltf-entrypoint.sh .
USER mltf2

ENTRYPOINT ["bash", "/usr/src/mltf2/mltf-entrypoint.sh"]
