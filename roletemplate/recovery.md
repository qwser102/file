```
kubectl get roletemplate -o name | xargs -I {} kubectl annotate {} auth.cpaas.io/bootstrap-fix="true" --overwrite
```
