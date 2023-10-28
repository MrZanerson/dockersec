FROM alpine:3.14


LABEL maintainer="szane @Cryptoambient"
LABEL maintainer= "Tonight at the Magic Theater, for Mad men only and once Price only YOUR MIND"



RUN apk --update add python3 py3-pip py3-netifaces py3-prettytable py3-certifi \
py3-chardet py3-future py3-idna py3-netaddr py3-parsing py3-six\
 openssh nmap nmap-scripts curl tcpdump ruby bind-tools jq nmap-ncat bash util-linux libcap libcap-ng-utils iproute2 iptables && \
sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config && rm -rf /var/cache/apk/*


#Kubernetes 1.12 for old clusters
RUN curl -O https://storage.googleapis.com/kubernetes-release/release/v1.12.8/bin/linux/amd64/kubectl && \
chmod +x kubectl && mv kubectl /usr/local/bin/kubectl112

#Kubernetes 1.16 for medium old clusters
RUN curl -O https://storage.googleapis.com/kubernetes-release/release/v1.16.7/bin/linux/amd64/kubectl && \
chmod +x kubectl && mv kubectl /usr/local/bin/kubectl116

#Kubernetes 1.21 for new clusters
RUN curl -O https://storage.googleapis.com/kubernetes-release/release/v1.21.5/bin/linux/amd64/kubectl && \
chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

#Get docker we're not using the apk as it includes the server binaries that we don't need
RUN curl -OL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz && tar -xzvf docker-20.10.9.tgz && \
cp docker/docker /usr/local/bin && chmod +x /usr/local/bin/docker && rm -rf docker/ && rm -f docker-20.10.9.tgz

#Get etcdctl
RUN curl -OL https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz && \
tar -xzvf etcd-v3.3.13-linux-amd64.tar.gz && cp etcd-v3.3.13-linux-amd64/etcdctl /usr/local/bin && \
chmod +x /usr/local/bin/etcdctl && rm -rf etcd-v3.3.13-linux-amd64 && rm -f etcd-v3.3.13-linux-amd64.tar.gz

#Get AmIcontained
RUN curl -OL https://github.com/genuinetools/amicontained/releases/download/v0.4.9/amicontained-linux-amd64 && \
mv amicontained-linux-amd64 /usr/local/bin/amicontained && chmod +x /usr/local/bin/amicontained

#Get botb
RUN curl -OL https://github.com/brompwnie/botb/releases/download/1.8.0/botb-linux-amd64 && \
mv botb-linux-amd64 /usr/local/bin/botb && chmod +x /usr/local/bin/botb

#Get Reg
RUN curl -OL https://github.com/genuinetools/reg/releases/download/v0.16.1/reg-linux-amd64 && \
mv reg-linux-amd64 /usr/local/bin/reg && chmod +x /usr/local/bin/reg

#Get kubectl-who-can
RUN curl -OL https://github.com/aquasecurity/kubectl-who-can/releases/download/v0.1.0/kubectl-who-can_linux_x86_64.tar.gz && \
tar -xzvf kubectl-who-can_linux_x86_64.tar.gz && mv kubectl-who-can /usr/local/bin && rm -f kubectl-who-can_linux_x86_64.tar.gz

#Get Helm3
RUN curl -OL https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz && \
tar -xzvf helm-v3.7.0-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && \
chmod +x /usr/local/bin/helm && rm -rf linux-amd64 && rm -f helm-v3.7.0-linux-amd64.tar.gz

#Get Helm2
RUN curl -OL https://get.helm.sh/helm-v2.17.0-linux-amd64.tar.gz && \
tar -xzvf helm-v2.17.0-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm2 && \
chmod +x /usr/local/bin/helm && rm -rf linux-amd64 && rm -f helm-v2.17.0-linux-amd64.tar.gz

#Get kdigger
RUN curl -OL https://github.com/quarkslab/kdigger/releases/download/v1.0.0/kdigger-linux-amd64 && \
mv kdigger-linux-amd64 /usr/local/bin/kdigger && chmod +x /usr/local/bin/kdigger

#Get nerdctl
RUN curl -OL https://github.com/containerd/nerdctl/releases/download/v1.5.0/nerdctl-1.5.0-linux-amd64.tar.gz && \
tar -xzvf nerdctl-1.5.0-linux-amd64.tar.gz && mv nerdctl /usr/local/bin && chmod +x /usr/local/bin/nerdctl && \
rm -f nerdctl-1.5.0-linux-amd64.tar.gz

#Get crictl
RUN curl -OL https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.27.1/crictl-v1.27.1-linux-amd64.tar.gz && \
tar -xzvf crictl-v1.27.1-linux-amd64.tar.gz && mv crictl /usr/local/bin && chmod +x /usr/local/bin/crictl && \
rm -f crictl-v1.27.1-linux-amd64.tar.gz

#Put a Sample Privileged Pod Chart in the Image
RUN mkdir /charts
COPY /charts/* /charts/

COPY /bin/conmachi /usr/local/bin/

COPY /bin/escape.sh /usr/local/bin/

COPY /bin/deepce.sh /usr/local/bin/

COPY /bin/keyctl-unmask /usr/local/bin/

RUN mkdir /manifests
COPY /manifests/* /manifests/



COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

#SetUID shell might be handy
RUN cp /bin/bash /bin/setuidbash && chmod 4755 /bin/setuidbash

# Set the ETCD API to 3
ENV ETCDCTL_API 3

#We can run this but lets let it be overridden with a CMD 
CMD ["/entrypoint.sh"]
