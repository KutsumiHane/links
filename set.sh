#!/bin/bash
# set.sh — 单独修改某一个跳转页的目标网址
# 用法：bash set.sh 编号 网址
# 例如：bash set.sh 5 https://sudokupad.app/某道题

cd "$(dirname "$0")"

if [ $# -ne 2 ]; then
    echo "用法：bash set.sh 编号 网址    例如：bash set.sh 5 https://example.com"
    exit 1
fi

n=$((10#$1))    # 编号，允许写 5 或 05
url="$2"

if [ "$n" -lt 1 ] || [ "$n" -gt 99 ]; then
    echo "错误：编号必须是 1~99"
    exit 1
fi
if [ ! -f "to-$(printf '%02d' $n).html" ]; then
    echo "错误：to-$(printf '%02d' $n).html 不存在，编号超出现有范围"
    exit 1
fi

# 1. 更新 links.txt 里对应的行（自动跳过注释/空行来定位）
line=$(awk -v target="$n" '
    BEGIN { c=0 }
    { t=$0; sub(/\r$/,"",t); gsub(/^[ \t]+|[ \t]+$/,"",t)
      if (t=="" || t ~ /^#/) next
      c++
      if (c==target) { print NR; exit } }
' links.txt)
if [ -z "$line" ]; then
    echo "错误：links.txt 里找不到第 $n 个有效链接"
    exit 1
fi
sed -i "${line}c\\$url" links.txt

# 2. 重新生成这一个 html
num=$(printf '%02d' $n)
cat > "to-$num.html" <<EOF
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0;url=$url">
<title>Loading…</title>
</head>
<body>
<script>location.replace("$url");</script>
<p>Redirecting… If nothing happens, <a href="$url">click here</a>.</p>
</body></html>
EOF

echo "已更新 to-$num.html → $url（links.txt 同步）"
