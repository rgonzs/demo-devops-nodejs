FROM node:18-alpine

# Creamos el usuario appuser con el UID 1010 para que el aplicativo no se ejecute como root
RUN adduser appuser -u 1010 -D
RUN mkdir -p /app && chown appuser:appuser /app

USER appuser
WORKDIR /app
# Instalamos dependencias 
COPY --chown=appuser:appuser package*.json .
RUN npm ci --production
# Copiamos el codigo de la  aplicacion nodejs
COPY --chown=appuser:appuser . .
# Ejecutamos el app
ENTRYPOINT [ "npm" ]
CMD [ "run", "start" ]