# Use the official Ubuntu base image
FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and Perl 5.32
RUN apt-get update && \
    apt-get install -y wget gnupg2 make g++ sudo && \
    apt-get install -y vim && \
    apt-get clean

# Add a regular user
RUN useradd -m dockeruser && \
    echo "dockeruser:dockeruser" | chpasswd && \
    adduser dockeruser sudo

# Switch to the regular user
USER dockeruser
WORKDIR /home/dockeruser

RUN wget https://github.com/libexpat/libexpat/releases/download/R_2_2_10/expat-2.2.10.tar.gz && \
    tar -xzf expat-2.2.10.tar.gz && \
    rm expat-2.2.10.tar.gz && \
    cd expat-2.2.10 && \
    ./configure --prefix=$HOME/expat-2.2.10 && \
    make && \
    make install

RUN wget https://www.cpan.org/src/5.0/perl-5.32.1.tar.gz && \
    tar -xzf perl-5.32.1.tar.gz && \
    rm perl-5.32.1.tar.gz && \
    cd perl-5.32.1 && \
    ./Configure -des -Dprefix=$HOME/perl-5.32.1 && \
    make && \
    #make test && \
    make install

ENV PERL=/home/dockeruser/perl-5.32.1/bin/perl
RUN wget https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz && \
    tar -xzf XML-Parser-2.47.tar.gz && \
    rm XML-Parser-2.47.tar.gz && \
    cd XML-Parser-2.47 && \
    $PERL Makefile.PL EXPATLIBPATH=/home/dockeruser/expat-2.2.10/lib EXPATINCPATH=/home/dockeruser/expat-2.2.10/include && \
    make && \
    make test && \
    make install

    # Set the entrypoint to a shell prompt
ENTRYPOINT ["/bin/bash"]

# Expose a shell prompt
CMD ["-l"]
