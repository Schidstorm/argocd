local deployments = import 'deployments.jsonnet';
local app = std.extVar('app');
local deployment = if std.objectHas(deployments, app) then deployments[app] else error 'No deployment found for app';

local namespace = if std.objectHas(deployment, "namespace") then deployment.namespace else app;
local values = if std.objectHas(deployment, "values") then deployment.values else {};

std.manifestYamlDoc({
    "apiVersion": "argoproj.io/v1alpha1",
    "kind": "Application",
    "metadata": {
      "name": namespace + "-" + app,
      "namespace": "argocd"
    },
    "spec": {
      "syncPolicy": {
        "automated": {
          "prune": true,
          "selfHeal": true
        },
        "syncOptions": [
          "ServerSideApply=true"
        ]
      },
      "project": "default",
      "source": {
        "path": "apps/" + app,
        "repoURL": "https://github.com/schidstorm/argocd/",
        "targetRevision": "main",
        "helm": {
          "releaseName": "release.name",
          "values": std.manifestYamlDoc(values)
        }
      },
      "destination": {
        "server": "https://kubernetes.default.svc",
        "namespace": namespace
      }
    }
  }, indent_array_in_object=false)