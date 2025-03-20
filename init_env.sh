#!/bin/bash
# 初始化Hexo环境并同步仓库（跨平台版）
# 支持系统：Ubuntu/Debian/CentOS/macOS

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 系统检测
OS_TYPE=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/redhat-release ]; then
        OS_TYPE="centos"
    elif [ -f /etc/lsb-release ]; then
        OS_TYPE="ubuntu"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
fi

# 依赖检查函数
check_dependencies() {
    echo -e "\n${GREEN}🔍 检查系统依赖..."
    
    # 检查Git
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️  Git未安装，正在自动安装...${NC}"
        install_git
    else
        echo -e "${GREEN}✅  Git已安装（版本：$(git --version 2>&1 | cut -d' ' -f3）)${NC}"
    fi

    # 检查Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}⚠️  Node.js未安装，正在自动安装...${NC}"
        install_nodejs
    else
        echo -e "${GREEN}✅  Node.js已安装（版本：$(node -v）)${NC}"
    fi

    # 检查npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌  npm未正确安装，请手动安装后重试${NC}"
        exit 1
    else
        echo -e "${GREEN}✅  npm已安装（版本：$(npm -v）)${NC}"
    fi
}

# Git安装函数
install_git() {
    case $OS_TYPE in
        "ubuntu"|"debian")
            sudo apt-get update -qq
            sudo apt-get install -y git-core
            ;;
        "centos")
            sudo yum install -y git
            ;;
        "macos")
            if ! command -v brew &> /dev/null; then
                echo -e "${RED}❌ 需要Homebrew安装Git，请先安装Homebrew${NC}"
                exit 1
            fi
            brew install git
            ;;
        *)
            echo -e "${RED}❌ 不支持的OS类型：$OS_TYPE${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}✅  Git安装完成${NC}"
}

# Node.js安装函数
install_nodejs() {
    case $OS_TYPE in
        "ubuntu"|"debian")
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "centos")
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        "macos")
            if ! command -v brew &> /dev/null; then
                echo -e "${RED}❌ 需要Homebrew安装Node.js，请先安装Homebrew${NC}"
                exit 1
            fi
            brew install node@18
            ;;
        *)
            echo -e "${RED}❌ 不支持的OS类型：$OS_TYPE${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}✅  Node.js安装完成${NC}"
}

# SSH配置验证函数
setup_ssh() {
    echo -e "\n${GREEN}🔍 验证SSH配置..."
    
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    if [[ ! -f ~/.ssh/id_rsa || ! -f ~/.ssh/id_rsa.pub ]]; then
        echo -e "${RED}❌ 密钥文件缺失：~/.ssh/id_rsa 或 id_rsa.pub 不存在"
        echo -e "请执行以下操作："
        echo -e "1. 将SSH密钥对复制到 ~/.ssh 目录"
        echo -e "2. 或运行 ssh-keygen 生成新密钥对${NC}"
        exit 1
    fi

    chmod 600 ~/.ssh/id_rsa >/dev/null 2>&1 || {
        echo -e "${RED}❌ 无法设置私钥权限，请检查文件所有权${NC}"
        exit 1
    }
    chmod 644 ~/.ssh/id_rsa.pub

    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo -e "${YELLOW}⚠️  启动SSH代理..."
        eval "$(ssh-agent -s)" >/dev/null
    fi

    if ! ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/id_rsa | awk '{print $2}')"; then
        echo -e "🔑 添加SSH密钥到代理..."
        ssh-add ~/.ssh/id_rsa || {
            echo -e "${RED}❌ 密钥加载失败！可能原因："
            echo -e "1. 密钥受密码保护但未解锁"
            echo -e "2. 密钥文件格式错误${NC}"
            exit 1
        }
    fi

    if ! grep -q 'github.com' ~/.ssh/known_hosts 2>/dev/null; then
        echo -e "🔒 添加GitHub到已知主机..."
        ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts 2>/dev/null
    fi

    echo -e "📡 测试GitHub连接..."
    if ! ssh -T git@github.com 2>&1 | grep -i -e "success" -e "authenticated"; then
        echo -e "${RED}❌ SSH认证失败！请检查："
        echo -e "1. 公钥是否添加到GitHub账户"
        echo -e "2. 网络代理设置（如果有）"
        echo -e "3. 防火墙是否允许SSH连接${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ SSH配置验证通过！${NC}"
}

# 主流程
echo -e "\n${GREEN}🌐 开始环境检查...${NC}"
check_dependencies

setup_ssh

echo -e "\n${GREEN}📥 克隆仓库...${NC}"
repo_dir="scaleflower.github.io"
if [ ! -d "$repo_dir" ]; then
    git clone -b hexo --single-branch git@github.com:scaleflower/scaleflower.github.io.git || {
        echo -e "${RED}❌ 仓库克隆失败！错误代码：$?"
        echo -e "尝试以下解决方案："
        echo -e "1. 检查网络连接"
        echo -e "2. 确认公钥已添加到GitHub账户"
        echo -e "3. 删除目录重试：rm -rf $repo_dir${NC}"
        exit 1
    }
    cd "$repo_dir" || exit 1
else
    echo -e "${YELLOW}⚠️  已存在本地仓库，尝试更新...${NC}"
    cd "$repo_dir" || exit 1
    git pull origin hexo || {
        echo -e "${RED}❌ 仓库更新失败！建议操作："
        echo -e "1. 检查本地修改：git status"
        echo -e "2. 备份后重置：git reset --hard origin/hexo${NC}"
        exit 1
    }
fi

echo -e "\n${GREEN}📦 安装项目依赖...${NC}"
if [ ! -d "node_modules" ]; then
    sudo chown -R $(whoami) ~/.npm 2>/dev/null
    npm config set unsafe-perm true 2>/dev/null
    
    npm install --force --silent || {
        echo -e "${RED}❌ 依赖安装失败！尝试："
        echo -e "1. 删除 node_modules 重试"
        echo -e "2. 设置淘宝镜像：npm config set registry https://registry.npmmirror.com${NC}"
        exit 1
    }
    npm install hexo-cli -g --silent
    npm install hexo-deployer-git --save --silent
else
    echo -e "${YELLOW}⚠️  已存在 node_modules，跳过依赖安装${NC}"
fi

echo -e "\n${GREEN}🎨 初始化主题...${NC}"
if [ ! -d "themes/anzhiyu" ]; then
    git submodule update --init --recursive --quiet || {
        echo -e "${RED}❌ 主题初始化失败！请检查："
        echo -e "1. .gitmodules 文件配置"
        echo -e "2. 子模块仓库权限${NC}"
        exit 1
    }
    echo -e "${GREEN}✅ 主题初始化完成${NC}"
else
    echo -e "${YELLOW}⚠️  主题已存在，跳过初始化${NC}"
fi

echo -e "\n${GREEN}🚀 环境初始化完成！执行以下命令启动："
echo -e "   hexo server  # 本地预览"
echo -e "   ./deploy_post.sh \"文章标题\"  # 发布新文章${NC}"
