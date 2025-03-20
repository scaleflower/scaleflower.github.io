#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 配置参数
REPO_DIR="scaleflower.github.io"
REPO_URL="git@github.com:scaleflower/scaleflower.github.io.git"
BRANCH="hexo"
FORCE_CLEAN=false

# 显示欢迎信息
echo -e "${GREEN}🚀 Hexo 博客环境初始化脚本 v2.0${NC}"
echo -e "${YELLOW}📅 最后更新: 2023-12-01${NC}\n"

# 清理环境函数
clean_environment() {
    echo -e "\n${RED}⚠️  即将执行危险操作！${NC}"
    read -p "是否确认删除整个仓库目录并重新克隆？[y/N] " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑  删除本地仓库...${NC}"
        rm -rf "$REPO_DIR" && return 0
    else
        echo -e "${GREEN}✅ 取消清理操作${NC}"
        return 1
    fi
}

# 处理命令行参数
if [ "$1" == "--force-clean" ]; then
    if clean_environment; then
        FORCE_CLEAN=true
    else
        exit 1
    fi
fi

# 检查依赖项
echo -e "\n${GREEN}🔍 检查系统依赖...${NC}"
for cmd in git node npm npx; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}❌ 未找到 $cmd，请先安装${NC}"
        exit 1
    done
done
echo -e "${GREEN}✅ 所有依赖已安装${NC}"

# 仓库同步逻辑
echo -e "\n${GREEN}📥 仓库同步检查...${NC}"
if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}⚠️  检测到已存在的本地仓库${NC}"
    
    if ! $FORCE_CLEAN; then
        echo -e "请选择操作："
        select action in "保留并更新" "删除并重新克隆" "退出"; do
            case $action in
                "保留并更新")
                    echo -e "\n${GREEN}🔄 尝试更新仓库...${NC}"
                    cd "$REPO_DIR" || exit 1
                    if ! git pull origin $BRANCH; then
                        echo -e "\n${RED}❌ 更新失败！建议操作："
                        echo -e "1. 手动解决冲突"
                        echo -e "2. 使用 --force-clean 参数强制清理"
                        echo -e "3. 检查网络连接${NC}"
                        exit 1
                    fi
                    cd ..
                    break
                    ;;
                "删除并重新克隆")
                    if clean_environment; then
                        FORCE_CLEAN=true
                    fi
                    break
                    ;;
                "退出")
                    echo -e "${GREEN}👋 操作已取消${NC}"
                    exit 0
                    ;;
            esac
        done
    fi
fi

# 克隆仓库逻辑
if [ ! -d "$REPO_DIR" ] || $FORCE_CLEAN; then
    echo -e "\n${GREEN}🔃 重新克隆仓库...${NC}"
    git clone -b $BRANCH --single-branch $REPO_URL $REPO_DIR || {
        echo -e "${RED}❌ 克隆失败！错误代码：$?"
        echo -e "可能原因："
        echo -e "1. SSH 密钥未配置"
        echo -e "2. 仓库权限不足"
        echo -e "3. 网络连接问题${NC}"
        exit 1
    }
fi

# 进入仓库目录
cd "$REPO_DIR" || exit 1

# 安装 npm 依赖
echo -e "\n${GREEN}📦 安装 Node.js 依赖...${NC}"
if [ ! -d "node_modules" ]; then
    npm install --loglevel=error || {
        echo -e "${RED}❌ 依赖安装失败！${NC}"
        exit 1
    }
else
    echo -e "${YELLOW}✅ 依赖已存在 (node_modules)${NC}"
fi

# 初始化主题子模块
echo -e "\n${GREEN}🎨 初始化主题子模块...${NC}"
if [ -f ".gitmodules" ]; then
    git submodule update --init --recursive || {
        echo -e "${RED}❌ 子模块初始化失败！${NC}"
        exit 1
    }
fi

# 创建示例文章
echo -e "\n${GREEN}📝 创建示例文章...${NC}"
npx hexo new post "Hello-World" --silent

# 显示完成信息
echo -e "\n${GREEN}🎉 环境初始化完成！${NC}"
echo -e "接下来可以执行以下操作："
echo -e "1. 编写文章：   cd $REPO_DIR/source/_posts"
echo -e "2. 本地预览：   npx hexo server"
echo -e "3. 部署发布：   ../deploy_post.sh"

# 安全提醒
echo -e "\n${YELLOW}⚠️  重要提示："
echo -e "1. 定期提交本地修改到GitHub"
echo -e "2. 重要修改前使用 git branch 创建新分支"
echo -e "3. 使用 --force-clean 参数需谨慎${NC}"
