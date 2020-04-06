FROM golang as builder
EXPOSE 8080
RUN apt -qq update
RUN apt -qq install dnsutils -y
COPY . .
RUN mkdir /certs
RUN cp -r certs /certs
RUN useradd scratchuser && \
    export GOPATH="" && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o /webhooktest .

# RUN cd / && openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -out certificate.pem -days 3650 -subj "/C=DE/ST=NRW/L=Earth/O=Random Company/OU=IT/CN=www.random.com/emailAddress=$1"
# FROM scratch
# COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs
# COPY --from=builder /webhook /
# COPY --from=builder /etc/passwd /etc/passwd
# USER scratchuser

CMD ["/webhooktest"]
