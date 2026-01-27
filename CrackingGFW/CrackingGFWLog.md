I'm in mainland china spent hours dealing with the proxy. 

I've struggling with it for years, back in old days, there were mirror stations(docker.ustc.edu.cn), public proxies(ghproxy.com), just unstable.

It started from the project where I want to excecise the Kubernetes operator, and I planned to install `kind`, a local cluster tool. The first thing that blocks me was merely download the binary. `https://kind.sigs.k8s.io` is blocked by GFW.

I configured proxy on my local laptop, but not the production env: complicated and unsafe. This is how I worked around:
1. Directly curl: `curl -Lo kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64`, Failed.
2. Use Github Mirror `ghproxy` and get it from github. Failed again.
3. Happened to find that it is available for `go install`, so I put proxy (golang install is also blocked, you need a GOPROXY!), done！
4. Not usable. need to specify the `$PATH`, since golang install don't put binaries under legacy path.
FINALLY!

Shall I start a cluster with `kind create cluster` now? Hold your horse. There's still a long way to go. DockerHub is blocked.
1. Use different docker registry mirrors: 
   1. USTC Dockerhub stopped service from Dec 2024;
   2. 163 dockerhub stopped way long time ago;
   3. Aliyun is still working, but need registering. OK, I'll do it
   4. After register, and get the link, start creating? Stop dreaming. It does not work.
   5. I try to pull the images first and see what's wrong with docker pull, still not working
   6. Turns out it only allows its own vps to use the service: https://help.aliyun.com/zh/acr/product-overview/product-change-acr-mirror-accelerator-function-adjustment-announcement
   7. Then I'll switch to tencent cloud, it works for nginx, but not for kindest/node
   8. I then serched, and found that tencent only accept specified tag, so then I added 1.29.2, as GPT suggested, The download succeeded, but the kind request v1.35.0.Failed.
   9. `docker pull kindest/node:v1.35.0`. Finally!

Now, an hour and half past. I've not even started coding yet.


Now the Scaffolding, Installing the kubebuilder. conventionally, you would use this scriptlet:
```shell
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
```
and you think: its neither docker nor github, just run the script. Ha! Gotcha! 
```
ubuntu@VM-8-15-ubuntu:~/hsimwong.github.io/scripts$ ./kubebuilder.sh 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    68  100    68    0     0     65      0  0:00:01  0:00:01 --:--:--    66
100   110  100   110    0     0     78      0  0:00:01  0:00:01 --:--:--    78
  0     0    0     0    0     0      0      0 --:--:--  0:01:31 --:--:--     0
curl: (56) Failure when receiving data from the peer
chmod: cannot access 'kubebuilder': No such file or directory
```
Config your proxy!


## Update on Jan 26
The Tencent VM is too small, so I transterred the code onto my local laptop, and the env has to be 
re-configured.

I just found the tencent docker hub is not accessible from outside, so I have to find another one. 

There used to be many docker mirror hubs hosted in mainland China, and many of them are either blocked or censored.

There are also many pioneers that tried to work around:

https://www.wangdu.site/course/2109.html
