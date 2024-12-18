FROM alpine:latest

# Install dnsmasq and other dependencies
RUN apk update && \
    apk add --no-cache dnsmasq

# Install inotify-tools
RUN apk add --no-cache inotify-tools

# Check if inotifywait is installed, and fail the build if it's not
RUN which inotifywait || (echo "inotify-tools installation failed!" && exit 1)

# Configure dnsmasq (you can customize the config as needed)
COPY dnsmasq.conf /etc/dnsmasq.conf

# Copy the monitoring script that will watch /etc/hosts
COPY monitor_hosts.sh /usr/local/bin/monitor_hosts.sh
RUN chmod +x /usr/local/bin/monitor_hosts.sh

# Expose the DNS port
EXPOSE 53/tcp 53/udp

# Start dnsmasq with your configuration
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/monitor_hosts.sh & dnsmasq -k --conf-file=/etc/dnsmasq.conf --no-daemon"]