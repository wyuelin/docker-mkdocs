# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
FROM ubuntu:12.04
MAINTAINER wyuelin <wyuelin@gmail.com>

RUN echo "\n  \
deb http://mirrors.aliyun.com/ubuntu/ precise main restricted universe multiverse              \n\
deb http://mirrors.aliyun.com/ubuntu/ precise-security main restricted universe multiverse     \n\
deb http://mirrors.aliyun.com/ubuntu/ precise-updates main restricted universe multiverse      \n\
deb http://mirrors.aliyun.com/ubuntu/ precise-proposed main restricted universe multiverse     \n\
deb http://mirrors.aliyun.com/ubuntu/ precise-backports main restricted universe multiverse    \n\
deb-src http://mirrors.aliyun.com/ubuntu/ precise main restricted universe multiverse          \n\
deb-src http://mirrors.aliyun.com/ubuntu/ precise-security main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ precise-updates main restricted universe multiverse  \n\
deb-src http://mirrors.aliyun.com/ubuntu/ precise-proposed main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ precise-backports main restricted universe multiverse " \
>/etc/apt/sources.list

# Make sure the package repository is up to date.
RUN apt-get update
RUN apt-get -y upgrade

# Install a basic SSH server
RUN apt-get install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# install pip mkdocs
RUN apt-get install -y python-pip
RUN pip install mkdocs

# Install JDK 7 (latest edition)
RUN apt-get install -y openjdk-7-jdk

# Install git
RUN apt-get install -y git

# Add user jenkins to the image
RUN adduser --quiet jenkins
# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd

# Add docs build file
ADD docs-build /usr/local/bin/docs-build
RUN chmod +x /usr/local/bin/docs-build

# modify search file
RUN rm /usr/local/lib/python2.7/dist-packages/mkdocs/assets/search/mkdocs/js/lunr-0.5.7.min.js
ADD lunr.js /usr/local/lib/python2.7/dist-packages/mkdocs/assets/search/mkdocs/js/lunr.js
RUN sed -i "s/base_url + '\/mkdocs\/js\/lunr-0.5.7.min.js',/base_url + '\/mkdocs\/js\/lunr.js',/" /usr/local/lib/python2.7/dist-packages/mkdocs/assets/search/mkdocs/js/search.js 

RUN sed -i "s/return json.dumps(page_dicts, sort_keys=True, indent=4)/return json.dumps(page_dicts, sort_keys=True, ensure_ascii=False, indent=4)/" /usr/local/lib/python2.7/dist-packages/mkdocs/search.py
RUN python -m py_compile /usr/local/lib/python2.7/dist-packages/mkdocs/search.py

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
