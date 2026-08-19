# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copy dependency definitions
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o digitalocean_exporter .

# Runtime stage
FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/digitalocean_exporter /usr/bin/digitalocean_exporter

EXPOSE 9212

ENTRYPOINT ["/usr/bin/digitalocean_exporter"]
