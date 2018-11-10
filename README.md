# docker-splunk-nginx-defaults-awssm

#### Splunk default.yml Nginx container populated by AWS Secrets Manager

> This is an example or prototype, as opposed to a complete and usable component.

---

### Resources

* Kubernetes - https://kubernetes.io/
* Splunk's Docker Image
  * https://hub.docker.com/r/splunk/splunk/
  * https://github.com/splunk/docker-splunk
  * https://github.com/splunk/splunk-ansible
* `confd` - https://github.com/kelseyhightower/confd
* `summon` - https://github.com/cyberark/summon

### Description

The latest [official Splunk docker image][2]
uses [Ansible][6] under the hood for setup,
configuration and auto-discovery. Using the pattern set forth by Splunk when
deploying via [Kubernetes][1], a `default.yml` and a license
file can be provided via http to allow for external configurations using the internal
networking support.

> See: https://github.com/splunk/docker-splunk/blob/dd1c3e5cccfefac18ef559e4d6b6454917cc86e1/test_scenarios/kubernetes/README.md#nginx
> for additional information on default.yml.

This repo provides all the necessary files and configuration to build an Nginx
image setup to define `default.yml` values and a license file using [AWS Secrets
Manager][7] for secrets and environment
variables passed to the container for other configurations.

The Docker build contained herein includes [confd][4] templates, which are included
in the container at build time. It uses [summon][5] to pull secret values from AWS
Secrets Manager and [godotenv][8] inject the secrets in to the environment at runtime
via the entrypoint. [summon][5] looks for a file on disk -- `secrets.yaml` -- which
is used to define the mapping between [AWS Secret Manager][7] keys and the environment
variables they'll be applied to.  In the Kubernetes example manifest provided, we
use a ConfigMap to build `secrets.yaml`, which is mounted in to the running container.
For non-secret configurations, we leverage Kubernetes container runtime environment
variable support.

### Deploying the example

You can use this repo as working example, assuming you have a Kubernetes cluster
up and running, and an AWS account to add secrets to.

> It's recommended that you fork or copy this repo, build your own image and push
> it to your docker registry for production use.

#### Setup secrets

Before deploying the Kubernetes manifest, you'll first need to create the required
secrets in AWS.

```bash
# HEC Token
aws secretsmanager create-secret --name "/splunk/hec/token" --secret-string="xxx-xxx-xxx-xxx"

# Splunk Password
aws secretsmanager create-secret --name "/splunk/password" --secret-string="changeme"

# Splunk Indexer Cluster Secret
aws secretsmanager create-secret --name "/splunk/idxc/secret" --secret-string="changeme"

# Splunk Search Cluster Secret
aws secretsmanager create-secret --name "/splunk/shc/secret" --secret-string="changeme"
```

It's worth noting that [summon][5] is configurated to ignore missing secrets and
continue without error.

#### Setup secrets

Once secrets have been created, simply apply the Kubernetes manifest.

```bash
kubectl apply -f k8s-example.yaml
```

#### Including a License

You can add your license to AWS Secrets Manager using the following. If set,
the container will automatically build the license file at run time.

```bash
# license
aws secretsmanager create-secret --name "/splunk/license" \
    --secret-string="$(cat /path/to/your_license.lic)"
```

[1]: https://kubernetes.io/
[2]: https://hub.docker.com/r/splunk/splunk/
[3]: https://github.com/splunk/docker-splunk
[4]: https://github.com/kelseyhightower/confd
[5]: https://github.com/cyberark/summon
[6]: https://github.com/splunk/splunk-ansible
[7]: https://aws.amazon.com/secrets-manager/
[8]: https://github.com/joho/godotenv
