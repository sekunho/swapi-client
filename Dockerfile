FROM alpine:3.14.0 AS assets

ENV TAILWIND_VERSION=3.0.18
ENV TAILWIND_URL=https://github.com/tailwindlabs/tailwindcss/releases/download/v${TAILWIND_VERSION}/tailwindcss-linux-x64

ENV ESBUILD_VERSION=0.14.13
ENV ESBUILD_URL=https://registry.npmjs.org/esbuild-linux-64/-/esbuild-linux-64-${ESBUILD_VERSION}.tgz

WORKDIR /app

# Download Tailwind
RUN \
    apk add curl && \
    curl -sL ${TAILWIND_URL} -o /usr/bin/tailwindcss && \
     chmod +x /usr/bin/tailwindcss

# Download esbuild
RUN \
    apk add curl && \
    curl ${ESBUILD_URL} | tar xvz && \
     mv ./package/bin/esbuild /usr/bin/esbuild && \
     chmod +x /usr/bin/esbuild

# Copy swoogle template
# Need this because Tailwind purges the classes in the template. So, without it,
# only the default styles will remain.
COPY swoogle swoogle

# Copy swoogle static files
COPY assets assets
COPY priv/static/images priv/static/images

RUN apk add tree

RUN tree .

# Build and minify stylesheet
RUN \
    mkdir priv/static/assets && \
    tailwindcss \
      --input assets/app.css \
      --output priv/static/assets/app.css \
      --config assets/tailwind.config.js \
      --minify

# Build and minify *S
RUN \
    esbuild assets/app.js \
      --outfile=priv/static/assets/app.js \
      --minify

# ============================================================================ #

FROM alpine:3.14.0

WORKDIR /app

RUN chown nobody /app

COPY --chown=nobody:root swoogle-server swoogle-server
COPY --from=assets --chown=nobody:root /app/priv priv

EXPOSE 3000

CMD ["/app/swoogle-server"]
