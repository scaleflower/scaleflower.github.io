#!/bin/bash
# 初始化Hexo环境并同步仓库（跨平台版）
# 支持系统：Ubuntu/Debian/CentOS/macOS

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 依赖检查函数
check_dependencies() {
    # 检查操作系统
    if [ -f /etc/os-release ]; then
        OS=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    elif [[ "$(uname)" == "Darwin" ]]; then
        OS="macos"
    else
        echo -e "${RED}❌ 无法识别的操作系统${NC}"
        exit 1
    fi

    # 检查Git
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️  未安装 Git${NC}"
        install_git
    else
        echo -e "${GREEN}✅ Git 已安装 ($(git --version | awk '{print $3}'))${NC}"
    fi

    # 检查Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}⚠️  未安装 Node.js${NC}"
        install_nodejs
    else
        echo -e "${GREEN}✅ Node.js 已安装 ($(node --version))${NC}"
    fi
}

# Git安装函数
install_git() {
    echo -e "🔧 正在安装 Git..."
    case $OS in
        ubuntu|debian)
            sudo apt-get update -qq
            sudo apt-get install -y git
            ;;
        centos|rhel)
            sudo yum install -y git
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                echo -e "${RED}请先安装 Homebrew：https://brew.sh/${NC}"
                exit 1
            fi
            brew install git
            ;;
        *)
            echo -e "${RED}不支持的操作系统：${OS}${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}✅ Git 安装完成"
}

# Node.js安装函数
install_nodejs() {
    echo -e "🔧 正在安装 Node.js..."
    case $OS in
        ubuntu|debian)
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        centos|rhel)
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                echo -e "${RED}请先安装 Homebrew：https://brew.sh/${NC}"
                exit 1
            fi
            brew install node
            ;;
        *)
            echo -e "${RED}不支持的操作系统：${OS}${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}✅ Node.js 安装完成 ($(node --version))"
}

# 主流程
echo -e "\n${GREEN}🌐 开始环境检查...${NC}"
check_dependencies

# 克隆仓库
echo -e "\n${GREEN}📥 克隆仓库...${NC}"
if [ ! -d "scaleflower.github.io" ]; then
    git clone -b hexo --single-branch git@github.com:scaleflower/scaleflower.github.io.git
    cd scaleflower.github.io || exit 1
else
    echo -e "${YELLOW}⚠️  已存在本地仓库，跳过克隆${NC}"
    cd scaleflower.github.io || exit 1
    git pull origin hexo
fi

# 安装项目依赖
echo -e "\n${GREEN}📦 安装项目依赖...${NC}"
if [ ! -d "node_modules" ]; then
    npm install --force --silent
    npm install hexo-cli -g --silent
    npm install hexo-deployer-git --save --silent
else
    echo -e "${YELLOW}⚠️  已存在 node_modules，跳过依赖安装${NC}"
fi

# 初始化主题
echo -e "\n${GREEN}🎨 初始化主题...${NC}"
if [ ! -d "themes/anzhiyu" ]; then
    git submodule update --init --recursive --quiet
    echo -e "${GREEN}✅ 主题初始化完成${NC}"
else
    echo -e "${YELLOW}⚠️  主题已存在，跳过初始化${NC}"
fi

echo -e "\n${GREEN}🚀 环境初始化完成！执行以下命令启动："
echo -e "   hexo server  # 本地预览"
echo -e "   ./deploy_post.sh \"文章标题\"  # 发布新文章${NC}"
# 首次运行前：
# chmod +x init_env.sh
# 国内用户加速（可选）：
# 在安装Node.js前设置镜像源
# export NODEJS_ORG_MIRROR=http://npmmirror.com/mirrors/node
# 权限处理：
#sudo visudo
#username ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/yum
