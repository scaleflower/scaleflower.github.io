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
THEME_NAME="anzhiyu"
FORCE_CLEAN=false

# 显示欢迎信息
echo -e "${GREEN}🚀 Hexo 博客环境初始化脚本 v2.1${NC}"
echo -e "${YELLOW}📅 最后更新: 2023-12-10${NC}"
echo -e "${YELLOW}✨ 包含 anzhiyu 主题集成${NC}\n"

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
if [[ "$1" == "--force-clean" ]]; then
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
    fi
done
echo -e "${GREEN}✅ 所有依赖已安装${NC}"

# 仓库同步逻辑
echo -e "\n${GREEN}📥 仓库同步检查...${NC}"
if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}⚠️  检测到已存在的本地仓库${NC}"
    
    if ! $FORCE_CLEAN; then
        PS3="请选择操作 (输入数字): "
        echo -e "请选择操作："
        select action in "保留并更新" "删除并重新克隆" "退出"; do
            case $REPLY in
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

# 克隆仓库逻辑
if [ ! -d "$REPO_DIR" ] || $FORCE_CLEAN; then
    echo -e "\n${GREEN}🔃 重新克隆仓库...${NC}"
    if [ -d "$REPO_DIR" ]; then
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

# 进入仓库目录
cd "$REPO_DIR" || {
    echo -e "${RED}❌ 无法进入仓库目录${NC}"
    exit 1
}

# 安装主题子模块函数
install_theme() {
    echo -e "\n${GREEN}🎨 强制安装 anzhiyu 主题...${NC}"
    
    # 清理旧主题
    if [ -d "themes/$THEME_NAME" ]; then
        echo -e "${YELLOW}🗑  移除旧主题...${NC}"
        git rm --cached themes/$THEME_NAME >/dev/null 2>&1 || true
        rm -rf themes/$THEME_NAME
    fi

    # 添加子模块
    echo -e "${YELLOW}📦 添加主题子模块...${NC}"
    git submodule add --force https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/$THEME_NAME

    # 初始化子模块
    echo -e "${YELLOW}🔧 初始化子模块...${NC}"
    git submodule update --init --recursive --remote

    # 安装主题依赖
    echo -e "${YELLOW}📦 安装主题专属依赖...${NC}"
    (cd themes/$THEME_NAME && npm install --loglevel=error)

    # 修复权限
    if [ "$(uname -s)" = "Linux" ]; then
        sudo chmod -R 755 themes/$THEME_NAME
    fi
}

# 主题初始化
echo -e "\n${GREEN}🎨 初始化主题配置...${NC}"
if [ -d "themes/$THEME_NAME" ]; then
    echo -e "${YELLOW}✅ 主题已存在，正在验证完整性...${NC}"
    if [ ! -f "themes/$THEME_NAME/layout/index.ejs" ]; then
        echo -e "${RED}⚠️  检测到损坏的主题安装，重新初始化...${NC}"
        install_theme
    fi
else
    install_theme
fi

# 校验主题配置
echo -e "\n${GREEN}🔍 校验主题配置...${NC}"
if ! grep -q "theme: $THEME_NAME" _config.yml; then
    echo -e "${YELLOW}⚠️  正在自动配置主题参数...${NC}"
    sed -i.bak "s/theme:.*/theme: $THEME_NAME/" _config.yml
fi

# 安装 npm 依赖
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

# 创建示例文章
echo -e "\n${GREEN}📝 创建示例文章...${NC}"
post_title="Hello-World-$(date +%s)"
npx hexo new post "$post_title" --silent

# 显示完成信息
echo -e "\n${GREEN}🎉 环境初始化完成！${NC}"
echo -e "接下来可以执行以下操作："
echo -e "1. 编写文章：   cd $REPO_DIR/source/_posts && ls -l"
echo -e "2. 本地预览：   cd $REPO_DIR && npx hexo server"
echo -e "3. 部署发布：   cd .. && ./deploy_post.sh"

# 主题管理提示
echo -e "\n${GREEN}🔧 主题管理命令：${NC}"
echo -e "   更新主题: git submodule update --remote"
echo -e "   回滚主题: cd themes/$THEME_NAME && git checkout HEAD~1"

# 安全提醒
echo -e "\n${YELLOW}⚠️  重要提示："
echo -e "1. 定期运行 'git status' 检查修改"
echo -e "2. 修改主题请提交到子模块仓库"
echo -e "3. 避免直接修改 themes/$THEME_NAME 的原始文件"
echo -e "4. 建议 fork 主题仓库进行自定义${NC}"
