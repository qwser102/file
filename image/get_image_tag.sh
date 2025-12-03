#!/bin/bash

# === 配置项 ===
REGISTRY_URL="https://your-registry.example.com"   # 🔁 修改为你的 registry 地址（支持 HTTP/HTTPS）
REGISTRY_USER="your-username"                      # 🔁 修改为用户名，使用admin
REGISTRY_PASS="your-password"                      # 🔁 修改为密码，通过kubectl get secret获取
PAGE_SIZE=100

AUTH_HEADER="Authorization: Basic $(echo -n "$REGISTRY_USER:$REGISTRY_PASS" | base64)"

# === 函数：分页获取仓库列表 ===
get_all_repos() {
  local url="$REGISTRY_URL/v2/_catalog?n=$PAGE_SIZE"
  local repos=()

  while [[ -n "$url" ]]; do
    echo "➡️  Fetching: $url"
    response=$(curl -sSL -H "$AUTH_HEADER" -D - "$url")
    body=$(echo "$response" | sed -n '/^{/,$p')
    headers=$(echo "$response" | sed -n '/^HTTP\|^Link/p')
    new_repos=$(echo "$body" | jq -r '.repositories[]?')
    repos+=($new_repos)

    next_url=$(echo "$headers" | grep -i '^Link:' | sed -E 's/^.*<([^>]+)>.*/\1/')
    if [[ -n "$next_url" && "$next_url" != "$url" ]]; then
      url="$next_url"
    else
      url=""
    fi
  done

  echo "${repos[@]}"
}

# === 主流程 ===
echo "🔐 正在使用认证访问 $REGISTRY_URL ..."

ALL_REPOS=($(get_all_repos))

echo
echo "✅ 共发现 ${#ALL_REPOS[@]} 个仓库"
echo "======================================"

for repo in "${ALL_REPOS[@]}"; do
  echo "📦 仓库: $repo"
  tags=$(curl -sSL -H "$AUTH_HEADER" "$REGISTRY_URL/v2/$repo/tags/list" | jq -r '.tags[]?' 2>/dev/null)
  if [[ -z "$tags" ]]; then
    echo "  🚫 无 tag"
    continue
  fi
  for tag in $tags; do
    echo "  ➜ $repo:$tag"
  done
done



USER='xxxx'       #查询cat /etc/kubernetes/registry/auth.yaml账号
PASS='xxxx'       #查询cat /etc/kubernetes/registry/auth.yaml密码
EDNPOINT=https://0.0.0.0:11443  #换成平台镜像仓库和端口

for i in $(curl -k -u $USER:$PASS $EDNPOINT/v2/_catalog?n=5000 2>/dev/null | sed -e 's/^.*\[//' -e 's/\].*$//' -e 's/,/\n/g' -e s'/"//g'); do for j in $(curl  -k -u $USER:$PASS $EDNPOINT/v2/$i/tags/list 2>/dev/null | jq ".tags|keys" | sed -e '1d' -e '$d' -e 's/,//g') ; do echo $i:$(curl -k -u $USER:$PASS $EDNPOINT/v2/$i/tags/list 2>/dev/null |jq ".tags[$j]" | sed 's/"//g') ; done ; done
