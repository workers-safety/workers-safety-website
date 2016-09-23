FROM ubuntu:14.04 

MAINTAINER Berenice Venegas Cotero <bvcotero@gmail.com>

RUN apt-get update && apt-get install -y curl tar

ENV HUGO_VERSION 0.15
RUN curl -sSL https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux_amd64.tar.gz | tar -v -C /usr/local/bin -xz --strip-components 1 \
	&& mv /usr/local/bin/hugo_${HUGO_VERSION}_linux_amd64 /usr/local/bin/hugo

ENV HOME /usr/src
VOLUME ${HOME}/blog/
WORKDIR ${HOME}/blog/

EXPOSE 1313 

#ENTRYPOINT ["./release.sh"]
#CMD ["hugo"]
