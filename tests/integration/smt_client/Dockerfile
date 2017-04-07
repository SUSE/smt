FROM registry.scc.suse.de/connect_sp2

RUN zypper ref && zypper --non-interactive install --no-recommend \
    timezone

ADD files/run.sh /root/run.sh

ENTRYPOINT ["/root/run.sh"]
CMD ["tail", "-f", "/dev/null"]
