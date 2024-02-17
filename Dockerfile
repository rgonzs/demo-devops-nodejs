FROM node:18-alpine

# Creamos el usuario appuser con el UID 1010 para que el aplicativo no se ejecute como root
RUN adduser appuser -u 1010 -D
RUN mkdir -p /app && chown appuser:appuser /app
# RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

USER appuser
WORKDIR /app
# Instalamos dependencias 
COPY --chown=appuser:appuser --chmod=644 package*.json .
RUN npm ci && npm audit fix
# Copiamos el codigo de la  aplicacion nodejs
COPY --chown=appuser:appuser --chmod=700 . .
# Ejecutamos el app
ENTRYPOINT [ "npm" ]
CMD [ "run", "start" ]