FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Default configuration
ENV DISPLAY :20.0
ENV SCREEN_GEOMETRY "1440x900x24"
ENV CHROMEDRIVER_PORT 4444
ENV CHROMEDRIVER_WHITELISTED_IPS ""
ENV CHROMEDRIVER_URL_BASE ''
ENV CHROMEDRIVER_VERBOSE ""
ENV CHROME_BIN=/usr/bin/google-chrome

# Set timezone
RUN echo "US/Eastern" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Create a default user
RUN useradd automation --shell /bin/bash --create-home

# Update the repositories
# Install utilities
# Install XVFB and TinyWM
# Install fonts
# Install Python
RUN apt-get -yqq update && \
    apt-get -yqq install wget curl unzip && \
    apt-get -yqq install xvfb tinywm && \
    apt-get -yqq install gnupg libxi6 libgconf-2-4 && \
    apt-get -yqq install fonts-liberation libcairo2 libnss3 libnspr4 libasound2 libcups2 libxcomposite1 libxrender1 libxss1 lsb-release xdg-utils libappindicator3-1  && \
    apt-get -yqq install fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic && \
    apt-get -yqq install python && \
    rm -rf /var/lib/apt/lists/*

# Install Supervisor
RUN curl -sS -o - https://bootstrap.pypa.io/ez_setup.py | python && \
    easy_install -q supervisor

ARG CHROMEDRIVER_VERSION=79.0.3945.36

# Install Chrome WebDriver
RUN mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

# Install Google Chrome
#RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN apt-get -yqq update && apt-get -yqq install google-chrome-stable

# Configure Supervisor
ADD ./etc/supervisord.conf /etc/
ADD ./etc/supervisor /etc/supervisor

EXPOSE $CHROMEDRIVER_PORT

VOLUME [ "/var/log/supervisor" ]

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
