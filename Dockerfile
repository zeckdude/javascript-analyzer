FROM node:lts-alpine as builder

# Install SSL ca certificates
RUN apk update && apk add ca-certificates

# Create appuser
RUN adduser -D -g '' appuser

# get the source code
WORKDIR /javascript-analyzer
COPY . .

# build
RUN yarn install && yarn build && yarn install --prod

# Build a minimal and secured container
FROM node:lts-alpine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /javascript-analyzer/bin /opt/analyzer/bin
COPY --from=builder /javascript-analyzer/dist /opt/analyzer/dist
COPY --from=builder /javascript-analyzer/node_modules /opt/analyzer/node_modules
USER appuser
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/analyze.sh"]
