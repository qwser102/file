#!/usr/bin/env bash

# 输出到终端的同时写入 apps.yaml
# 使用 tee，且在每次执行时覆盖旧文件
{
  # -----------------------------
  # 第一部分：applications
  # -----------------------------
  echo "applications:"
  {
    kubectl get moduleplugin --no-headers | awk '{print "  "$1": null"}'
    kubectl get packagemanifest --no-headers | awk '{print "  "$1": null"}'
  } | sort -u


  # -----------------------------
  # 第二部分：core
  # -----------------------------

  # 获取当前平台版本 (例如 v4.0.2)
  current_version=$(kubectl get cm -n kube-public platform -o jsonpath='{.data.version}')

  # 去掉 v 前缀
  ver=${current_version#v}
  major=$(echo "$ver" | cut -d. -f1)
  minor=$(echo "$ver" | cut -d. -f2)

  # 当前版本的 major.minor
  current_minor_version="v${major}.${minor}"

  # 计算前后两个 minor 版本，并确保不小于 0
  prev1_minor=$((minor - 1))
  prev2_minor=$((minor - 2))

  if [ "$prev1_minor" -lt 0 ]; then
    prev1_minor=0
  fi
  if [ "$prev2_minor" -lt 0 ]; then
    prev2_minor=0
  fi

  prev2="v${major}.${prev2_minor}"
  prev1="v${major}.${prev1_minor}"
  next1="v${major}.$((minor + 1))"
  next2="v${major}.$((minor + 2))"

  # 去重并保持顺序
  versions=($(printf "%s\n" "$prev2" "$prev1" "$current_minor_version" "$next1" "$next2" | awk '!seen[$0]++'))

  # 定义 core 组件的变更表（只写有变更的版本）
  declare -A CORE_COMPONENTS_MAP
  CORE_COMPONENTS_MAP["v4.0"]="alive platform-registry cert-manager container-platform marketplace alb flannel internal-docker-registry auth-manager cluster-manager calico prometheus aiops-base acp-business kube-ovn coredns sentry base "
  CORE_COMPONENTS_MAP["v4.1"]="alive platform-registry ingress-nginx-operator cert-manager container-platform marketplace alb flannel internal-docker-registry i18n-zh auth-manager cluster-manager calico prometheus aiops-base acp-business kube-ovn coredns sentry base"

  # 打印 core
  echo "core:"

  last_comps=""
  for v in "${versions[@]}"; do
    comps="${CORE_COMPONENTS_MAP[$v]}"

    # 如果当前版本没定义，就继承上一个版本
    if [ -z "$comps" ]; then
      comps="$last_comps"
    fi

    echo "  $v:"
    for comp in $comps; do
      echo "    $comp: null"
    done

    last_comps="$comps"
  done

} | tee apps.yaml
