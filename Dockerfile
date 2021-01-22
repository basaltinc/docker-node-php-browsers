FROM ubuntu:16.04

RUN export LC_ALL=C.UTF-8
RUN DEBIAN_FRONTEND=noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install --no-install-recommends -y \
    sudo \
    autoconf \
    autogen \
    language-pack-en-base \
    wget \
    curl \
#    rsync \
    ssh \
#    openssh-client \
    git \
    build-essential \
    apt-utils \
    software-properties-common \
#    python-software-properties \
    nasm && \
#    libjpeg-dev \
#    libpng-dev \
#    libpng16-16 && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# PHP
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && apt-get update && apt-get install --no-install-recommends -y \
    php7.2 \
    php7.2-curl \
#    php7.2-gd \
    php7.2-dev \
    php7.2-xml \
    php7.2-bcmath \
#    php7.2-mysql \
    php7.2-mbstring \
    php7.2-zip \
    php7.2-bz2 \
    php7.2-sqlite \
#    php7.2-soap \
    php7.2-json && \
#    php7.2-intl \
#    php7.2-imap \
#    php7.2-imagick \
#    php-xdebug \
#    php-memcached && \
    rm -rf /var/lib/apt/lists/* && \
    command -v php

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update --preview
RUN command -v composer

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install --no-install-recommends nodejs -y
RUN npm install npm@latest -g
RUN command -v node
RUN command -v npm

# Yarn
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get update && sudo apt-get install yarn

# Ansible
#RUN apt-add-repository ppa:ansible/ansible
#RUN apt-get update && apt-get install --no-install-recommends ansible -y && rm -rf /var/lib/apt/lists/* && command -v ansible

# Other
RUN mkdir ~/.ssh && touch ~/.ssh_config

# Display versions installed
RUN php -v && composer --version && node -v && npm -v && yarn -v

WORKDIR /app

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
# ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
# RUN chmod +x /usr/local/bin/dumb-init
# ENTRYPOINT ["dumb-init", "--"]

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install puppeteer so it's available in the container.
# RUN npm i puppeteer \
#   # Add user so we don't need --no-sandbox.
#   # same layer as npm install to keep re-chowned files from using up several hundred MBs more space
#   && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
#   && mkdir -p /home/pptruser/Downloads \
#   && chown -R pptruser:pptruser /home/pptruser \
#   && chown -R pptruser:pptruser /node_modules

# # Run everything after as non-privileged user.
# USER pptruser

# CMD ["google-chrome-unstable"]
