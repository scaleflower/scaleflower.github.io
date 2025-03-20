#!/bin/bash
# 创建新文章并自动同步到GitHub
# 使用方法：./deploy_post.sh "文章标题" "可选的内容追加"

if [ -z "$1" ]; then
    echo "[错误] 请指定文章标题"
    echo "示例：./deploy_post.sh '新文章标题' '内容追加'"
    exit 1
fi

# 生成新文章
echo "▶ 创建新文章：$1"
hexo new post "$1"
POST_PATH=$(ls -t source/_posts | head -n1)

# 追加内容（如果提供第二个参数）
if [ -n "$2" ]; then
    echo "▶ 添加自定义内容..."
    echo -e "\n$2" >> "source/_posts/$POST_PATH"
fi

# 生成静态文件
echo "▶ 生成静态页面..."
hexo clean && hexo generate

# 部署到GitHub Pages
echo "▶ 部署到生产环境..."
hexo deploy

# 提交源代码到hexo分支
echo "▶ 同步源代码..."
git add .
git commit -m "发布新文章: $1"
git push origin hexo

echo "✅ 部署完成！"
echo "访问地址：https://scaleflower.github.io/$(date +%Y/%m/%d)/${1// /-}/"
