# docker-splunk-nginx-defaults-awssm

#### Splunk default.yml Nginx container populated by AWS Secrets Manager

> This is an example or prototype, as opposed to a complete and usable component.

---

### Resources

* Kubernetes - https://kubernetes.io/
* Splunk's Docker Image
  * https://hub.docker.com/r/splunk/splunk/
  * https://github.com/splunk/docker-splunk
* `confd` - https://github.com/kelseyhightower/confd
* `summon` - https://github.com/cyberark/summon

### Description

The latest [official Splunk docker image](https://hub.docker.com/r/splunk/splunk/)
uses [Ansible](https://github.com/splunk/splunk-ansible) under the hood for setup,
configuration and auto-discovery. Using the pattern set forth by Splunk when
deploying via [Kubernetes](https://kubernetes.io/), a `default.yml` and a license
file can be provided via http to allow for external configurations using the internal
networking support.

> See: https://github.com/splunk/docker-splunk/blob/dd1c3e5cccfefac18ef559e4d6b6454917cc86e1/test_scenarios/kubernetes/README.md#nginx
> for additional information on default.yml.

This repo provides all the necessary files and configuration to build an Nginx
image setup to define `default.yml` values and a license file using [AWS Secrets
Manager](https://aws.amazon.com/secrets-manager/) for secrets and environment
variables passed to the container for other configurations.

The Docker build contained herein includes [confd](https://github.com/kelseyhightower/confd)
templates, which are included in the container at build time. It uses
[summon](https://github.com/cyberark/summon) to pull secret values from AWS
Secrets Manager and [godotenv](https://github.com/joho/godotenv) inject the
secrets in to the environment at runtime via the entrypoint. [summon](https://github.com/cyberark/summon)
looks for a file on disk -- `secrets.yaml` -- which is used to define the mapping
between AWS Secret Manager keys and the environment variables they'll be applied to.
In the Kubernetes example manifest provided, we use a ConfigMap to build `secrets.yaml`,
which is mounted in to the running container. For non-secret configurations, we
leverage Kubernetes container runtime environment variable support.

