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

# 处理命令行参数（增加参数容错）
if [[ "$1" == "--force-clean" ]]; then
    if clean_environment; then
        FORCE_CLEAN=true
    else
        exit 1
    fi
fi

# 检查依赖项（修复语法错误关键点）
echo -e "\n${GREEN}🔍 检查系统依赖...${NC}"
for cmd in git node npm npx; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}❌ 未找到 $cmd，请先安装${NC}"
        exit 1
    fi  # 将错误的 done 改为 fi
done
echo -e "${GREEN}✅ 所有依赖已安装${NC}"

# 仓库同步逻辑（增强MacOS兼容性）
echo -e "\n${GREEN}📥 仓库同步检查...${NC}"
if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}⚠️  检测到已存在的本地仓库${NC}"
    
    if ! $FORCE_CLEAN; then
        PS3="请选择操作 (输入数字): "  # 增加select提示符
        echo -e "请选择操作："
        select action in "保留并更新" "删除并重新克隆" "退出"; do
            case $REPLY in  # 改用数字判断提升兼容性
                1)
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
                2)
                    if clean_environment; then
                        FORCE_CLEAN=true
                    fi
                    break
                    ;;
                3)
                    echo -e "${GREEN}👋 操作已取消${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}❌ 无效选项，请重新选择${NC}"
                    ;;
            esac
        done
    fi
fi

# 克隆仓库逻辑（增加目录存在检查）
if [ ! -d "$REPO_DIR" ] || $FORCE_CLEAN; then
    echo -e "\n${GREEN}🔃 重新克隆仓库...${NC}"
    if [ -d "$REPO_DIR" ]; then  # 额外安全检查
        rm -rf "$REPO_DIR"
    fi
    git clone -b $BRANCH --single-branch $REPO_URL $REPO_DIR || {
        echo -e "${RED}❌ 克隆失败！错误代码：$?"
        echo -e "可能原因："
        echo -e "1. SSH 密钥未配置"
        echo -e "2. 仓库权限不足"
        echo -e "3. 网络连接问题${NC}"
        exit 1
    }
fi

# 进入仓库目录（增加错误处理）
cd "$REPO_DIR" || {
    echo -e "${RED}❌ 无法进入仓库目录${NC}"
    exit 1
}

# 安装 npm 依赖（增加网络重试）
echo -e "\n${GREEN}📦 安装 Node.js 依赖...${NC}"
if [ ! -d "node_modules" ]; then
    for attempt in {1..3}; do
        npm install --loglevel=error && break || {
            if [ $attempt -eq 3 ]; then
                echo -e "${RED}❌ 依赖安装失败！请检查："
                echo -e "1. 网络代理设置"
                echo -e "2. npm registry 配置"
                echo -e "3. 服务器状态${NC}"
                exit 1
            fi
            echo -e "${YELLOW}⚠️ 安装失败，正在重试 (第$attempt次)...${NC}"
        }
    done
else
    echo -e "${YELLOW}✅ 依赖已存在 (node_modules)${NC}"
fi

# 初始化主题子模块（增加空目录检查）
echo -e "\n${GREEN}🎨 初始化主题子模块...${NC}"
if [ -f ".gitmodules" ]; then
    if [ -z "$(ls -A themes)" ]; then  # 空目录时才初始化
        git submodule update --init --recursive || {
            echo -e "${RED}❌ 子模块初始化失败！${NC}"
            exit 1
        }
    else
        echo -e "${YELLOW}✅ 主题已存在${NC}"
    fi
fi

# 创建示例文章（增加时间戳防冲突）
echo -e "\n${GREEN}📝 创建示例文章...${NC}"
post_title="Hello-World-$(date +%s)"
npx hexo new post "$post_title" --silent

# 显示完成信息（增加路径提示）
echo -e "\n${GREEN}🎉 环境初始化完成！${NC}"
echo -e "接下来可以执行以下操作："
echo -e "1. 编写文章：   cd $REPO_DIR/source/_posts && ls -l"
echo -e "2. 本地预览：   cd $REPO_DIR && npx hexo server"
echo -e "3. 部署发布：   cd .. && ./deploy_post.sh"

# 安全提醒（增加备份提示）
echo -e "\n${YELLOW}⚠️  重要提示："
echo -e "1. 定期运行 'git status' 检查修改"
echo -e "2. 使用 'git stash' 暂存临时修改"
echo -e "3. 推荐配置 git 自动备份钩子${NC}"
