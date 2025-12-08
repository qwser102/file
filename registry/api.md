### list the images for each namespace 
## Search for repostory
curl -u <username>:<password> http://<registry-domain>:<port>/v2/_catalog
# For example
curl -u admin:"Alaudapoc@123" https://registry.acp1.uat.dbs.com/v2/_catalog -k |jq

## search for image tags
curl -u <username>:<password> http://<registry-domain>:<port>/v2/<project>/<image-name>/tags/list
# For example
curl -u admin:"Alaudapoc@123" https://registry.acp1.uat.dbs.com/v2/test-1/busybox/tags/list -k

## search for digest,and get the docker-content-digest value
curl -I  -u <user>:<password> -H "Accept: application/vnd.docker.distribution.manifest.v2+json, application/vnd.docker.distribution.manifest.v1+prettyjws, application/vnd.oci.image.manifest.v1+json, application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.docker.distribution.manifest.v1+json" https://registry.acp1.uat.dbs.com/v2/<repository>/manifests/<tag>  -k

# For example
curl -I  -u admin:"Alaudapoc@123" -H "Accept: application/vnd.docker.distribution.manifest.v2+json, application/vnd.docker.distribution.manifest.v1+prettyjws, application/vnd.oci.image.manifest.v1+json, application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.docker.distribution.manifest.v1+json" https://registry.acp1.uat.dbs.com/v2/test-1/busybox/manifests/1.29  -k

## Delete images
curl -k -X DELETE -s --connect-timeout 30 -u <user>:<password> https://registry.acp1.uat.dbs.com/v2/<repository>/manifests/<docker-content-digest value>

# For example
curl -k -X DELETE -s --connect-timeout 30 -u admin:"Alaudapoc@123" https://registry.acp1.uat.dbs.com/v2/test-1/busybox/manifests/sha256:3b58ed3d37670d11eae9071d9ce54adbf38b632e6fb7bb395f0c301cbf4e3bd8


## gc
kubectl exec -n "$NAMESPACE" "$pod_name" -c registry -- \
                  /bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml --dry-run=false
