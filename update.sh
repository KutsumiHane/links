#!/bin/bash
# update.sh — 读取 links.txt，重新生成全部跳转页
# 用法：编辑 links.txt 后，在仓库目录里执行  bash update.sh

cd "$(dirname "$0")"

n=0
while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}                      # 去掉可能的 Windows 回车符
    line=$(printf '%s' "$line" | tr -d '[:space:]')   # 去首尾空白
    case "$line" in ""|\#*) continue ;; esac           # 跳过空行和注释行
    n=$((n+1))
    num=$(printf '%02d' "$n")
    cat > "to-$num.html" <<EOF
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0;url=$line">
<title>Loading…</title>
</head>
<body>
<script>location.replace("$line");</script>
<p>Redirecting… If nothing happens, <a href="$line">click here</a>.</p>
</body></html>
EOF
done < links.txt

echo "已生成 $n 个跳转页。"
if [ "$n" -ne 12 ]; then
    echo "警告：links.txt 里有 $n 个有效链接，不是 12 个，请检查！"
fi
