# Build hp_wmi_sensors kernel module for Flatcar Container Linux
FROM alpine:3.19 AS builder

ARG KERNEL_VERSION=6.12.66
ENV KERNEL_VERSION=${KERNEL_VERSION}

# Copy build script first
COPY build-module.sh /tmp/build-module.sh
RUN chmod +x /tmp/build-module.sh

# Build the module
RUN /tmp/build-module.sh

# Runtime image - alpine with the module and loader script
FROM alpine:3.19

# Install kmod for modprobe/insmod
RUN apk add --no-cache kmod bash

# Copy the built module
COPY --from=builder /output/*.ko /lib/modules/

# Create module loader script
COPY load-module.sh /load-module.sh
RUN chmod +x /load-module.sh

CMD ["/load-module.sh"]
