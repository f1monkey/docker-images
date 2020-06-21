FROM cyradin/php:7.4-latest

ARG USER_GID=1000
ARG USER_UID=1000
RUN addgroup -g ${USER_GID} app \
  && adduser -D -s /bin/bash -G app -u ${USER_UID} app \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && composer global require bamarni/symfony-console-autocomplete \
  && symfony-autocomplete composer | tee /usr/share/bash-completion/completions/composer \
  && chown -R app:app /opt

COPY start.sh /scripts/start.sh
COPY wait-for-it.sh /scripts/wait-for-it.sh
COPY server.sh /scripts/server.sh

RUN chmod +x /scripts/start.sh \
    && chmod +x /scripts/server.sh \
    && chmod +x /scripts/wait-for-it.sh

WORKDIR /srv
RUN chown -R app:app /srv
USER app

ENTRYPOINT /scripts/start.sh