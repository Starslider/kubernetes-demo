# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod ./
# Download dependencies
RUN go mod download

# Copy source code
COPY *.go ./
# Generate go.sum based on actual imports
RUN go mod tidy

# Build arguments for multi-platform support
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Build the application
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -a -installsuffix cgo -o rag-pipeline .

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/rag-pipeline .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./rag-pipeline"]

