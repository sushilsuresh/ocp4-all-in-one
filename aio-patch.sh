#!/bin/bash

# Set etcd-quorum-guard to unmanaged state:
oc patch clusterversion/version -n openshift-machine-config-operator --type=merge -p='{"spec": {"overrides": [{"group": "apps/v1", "kind": "Deployment", "name": "etcd-quorum-guard", "namespace": "openshift-machine-config-operator", "unmanaged": true}]}}'

# Downscale etcd-quorum-guard to one:
oc scale --replicas=1 deployment/etcd-quorum-guard -n openshift-machine-config-operator

# Downscale the number of routers to one:
oc scale --replicas=1 ingresscontroller/default -n openshift-ingress-operator

# Downscale the number of consoles, authentication, OLM and monitoring services to one:
oc scale --replicas=1 deployment.apps/console -n openshift-console
oc scale --replicas=1 deployment.apps/downloads -n openshift-console
oc scale --replicas=1 deployment.apps/oauth-openshift -n openshift-authentication
oc scale --replicas=1 deployment.apps/packageserver -n openshift-operator-lifecycle-manager

# NOTE: When enabled, the Operator will auto-scale this services back to original quantity
oc scale --replicas=1 deployment.apps/prometheus-adapter -n openshift-monitoring
oc scale --replicas=1 deployment.apps/thanos-querier -n openshift-monitoring
oc scale --replicas=1 statefulset.apps/prometheus-k8s -n openshift-monitoring
oc scale --replicas=1 statefulset.apps/alertmanager-main -n openshift-monitoring

# This patch is required start with OCP 4.4.3
# So run it in and OCP cluster < 4.4.3 at your own risk :-)
# REF: https://bugzilla.redhat.com/show_bug.cgi?id=1805034
oc patch etcd cluster -p='{"spec": {"unsupportedConfigOverrides": {"useUnsupportedUnsafeNonHANonProductionUnstableEtcd": true}}}' --type=merge

