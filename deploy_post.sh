#!/bin/bash
# Hexo 博客自动部署脚本
# 功能：编译静态页面并同步到main分支，同时提交源码到hexo分支

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 重置颜色

# 错误处理函数
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 命令执行失败：$1${NC}"
        exit 1
    fi
}

# 版本检查
echo -e "${CYAN}🔍 检查系统依赖...${NC}"
hexo -v >/dev/null 2>&1 || { echo -e "${RED}❌ 未检测到Hexo，请先安装${NC}"; exit 1; }
git --version >/dev/null 2>&1 || { echo -e "${RED}❌ 未检测到Git，请先安装${NC}"; exit 1; }

# 目录安全检查
if [ ! -f "_config.yml" ] || [ ! -d "themes" ]; then
    echo -e "${RED}❌ 当前目录不是有效的Hexo项目根目录${NC}"
    exit 1
fi

# 编译静态页面
echo -e "${CYAN}🛠  开始编译博客...${NC}"
hexo clean && hexo generate
check_error "Hexo编译失败，请检查日志"

# 部署到GitHub Pages (main分支)
echo -e "\n${CYAN}🚀 部署到生产环境 (main分支)...${NC}"
hexo deploy
check_error "静态页面部署失败，请检查_config.yml的部署配置"

# 提交源码到hexo分支
echo -e "\n${CYAN}📦 提交源代码变更...${NC}"
GIT_STATUS=$(git status --porcelain)

if [ -n "$GIT_STATUS" ]; then
    echo -e "${YELLOW}检测到以下变更：${NC}"
    echo "$GIT_STATUS"
    
    # 自动提交参数
    COMMIT_MSG="自动提交: 博客源码更新 [$(date +%Y-%m-%d\ %H:%M)]"
    
    # 执行提交
    git add .
    git commit -m "$COMMIT_MSG"
    check_error "Git提交失败，请检查变更内容"
    
    # 推送到远程
    echo -e "\n${CYAN}📤 推送至hexo分支...${NC}"
    git push origin hexo
    check_error "Git推送失败，请检查网络连接和权限"
else
    echo -e "${GREEN}✅ 未检测到源码变更${NC}"
fi

# 完成提示
echo -e "\n${GREEN}🎉 部署完成！${NC}"
echo -e "访问地址：${CYAN}https://scaleflower.github.io/${NC}"
echo -e "源码仓库：${CYAN}https://github.com/scaleflower/scaleflower.github.io/tree/hexo${NC}"
