FROM ubuntu:20.04
LABEL maintainer=jswart@kevel.co

# The apt packages was a guess as to what would be required to build the ronn
# gem. More minimal incantations failed.
RUN apt update --fix-missing
RUN DEBIAN_FRONTEND=noninteractive apt install --yes coreutils make wget pv rs \
                      curl g++ gcc autoconf automake \
                      gettext ruby-full
RUN gem install ronn

WORKDIR /workdir
COPY . .

# Make a dir local to the container for the install, and then install into this
# location. Afterward we zip this file for extraction to the host.
RUN mkdir /workdir/installed
RUN make PREFIX=/workdir/installed install
RUN zip -r ah_build.zip /workdir/installed/*

CMD ["bash"]
