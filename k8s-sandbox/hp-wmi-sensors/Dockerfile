# Build hp_wmi_sensors kernel module for Flatcar Container Linux
FROM alpine:3.19 as builder

ARG KERNEL_VERSION=6.12.66

WORKDIR /build

# Copy build script
COPY build-module.sh /build/
RUN chmod +x /build/build-module.sh

# Build the module
RUN /build/build-module.sh

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
